require("net")
net:registerModule("eft",{1,0,0})
--[[
	This module makes use of the new threading features of the multi library!
	This means we can use threading to imporve our speed!
	This module will mirror the aft module so if we are unable to create systemThreads
	We will fall back to aft!
]]
if multi:canSystemThread() then -- can we spawn system threads?
	-- How do we set up the threading stuff?
	-- On the server side we will use lanes, clients may vary though... It could be a lanes or love2d intergration, or some other intergration...
	local __GLOBAL=multi.intergration.GLOBAL
	local __THREAD=multi.intergration.THREAD
	multi:newSystemThread("eftThread",function()
		require("multi.all")
		if multi:getPlatform()=="love2d" then
			__GLOBAL=_G.GLOBAL
			__THREAD=_G.sThread
		end -- we cannot have upvalues... in love2d globals not locals must be used
		print("Testing...",__THREAD.waitFor("Test1"))
	end)
	net.OnServerCreated:connect(function(s)
		print("The eft(Expert File Transfer) Module has been loaded onto the server!")
		if s.Type~="tcp" then
			print("It is recomended that you use tcp to transfer files!")
		end
		s.OnDataRecieved(function(self,data,CID_OR_HANDLE,IP_OR_HANDLE,PORT_OR_IP)
			--
		end,"eft")
		--
	end)
	net.OnClientCreated:connect(function(c)
		c.OnDataRecieved(function(self,data)
			--
		end,"eft")
		--
	end)
else
	print("Unable to system thread! Check Your intergrations with the multi library! Falling back to aft!")
	require("net.aft") -- fallback
end
