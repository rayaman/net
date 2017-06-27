package.path="?/init.lua;"..package.path
-- Note: you need 2 computers to test this! Broadcast does not on local host!
-- I have tested this code and it works, but only on seperate PC's within the same LAN network
require("bin")
require("multi")
require("net")
server=net:newServer(12345)
server.OnDataRecieved(function(self,data,CID_OR_HANDLE,IP_OR_HANDLE,PORT_OR_IP,UPDATER_OR_NIL)
	if data=="Hello!" then -- copy from other example
		print("Got response from client sending back data!")
		self:send(IP_OR_HANDLE,"Hello Client!",PORT_OR_IP) -- doing it like this makes this code work for both udp and tcp
	end
end)
server:broadcast("Lua_Server")
multi:mainloop()
