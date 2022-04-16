#!/usr/bin/env lua

require "luarocks.loader"

package.path = os.getenv("HOME") .. '/?.lua;'
    .. package.path

local Util = require("minilib.util")
local Ctl  = require("mxctl.control")

function test_dmenu_select_pa_sinks()
	Ctl.Funs.tmenu_select_pa_sinks()
end

test_dmenu_select_pa_sinks()
