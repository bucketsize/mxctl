#!/usr/bin/env lua

require "luarocks.loader"

package.path = os.getenv("HOME") .. '/?.lua;'
    .. package.path

local Util = require("minilib.util")
local Ctl  = require("mxctl.control")

function test_control_tmenu_set_wallpaper()
	Ctl.Funs.tmenu_set_wallpaper()
end

test_control_tmenu_set_wallpaper()
