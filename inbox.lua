require("net.identity")
net:registerModule("inbox",{1,0,0})
--self.OnUserLoggedIn:Fire(user,cid,ip,port,bin.ToStr(handle))
--allows the storing of messages that the user can recieve and view whenever. Allows user to also send messeges to users that are even offline!
--requires an account setup and nick name to be set at account creation
net.OnServerCreated:connect(function(s)
	s.OnDataRecieved(function(self,data,CID_OR_HANDLE,IP_OR_HANDLE,PORT_OR_IP)
		if self:userLoggedIn(cid) then -- If the user is logged in we do the tests
			--
		else
			return
		end
	end,"inbox")
end)
net.OnClientCreated:connect(function(c)
	c.OnDataRecieved(function(self,data)
		--
	end,"inbox")
end)
