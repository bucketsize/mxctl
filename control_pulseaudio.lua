require "luarocks.loader"

local Sh   = require('minilib.shell')
local Pr   = require('minilib.process')
local Util = require('minilib.util')
local Cfg  = require('mxctl.config')

local pop_term = Cfg.build_pop_term 
local menu_sel = Cfg.build_menu_sel
local ctrl_bin = Cfg.build_ctrl_bin

local _PA_CMD  = {
	vol_up      = 'pactl set-sink-volume @DEFAULT_SINK@ +10%',
	vol_down    = 'pactl set-sink-volume @DEFAULT_SINK@ -10%',
	vol_mute    = 'pactl set-sink-mute   @DEFAULT_SINK@ toggle',
	vol_unmute  = 'pactl set-sink-mute   @DEFAULT_SINK@ toggle',
}

function pa_sinks()
	local iv = {}
	Pr.pipe()
	.add(Sh.exec('pactl list sinks'))
	.add(Sh.grep('Name: (.+)'))
	.add(function(x)
		if x then
			table.insert(iv, x)
		end
	end)
	.run()
	return iv
end

local Fn = {}
function Fn:tmenu_select_pa_sinks()
	local opts = Util:map(
		function(v) return v[1] end,
		Util:values(pa_sinks()))
	local opss = table.concat(opts, '\n')

	Pr.pipe()
	.add(Sh.exec(menu_sel(string.format('echo "%s"', opss))))
	.add(function(id)
		if id then
			Sh.sh('pactl set-default-sink '..id)
		end
	end)
	.run()
end
function Fn:dmenu_select_pa_sinks()
	Sh.sh(pop_term(ctrl_bin("tmenu_select_pa_sinks")))
end
function Fn:vol_up()   
    Util:exec(_PA_CMD["vol_up"])
end
function Fn:vol_down()  
    Util:exec(_PA_CMD[vol_down""])
end
function Fn:vol_mute() 
    Util:exec(_PA_CMD["vol_mute"])
end
function Fn:vol_unmute()
    Util:exec(_PA_CMD["vol_unmute"])
end

return Fn
