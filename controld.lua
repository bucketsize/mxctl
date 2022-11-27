#!/usr/bin/env lua

require "luarocks.loader"

local Ctrl = require("mxctl.control")
local Util = require("minilib.util")
local logger = require("minilib.logger").create()

local Handler = {
   cmd = function(client, p)
	  local cmd = Ctrl.Cmds[p]
	  logger.info("cmd %s, %s", p, cmd)
	  if cmd then
		 Util:exec(cmd)
	  else
		 client:send("bad\n")
	  end
	  client:send("ok\n")
   end,
   fun = function(client, p)
	  local cmd = Ctrl.Funs[p]
	  logger.info("fun %s", p)
	  if cmd then
		 local rcmd = cmd()
		 if rcmd then
			if type(rcmd) == 'table' then
			   for i,icmd in ipairs(rcmd) do
				  Util:exec(icmd)
			   end
			else
			   Util:exec(rcmd)
			end
		 end
	  else
		 client:send("bad\n")
	  end
	  client:send("ok\n")
   end
}

-----------------------------
local host, port = "*", 51516
if not (arg[1] == "-") then
   host = arg[1]
end
if not (arg[2] == "-") then
   port = tonumber(arg[2])
end
-----------------------------

local CmdServer = require('cmd_server')
CmdServer:start(host, port, Handler)
