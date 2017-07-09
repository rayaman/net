# net (2.0.1)
Updated from 2.0.0 to 2.0.1
Added:
- Examples
- Support for latest multi version
- Updated readme


# Discord
For real-time assistance with my libraries! A place where you can ask questions and get help with any of my libraries</br>
https://discord.gg/U8UspuA</br>

The net library was created to make servers and clients interact easily. This isn't for webservers! (It could be, but you would need to code that part) The goal was to allow the creation for game servers!

This library depends on luasocket and you should use luajit! It will work on a standard lua interperter, but wont be as fast.
# Goal
A simple and powerful way to make servers and clients
# Todo
- [ ] Write the wiki
- [x] Make Example folder
- [ ] Document stable modules
- [ ] IPV6 Support
- [ ] Multicast support
- [ ] Clean up modules
- [ ] Improve server ban features
- [ ] Improve 'stable' modules
- [ ] AUDP - advance udp. Ensures packets arrive and handles late packets.
- [ ] P2P - peer to peer (Server to set up initial connection)
- [ ] Relay - offput server load (locally)
- [ ] Threading - Simple threading ~~(UDP/AUDP Only)~~ Thanks to an updated multi library we can thread with ease
- [ ] Priority handling

# Note
You will see a bunch of files inside of the net folder. All that is stable is the init.lua and sft.lua file. Everything else is a work in progress. Plus I am planning on rewritting all of the modules to take advantage of the new threading features that are found in the new multi updates. PRogress on this will be made soon. I have just been away from my PC for a while.
# Usage
server.lua
```lua
require("bin") -- this library needs a lot of work it has a bunch of old useless code, but also has many nice things as well that are really useful
require("multi") -- you need this to handle multiple connections and such
require("net") -- That requires the main library
server=net:newTCPServer(12345) -- create a server that listens on port 12345
server.OnDataRecieved(function(self,data,CID_OR_HANDLE,IP_OR_HANDLE,PORT_OR_IP,UPDATER_OR_NIL) -- a bit confusing, but dont worry you will hardly ever need more then the first 5 arguments, unless you are writing modules!
  if data=="Hello!" then
    print("Got response from client sending back data!")
    self:send(IP_OR_HANDLE,"Hello Client!",PORT_OR_IP) -- doing it like this makes this code work for both udp and tcp
  end
end)
multi:mainloop()
```
client.lua
```lua
require("bin") -- this library needs a lot of work it has a bunch of old useless code, but also has many nice things as well that are really useful
require("multi") -- you need this to handle multiple connections and such
require("net") -- That requires the main library
client=net:newTCPClient("localhost",12345) -- connect to the server
client.OnClientReady(function(self)
  self:send("Hello!")
end) -- For a tcp client the client is already ready, with udp a small handshake is done and the client is not instantly ready
client.OnDataRecieved(function(self,data) -- thats it clients only have to worry about itself and the server
  if data=="Hello Client!" then
    print("Server Responded Back!")
  end
end)
multi:mainloop()
```

There is support for broadcasting, multicasting will be added soon requires luasocker 3.0+.</br>
Here is a broadcasting example:</br>
broadcastingExampleServer.lua (included in example folders)
```lua
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
```
broadcastingExampleClient.lua (included in example folders)
```lua
package.path="?/init.lua;"..package.path
require("bin")
require("multi")
require("net.aft")
client=net:newCastedClient("Lua_Server") -- searches the lan for this server name
-- Both udp and tcp clients can be broadcasted
client.OnClientReady(function(self)
	self:send("Hello!")
end) -- For a tcp client the client is already ready, with udp a small handshake is done and the client is not instantly ready
client.OnDataRecieved(function(self,data) -- thats it clients only have to worry about itself and the server
	if data=="Hello Client!" then
		print("Server Responded Back!")
	end
end)
multi:mainloop()
```
The net library also provides a powerful module creation interface. You have all of the modules in the net folder as examples, however I will show you how you could go about creating your own!</br>

