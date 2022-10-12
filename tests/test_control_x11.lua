#!/usr/bin/env lua
package.path = '?.lua;' .. package.path
require "luarocks.loader"
luaunit = require('luaunit')

local Ctl  = require("control_x11")

function test_dmenu_select_window()
   Ctl.tmenu_select_window()
end

function test_dmenu_exit()
   Ctl.tmenu_exit()
end

function test_dmenu_setup_video()
   Ctl.tmenu_setup_video()
end

function test_scr_lock_if()
   -- Ctl.scr_lock_if()
end

function test_brightness()
   -- Ctl.brightness(10)
end

os.exit( luaunit.LuaUnit.run() )
