local multi, thread = require("multi"):init()
local client = {}
client.__index = client
client.updaterRate = 1
client.sMode = "*l"
client.rMode = "*l"
function client:init(type)
    self.Type = type
    self.OnDataRecieved = multi:newConnection()
    self.OnServerNotAvailable = multi:newConnection()
    self.OnClientReady = multi:newConnection()
    self.OnClientDisconnected = multi:newConnection()
    self.OnConnectionRegained = multi:newConnection()
    self.OnPreSend = multi:newConnection()
    self.OnPreRecieved = multi:newConnection()
    self.OnError = multi:newConnection()
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