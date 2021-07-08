local multi, thread = require("multi"):init()
local client = {}
client.__index = client
client.OnDataRecieved = multi:newConnection()
client.OnServerNotAvailable = multi:newConnection()
client.OnClientReady = multi:newConnection()
client.OnClientDisconnected = multi:newConnection()
client.OnConnectionRegained = multi:newConnection()
client.OnPreSend = multi:newConnection()
client.OnPreRecieved = multi:newConnection()
client.updaterRate = 1
client.sMode = "*l"
client.rMode = "*l"
function client:init(type)
    self.Type = type
    self.process = multi:newProcessor()
    self.process.Start()
end
function client:send(data)
    -- Override this function
end
function client:close()
    -- Override this function
end
function client:setUpdateRate(n)
    self.updaterRate = n
end
function client:setReceiveMode(mode)
    self.rMode = mode
end
function client:setSendMode(mode)
    self.sMode = mode
end
return client