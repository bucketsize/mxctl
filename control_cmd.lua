require "luarocks.loader"

local Ut  = require('minilib.util')
local Pr  = require('minilib.process')
local Sh  = require('minilib.shell')
local Cfg = require("mxctl.config")
local x11 = require("mxctl.control_x11")
local wpc = require("mxctl.control_wallpaper")

local logger = require("minilib.logger").create()

local pop_term = Cfg.build_pop_term 
local menu_sel = Cfg.build_menu_sel
local ctrl_bin = Cfg.build_ctrl_bin

local Fn = {}

local misc = {
	["kb led on"]  = x11.kb_led_on,
	["kb led off"] = x11.kb_led_off,
	["setup display"] = x11.tmenu_setup_video,
	["set wallpaper"] = wpc.tmenu_set_wallpaper, 
}

function exec_options(eopts)
   local opts = {}
   for k, _ in pairs(eopts) do
	 table.insert(opts, k) 
   end

   Pr.pipe()
	   .add(Sh.exec(menu_sel(string.format('echo "%s"',
	   		table.concat(opts, '\n')))))
	   .add(function(name)
		   if name then
			   if eopts[name] and eopts[name] ~= "" then
				   eopts[name]()
			   else
				   logger.info("no %s for", name)
			   end
		   end
		   return name
	   end)
	   .run()
end
function Fn:tmenu_misc()
	exec_options(misc)	
end
function Fn:dmenu_misc()
	Sh.sh(pop_term(ctrl_bin("tmenu_misc")))
end
    
return Fn 
