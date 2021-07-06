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
                return c.udp:receive()
            end)
            local dat = {data = data}
            c.OnPreSend:Fire(dat)
            c.OnDataRecieved:Fire(c,dat.data)
        end
    end).OnError(function(a,b,c)
        print(a,b,c)
    end)
    return c
end