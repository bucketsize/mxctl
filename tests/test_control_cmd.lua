#!/usr/bin/env lua

require "luarocks.loader"

package.path = os.getenv("HOME") .. '/?.lua;'
    .. package.path

local Util = require("minilib.util")
local Ctl  = require("mxctl.control")

function test_control_tmenu_misc()
	Ctl.Funs.tmenu_misc()
end

test_control_tmenu_misc()
