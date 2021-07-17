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
	for k, v in pairs(t2) do
		if type(v) == "table" then
			if type(t1[k] or false) == "table" then
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
	local from = s:match "^%s*()"
	return from > #s and "" or s:match(".*%S", from)
end
local guid = {}
local char = {}
for i = 48, 57 do
	char[#char + 1] = string.char(i)
end
for i = 65, 90 do
	char[#char + 1] = string.char(i)
end
for i = 97, 122 do
	char[#char + 1] = string.char(i)
end

math.random()
math.random()
math.random()
local multi, thread = require("multi").init()
local socket = require("socket")
local http = require("socket.http")
--ssl=require("ssl")
--https=require("ssl.https")
local net = {}
net.Version = {5, 0, 0} -- This will probably stay this version for quite a while... The modules on the otherhand will change more often
net._VERSION = "5.0.0"
net.ClientCache = {}
net.OnServerCreated = multi:newConnection()
net.OnClientCreated = multi:newConnection()
net.loadedModules = {}
net.OnCastedClientInfo = multi:newConnection()
net.autoInit = true
net.ConnectionDriver = {}
net.BroadcastDriver = {}
math.randomseed(math.ceil(os.time()+(os.clock()*1000)))
local isHyphen = {[9] = 1, [14] = 1, [19] = 1, [24] = 1}
net.generateGUID = function(t)
	local pass = {}
	local a = 0
	local x = ""
	for i in string.format("%x",os.time()+math.ceil(os.time()+os.clock()*1000)):gmatch(".") do
		table.insert(pass,i)
	end
	for z = 9, 36 do
		if isHyphen[z] then
			x = "-"
		else
			a = math.random(1, #char)
			x = char[a]
		end
		table.insert(pass, x)
		if t == z then
			break
		end
	end
	z = nil
	return tostring(table.concat(pass))
end
function net.normalize(input)
	local enc = mime.b64(input)
	return enc
end
function net.denormalize(input)
	local unenc = mime.unb64(input)
	return unenc
end
function net.getLocalIP()
	local someRandomIP = "192.168.1.122"
	local someRandomPort = "3102"
	local mySocket = socket.udp()
	mySocket:setpeername(someRandomIP, someRandomPort)
	local dat = (mySocket:getsockname())
	mySocket:close()
	return dat
end
function net.getExternalIP()
	local data = http.request("http://www.myipnumber.com/my-ip-address.asp")
	return data:match("(%d+%.%d+%.%d+%.%d+)")
end
function net.registerModule(mod, version)
	if net[mod] then
		error("Module by the name: " .. mod .. " has already been registered! Remember some modules are internal and use certain names!")
	end
	table.insert(net.loadedModules, mod)
	net[mod] = {}
	if version then
		net[mod].Version = version
		net[mod]._VERSION = table.concat(version,".")
	else
		net[mod].Version = {1, 0, 0}
		net[mod]._VERSION = {1, 0, 0}
	end
	return {Version = version, _VERSION = table.concat(version,".")}
end
function net.getModuleVersion(ext)
	if not ext then
		return string.format("%d.%d.%d", net.Version[1], net.Version[2], net.Version[3])
	end
	return string.format("%d.%d.%d", net[ext].Version[1], net[ext].Version[2], net[ext].Version[3])
end
function net.resolveID(obj)
	local num = math.random(10000000, 99999999)
	if obj[tostring(num)] then
		return net.resolveID(obj)
	end
	obj.ids[tostring(num)] = true
	return tostring(num)
end
function net.inList(list, dat)
	for i, v in pairs(list) do
		if v == dat then
			return true
		end
	end
	return false
end
function net.setTrigger(funcW, funcE)
	multi:newTrigger(func)
end
net.registerModule("net", net.Version)
-- Client broadcast
function net.newCastedClient(name) -- connects to the broadcasted server
	local listen = socket.udp() -- make a new socket
	listen:setsockname(net.getLocalIP(), 11111)
	listen:settimeout(0)
	local timer = multi:newTimer()
	while true do
		local data, ip, port = listen:receivefrom()
		if timer:Get() > 3 then
			error("Timeout! Server by the name: " .. name .. " has not been found!")
		end
		if data then
			local n, tp, ip, port = data:match("(%S-)|(%S-)|(%S-):(%d+)")
			if n:match(name) then
				if tp == "tcp" then
					return net.newTCPClient(ip, tonumber(port))
				else
					return net.newClient(ip, tonumber(port))
				end
			end
		end
	end
end
function net.newCastedClients(name) -- connects to the broadcasted server
	local listen = socket.udp() -- make a new socket
	listen:setsockname(net.getLocalIP(), 11111)
	listen:settimeout(0)
	multi:newThread("net.castedTask",function()
		while true do
			thread.skip(24)
			local data, ip, port = listen:receivefrom()
			if data then
				local n, tp, ip, port = data:match("(%S-)|(%S-)|(%S-):(%d+)")
				if n:match(name) and not net.ClientCache[n] then
					local capture = n:match(name)
					local client = {}
					if tp == "tcp" then
						client = net:newTCPClient(ip, tonumber(port))
					else
						client = net:newUDPClient(ip, tonumber(port))
					end
					net.ClientCache[n] = client
					net.OnCastedClientInfo:Fire(client, n, ip, port)
				end
			end
		end
	end)
end
return net
