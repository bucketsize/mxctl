require "luarocks.loader"

local Sh = require('minilib.shell')
local Pr = require('minilib.process')
local Util = require('minilib.util')
local Ot = require('minilib.otable')
local Cfg = require('mxctl.config')
local Cmds = require('mxctl.control_cmds')

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
function Funs:find()
   local paths = "/usr/local/bin/ ~/.local/bin ~/.local/share/flatpak/exports/share/applications /usr/share/applications"
   local apps = Ot.newT()
   Pr.pipe()
	  .add(Sh.exec(string.format('find %s -type f,l', paths)))
	  .add(Pr.filter(function(x)
				 if string.match(x, ".desktop") then
					return false
				 else
					return true
				 end
		  end))
	  .add(function(x)
			local ps = Util:segpath(x)
			apps[ps[#ps]] = x
			return x
		  end)
	  .run()
   Pr.pipe()
	  .add(Sh.exec(string.format('find %s -type f,l -name "*.desktop"', paths)))
	  .add(function(x)
			local app = {}
			Pr.pipe()
			   .add(Sh.cat(x))
			   .add(Pr.branch()
					.add(Sh.grep("Exec=([%w%s-_/]+)"))
					.add(Sh.grep("Name=([%w%s-_/]+)"))
					.build())
			   .add(function(ar)
					 if ar[1] then
						app["exec"] = ar[1][1]
					 end
					 if ar[2] then
						app["name"] = ar[2][1]
					 end
					 return ar
				   end)
			   .run()
			apps[app.exec .. ": " .. app.name] = app.exec
			return app
		  end)
	  .run()
   Util:tofile("/tmp/exec-apps.lua", apps)
end

function Funs:findcached()
   local apps = Util:fromfile("/tmp/exec-apps.lua")
   for k, v in apps:opairs() do
	  print(k)
   end
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
function Funs:tmenu_exit()
	local exit_with = {
		lock = Cmds["scr_lock"],
		logout = "i3-msg exit",
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
