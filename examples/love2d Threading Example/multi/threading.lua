--[[
MIT License

Copyright (c) 2017 Ryan Ward

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]
require("multi")
thread={}
multi.GlobalVariables={}
if os.getOS()=="windows" then
	thread.__CORES=tonumber(os.getenv("NUMBER_OF_PROCESSORS"))
else
	thread.__CORES=tonumber(io.popen("nproc --all"):read("*n"))
end
function thread.sleep(n)
	coroutine.yield({"_sleep_",n})
end
function thread.hold(n)
	coroutine.yield({"_hold_",n})
end
function thread.skip(n)
	coroutine.yield({"_skip_",n})
end
function thread.kill()
	coroutine.yield({"_kill_",":)"})
end
function thread.yeild()
	coroutine.yield({"_sleep_",0})
end
function thread.getCores()
	return thread.__CORES
end
function thread.set(name,val)
	multi.GlobalVariables[name]=val
	return true
end
function thread.get(name)
	return multi.GlobalVariables[name]
end
function thread.waitFor(name)
	thread.hold(function() return thread.get(name)~=nil end)
	return thread.get(name)
end
function thread.testFor(name,val,sym)
	thread.hold(function() return thread.get(name)~=nil end)
	return thread.get(name)
end
function multi:newTBase(ins)
	local c = {}
	c.Active=true
	c.func={}
	c.ender={}
	c.Id=0
	c.PId=0
	c.Parent=self
	c.held=false
	return c
end
function multi:newThread(name,func)
	local c={}
	c.ref={}
	c.Name=name
	c.thread=coroutine.create(func)
	c.sleep=1
	c.firstRunDone=false
	c.timer=multi.scheduler:newTimer()
	c.ref.Globals=self:linkDomain("Globals")
	function c.ref:send(name,val)
		ret=coroutine.yield({Name=name,Value=val})
		self:syncGlobals(ret)
	end
	function c.ref:get(name)
		return self.Globals[name]
	end
	function c.ref:kill()
		err=coroutine.yield({"_kill_"})
		if err then
			error("Failed to kill a thread! Exiting...")
		end
	end
	function c.ref:sleep(n)
		if type(n)=="function" then
			ret=coroutine.yield({"_hold_",n})
			self:syncGlobals(ret)
		elseif type(n)=="number" then
			n = tonumber(n) or 0
			ret=coroutine.yield({"_sleep_",n})
			self:syncGlobals(ret)
		else
			error("Invalid Type for sleep!")
		end
	end
	function c.ref:syncGlobals(v)
		self.Globals=v
	end
	table.insert(self:linkDomain("Threads"),c)
	if not multi.scheduler:isActive() then
		multi.scheduler:Resume()
	end
end
multi:setDomainName("Threads")
multi:setDomainName("Globals")
multi.scheduler=multi:newUpdater()
multi.scheduler.Type="scheduler"
function multi.scheduler:setStep(n)
	self.skip=tonumber(n) or 24
end
multi.scheduler.skip=0
multi.scheduler.counter=0
multi.scheduler.Threads=multi:linkDomain("Threads")
multi.scheduler.Globals=multi:linkDomain("Globals")
multi.scheduler:OnUpdate(function(self)
	self.counter=self.counter+1
	for i=#self.Threads,1,-1 do
		ret={}
		if coroutine.status(self.Threads[i].thread)=="dead" then
			table.remove(self.Threads,i)
		else
			if self.Threads[i].timer:Get()>=self.Threads[i].sleep then
				if self.Threads[i].firstRunDone==false then
					self.Threads[i].firstRunDone=true
					self.Threads[i].timer:Start()
					_,ret=coroutine.resume(self.Threads[i].thread,self.Threads[i].ref)
				else
					_,ret=coroutine.resume(self.Threads[i].thread,self.Globals)
				end
				if ret==true or ret==false then
					print("Thread Ended!!!")
					ret={}
				end
			end
			if ret then
				if ret[1]=="_kill_" then
					table.remove(self.Threads,i)
				elseif ret[1]=="_sleep_" then
					self.Threads[i].timer:Reset()
					self.Threads[i].sleep=ret[2]
				elseif ret[1]=="_skip_" then
					self.Threads[i].timer:Reset()
					self.Threads[i].sleep=math.huge
					local event=multi:newEvent(function(evnt) return multi.scheduler.counter>=evnt.counter end)
					event.link=self.Threads[i]
					event.counter=self.counter+ret[2]
					event:OnEvent(function(evnt)
						evnt.link.sleep=0
					end)
				elseif ret[1]=="_hold_" then
					self.Threads[i].timer:Reset()
					self.Threads[i].sleep=math.huge
					local event=multi:newEvent(ret[2])
					event.link=self.Threads[i]
					event:OnEvent(function(evnt)
						evnt.link.sleep=0
					end)
				elseif ret.Name then
					self.Globals[ret.Name]=ret.Value
				end
			end
		end
	end
end)
multi.scheduler:setStep()
multi.scheduler:Pause()
multi.OnError=multi:newConnection()
