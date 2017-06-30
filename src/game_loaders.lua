local utils = require "utils"
local templar = require "templar"

local worldmap = require "worldmap"

local scriptFolder = "mod/scripts"
local nodeFolder   = "mod/nodes"

return function(game)
	function game:loadScripts()
		local scripts = {}
		local files = utils.recursiveFind("%.lua$", scriptFolder)
		table.sort(files)

		for i, file in ipairs(files) do
			local name = file:match(".*/([^/]+%.lua)$")
			local contents, size = love.filesystem.read(file)

			print(name, file)

			table.insert(scripts, { name = name, script = contents })
		end

		self.scripts = scripts
	end

	function game:loadNodes()
		local nodeGenerators = {}
		local files = utils.recursiveFind("%.lua$", nodeFolder)
		-- table.sort(files)

		-- TODO: move to a different file
		templar.registerGenerator("devicename", function ()
			return function ()
				-- TODO: compile a list of common names (first + last),
				--       and use that list to generate the names

				return string.format("node%04d", love.math.random(1, 9999))
			end
		end)
		templar.registerGenerator("uuid", function ()
			return function () return utils.uuid() end
		end)
		templar.registerGenerator("pointOnLand", function ()
			return function () 
				local x, y = worldmap.randomPoint()
				return { x = x, y = y }
			end
		end)

		for i, file in ipairs(files) do
			local name = file:match(".*/([^/]+)%.lua$")
			local chunk = assert(love.filesystem.load(file))

			print(name, file)

			local generator = templar.generator(chunk)
			nodeGenerators[name] = generator
		end

		self.nodeGenerators = nodeGenerators
	end
end