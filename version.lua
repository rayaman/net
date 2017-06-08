net:registerModule("version",{1,0,0}) -- allows communication of versions for modules
net.OnServerCreated:connect(function(s)
	s.OnDataRecieved(function(self,data,CID_OR_HANDLE,IP_OR_HANDLE,PORT_OR_IP)
		--
	end,"version")
	s.OnClientConnected(function(self,CID_OR_HANDLE,IP_OR_HANDLE,PORT_OR_IP)
		s:pollClientModules(IP_OR_HANDLE,PORT_OR_IP)
	end)
	s.OnClientsModulesList(function(list,CID_OR_HANDLE,IP_OR_HANDLE,PORT_OR_IP)
		--
	end)
end)
net.OnClientCreated:connect(function(c)
	c.OnDataRecieved(function(self,data)
		--
	end,"version")
end)
