package.path = "./?/init.lua;./?.lua;"..package.path
local net = require("net.tcp")
local server = net:newTCPServer(12345)

server.OnDataRecieved(function(serv, data,cid)
    print("Response: ",data)
    server:send(cid,"Hello!")
end)
multi:mainloop()