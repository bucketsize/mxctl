#!/usr/bin/env lua

package.path = '?.lua;' .. package.path
require "luarocks.loader"
luaunit = require('luaunit')

local Util = require("minilib.util")
local Ctl  = require("control_power")

function test_control_monitor_power()
	Ctl.monitor_power()
end

os.exit( luaunit.LuaUnit.run() )
