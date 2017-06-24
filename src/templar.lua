-- templating language for random lua tables

local random = love and love.math.random or math.random

local templar = {}

local generators = {
	extend = function (...)
		local a = {...}
		return function ()
			local o = {}
			for i, b in ipairs(a) do
				if type(b) == "function" then b = b() end

				for i, v in ipairs(b) do
					o[#o + 1] = templar.handle(v)
				end
			end
			return o
		end
	end,

	range = function(low, high, step)
		step = step or 1
		return function()
			return random(low / step, high / step) * step end
		end,

	amount = function(low, high, item)
		return function ()
			local old_index = templar.generators.index
			local j = random(low, high)
			local o = {}

			for i = 1, j do
				templar.generators.index = function() return i - 1 end
				o[#o + 1] = templar.handle(item())
			end

			templar.generators.index = old_index
			return o
		end
	end,

	choice = function (...)
		local a = {...}
		if (#a == 1) and (type(a[1]) == "table") then a = a[1] end

		return function () return a[random(#a)] end
	end,

	raw = function (...)
		local a = ...
		return function () return a end
	end,

	index = function () return 0 end
}

templar.generators = generators

function templar.registerGenerator(identifier, func)
	templar.generators[identifier] = func
end

function templar.handle(t)
	local _type = type(t)

	if _type == "table" then
		local o = {}

		for k, v in pairs(t) do
			o[k] = templar.handle(v)
		end

		return o
	elseif _type == "function" then
		return t()
	else
		return t
	end
end

function templar.generator(t)
	local handled = templar.handle(t)

	local i = 0
	return function ()
		i = i + 1

		local old_index = templar.generators.index
		templar.generators.index = function() return i end
		local handled = templar.handle(handled)
		templar.generators.index = old_index

		return templar.handle(handled)
	end
end

do
	local env = getfenv(f)
	local old_meta = getmetatable(env) or {}
	local old_index = old_meta.__index or {}

	if type(old_index) == "table" then
		local o = old_index
		old_index = function (t, k) return o[k] end
	end 

	local templar_meta = { __index = function(t, k)
			local o = templar.generators[k] or old_index(t, k)
			return o
		end,
	}
	setmetatable(env, templar_meta)
end

return templar