#!/usr/bin/env lua

require "luarocks.loader"

------------------------------
function test(client)
   ----------------------------
   print("sending vol_up")
   client:send("cmd", "vol_up")

   print("sending dmenu_run")
   client:send("fun", "dmenu_run")
end

-----------------------------
local host, port = "localhost", 51516
if not (arg[1] == "-") then
   host = arg[1]
end
if not (arg[2] == "-") then
   port = tonumber(arg[2])
end
-----------------------------

local CmdClient = require('minilib.cmd_client')
CmdClient:configure(host, port)

if arg[3] == 'test' then
   test(CmdClient)
else
   CmdClient:send(arg[3], arg[4])
end

return Client
