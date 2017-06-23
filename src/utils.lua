-- some commonly used helper functions

local utils = {}

function utils.filter(t, f)
	local o = {}

	for k, v in pairs(t) do
		if f(v, k) then o[k] = v end
	end

	return o
end

function utils.ifilter(t, f)
	local o = {}

	for k, v in ipairs(t) do
		if f(v, k) then o[k] = v end
	end

	return o
end


-- TODO: move these to utils.lua or something
function utils.iextend (a, b)
	if (not b) or #b == 0 then return a end

	for i, v in ipairs(b) do
		a[#a + 1] = v
	end

	return a
end

function utils.recursiveFind (pattern, dir)
	local items = love.filesystem.getDirectoryItems(dir)
	local out = {}

	for i, v in ipairs(items) do
		local file = dir .. '/' .. v

		print(file)

		if love.filesystem.isFile(file) and file:match(pattern) then
			table.insert(out, file)
		elseif love.filesystem.isDirectory(file) then
			utils.extend(out, recursiveFind(pattern, file))
		end
	end

	return out
end


return utils