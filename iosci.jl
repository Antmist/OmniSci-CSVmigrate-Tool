using DataFrames
using CSV
using Blink
using OmniSci
using Interact

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
#conn = connect(wi[:localhost], wi[:port], wi[:user], wi[:password], wi[:db])



tab = radiobuttons(Dict("Create Table" => "ct", "Load Table" => "lt"))





uu = OrderedDict(
    "Connect" => hbox(wi, connbtn),
    "Data" => vbox(tab),
    "Custom SQL" => vbox(println("SQL"))
)

ui = tabulator(uu)

w = Window()
body!(w, ui)
