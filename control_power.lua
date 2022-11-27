require "luarocks.loader"

local Sh   = require('minilib.shell')
local Pr   = require('minilib.process')
local Ut   = require('minilib.util')
local Tr   = require('minilib.timer')
local Cfg  = require('mxctl.config')
local logger = require("minilib.logger").create()

local pop_term = Cfg.build_pop_term 
local menu_sel = Cfg.build_menu_sel
local ctrl_bin = Cfg.build_ctrl_bin

function battery()
	local ecur = tonumber(Ut:head_file("/sys/class/power_supply/BAT0/energy_now"))
	local emax = tonumber(Ut:head_file("/sys/class/power_supply/BAT0/energy_full"))
	local pcap = tonumber(Ut:head_file("/sys/class/power_supply/BAT0/capacity"))
	local stat = Ut:head_file("/sys/class/power_supply/BAT0/status")
	return {ecur=ecur,emax=emax,pcap=pcap,stat=stat,stat_enum={"Charging","Discharging"}}
end

local F = {}
function F:monitor_power()
	local power_co = coroutine.create(function()
		local pstat = nil -- ce,ac,ba
		local ce_ep = 0
		while true do
			local bs = battery()
			if bs.pcap <= 10 and bs.stat == "Discharging" then
				if pstat == nil or pstat ~= "ce" then
					pstat = "ce"
					ce_ep = 1
				else
					if pstat == "ce" then
						if ce_ep >= 30 then
							logger.info("going to suspend ...")
							-- TODO
						else
							ce_ep = ce_ep + 1
						end
					end
				end
			end
			if bs.pcap > 10 and bs.stat == "Charging" then
				pstat = "ac"
				ce_ep = 0
			end
			if bs.pcap > 10 and bs.stat == "Discharging" then
				pstat = "ba"
				ce_ep = 0
			end
			coroutine.yield(pstat, bs.stat, bs.pcap)
		end
	end)
	while true do
		coroutine.resume(power_co)
		Tr.sleep(1)
	end
end

return F
