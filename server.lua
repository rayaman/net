-- package.path = "./?/init.lua;./?.lua;"..package.path
-- local net = require("net.tcp")
-- local server = net:newTCPServer(12345)

-- server.OnDataRecieved(function(serv, data,cid)
--     print("Response: ",data)
--     server:send(cid,"Hello!")
-- end)
-- multi:mainloop()
http = require("socket.http")
data, code, headers = http.request("http://zjcdn.mangafox.me/store/manga/33769/091.0/compressed/s20210705_163050_598.jpg")
for i,v in pairs(headers) do
    print(i,v)
end