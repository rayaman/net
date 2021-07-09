local multi, thread = require("multi"):init()
local socket = require("socket")
local net = require("net")
local server = {}
local bCaster = 0
server.__index = server
server.updaterRate = 1
server.rMode = "*l"
server.sMode = "*l"
function server:init(type)
    self.OnClientsModulesList = multi:newConnection()
    self.OnPreRecieved = multi:newConnection()
    self.OnDataRecieved = multi:newConnection()
    self.OnClientClosed = multi:newConnection()
    self.OnClientConnected = multi:newConnection()
    self.OnPreSend = multi:newConnection()
    self.idleRate = 5
    self.bannedCIDs = {}
    self.bannedIPs = {}
    self.broad = socket.udp()
    self.localIP = net.getLocalIP()
    self.Type = type
    self.ips = {}
    self.links = {}
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
    if not self.isBroadcasting then
        bCaster = bCaster + 1
        self.isBroadcasting = true
        self.process:newThread("Broadcast Handler<"..bCaster..">",function()
            while true do
                thread.yield()
                self.broad:setoption("broadcast",true)
                self.broad:sendto(table.concat({name,self.Type,self.localIP},"|")..":"..self.port, "255.255.255.255", 11111)
                self.broad:setoption("broadcast", false)
            end
        end)
    end
end
function server:send(cid,data)
    -- Override this
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