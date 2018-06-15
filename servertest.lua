package.path="?/init.lua;"..package.path
require("multi")
require("net")
port=12344
udp=assert(socket.udp())
udp:settimeout(0)
udp:setsockname("*", port)
multi:newLoop(function()
	local data,ip,port=udp:receivefrom()
	if data then
		print(data)
		udp:sendto("Hey Client!\n", ip, port)
	end
end)
multi:mainloop()
