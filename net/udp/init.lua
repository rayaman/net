local net = require("net")
local clientbase = require("net.clientbase")
local serverbase = require("net.serverbase")
local multi, thread = require("multi"):init()
local GLOBAL, THREAD = require("multi.integration.threading"):init()
local CID = {}
CID.__index = cid
local udpcount = 0
CID.ip = "0.0.0.0"
CID.port = 0
function net:newUDPServer(port)
    local c = {}
    setmetatable(c,serverbase)
    c:init("udp")
    c.udp = assert(socket.udp())
    c.udp:settimeout(0)
    c.udp:setsockname("*",port)
    c.bannedIPs = {}
    c.bannedCIDs = {}
    local inactivity = {}
    if port == 0 then
        _,c.port = c.udp:getsockname()
    else
        c.port = port
    end
    udpcount = udpcount + 1
    c.updateThread = c.process:newThread("UDPServer Thread<"..udpcount..">",function()
        local sideJob = thread:newFunction(function()
            thread.sleep(60*c.idleRate)
            for i,v in pairs(c.cids) do
                thread.skip(1)
                if os.clock() - v.activity >= 60*c.idleRate then
                    c.OnClientClosed:Fire(v)
                    c.cids[i] = nil
                end
            end
            return true
        end)
        while true do
            thread.skip(c.updaterRate)
            local data, ip, port = c.udp:receivefrom()
            sideJob().connect(function(yes,a,b,c)
                if yes then
                    sideJob:Resume()
                end
            end)
            sideJob:Pause()
            if data then
                local cid = c:getCid(ip,port)
                if not cid then
                    local cd = {}
                    setmetatable(cd,CID)
                    cd.ip = ip
                    cd.port = port
                    cd.activity = os.clock()
                    c.cids[ip .. port] = cd
                    cid = cd
                end
                print("Refreshing CID: ",cid," Activity!")
                cid.activity = os.clock()
                local dat = {data = data,cid = cid}
                c.OnPreRecieved:Fire(dat)
                c.OnDataRecieved:Fire(c,dat.data,dat.cid)
            end
        end
    end).OnError(function(...)
        print(...)
    end)
    return c
end
function net:newUDPClient(host, port)
    local c = {}
    setmetatable(c,clientbase)
    c:init("udp")
    c.ip = assert(socket.dns.toip(host))
    c.udp = assert(socket.udp())
    c.udp:settimeout(0)
    c.udp:setpeername(c.ip,port)
    c.updateThread = c.process:newThread("UDPServer Thread<"..udpcount..">",function()
        while true do
            thread.skip(c.updaterRate)
            local data = thread.hold(function()
                return c.udp:receive()
            end)
            local dat = {data = data}
            c.OnPreRecieved:Fire(dat)
            c.OnDataRecieved:Fire(c,dat.data)
        end
    end)
    return c
end
return net