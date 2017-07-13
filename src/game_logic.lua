local tiny = require "tiny"

return function(game)


	function game:createEnv(node)
		local env = {
			node = node
		}
		env.print = function (...)
			table.insert(self.gui.log, {...})
		end

		for k, v in pairs(require "mod.lib.core.utils") do
			env[k] = v
		end
	end

	function game:wrapThread(node)
		local env = self:createEnv(node)
		local chunk = loadstring(node.script, node.name .. "-script")
		setfenv(chunk, env)

		return function()
			local success, res = xpcall(chunk, self.errorHandler)

			return res
		end
	end

	function game:newThread(node)
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

	function game:runScript(node)
		if not node.script then return end

		node.thread = self:newThread(node)
	end

	function game.errorHandler(...)
		table.insert(game.gui.log, {...})
	end


	--- Handles script states and stuff
	function game:scriptingSystem()
		local system = tiny.processingSystem()
		system.filter = tiny.requireAll("scriptable", "thread")

		function system:update(e, dt)
			-- just store the 'thread' in the node, I don't care
			local thread = e.thread

			if thread.state == "finished" then
				-- do nothing?
			elseif thread.state == "idle" then
				-- process wants
				-- TODO: need a better way to do this, or this function gets _big_
				if thread.wants.sleep then
					thread.wants.sleep = thread.wants.sleep - dt
					if thread.wants.sleep <= 0 then
						thread.wants.sleep = nil
					end
				end

				if thread.wants == {} then
					thread.state = "running"
				end
			else
				thread.wants = {}
				local success, res = coroutine.resume(thread.routine)

				if not success then
					thread.state = "finished"
				else
					if type(res) == "table" then
						if res.sleep then
							thread.wants.sleep = res.sleep
						end
					end
				end
			end
		end
	end

	function game:networkSystem()

	end

	function game:setupSystems()
		local world = tiny.world(
			self:scriptingSystem(),
			self:networkSystem()
			)

		self.world = world
	end

	function game:updateSystems()

	end
end