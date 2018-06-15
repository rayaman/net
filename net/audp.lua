require("net")
function net:newUDPServer(port,servercode)
	local c={}
	c.hostip=net.getLocalIP()
	c.port=port
	c.bannedCIDs={}
	c.bannedIPs={}
	function c:setUpdateRate(n)
		self.updater:setSkip(n or 0)
	end
	function c:banCID(cid)
		--
	end
	function c:banIP(ip)
		--
	end
	function c:broadcast(name)
		--
	end
	function c:send(ip,data,port,cid)
		--
	end
	function c:pollClientModules(ip,port)
		--
	end
	function c:CIDFrom(ip,port)
		--
	end
	function c:sendAll(data)
		--
	end
	function c:sendAllBut(data,cid)
		--
	end
	function c:clientRegistered(cid)
		--
	end
	function c:clientLoggedIn(cid)
		--
	end
	function c:update()
		--
	end
	c.Updater=multi:newUpdater(0)
	c.Updater.link=c
	c.updater:OnUpdate(function(self)
		self.link:update()
	end)
	c.OnClientsModulesList=multi:newConnection(false)
	c.OnDataRecieved=multi:newConnection(false)
	c.OnClientClosed=multi:newConnection(false)
	c.OnClientConnected=multi:newConnection(false)
end
function net:newUDPClient(host,port,servercode)
	local c={}
	c.host=host
	c.port=port
	function c:setUpdateRate(n)
		self.updater:setSkip(n or 0)
	end
	function c:send(data)
		--
	end
	function c:sendRaw(data)
		--
	end
	function c:close()
		--
	end
	function c:getCID()
		--
	end
	function c:update()
		--
	end
	function c:reconnect()
		--
	end
	function c:IDAssigned()
		--
	end
	c.Updater=multi:newUpdater(0)
	c.Updater.link=c
	c.updater:OnUpdate(function(self)
		self.link:update()
	end)
	c.OnDataRecieved=multi:newConnection(false)
	c.OnClientReady=multi:newConnection(false)
	c.OnClientDisconnected=multi:newConnection(false)
	c.OnConnectionRegained=multi:newConnection(false)
	c.OnPingRecieved=multi:newConnection(false)
	c.OnServerNotAvailable=multi:newConnection(false)
end
