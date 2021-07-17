local net = require("lnet")
local clientbase = require("lnet.base.client")
local serverbase = require("lnet.base.server")
local multi, thread = require("multi"):init()
local socket = require("socket")
local tcpcount = 0
net.newTCPServer = thread:newFunction(function(port)
    local c = {}
    setmetatable(c,serverbase)
    c:init("tcp")
    c.tcp = assert(socket.bind("*", port or 0))
    c.tcp:settimeout(0)
	c.ip, c.port = c.tcp:getsockname()
    if port and port == 0 then
		_, c.port = c.tcp:getsockname()
	end
    function c:send(cid,data)
        local dat = {data = data, cid = cid}
        self.OnPreSend:Fire(dat)
        if self.sMode == "*l" then
            cid:send(data .. "\n")
        else
            cid:send(data)
        end
    end
    tcpcount = tcpcount + 1
    c.updateThread = c.process:newThread("TCPServer Thread<"..tcpcount..">",function()
        while true do
            thread.skip(c.updaterRate)
            local client = c.tcp:accept(c.rMode)
            if client then
                print("Got Client!")
                table.insert(c.ips, client)
                client:settimeout(0)
                client:setoption("keepalive", true)
                ip, port = client:getpeername()
                if ip and port then
                    c.OnClientConnected:Fire(c, client, ip, port)
                    -- We need to cache the client handler so we can work with it
                    c.clientHandlers[client] = multi:newThread("ServerClientHandler<".. tostring(client):match(": (.+)") ..">",function()
                        local cli = client
                        while true do
                            thread.yield()
                            local data, err, dat, len
                            data, err = thread.hold(function()
                                data, err = cli:receive(c.rMode)
                                if data then print(data) end
                                if data~=nil and err then
                                    print(err)
                                    return multi.NIL, err
                                end
                                return data
                            end)
                            if err == "closed" then
                                for i = 1, #c.ips do
                                    if c.ips[i] == cli then
                                        table.remove(c.ips, i)
                                    end
                                end
                                c.OnClientClosed:Fire(c, "Client Closed Connection!", cli, ip)
                                c.links[cli] = nil -- lets clean up
                                thread.kill()
                            end
                            if data then
                                if net.inList(c.bannedIPs, ip) then
                                    return
                                end
                                c.OnDataRecieved:Fire(c, data, cli, ip, port)
                            end
                        end
                    end)
                end
            end
        end
    end).OnError(function(...)
        print(...)
    end)
    net.OnServerCreated:Fire(c)
    return c
end,true)

net.newTCPClient = thread:newFunction(function(host, port)
    local c = {}
    setmetatable(c,clientbase)
    c:init("tcp")
    c.ip = assert(socket.dns.toip(host))
    c.tcp = socket.connect(c.ip,port)
    c.tcp:settimeout(0)
    c.tcp:setoption("keepalive",true)
    function c:send(data)
        if self.sMode == "*l" then
            data = data .. "\n"
        end
        print("Sending:",data)
        local dat = {data = data}
        self.OnPreSend:Fire(dat)
        local ind, err = self.tcp:send(dat.data)
        print(ind,err)
        print("Data Sent!")
        if err == "closed" then
            self.OnClientDisconnected:Fire(self,err)
        elseif err == "timeout" then
            self.OnClientDisconnected:Fire(self,err)
        end
    end
    c.updateThread = c.process:newThread("TCPClient Thread<"..tcpcount..">",function()
        while true do
            thread.skip(c.updaterRate)
            local data = thread.hold(function()
				local d,err = c.tcp:receive(c.rMode)
                if not(d) then
                    if err == "closed" then
                        c.OnClientDisconnected:Fire(c,err)
                    elseif err == "timeout" then
                        c.OnClientDisconnected:Fire(c,err)
                    else
                        print(err)
                    end
                else
                    return d
                end
			end)
            if data then
                local dat = {data = data}
                c.OnPreRecieved:Fire(dat)
                c.OnDataRecieved:Fire(c,dat.data)
            end
        end
    end).OnError(function(...)
        print(...)
    end)
    net.OnClientCreated:Fire(c)
    return c
end,true)
return net