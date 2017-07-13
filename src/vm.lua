-- the "virtual machine" that simulates the nodes
-- saved for future references

local vm = {}

local _Thread = {
	
}

function vm:wrapThread(node)
	local env = self:createEnv(node)
	local chunk = loadstring(node.script, node.name .. "-script")
	setfenv(chunk, env)

	return function()
		local success, res = xpcall(chunk, self.errorHandler)

		return res
	end
end

function vm:newThread(node)
	local wrapped = self:wrapThread(node)
	local routine = coroutine.create(wrapped)

	local t = {
		state = "stopped", -- stopped, running, idle, finished
		script = script,   -- script as string
		routine = routine, -- baked coroutine
		wants = {},        -- interface?
		node = node,
	}

	return setmetatable(t, { __index = _Thread })
end

function vm:createEnv(node)
	local env = {
		node = node
	}
	env.print = function (...)
		table.insert(self.game.gui.log, {...})
	end

	for k, v in pairs(require "mod.lib.core.utils") do
		env[k] = v
	end
end

function vm.init(game)
	local t = {
		game = game,
		pool = {},
		threads = {},
	}

	function vm.errorHandler(...)
		table.insert(game.gui.log, {...})
	end
	return setmetatable(t, { __index = vm })
end

function vm:runScript(node)
	if not node.script then return end

	local thread = self:newThread(node)
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

-- networking
vm.net = {
	networks = { -- keep track of all the networks
		{
			name = "internet",
			netmask = "0.0.0.0",
		}
	}
}

function vm.net.aton(str)
	local a, b, c, d = str:match("^(%d+)%.(%d+)%.(%d+)%.(%d+)$")
	a, b, c, d = tonumber(a), tonumber(b), tonumber(c), tonumber(d)

	return { a, b, c, d }
end

function vm.net.ntoa(tbl)
	return string.format("%d.%d.%d.%d", tbl[1], tbl[2], tbl[3], tbl[4])
end

return vm