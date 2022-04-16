require "luarocks.loader"

local Sh   = require('minilib.shell')
local Pr   = require('minilib.process')
local Util = require('minilib.util')
local Cfg  = require('mxctl.config')

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
        -- print(string.format("%s > %s >> %s => %s|", tag, b.bin, b.name, b.exec))
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
                -- print("[]debug")
                -- print(exec)
                -- print(b.exec)
                -- print(b.bin)
            end
        end
    end
    buildapp(tostring(i+1), bs, b)
    h:close()
    return bs
end

function F:find()
    local paths = table.concat(Cfg.app_dirs, " ")
    -- print("paths:", paths)

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
            apps[d.bin .. ": " .. d.name] = d.exec
        end
    end)
    .run()

    -- print("discovered [apps+exes]:", Util:size(apps))
    return apps
end

function F:findcached()
    if not Sh.path_exists(appcache) then
        local apps = F:find()
        Util:tofile(appcache, apps)
    end
    local apps = Util:fromfile(appcache)
	for k,_ in pairs(apps) do
		print(k)
	end
end
function F:tmenu_run()
    local list_apps = menu_sel(ctrl_bin("findcached"))
    Pr.pipe()
        .add(Sh.exec(list_apps))
        .add(function(app)
            if not app then
                return 
            end
            local apps = Util:fromfile(appcache)
            Sh.launch(apps[app])
        end)
       .run()
end
function F:dmenu_run()
	Util:exec(pop_term(ctrl_bin("tmenu_run")))
end

return F
