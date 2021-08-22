require "luarocks.loader"

local Sh = require('minilib.shell')
local Pr = require('minilib.process')
local Util = require('minilib.util')
local Cfg = require('mxctl.config')
local Cmds = require('mxctl.control_cmds')

function pa_sinks()
	local iv = Pr.pipe()
	.add(Sh.exec('pacmd list-sinks'))
	.add(Sh.grep('name: <(.+)>'))
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
	.add(Sh.exec(string.format('echo "%s" | %s', opts, Cfg.menu_sel)))
	.add(function(id)
		Util:exec('pacmd set-default-sink '..id)
	end)
	.run()
end
function Funs:dmenu_select_pa_sinks()
	Util:exec(Cfg.pop_term .. " fun tmenu_select_pa_sinks")
end

return Funs