**All functions include:</br>**
- net.OnServerCreated() -- Refer to the multi library example on connections: https://github.com/rayaman/multi#connections
- net.OnClientCreated() -- ^^
- net.normalize(input) -- formats data in base 64
- net.denormalize(input) -- takes base 64 data and turns it back into what it was
- net.getLocalIP() -- returns your loacl ip
- net.getExternalIP() -- If this ever stops working let me know... Ill have to update the service I am using
- net:registerModule(mod,version) -- registers a module. Checks out the example below
- net.getModuleVersion(ext) -- returns the version of a module
- net.resolveID(obj) -- an internal method for generating unique IDs obj is a table with an ID key
- net.inList(list,dat) -- checks if dat is a value in list
- net.setTrigger(funcW,funcE) -- Currently does nothing... I forgot where I was going with this
- net:newCastedClient(name) -- connects to a server that is being broadcasted see above example
- net:newServer(port,servercode) -- creates a UDP Server
- net:newClient(host,port,servercode,nonluaServer) -- creates a UDP Client
- net:newTCPServer(port) -- creates a TCP Server
- net:newTCPClient(host,port) -- creates a TCP Client

Both TCP/UPD Clients and Servers contain the same methods:
Server Object:
# General Server Methods
- serverobj:setUpdateRate(n)
- server:banCID(cid)
- server:banIP(ip)
- server:broadcast(name)
- server:send(ip,data,port,cid)
- server:pollClientModules(ip,port)
- server:CIDFrom(ip,port)
- server:sendAll(data)
- server:sendAllBut(data,cid)
- server:clientRegistered(cid)
- server:clientLoggedIn(cid)
- server:update() -- Internal method do not call!
- server.OnClientsModulesList()
- server.OnDataRecieved()
- server.OnClientClosed()
- server.OnClientConnected()
- server.hostip=net.getLocalIP()
- server.port

# TCP Server Only Methods
- server:setReceiveMode(mode)
- server:setSendMode(mode)
- server:sendAllData(handle,data)
- server:getUpdater(cid)

# General Client Methods
- client:send(data)
- client:sendRaw(data)
- client:close()
- client:getCID()
- client:update() -- Internal method do not call!
- client:reconnect()
- client:IDAssigned()
- client.OnDataRecieved()
- client.OnClientReady()
- client.OnClientDisconnected()
- client.OnConnectionRegained()

# UDP Client Only Methods
- client.OnPingRecieved()
- client.OnServerNotAvailable

# TCP Client Only Methods
- client:setReceiveMode(mode)
- client:setSendMode(mode)

When using the module creation support here is the shell that you can use:
```lua
require("net") -- what do you need? other modules or the core? always require the core so users can require your module without having to require the core themself
local MODULENAME="EXAMPLE"
net:registerModule(MODULENAME,{1,0,0})
if not io.dirExists(string.upper(MODULENAME)) then -- do you need a directory to store stuff for your module?
	io.mkDir(string.upper(MODULENAME))
end
net.OnServerCreated:connect(function(s)
	s.OnDataRecieved(function(self,data,CID_OR_HANDLE,IP_OR_HANDLE,PORT_OR_IP)
		local cmd,arg1,arg2=data:match("!"..MODULENAME.."! (%S+) (%S+) (%S+)") -- change to fit your needs
		if cmd=="SEND" then
			--
		elseif cmd=="GET" then
			--
		end
	end,MODULENAME)
end)
net.OnClientCreated:connect(function(c)
	c.OnDataRecieved(function(self,data)
		local cmd,arg1,arg2=data:match("!"..MODULENAME.."! (%S+) (%S+) (%S+)") -- change to fit your needs
        if cmd=="SEND" then
			--
		elseif cmd=="GET" then
			--
		end
	end,MODULENAME)
end)
```

The bin and multi library can be found on my github page. They are all '100%'(If you ingore intergrations) pure lua so it should be easy to add to your project.
https://github.com/rayaman/multi</br>https://github.com/rayaman/bin
