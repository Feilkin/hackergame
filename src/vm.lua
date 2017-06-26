-- the "virtual machine" that simulates the nodes

local vm = {}

local _Thread = {
	
}

function vm:wrapThread(script)
	local chunk = loadstring(script, self.env.__name)
	setfenv(chunk, self.env)

	return function()
		local success, res = xpcall(chunk, self.errorHandler)

		return res
	end
end

function vm:newThread(script)
	local wrapped = self:wrapThread(script)
	local routine = coroutine.create(wrapped)

	local t = {
		state = "stopped", -- stopped, running, idle, finished
		script = script,   -- script as string
		routine = routine, -- baked coroutine
		wants = {},        -- interface?
	}

	return setmetatable(t, { __index = _Thread })
end

function vm.errorHandler(...)
	print(...)
end

function vm.init(env)
	local t = {
		env = env or {},
		pool = {},
		threads = {},
	}
	return setmetatable(t, { __index = vm })
end

function vm:runScript(script)
	local thread = self:newThread(script)
	table.insert(self.pool, thread)
end

function vm:update(dt)
	for i = #self.pool, 1, -1 do
		local thread = self.pool[i]

		if thread.state == "finished" then
			table.remove(self.pool, i)
		elseif thread.state == "idle" then
			if thread.wants.sleep then
				thread.wants.sleep = thread.wants.sleep - dt
				if thread.wants.sleep <= 0 then
					thread.state = "running"
				end
			end
		else
			thread.wants = {}
			local success, res = coroutine.resume(thread.routine)

			if not success then
				self.errorHandler(res)
				thread.state = "finished"
			else
				if type(res) == "table" then
					-- the thread probably wants something from us

					if res.sleep then
						thread.wants.sleep = res.sleep
						thread.state = "idle"
					end
				end
			end
		end
	end
end


return vm