require("luarocks.loader")

local Sh = require("minilib.shell")
local Pr = require("minilib.process")
local Util = require("minilib.util")
local Ut = Util
local Cfg = require("mxctl.config")
local xcmd = require("mxctl.control_x11_min")
local logger = require("minilib.logger").create()

local pop_term = Cfg.build_pop_term
local menu_sel = Cfg.build_menu_sel
local ctrl_bin = Cfg.build_ctrl_bin

local _LOGOUT_CMD = {
	bspwm = "bspc quit",
	lg3d = "bspc quit",
	i3wm = "i3-msg exit",
	openbox = "openbox --exit",
	xmonad = "",
}

local Funs = {}

function Funs:tmenu_exit()
	local wminf = Util:wminfo()
	local exit_with = {
		lock = xcmd.scr_lock_cmd(),
		logout = _LOGOUT_CMD[wminf.wm:lower()],
		reboot = "systemctl reboot",
		shutdown = "systemctl poweroff -i",
		hibernate = "systemctl hibernate",
		suspend = "systemctl suspend",
	}

	local opts = {}
	for k, _ in pairs(exit_with) do
		table.insert(opts, k)
	end

	Pr.pipe()
		.add(Sh.exec(menu_sel(string.format('echo "%s"', table.concat(opts, "\n")))))
		.add(function(name)
			if name then
				if exit_with[name] ~= "" then
					Sh.sh(exit_with[name])
				else
					logger:info("no %s for %s", name, wminf.wm)
				end
			end
			return name
		end)
		.run()
end
function Funs:dmenu_exit()
	Sh.sh(pop_term(ctrl_bin("tmenu_exit")))
end

return Funs
