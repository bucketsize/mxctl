#!/usr/bin/env lua

require "luarocks.loader"

package.path = os.getenv("HOME") .. '/?.lua;'
    .. package.path

local Util = require("minilib.util")
local Ctl  = require("mxctl.control")

function t01_dmenu_select_window()
   Ctl.Funs.tmenu_select_window()
end

function t02_dmenu_exit()
   Ctl.Funs.tmenu_exit()
end

function t04_dmenu_setup_video()
   Ctl.Funs.tmenu_setup_video()
end
function t03_scr_lock_if()
   Ctl.Funs.scr_lock_if()
end
function t04_brightness()
   Ctl.Funs:brightness(10)
end


-- t01_dmenu_select_window()
-- t02_dmenu_exit()
-- t03_scr_lock_if()
-- t04_dmenu_setup_video()
t04_brightness()
