package = "mxctl"
version = "dev-1"
source = {
   url = "."
}
description = {
   homepage = "",
   license = "EULA"
}
dependencies = {
   "lua >= 5.1",
   "minilib"
}
build = {
	type = "none",
	install = {
		lua = {
			["mxctl.config"] = "src/config.lua",
			["mxctl.control_cmds"] = "src/control_cmds.lua",
			["mxctl.control_process"] = "src/control_process.lua",
			["mxctl.control_pulseaudio"] = "src/control_pulseaudio.lua",
			["mxctl.control_x11"] = "src/control_x11.lua",
			["mxctl.control"] = "src/control.lua",
		},
		bin = {
			["mxctl.control"] = "src/control.lua",
			["mxctl.controld"] = "src/controld.lua"
		}
	}
}
