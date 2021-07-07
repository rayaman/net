local net = require("net")
local clientbase = require("net.clientbase")
local serverbase = require("net.serverbase")
local multi, thread = require("multi"):init()
local GLOBAL, THREAD = require("multi.integration.threading"):init()


function net:newTCPClient(host, port)
    local c = {}
    setmetatable(c,clientbase)
    c:init("tcp")
    c.ip = assert(socket.dns.toip(host))
    c.tcp = socket.connect(c.ip,port)
    c.tcp:settimeout(0)
    c.tcp:setoption("keepalive",true)
    c.updateThread = c.process:newThread("TCPServer Thread<"..udpcount..">",function()
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
    end).OnError(function(a,b,c)
        print(a,b,c)
    end)
    return c
end