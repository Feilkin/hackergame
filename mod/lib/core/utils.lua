local utils = {}

function utils.sleep(s)
	coroutine.yield({ sleep = 1 })
end

return utils