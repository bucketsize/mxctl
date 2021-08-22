require "luarocks.loader"

local Ctl = require("mxctl.control")

function test_list()
   for k,v in pairs(Ctl.Cmds) do
	  print("cmd:", k)
   end
   for k,v in pairs(Ctl.Funs) do
	  print("fun:", k)
   end
end

function test_findapps()
   Ctl.Funs['find']()
   local apps = Ctl.Funs['findcached']()
   for k,v in apps.opairs() do
	  print("app:", k)
   end
end


test_list()
test_findapps()