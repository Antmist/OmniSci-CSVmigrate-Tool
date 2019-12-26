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
csvpath = joinpath(@__DIR__, "data-import")

 dbg = get_tables_meta(conn)
#loop that iterates a select sql statement on all tables
for i = firstindex(dbg[!, :table_name]):lastindex(dbg[!, :table_name])
    try
        CSV.write(joinpath(csvpath, "$(dbg[!, :table_name][i]).csv"), sql_execute(conn, "SELECT * FROM $(dbg[!, :table_name][i])"))
    catch
        # ignore the index error
    end
end
