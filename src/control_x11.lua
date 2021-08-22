require "luarocks.loader"

local Sh = require('minilib.shell')
local Pr = require('minilib.process')
local Util = require('minilib.util')
local Cmds = require('mxctl.control_cmds')
local Cfg = require('mxctl.config')

DISPLAYS = Cfg.displays

DISPLAY_ON = [[
		xrandr \
			--output %s \
			--mode %dx%d \
			--rotate normal \
			--pos %dx%d %s]]
DISPLAY_OFF = [[
		xrandr \
			--output %s \
			--off ]]

function xrandr_info()
	local h = assert(io.popen("xrandr -q"))
	local ots = {}

	local ot
	for line in h:lines() do
		local otc = line:match("^([%w-]+) connected ")
		if otc then
			ot = otc
			if ots[ot] == nil then
				ots[ot] = {modes={}}
			end
		else
			if not (ot == nil) then
				local mx, my = string.match(line, "%s+(%d+)x(%d+)")
				if not (my == nil) then
					table.insert(ots[ot].modes, {x=mx, y=my})
					--print(ot, mx, my)
				end
			end
		end
	end
	h:close()
	return ots
end

function get2dElem(t, i, j)
	if t[i] == nil then
		return nil
	else
		return t[i][j]
	end
end

function getElem(t, indexes)
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

function xrandr_configs()
	local outputs = xrandr_info()
	local outgrid = {}
	for i,d in ipairs(DISPLAYS) do
		--print("configure", i, d.name)
		local o = outputs[d.name]
		local mode = o.modes[1]
		for i,m in ipairs(o.modes) do
			--print("?y", m.x, m.y, d.mode, type(m.y), type(d.mode))
			if (tonumber(m.y) == d.mode.y) and (tonumber(m.x) == d.mode.x) then
				--print("configure", d.name, d.pos[1], d.pos[2])
				mode = m
				break
			end
		end
		o.name = d.name
		o.mode = mode
		o.pos = d.pos
		o.extra_opts = d.extra_opts
		outgrid[d.pos[1]] = {}
		outgrid[d.pos[1]][d.pos[2]] = o
	end

	local outsetup, outgrid_ctl = {}, {}
	for i,d in ipairs(DISPLAYS) do
		local x, y = d.pos[1], d.pos[2]
		local o = get2dElem(outgrid, x, y)
		local off_xo, off_yo = get2dElem(outgrid, x-1, y), get2dElem(outgrid, x, y-1)
		local off_x, off_y
		if off_xo == nil then
			off_x = 0
		else
			off_x = off_xo.mode.x * d.pos[1]
		end
		if off_yo == nil then
			off_y = 0
		else
			off_y = off_xo.mode.y * d.pos[2]
		end

		local dOn = string.format(DISPLAY_ON
				, o.name
				, o.mode.x, o.mode.y
				, off_x, off_y
			  , o.extra_opts)
		local dOff = string.format(DISPLAY_OFF, o.name)
		outgrid_ctl[d.name .. " on"]  = dOn
		outgrid_ctl[d.name .. " off"] = dOff
		table.insert(outsetup, dOn)
	end
	return outsetup, outgrid_ctl
end

local Funs = {}
function Funs:setup_video()
	local setup, _ = xrandr_configs()
	return setup
end

function Funs:tmenu_setup_video()
	local _, vgridctl = xrandr_configs()
	local opts = ""
	for k, cmd in pairs(vgridctl) do
		opts = opts .. string.format("%s", k) .. "\n"
	end

	Pr.pipe()
	.add(Sh.exec(string.format('echo "%s" | %s', opts, Cfg.menu_sel)))
	.add(function(id)
		Util:exec(vgridctl[id])
	end)
	.run()
end

function Funs:dmenu_setup_video()
	Util:exec(Cfg.pop_term .. " fun tmenu_setup_video")
end

return Funs
