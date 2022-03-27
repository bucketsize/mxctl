require "luarocks.loader"

local Sh   = require('minilib.shell')
local Pr   = require('minilib.process')
local Util = require('minilib.util')
local Cfg  = require('mxctl.config')
local Cmds = require('mxctl.control_cmds')

local pop_term = Cfg.build_pop_term 
local menu_sel = Cfg.build_menu_sel
local ctrl_bin = Cfg.build_ctrl_bin

function pa_sinks()
	local iv = {}
	Pr.pipe()
	.add(Sh.exec('pactl list sinks'))
	.add(Sh.grep('Name: (.+)'))
	.add(Sh.echo())
	.add(function(x)
		table.insert(iv, x)
	end)
	.run()
	return iv
end

local Funs = {}
function Funs:tmenu_select_pa_sinks()
	local opts = ""
	for i, v in ipairs(pa_sinks()) do
		opts = opts .. v .. "\n"
	end

	Pr.pipe()
	.add(Sh.exec(menu_sel(string.format('echo "%s"', opts))))
	.add(function(id)
		Util:exec('pacmd set-default-sink '..id)
	end)
	.run()
end
function Funs:dmenu_select_pa_sinks()
	Util:exec(pop_term(ctrl_bin("tmenu_select_pa_sinks")))
end

return Funs
