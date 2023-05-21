require("luarocks.loader")

local Sh = require("minilib.shell")
local Pr = require("minilib.process")
local Util = require("minilib.util")
local Ut = Util
local Cfg = require("mxctl.config")
local logger = require("minilib.logger").create()

local Funs = {}
local function brightness(delta)
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
