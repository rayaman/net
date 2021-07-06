package.path = "./?/init.lua;./?.lua;"..package.path
local net = require("net.udp")
local server = net:newUDPServer(12345)

server.OnDataRecieved(function(serv, data,cid)
    print("Response: ",data)
    server:send("Hello!",cid)
end)
multi:mainloop()