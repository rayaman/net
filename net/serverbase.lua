local multi, thread = require("multi"):init()
local socket = require("socket")
local net = require("net")
local server = {}
local bCaster = 0
server.__index = server
server.OnClientsModulesList = multi:newConnection()
server.OnPreRecieved = multi:newConnection()
server.OnDataRecieved = multi:newConnection()
server.OnClientClosed = multi:newConnection()
server.OnClientConnected = multi:newConnection()
server.OnPreSend = multi:newConnection()
server.updaterRate = 1
server.rMode = "*l"
server.sMode = "*l"
function server:init(type)
    self.idleRate = 5
    self.bannedCIDs = {}
    self.bannedIPs = {}
    self.broad = socket.udp()
    self.localIP = net.getLocalIP()
    self.Type = type
    self.ips = {}
    self.cids = {}
    self.process = multi:newProcessor()
    self.process.Start()
end
function server:setIdleRate(minutes)
    self.idleRate = minutes
end
function server:setUpdateRate(n)
    self.updaterRate = n
end
function server:banCID(cid)
    table.insert(self.bannedCIDs,cid)
end
function server:banIP(ip)
    table.insert(self.bannedIPs)
end
function server:setRecieveMode(mode)
    self.rMode = mode
end
function server:setSendMode(mode)
    self.sMode = mode
end
function server:broadcast(name)
    bCaster = bCaster + 1
    self.process:newThread("Broadcast Handler<"..bCaster..">",function()
        while true do
            thread.yield()
            self.broad:setoption("broadcast",true)
            self.broad:sendto(table.concat({name,self.Type,self.localIP},"|")..":"..self.port, "255.255.255.255", 11111)
            self.broad:setoption("broadcast", false)
        end
    end)
end
function server:send(data,cid)
    if self.Type == "udp" then
        ---
    elseif self.Type == "tcp" then
        --
    end
end
function server:getCid(ip,port)
    if self.cids[ip .. port] then
        return self.cids[ip .. port]
    end
end
function server:sendAll(data)
    for i,v in pairs(self.cids) do
        self:send(data,cid)
    end
end
function server:sendAllBut(data,cid)
    for i,v in pairs(self.cids) do
        if v~=cid then
            self:send(data,cid)
        end
    end
end
function server:clientRegistered(cid)
    return self.cids[cid]
end
return server