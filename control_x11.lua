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

local DISPLAYS = Cfg.displays

local DISPLAY_ON = [[
		xrandr \
			--output %s \
			--mode %dx%d \
			--rotate normal \
			--pos %dx%d \
			%s
]]
local DISPLAY_OFF = [[
		xrandr \
			--output %s \
			--off
]]

local function xrandr_info()
	local h = assert(io.popen("xrandr -q"))
	local ots = {}

	local ot
	for line in h:lines() do
		local otc = line:match("^([%w-]+) connected ")
		if otc then
			logger:info("xrandr_info, parse connected %s", otc)
			ot = otc
			if ots[ot] == nil then
				ots[ot] = { modes = {}, name = ot }
			end
		else
			if ot then
				local mx, my = string.match(line, "%s+(%d+)x(%d+)")
				if my then
					logger:info("xrandr_info, mode (%s,%s,%s)", ot, mx, my)
					table.insert(ots[ot].modes, { x = tonumber(mx), y = tonumber(my), active = false })
				end
			end
		end
	end
	h:close()
	return ots
end

local function get2dElem(t, i, j)
	if t[i] == nil then
		return nil
	else
		return t[i][j]
	end
end

local function getElem(t, indexes)
	if indexes[1] == nil then
		return nil
	else
		if indexes[2] == nil then
			return t
		else
			return getElem(t[indexes[1]], {})
		end
	end
end

local function mk_key(l)
	return Util:join("_", l)
end

local function outgrid_config(outgrid, o)
	logger:info("outgrid_config: %s", o.name)
	for _, d in ipairs(DISPLAYS) do
		logger:info("outgrid_config, DISPLAY: %s", d.name)
		if o.name == d.name then
			logger:info("outgrid_config, display config, (%s,%s,%s)", d.name, d.mode.x, d.mode.y)
			for _, m in ipairs(o.modes) do
				logger:info("\t mode=%dx%d :: %sx%s", m.x, m.y, type(m.x), type(d.mode.y))
				if (m.x == d.mode.x) and (m.y == d.mode.y) then
					o.mode = m
					break
				end
			end

			if not o.mode then
				logger:info("outgrid_config, display config not found, defaulting (%s,%s)", o.modes[1].x, o.modes[1].y)
				o.mode = o.modes[1]
			end
			o.mode.active = true
			o.pos = d.pos
			o.extra_opts = d.extra_opts
		else
			logger:info("outgrid_config, display default (%s,%s)", o.modes[1].x, o.modes[1].y)
			o.mode = o.modes[1]
			o.mode.active = true
			o.pos = { 0, 0 }
			o.extra_opts = ""
		end
	end
	outgrid[mk_key(o.pos)] = o
end

local function outgrid_controls_config(outgrid, outgrid_ctl, o)
	for _, m in pairs(o.modes) do
		local x, y = o.pos[1], o.pos[2]
		local off_xo, off_yo = outgrid[mk_key({ x - 1, y })], outgrid[mk_key({ x, y - 1 })]
		local off_x, off_y
		if off_xo == nil then
			off_x = 0
		else
			off_x = off_xo.mode.x * x
		end
		if off_yo == nil then
			off_y = 0
		else
			off_y = off_xo.mode.y * y
		end

		local dOn = string.format(DISPLAY_ON, o.name, m.x, m.y, off_x, off_y, o.extra_opts)
		local dOff = string.format(DISPLAY_OFF, o.name)

		local flag = ""
		if m.active then
			flag = "active"
		end

		local ar = m.x / m.y

		outgrid_ctl[string.format("%s (%dx%d) <%d,%d> %.1f %s", o.name, m.x, m.y, off_x, off_y, ar, flag)] =
			{ on = dOn, off = dOff, active = m.active }
	end
end

local function xrandr_configs()
	local outputs = xrandr_info()
	local outgrid = {}
	for otc, o in pairs(outputs) do
		logger:info("xrandr_configs, item %s, %s", otc, o.name)
		outgrid_config(outgrid, o)
	end

	local outgrid_ctl = {}
	for otc, o in pairs(outputs) do
		outgrid_controls_config(outgrid, outgrid_ctl, o)
	end
	return outgrid, outgrid_ctl
end

local Funs = {}
function Funs:setup_video()
	local outgrid, outgrid_ctl = xrandr_configs()
	for _, d in pairs(outgrid_ctl) do
		if d.active then
			Sh.exec_cmd(d.on)
		end
	end
end

function Funs:tmenu_setup_video()
	local _, vgridctl = xrandr_configs()
	local opts = table.concat(Util:keys(vgridctl), "\n")

	Pr.pipe()
		.add(Sh.exec(menu_sel(string.format('echo "%s"', opts))))
		.add(function(id)
			if id then
				Sh.exec_cmd(vgridctl[id].on)
			end
		end)
		.run()
end

function Funs:dmenu_setup_video()
	Sh.sh(pop_term(ctrl_bin("tmenu_setup_video")))
end

function Funs:tmenu_select_window()
	local ws = {}
	local wl = {}
	Pr.pipe()
		.add(Sh.exec("wmctrl -l"))
		.add(Sh.grep("(%w+)%s+(%d+)%s+([%w%p]+)%s+(.*)"))
		.add(function(arr)
			if arr then
				ws[arr[4]] = { id = arr[1], ws = arr[2], name = arr[4] }
				return arr[4]
			end
		end)
		.add(function(name)
			if name then
				table.insert(wl, name)
			end
		end)
		.run()

	local wl_opts = table.concat(wl, "\n")
	Pr.pipe()
		.add(Sh.exec(menu_sel(string.format('echo "%s"', wl_opts))))
		.add(function(name)
			if name then
				Sh.sh("wmctrl -ia " .. ws[name].id)
			end
		end)
		.run()
end
function Funs:dmenu_select_window()
	Sh.exec_cmd(pop_term(ctrl_bin("tmenu_select_window")))
end
function Funs:scr_lock_if()
	local iv = nil
	Pr.pipe()
		.add(Sh.exec("pactl list sinks"))
		.add(Sh.grep("RUNNING"))
		.add(Sh.echo())
		.add(function(x)
			if x then
				iv = x
			end
		end)
		.run()
	if iv == nil then
		Sh.sh(xcmd.scr_lock())
	end
end
local _LOGOUT_CMD = {
	bspwm = "bspc quit",
	lg3d = "bspc quit",
	i3wm = "i3-msg exit",
	openbox = "openbox --exit",
	xmonad = "",
}

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

function brightness(delta)
	logger:info("brightness", delta)
	Pr.pipe()
		.add(Sh.exec("ls /sys/class/backlight"))
		.add(function(bf)
			if bf then
				local max = tonumber(Ut:head_file("/sys/class/backlight/" .. bf .. "/max_brightness"))
				local cur = tonumber(Ut:head_file("/sys/class/backlight/" .. bf .. "/brightness"))
				local tar = math.floor(cur + delta * max / 100)
				if tar > max then
					tar = max
				end
				if tar < 0 then
					tar = cur
				end
				logger:info("brightness", delta, bf, cur, tar, max)
				local h = assert(io.open("/sys/class/backlight/" .. bf .. "/brightness", "w"))
				h:write(tar)
				h:close()
			end
		end)
		.run()
end

function Funs:brightness_up()
	brightness(Cfg.lux_step)
end

function Funs:brightness_down()
	brightness(-Cfg.lux_step)
end

return Funs
