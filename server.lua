package.path="?/init.lua;"..package.path
local multi = require("multi")
local net = require("net")
local GLOBAL, THREAD = require("multi.integration.lanesManager").init()
server = net:newTCPServer(12345)
server:enableBinaryMode()
print("Server hosted on "..net.getExternalIP().." listening on port: 12345")
server.OnDataRecieved(function(self,data,cid,ip,port)
	print(data)
	local file = bin.load("test.mp3")
	local dat = file:read(1024)
	while dat do
		thread.sleep(.002)
		self:send(ip,dat,port,cid)
		dat = file:read(1024)
	end
	self:send(ip,dat or "",port,cid)
	self:send(ip,"END",port,cid)
end)
multi:mainloop()
