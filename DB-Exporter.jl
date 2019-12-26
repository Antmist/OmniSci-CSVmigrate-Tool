#Unblock the code below if you need to install the dependancy libraries
#= 
using Pkg
Pkg.add("CSV")
Pkg.add("DataFrames")
Pkg.add("OmniSci")
=#
# configure settings bellow
server = "server.address.com"
port = 9091
user = "admin"
password = "HyperInteractive"
DB = "database"

using OmniSci, DataFrames, CSV

conn = connect(server, port, user, password, DB)
# makes dataframe of files in export-data and append-data directories
csvpath = joinpath(@__DIR__, "data-export")
rd = readdir(csvpath)
df = DataFrame(csvdata = rd)
data = hcat(df, DataFrame(reduce(vcat, permutedims.(split.(df.csvdata, '.'))), [:fname, :ftype]))
dfexpo = filter!(row -> row[:ftype] == "csv", data);

dbg = get_tables_meta(conn)
dfdrop = join(dfexpo, dbg, on = :fname => :table_name, kind = :inner)

#Carefull this loop deletes any existing tables that match csv file names
for i = firstindex(dfdrop[!, :fname]):lastindex(dfdrop[!, :fname])
    try
        exc = sql_execute(conn, ("""DROP table $(dfdrop[!, :fname][i]);"""))
    catch
        #ignore error
    end
end
#iterates the new data tables to load into OmniSciDB
for x = firstindex(dfexpo[!, :fname]):lastindex(dfexpo[!, :fname])
    try
        newcsv = (CSV.read(joinpath(csvpath, "$(dfexpo[!, :csvdata][x])"); dateformat="yyyy-mm-dd"))
        create_table(conn, "$(dfexpo[!, :fname][x])", newcsv, dryrun=false)
        load_table(conn, "$(dfexpo[!, :fname][x])", newcsv)
    catch
        #ignore error
    end
end
################################################################################
# Below is the data that will be appended onto the tables already on OmniSciDB #
################################################################################
appendpath = joinpath(@__DIR__, "data-append")
apprd = readdir(appendpath)
dfapp = DataFrame(csvdata = apprd)
appdata = hcat(dfapp, DataFrame(reduce(vcat, permutedims.(split.(dfapp.csvdata, '.'))), [:fname, :ftype]))
dfappend = filter!(row -> row[:ftype] == "csv", appdata);
dfchkapp = join(dfappend, dbg, on = :fname => :table_name, kind = :inner)

for a = firstindex(dfchkapp[!, :fname]):lastindex(dfchkapp[!, :fname])
    try
        appendcsv = (CSV.read(joinpath(appendpath, "$(dfchkapp[!, :csvdata][a])"); dateformat="yyyy-mm-dd"))
        load_table(conn, "$(dfchkapp[!, :fname][a])", appendcsv)
    catch
        #ignore error
    end
end
#println(dfchkapp)