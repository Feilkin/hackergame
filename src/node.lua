---- (c) Feilkin 2017
-- pseudoclass for Nodes

local utils = require "utils"

local node = {}
local node_mt = {
	__index = node,
	__tostring = node.tostring,
}

function node.new()
	return setmetatable({
		name = "undefined",
		type = "undefined",
		uuid = utis.uuid()
		}, node_mt)
end

--- Returns a new random node
function node.generate()
	local new = node.new()
	new.type = utils.choose({
		"pc", "laptop", "phone", "coffeepot"
		})
end

function node.tostring(n)
	return string.format("%s-%s[%s]", node.type, node.name, node.uuid)
end

return node