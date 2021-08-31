require "luarocks.loader"

local Sh = require('minilib.shell')
local Pr = require('minilib.process')
local Util = require('minilib.util')
local Ot = require('minilib.otable')
local Cfg = require('mxctl.config')
local Cmds = require('mxctl.control_cmds')
local appcache = "/tmp/exec-apps.lua"

local Funs = {}
function Funs:tmenu_select_window()
	local ws = {}
	local wl = ''
	Pr.pipe()
	.add(Sh.exec('wmctrl -l'))
	.add(Sh.grep('(%w+)%s+(%d+)%s+([%w%p]+)%s+(.*)'))
	.add(function(arr)
		ws[arr[4]]= {id = arr[1], ws = arr[2], name = arr[4]}
		return arr[4]
	end)
	.add(function(name)
		wl = wl .. name .. '\n'
	end)
	.run()

	Pr.pipe()
	.add(Sh.exec(string.format('echo "%s" | ' .. Cfg.menu_sel, wl)))
	.add(function(name)
		Util:exec('wmctrl -ia ' .. ws[name].id)
	end)
	.run()
end
function Funs:dmenu_select_window()
	Util:exec(Cfg.menu_sel .. "fun tmenu_select_window")
end

function Funs:tmenu_run()
   local list_apps = string.format('%s fun findcached | %s', Cfg.ctrl_bin, Cfg.menu_sel)
   Pr.pipe()
	  .add(Sh.exec(list_apps))
	  .add(function(app)
			local apps = Util:fromfile("/tmp/exec-apps.lua")
			Util:launch(apps[app])
		  end)
	  .run()
end
function Funs:dmenu_run()
	Util:exec(Cfg.pop_term .. " fun tmenu_run")
end
function Funs:scr_lock_if()
	local iv = Pr.pipe()
		.add(Sh.exec('pacmd list-sink-inputs'))
		.add(Sh.grep('state: RUNNING.*'))
		.add(Sh.echo())
		.run()
	print("audio live:", iv)
  if iv == nil then
		return Cmds['scr_lock']
	end
end
function wm_info()
   local h = assert(io.popen("wmctrl -m"))
   local wm
   for line in h:lines() do
	  wm = line:match("Name:%s(%w+)")
	  if wm then break end
   end
   return {wm=wm}
end
function Funs:tmenu_exit()
   local wminf = wm_info()
   local wxitf = ""
   if wminf.wm == 'bspwm' then
	  wxitf = "bspc quit"
   end
   if wminf.wm == 'i3wm' then
	  wxitf = "i3-msg exit"
   end

   local exit_with = {
	  lock = Cmds["scr_lock"],
	  logout = wxitf,
	  suspend = "systemctl suspend",
	  hibernate = "systemctl hibernate",
	  reboot = "systemctl reboot",
	  shutdown = "systemctl poweroff -i"
   }

   local opts = ""
   for k,v in pairs(exit_with) do
	  opts = opts .. k .. "\n"
   end

   Pr.pipe()
	  .add(Sh.exec(string.format('echo "%s" | %s', opts, Cfg.menu_sel)))
	  .add(function(name)
			Util:exec(exit_with[name])
		  end)
	  .run()
end
function Funs:dmenu_exit()
   Util:exec(Cfg.pop_term .. " fun tmenu_exit")
end

return Funs
