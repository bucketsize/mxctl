require "luarocks.loader"

local Sh = require('minilib.shell')
local Pr = require('minilib.process')
local Util = require('minilib.util')
local Ot = require('minilib.otable')
local Cfg = require('mxctl.config')
local appcache = "/tmp/exec-apps.lua"

function hazapp(bs, b)
    for i,bi in ipairs(bs) do
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
    local h = io.open(f, "r")
    local bs, b = {}, {}
    local i = 0
    for l in h:lines() do
        if l:match("^%[(.+)%]") then
            buildapp(tostring(i), bs, b)
            b = {name = "na", exec = "na", bin = "na"}
            i = i + 1
        else
            local name, exec = l:match("^Name=([%w%s-_/]+)")
            if name then
                b.name = name
            else
                exec = l:match("^Exec=(.+)")
                if exec then
                    b.exec = Util:strip(exec)
                    b.bin = b.exec:match("([%w%p]+)%s")
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
    local paths = Util:join(" ", Cfg.app_dirs)
    --print("paths:", paths)

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
        for i,d in ipairs(ds) do
            apps[d.bin .. ": " .. d.name] = d.exec
        end
    end)
    .run()

    print("discovered [apps+exes]:", Util:size(apps))
    Util:tofile(appcache, apps)
end

function F:findcached()
    if not Sh.path_exists(appcache) then
        F:find()
    end
    local apps = Util:fromfile(appcache)
    for k, v in pairs(apps) do
        print(k)
    end
    return apps
end

return F
