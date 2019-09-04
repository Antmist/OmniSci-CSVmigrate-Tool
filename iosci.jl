using DataFrames
using CSV
using Blink
using OmniSci
using Interact

### Custom widgets made of textboxes and activated from the Connect button
di = OrderedDict(
    :localhost => textbox("localhost"),
    :port => textbox("port"),
    :user => textbox("User"),
    :password => textbox("Password"),
    :db => textbox("Database")
)
wi = Widget{:connector}(di)
connbtn = button("Connect")

map(connbtn -> connect(di))


# Create and Load Table Widgets #

#tab = radiobuttons(Dict("Create Table" => "ct", "Load Table" => "lt"))

# Create Table Widget
ctable = OrderedDict(
    :tableName => textbox("Table Name"),
    :addTable =>  button("Create Data Table")
)
ct = Widget{:connector}(ctable)

# Load Table Widget
ltable = OrderedDict(
    :fp => filepicker(label="Data File"; multiple=false, accept=".csv"),
    :tableName => textbox("Table Name"),
    :loadTable =>  button("Load Data Table")
)
lt = Widget{:connector}(ltable)


#Tabs for the Data Table page Create/Load
clt = OrderedDict(
    "Create Table" => vbox(ct),
    "Load Table" => vbox(lt)
)

#Tabs for each sheet in the app
uu = OrderedDict(
    "Connect" => hbox(wi, connbtn),
    "Data" => tabulator(clt),
    "Custom SQL" => vbox(println("SQL"))
)

ui = tabulator(uu)

w = Window()
body!(w, ui)
