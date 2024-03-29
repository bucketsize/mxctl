require "luarocks.loader"

local Sh   = require('minilib.shell')
local Pr   = require('minilib.process')
local Util = require('minilib.util')
local M    = require('minilib.monad')
local Cfg  = require('mxctl.config')

local logger = require("minilib.logger").create()

local USER = os.getenv("USER")
local appcache = "/tmp/appcache.mxctl."..USER..".lua"
local pop_term = Cfg.build_pop_term
local menu_sel = Cfg.build_menu_sel
local ctrl_bin = Cfg.build_ctrl_bin

function hazapp(bs, b)
    for _,bi in ipairs(bs) do
        if bi.exec == b.exec then
            return true
        end
    end
    return false
end

function buildapp(tag, bs, b)
    if (b.name and b.exec) and (not hazapp(bs, b)) then
        -- logger.info(string.format("%s > %s >> %s => %s|", tag, b.bin, b.name, b.exec))
        table.insert(bs, b)
    end
end

local F={}
function F:parsedesktopfile(f)
    local h = assert(io.open(f, "r"), "bad file " .. f)
    local bs, b = {}, {}
    local i = 0
    for l in h:lines() do
        if l:match("^%[(.+)%]") then
            buildapp(tostring(i), bs, b)
            b = {name = "na", exec = "na", bin = "na"}
            i = i + 1
        else
            local name = l:match("^Name=([%w%s-_/]+)")
			local exec
            if name then
                b.name = name
            else
                exec = l:match("^Exec=(.+)")
                if exec then
                    b.exec = Util:strip(exec)
                    local ps = Util:split(".", Sh.split_path(f), {regex=false})
                    b.bin = ps[1]
                    if not b.bin then
                        b.bin = b.exec
                    end
                end
                -- logger.info("[]debug")
                -- logger.info(exec)
                -- logger.info(b.exec)
                -- logger.info(b.bin)
            end
        end
    end
    buildapp(tostring(i+1), bs, b)
    h:close()
    return bs
end

function F:find()
    local paths = table.concat(Cfg.app_dirs, " ")
    logger.info("find in %s", paths)

    local apps = {}

    -- find exes
    Pr.pipe()
    .add(Sh.exec(string.format('find %s -type f,l', paths)))
    .add(Pr.filter(function(x)
        if x == nil then
            return false
        end
        if string.match(x, ".desktop") then
            return false
        else
            return true
        end
    end))
    .add(function(x)
        if x == nil then
            return x
        end
        local p = Sh.split_path(x)
        apps[p] = x
		logger.info("find, found %s, %s", p, x)
        return x
    end)
    .run()

    -- find apps
    Pr.pipe()
    .add(Sh.exec(string.format('find %s -type f,l -name "*.desktop"', paths)))
    .add(function(x)
        if x == nil then
            return
        end
        local ds = F:parsedesktopfile(x)
        for _,d in ipairs(ds) do
			local p = d.bin .. ": " .. d.name
            apps[p] = d.exec 
			logger.info("find, found %s %s", p, d.exec)
        end
    end)
    .run()

    logger.info("discovered [apps+exes] %s targets", Util:size(apps))
	Util:tofile(appcache, apps)
    return apps
end

function F:list_apps()
    if not Sh.path_exists(appcache) then
        local apps = F:find()
        Util:tofile(appcache, apps)
    end
    local apps = Util:fromfile(appcache)
	return apps
end
function F:tmenu_run()
	local pmap = F:list_apps()
	local f = io.open("/tmp/mxcmd.out", "w")
	M.List.of(pmap):keys():fmap(function(k)
		f:write(k)
		f:write('\n')
	end)
	f:close()
	M.IO.read_lines_pout("fzf < /tmp/mxcmd.out"):fmap(function(x)
		x:fmap(function(y)
			if Cfg.termopts[y] then
				Sh.launch(Cfg.build_term(y))
			else
            	Sh.launch(pmap[y])
			end
		end)
	end)
end
function F:dmenu_run()
	Util:exec(pop_term(ctrl_bin("tmenu_run")))
end
function F:list_proc()
	local pmap = {}
    Pr.pipe()
        .add(Sh.exec("ps -xo pid,pcpu,pmem,stat,comm"))
        .add(Sh.grep("(%d+)%s+(%d+.%d+)%s+(%d+.%d+)%s+([%a%p]+)%s+([%a%p]+)"))
		.add(function(x)
			if x then
				pmap[string.format("%d \t\t %s \t\t %s", x[1], x[4] ,x[5])] = x[1]
				return x
			end
		end)
		.run()
	return pmap
end
function F:tmenu_kill_proc()
	local pmap = F:list_proc()
	local f = io.open("/tmp/mxcmd.out", "w")
	M.List.of(pmap):keys():fmap(function(k)
		f:write(k)
		f:write('\n')
	end)
	f:close()
	M.IO.read_lines_pout("fzf < /tmp/mxcmd.out"):fmap(function(x)
		x:fmap(function(y)
			logger.info("tmenu_kill_proc, kill", y)
			Sh.exec_cmd("kill "..pmap[y])
		end)
	end)
end
function F:dmenu_kill_proc()
	Util:exec(pop_term(ctrl_bin("tmenu_kill_proc")))
end

return F
