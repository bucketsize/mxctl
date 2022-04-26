#!/usr/bin/env lua

require "luarocks.loader"

package.path = os.getenv("HOME") .. '/?.lua;'
    .. package.path

local Util = require("minilib.util")
local Ctl  = require("mxctl.control")

function test_control_monitor_power()
	Ctl.Funs.monitor_power()
end

test_control_monitor_power()
