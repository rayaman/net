--[[
	UPCOMMING ADDITIONS
	AUDP - advance udp. Ensures packets arrive and handles late packets.
	P2P - peer to peer (Server to set up initial connection)
	Relay - offput server load (locally)
	Threading - Simple threading ~~(UDP/AUDP Only)~~ Thanks to an updated multi library we can thread with ease
	Priority handling
]]
--[[
	TODO: Finish stuff for Priority handling
]]
function table.merge(t1, t2)
    for k,v in pairs(t2) do
    	if type(v) == 'table' then
    		if type(t1[k] or false) == 'table' then
    			table.merge(t1[k] or {}, t2[k] or {})
    		else
    			t1[k] = v
    		end
    	else
    		t1[k] = v
    	end
    end
    return t1
end
function string.trim(s)
	local from = s:match"^%s*()"
	return from > #s and "" or s:match(".*%S", from)
end
local guid = {}
local char = {}
for i = 48,57 do
	char[#char+1]=string.char(i)
end
for i = 65,90 do
	char[#char+1]=string.char(i)
end
for i = 97,122 do
	char[#char+1]=string.char(i)
end
local isHyphen = {[9]=1,[14]=1,[19]=1,[24]=1}
math.randomseed(os.time())
local multi = require("multi")
local socket=require("socket")
local http=require("socket.http")
local mime=require("mime")
--ssl=require("ssl")
--https=require("ssl.https")
local net={}
net.Version={3,0,0} -- This will probably stay this version for quite a while... The modules on the otherhand will be more inconsistant
net._VERSION="3.0.0"
net.ClientCache = {}
net.OnServerCreated=multi:newConnection()
net.OnClientCreated=multi:newConnection()
net.loadedModules={}
net.OnCastedClientInfo=multi:newConnection()
net.autoInit=true
net.ConnectionDriver = {}
net.BroadcastDriver = {}
net.generateGUID = function(t)
	local pass = {}
	local a=0
	local x=""
	for z = 1,36 do
		if isHyphen[z] then
			x='-'
		else
			 a = math.random(1,#char)
			 x = char[a]
		end
		table.insert(pass, x)
		if t == z then break end
	end
	z = nil
	return tostring(table.concat(pass))
end
function net.normalize(input)
	local enc=mime.b64(input)
	return enc
end
function net.denormalize(input)
	local unenc=mime.unb64(input)
	return unenc
end
function net.getLocalIP()
	local someRandomIP = "192.168.1.122"
	local someRandomPort = "3102"
	local mySocket = socket.udp()
	mySocket:setpeername(someRandomIP,someRandomPort)
	local dat = (mySocket:getsockname())
	mySocket:close()
	return dat
end
function net.getExternalIP()
	local data=http.request("http://whatismyip.host")
	return data:match("(%d+.%d+.%d+.%d+)")
end
function net:registerModule(mod,version)
	if net[mod] then
		error("Module by the name: "..mod.." has already been registered! Remember some modules are internal and use certain names!")
	end
	table.insert(self.loadedModules,mod)
	net[mod]={}
	if version then
		net[mod].Version=version
		net[mod]._VERSION=version[1].."."..version[2].."."..version[3]
	else
		net[mod].Version={1,0,0}
		net[mod]._VERSION={1,0,0}
	end
	return {Version=version,_VERSION=version[1].."."..version[2].."."..version[3]}
end
function net.getModuleVersion(ext)
	if not ext then
		return string.format("%d.%d.%d",net.Version[1],net.Version[2],net.Version[3])
	end
	return string.format("%d.%d.%d",net[ext].Version[1],net[ext].Version[2],net[ext].Version[3])
end
function net.resolveID(obj)
	local num=math.random(10000000,99999999)
	if obj[tostring(num)] then
		return net.resolveID(obj)
	end
	obj.ids[tostring(num)]=true
	return tostring(num)
end
function net.inList(list,dat)
	for i,v in pairs(list) do
		if v==dat then
			return true
		end
	end
	return false
end
function net.setTrigger(funcW,funcE)
	multi:newTrigger(func)
end
net:registerModule("net",net.Version)
-- Client broadcast
function net:newCastedClient(name) -- connects to the broadcasted server
	local listen = socket.udp() -- make a new socket
	listen:setsockname(net.getLocalIP(), 11111)
	listen:settimeout(0)
	local timer=multi:newTimer()
	while true do
		local data, ip, port = listen:receivefrom()
		if timer:Get()>3 then
			error("Timeout! Server by the name: "..name.." has not been found!")
		end
		if data then
			print("found!",data)
			local n,tp,ip,port=data:match("(%S-)|(%S-)|(%S-):(%d+)")
			if n:match(name) then
				print("Found Server!",n,tp,ip,port)
				if tp=="tcp" then
					return net:newTCPClient(ip,tonumber(port))
				else
					return net:newClient(ip,tonumber(port))
				end
			end
		end
	end
end
function net:newCastedClients(name) -- connects to the broadcasted server
	local listen = socket.udp() -- make a new socket
	listen:setsockname(net.getLocalIP(), 11111)
	listen:settimeout(0)
	multi:newTLoop(function(self)
		local data, ip, port = listen:receivefrom()
		if data then
			local n,tp,ip,port=data:match("(%S-)|(%S-)|(%S-):(%d+)")
			if n:match(name) and not net.ClientCache[n] then
				local capture = n:match(name)
				local client = {}
				if tp=="tcp" then
					client=net:newTCPClient(ip,tonumber(port))
				else
					client=net:newUDPClient(ip,tonumber(port))
				end
				net.ClientCache[n]=client
				net.OnCastedClientInfo:Fire(client,n,ip,port)
			end
		end
	end,.1):setName("net.castedTask")
end
-- UDP Stuff
function net:newUDPServer(port,servercode,nonluaServer)
	local c={}
	c.udp=assert(socket.udp())
	c.udp:settimeout(0)
	c.udp:setsockname("*", port)
	c.ips={}
	c.Type="udp"
	if port == 0 then
		_, c.port = c.udp:getsockname()
	end
	c.ids={}
	c.servercode=servercode
	c.bannedIPs={}
	c.bannedCIDs={}
	c.autoNormalization=false
	function c:setUpdateRate(n)
		print("Not needed in a udp server!")
	end
	function c:banCID(cid)
		table.insert(self.bannedCIDs,cid)
	end
	function c:banIP(ip)
		table.insert(self.bannedIPs,cid)
	end
	c.broad=socket.udp()
	c.hostip=net.getLocalIP()
	function c:broadcast(name)
		table.insert(net.BroadcastDriver,function(loop,dt)
			self.broad:setoption('broadcast',true)
			self.broad:sendto(name.."|"..self.Type.."|"..self.hostip..":"..self.port, "255.255.255.255", 11111)
			self.broad:setoption('broadcast',false)
		end)
	end
	function c:send(ip,data,port,cid)
		if self.autoNormalization then
			data=net.normalize(data)
		end
		if self.servercode then
			cid=cid or self:CIDFrom(ip,port)
			if not self.ips[cid] then
				print("Can't determine cid from client... sending the client a new one!")
				local cid=net.resolveID(self)
				print("Sending unique cid to client: "..cid)
				self.ips[cid]={ip,port,0,self.servercode==nil}
				print(ip)
				self.udp:sendto("I!"..cid,ip,port)
				if self.servercode then
					self.udp:sendto("S!",ip,port)
				end
				return
			end
			if net.inList(self.bannedIPs,ip) or net.inList(self.bannedCIDs,cid) then
				self.udp:sendto("BANNED CLIENT", ip, port or self.port)
			elseif self.ips[cid][4] then
				self.udp:sendto(data, ip, port or self.port)
			elseif self.ips[cid][4]==false then
				self.udp:sendto("Make sure your server code is correct!", ip, port)
			end
		else
			self.udp:sendto(data, ip, port or self.port)
		end
	end
	function c:pollClientModules(ip,port)
		self:send(ip,"L!",port)
	end
	function c:CIDFrom(ip,port)
		for i,v in pairs(self.ips) do
			if(ip==v[1] and v[2]==port) then
				return i
			end
		end
	end
	function c:sendAll(data)
		for i,v in pairs(self.ips) do
			self:send(v[1],data,v[2],i)
		end
	end
	function c:sendAllBut(data,cid)
		for i,v in pairs(self.ips) do
			if i~=cid then
				self:send(v[1],data,v[2],i)
			end
		end
	end
	function c:clientRegistered(cid)
		return self.ips[cid]
	end
	function c:clientLoggedIn(cid)
		if not self.clientRegistered(cid) then
			return nil
		end
		return self.ips[cid][4]
	end
	function c:update()
		local data,ip,port=self.udp:receivefrom()
		if net.inList(self.bannedIPs,ip) or net.inList(self.bannedCIDs,cid) then
			print("We will ignore data from a banned client!")
			return
		end
		if data then
			if self.autoNormalization then
				data=net.denormalize(data)
			end
			if data:sub(1,4)=="pong" then
				--print("Recieved pong from: "..data:sub(5,-1))
				self.ips[data:sub(5,-1)][3]=os.clock()
			elseif data:sub(1,2)=="S!" then
				local cid=self:CIDFrom(ip,port)
				if data:sub(3,-1)==self.servercode then
					print("Servercode Accepted: "..self.servercode)
					if self.ips[cid] then
						self.ips[cid][4]=true
					else
						print("Server can't keep up! CID: "..cid.." has been skipped! Sending new CID to the client!")
						local cid=net.resolveID(self)
						print("Sending unique cid to client: "..cid)
						self.ips[cid]={ip,port,0,self.servercode==nil}
						print(ip)
						self.udp:sendto("I!"..cid,ip,port)
						if self.servercode then
							self.udp:sendto("S!",ip,port)
						end
					end
				else
					self.udp:sendto("Make sure your server code is correct!", ip, port)
				end
			elseif data:sub(1,2)=="C!" then
				local hook=(data:sub(11,-1)):match("!(.-)!")
				self.OnDataRecieved:getConnection(hook):Fire(self,data:sub(11,-1),data:sub(3,10),ip,port)
			elseif data:sub(1,2)=="E!" then
				self.ips[data:sub(3,10)]=nil
				obj.ids[data:sub(3,10)]=false
				self.OnClientClosed:Fire(self,"Client Closed Connection!",data:sub(3,10),ip,port)
			elseif data=="I!" then
				local cid=net.resolveID(self)
				print("Sending unique cid to client: "..cid)
				self.ips[cid]={ip,port,os.clock(),self.servercode==nil}
				print(ip)
				self.udp:sendto("I!"..cid,ip,port)
				if self.servercode then
					self.udp:sendto("S!",ip,port)
				end
				self.OnClientConnected:Fire(self,cid,ip,port)
			elseif data:sub(1,2)=="L!" then
				cid,cList=data:sub(3,10),data:sub(11,-1)
				local list={}
				for m,v in cList:gmatch("(%S-):(%S-)|") do
					list[m]=v
				end
				self.OnClientsModulesList:Fire(list,cid,ip,port)
			end
		end
		for cid,dat in pairs(self.ips) do
			if not((os.clock()-dat[3])<65) then
				self.ips[cid]=nil
				self.OnClientClosed:Fire(self,"Client lost Connection: ping timeout",cid,ip,port)
			end
		end
	end
	c.OnClientsModulesList=multi:newConnection()
	c.OnDataRecieved=multi:newConnection()
	c.OnClientClosed=multi:newConnection()
	c.OnClientConnected=multi:newConnection()
	c.connectiontest=multi:newAlarm(30):setName("net.pingOutTask")
	c.connectiontest.link=c
	c.connectiontest:OnRing(function(alarm)
		alarm.link:sendAll("ping")
		alarm:Reset()
	end)
	table.insert(net.ConnectionDriver,c)
	net.OnServerCreated:Fire(c)
	return c
end
local pingManager = {}
function net:newUDPClient(host,port,servercode,nonluaServer)
	local c={}
	c.ip=assert(socket.dns.toip(host))
	c.udp=assert(socket.udp())
	c.udp:settimeout(0)
	c.udp:setpeername(c.ip, port)
	c.cid="NIL"
	c.lastPing=0
	c.Type="udp"
	c.servercode=servercode
	c.autoReconnect=true
	c.autoNormalization=false
	function c:pollPing(n)
		return not((os.clock()-self.lastPing)<(n or 60))
	end
	function c:send(data)
		if self.autoNormalization then
			data=net.normalize(data)
		end
		self.udp:send("C!"..self.cid..data)
	end
	function c:sendRaw(data)
		if self.autoNormalization then
			data=net.normalize(data)
		end
		self.udp:send(data)
	end
	function c:getCID()
		if self:IDAssigned() then
			return self.cid
		end
	end
	function c:close()
		self:send("E!")
	end
	function c:IDAssigned()
		return self.cid~="NIL"
	end
	function c:update()
		local data=self.udp:receive()
		if data then
			if self.autoNormalization then
				data=net.denormalize(data)
			end
			if data:sub(1,2)=="I!" then
				self.cid=data:sub(3,-1)
				self.OnClientReady:Fire(self)
			elseif data=="S!" then
				self.udp:send("S!"..(self.servercode or ""))
			elseif data=="L!" then
				local mods=""
				local m=""
				for i=1,#net.loadedModules do
					m=net.loadedModules[i]
					mods=mods..m..":"..net.getModuleVersion(m).."|"
				end
				self.udp:send("L!"..self.cid..mods)
			elseif data=="ping" then
				self.lastPing=os.clock()
				self.OnPingRecieved:Fire(self)
				self.udp:send("pong"..self.cid)
			else
				local hook=data:match("!(.-)!")
				self.OnDataRecieved:getConnection(hook):Fire(self,data)
			end
		end
	end
	function c:reconnect()
		if not nonluaServer then
			self.cid="NIL"
			c.udp:send("I!")
		end
		self.pingEvent:Resume()
		self.OnConnectionRegained:Fire(self)
	end
	c.pingEvent=multi:newEvent(function(self) return self.link:pollPing() end)
	c.pingEvent:OnEvent(function(self)
		if self.link.autoReconnect then
			self.link.OnServerNotAvailable:Fire("Connection to server lost: ping timeout! Attempting to reconnect...")
			self.link.OnClientDisconnected:Fire(self,"closed")
			self.link:reconnect()
		else
			self.link.OnServerNotAvailable:Fire("Connection to server lost: ping timeout!")
			self.link.OnClientDisconnected:Fire(self,"closed")
		end
		self:Pause()
	end):setName("net.pingInTask")
	c.pingEvent.link=c
	c.OnPingRecieved=multi:newConnection()
	c.OnDataRecieved=multi:newConnection()
	c.OnServerNotAvailable=multi:newConnection()
	c.OnClientReady=multi:newConnection()
	c.OnClientDisconnected=multi:newConnection()
	c.OnConnectionRegained=multi:newConnection()
	c.notConnected=multi:newFunction(function(self)
		multi:newAlarm(3):OnRing(function(alarm)
			if self.link:IDAssigned()==false then
				self.link.OnServerNotAvailable:Fire("Can't connect to the server: no response from server")
			end
			alarm:Destroy()
		end):setName("net.clientTimeout")
	end)
	c.notConnected.link=c
	if not nonluaServer then
		c.udp:send("I!")
	end
	table.insert(net.ConnectionDriver,c)
	multi.nextStep(function() c.notConnected() end)
	net.OnClientCreated:Fire(c)
	return c
end
--TCP Stuff
function net:newTCPClientObject(fd)
	local c = {}
	local client
	c.Type="tcp-ClientObj"
	c.rMode="*l"
	c.sMode="*l"
	function c:packMsg(data)
		local temp = bin.new()
		temp:addBlock(#data,self.numspace,"n")
		temp:addBlock(data)
		return temp:getData()
	end
	function c:enableBinaryMode()
		self.rMode = "b"
		self.sMode = "b"
	end
	if fd then
		client=socket.tcp()
		client:setfd(fd)
		_,port = client:getsockname()
		c.handle = client
	else
		error("You need to enter a fd in order to be able to create a tcp client object like this!")
	end
	function c:setUpdateRate(n)
		self.updaterRate=n
	end
	function c:setReceiveMode(mode)
		self.rMode=mode
	end
	function c:setSendMode(mode)
		self.rMode=mode
	end
	function c:send(data)
		if self.autoNormalization then
			data=net.normalize(data)
		end
		if self.sMode=="*l" then
			self.handle:send(data.."\n")
		elseif self.sMode=="b" then
			self.handle:send(self:packMsg(data))
		else
			self.handle:send(data)
		end
	end
	multi:newThread("ServerClientHandler",function()
		while true do
			thread.skip(1)
			local data, err, dat, len
			if self.rMode == "b" then
				thread.hold(function()
					dat = client:receive(self.numspace)
					return dat
				end)
				len = bin.new(dat):getBlock("n",self.numspace)
				data, err = client:receive(len)
			else
				data, err = client:receive(self.rMode)
			end
			if err=="closed" then
				for i=1,#self.ips do
					if self.ips[i]==client then
						table.remove(self.ips,i)
					end
				end
				self.OnClientClosed:Fire(self,"Client Closed Connection!",client,client,ip)
				self.links[client]=nil -- lets clean up
				self:Destroy()
			end
			if data then
				if self.autoNormalization then
					data=net.denormalize(data)
				end
				if net.inList(self.bannedIPs,ip) then
					print("We will ingore data from a banned client!")
					return
				end
				local hook=data:match("!(.-)!")
				self.OnDataRecieved:getConnection(hook):Fire(self,data,client,client,ip,self)
				if data:sub(1,2)=="L!" then
					cList=data
					local list={}
					for m,v in cList:gmatch("(%S-):(%S-)|") do
						list[m]=v
					end
					self.OnClientsModulesList:Fire(list,client,client,ip)
				end
			end
		end
	end)
	c.OnClientsModulesList=multi:newConnection()
	c.OnDataRecieved=multi:newConnection()
	c.OnClientClosed=multi:newConnection()
	c.OnClientConnected=multi:newConnection()
	return c
end
function net:newTCPServer(port)
	local c={}
	local port = port or 0
	c.tcp=assert(socket.bind("*", port))
	c.tcp:settimeout(0)
	c.ip,c.port=c.tcp:getsockname()
	c.ips={}
	if port == 0 then
		_, c.port = c.tcp:getsockname()
	end
	c.ids={}
	c.bannedIPs={}
	c.Type="tcp"
	c.rMode="*l"
	c.sMode="*l"
	c.updaterRate=1
	c.autoNormalization=false
	c.updates={}
	c.links={}
	c.numspace = 4
	c.broad=socket.udp()
	c.hostip=net.getLocalIP()
	function c:packMsg(data)
		local temp = bin.new()
		temp:addBlock(#data,self.numspace,"n")
		temp:addBlock(data)
		return temp:getData()
	end
	function c:enableBinaryMode()
		self.rMode = "b"
		self.sMode = "b"
	end
	function c:broadcast(name)
		table.insert(net.BroadcastDriver,function(loop,dt)
			self.broad:setoption('broadcast',true)
			self.broad:sendto(name.."|"..self.Type.."|"..self.hostip..":"..self.port, "255.255.255.255", 11111)
			self.broad:setoption('broadcast',false)
		end)
	end
	function c:setUpdateRate(n)
		self.updaterRate=n
	end
	function c:setReceiveMode(mode)
		self.rMode=mode
	end
	function c:setSendMode(mode)
		self.rMode=mode
	end
	function c:banCID(cid)
		print("Function not supported on a tcp server!")
	end
	function c:banIP(ip)
		table.insert(self.bannedIPs,cid)
	end
	function c:send(handle,data)
		if self.autoNormalization then
			data=net.normalize(data)
		end
		if self.sMode=="*l" then
			handle:send(data.."\n")
		elseif self.sMode=="b" then
			handle:send(self:packMsg(data))
		else
			handle:send(data)
		end
	end
	function c:sendAllData(handle,data)
		if self.autoNormalization then
			data=net.normalize(data)
		end
		handle:send(data)
	end
	function c:pollClientModules(ip,port)
		self:send(ip,"L!",port)
	end
	function c:CIDFrom(ip,port)
		print("Method not supported when using a TCP Server!")
		return "CIDs in TCP work differently!"
	end
	function c:sendAll(data)
		for i,v in pairs(self.ips) do
			self:send(v,data)
		end
	end
	function c:sendAllBut(data,cid)
		for i,v in pairs(self.ips) do
			if not(cid==i) then
				self:send(v,data)
			end
		end
	end
	function c:clientRegistered(cid)
		return self.ips[cid]
	end
	function c:clientLoggedIn(cid)
		return self.ips[cid]
	end
	function c:getUpdater(cid)
		return self.updates[cid]
	end
	function c:update()
		local client = self.tcp:accept(self.rMode)
		if not client then return end
		table.insert(self.ips,client)
		client:settimeout(0)
		--client:setoption('tcp-nodelay', true)
		client:setoption('keepalive', true)
		ip,port=client:getpeername()
		if ip and port then
			print("Got connection from: ",ip,port)
			-- local updater=multi:newUpdater(skip):setName("net.tcpClientObj")
			-- self.updates[client]=updater
			self.OnClientConnected:Fire(self,client,client,ip)
			--updater:OnUpdate(function(self)
			multi:newThread("ServerClientHandler",function()
				while true do
					thread.skip(1)
					local data, err, dat, len
					if self.rMode == "b" then
						thread.hold(function()
							dat = client:receive(self.numspace)
							return dat
						end)
						len = bin.new(dat):getBlock("n",self.numspace)
						data, err = client:receive(len)
					else
						data, err = client:receive(self.rMode)
					end
					if err=="closed" then
						for i=1,#self.ips do
							if self.ips[i]==client then
								table.remove(self.ips,i)
							end
						end
						self.OnClientClosed:Fire(self,"Client Closed Connection!",client,client,ip)
						self.links[client]=nil -- lets clean up
						self:Destroy()
						thread.kill()
					end
					if data then
						if self.autoNormalization then
							data=net.denormalize(data)
						end
						if net.inList(self.bannedIPs,ip) then
							print("We will ingore data from a banned client!")
							return
						end
						local hook=data:match("!(.-)!")
						self.OnDataRecieved:getConnection(hook):Fire(self,data,client,client,ip,self)
						if data:sub(1,2)=="L!" then
							cList=data
							local list={}
							for m,v in cList:gmatch("(%S-):(%S-)|") do
								list[m]=v
							end
							self.OnClientsModulesList:Fire(list,client,client,ip)
						end
					end
				end
			end)
			-- updater:SetSkip(self.updaterRate)
			-- updater.client=client
			-- updater.Link=self
			-- function updater:setReceiveMode(mode)
				-- self.rMode=mode
			-- end
			-- self.links[client]=updater
		end
	end
	c.OnClientsModulesList=multi:newConnection()
	c.OnDataRecieved=multi:newConnection()
	c.OnClientClosed=multi:newConnection()
	c.OnClientConnected=multi:newConnection()
	table.insert(net.ConnectionDriver,c)
	net.OnServerCreated:Fire(c)
	return c
end
function net:newTCPClient(host,port)
	local c={}
	c.ip=assert(socket.dns.toip(host))
	c.tcp=socket.connect(c.ip,port)
	if not c.tcp then
		print("Can't connect to the server: no response from server")
		return false
	end
	c.tcp:settimeout(0)
	--c.tcp:setoption('tcp-nodelay', true)
	c.tcp:setoption('keepalive', true)
	c.Type="tcp"
	c.autoReconnect=true
	c.rMode="*l"
	c.sMode="*l"
	c.autoNormalization=false
	c.numspace = 4
	function c:enableBinaryMode()
		self.rMode = "b"
		self.sMode = "b"
	end
	function c:setReceiveMode(mode)
		self.rMode=mode
	end
	function c:setSendMode(mode)
		self.sMode=mode
	end
	function c:packMsg(data)
		local temp = bin.new()
		temp:addBlock(#data,self.numspace)
		temp:addBlock(data)
		return temp:getData()
	end
	function c:send(data)
		if self.autoNormalization then
			data=net.normalize(data)
		end
		if self.sMode=="*l" then
			ind,err=self.tcp:send(data.."\n")
		elseif self.sMode=="b" then
			ind,err=self.tcp:send(self:packMsg(data))
		else
			ind,err=self.tcp:send(data)
		end
		if err=="closed" then
			self.OnClientDisconnected:Fire(self,err)
		elseif err=="timeout" then
			self.OnClientDisconnected:Fire(self,err)
		elseif err then
			print(err)
		end
	end
	function c:sendRaw(data)
		if self.autoNormalization then
			data=net.normalize(data)
		end
		self.tcp:send(data)
	end
	function c:getCID()
		return "No Cid on a tcp client!"
	end
	function c:close()
		self.tcp:close()
	end
	function c:IDAssigned()
		return true
	end
	function c:update()
		if not self.tcp then return end
		local data,err,dat
		if self.rMode == "b" then
			thread.hold(function()
				dat = self.tcp:receive(self.numspace)
				return dat
			end)
			len = bin.new(dat):getBlock("n",self.numspace)
			data, err = self.tcp:receive(len)
		else
			data, err = self.tcp:receive()
		end
		if err=="closed" then
			self.OnClientDisconnected:Fire(self,err)
		elseif err=="timeout" then
			self.OnClientDisconnected:Fire(self,err)
		elseif err then
			print(err)
		end
		if data then
			if self.autoNormalization then
				data=net.denormalize(data)
			end
			local hook=data:match("!(.-)!")
			self.OnDataRecieved:getConnection(hook):Fire(self,data)
		end
	end
	function c:reconnect()
		multi:newFunction(function(func)
			self.tcp=socket.connect(self.ip,self.port)
			if self.tcp==nil then
				print("Can't connect to the server: No response from server!")
				multi:newAlarm(3):OnRing(function(alarm)
					self:reconnect()
					alarm:Destroy()
					return
				end):setName("net.timeoutTask")
			end
			self.OnConnectionRegained:Fire(self)
			self.tcp:settimeout(0)
			--self.tcp:setoption('tcp-nodelay', true)
			self.tcp:setoption('keepalive', true)
		end)
	end
	c.event=multi:newEvent(function(event)
		return event.link:IDAssigned()
	end):OnEvent(function(event)
		event.link.OnClientReady:Fire(event.link)
		event:Destroy()
	end)
	c.event:setName("net.handshakeTask")
	c.event.link=c
	c.OnClientReady=multi:newConnection()
	c.OnClientDisconnected=multi:newConnection()
	c.OnDataRecieved=multi:newConnection()
	c.OnConnectionRegained=multi:newConnection()
	table.insert(net.ConnectionDriver,c)
	net.OnClientCreated:Fire(c)
	return c
end
net.timer = multi:newTimer():Start()
multi:newThread("ClientServerHandler",function()
	while true do
		thread.skip()
		for i=1,#net.ConnectionDriver do
			thread.skip()
			net.ConnectionDriver[i]:update()
		end
		if net.timer:Get()>=1 then
			for i=1,#net.BroadcastDriver do
				net.BroadcastDriver[i]()
			end
			net.timer:Reset()
		end
	end
end)
return net
