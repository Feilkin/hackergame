---- (c) Feilkin 2017
-- Loads and renders the world map
-- Singleton for now

local lovesvg = require "lovesvg"

local utils = require "utils"

local map = {
	regions = {},
}

-- helper function used for pre-rendering the world map
local recursive_render
do
	local render_options = { depth = 4, discrad_distance = 0.001 }
	local minx, miny, maxx, maxy = math.huge,math.huge, 0,0

	recursive_render = function (obj)
		if obj.renderer then
			obj.renderer:render(render_options)
			map.regions[#map.regions + 1] = obj

			if obj.attributes.id then
				map.regions[obj.attributes.id] = obj
			end

			if obj.renderer.AABB then
				if obj.renderer.AABB[1] < minx then minx = obj.renderer.AABB[1] end
				if obj.renderer.AABB[2] < miny then miny = obj.renderer.AABB[2] end
				if obj.renderer.AABB[3] > maxx then maxx = obj.renderer.AABB[3] end
				if obj.renderer.AABB[4] > maxy then maxy = obj.renderer.AABB[4] end
			end
		end

		if obj.children then
			for i, child in ipairs(obj.children) do
				recursive_render(child)
			end
		end

		return { minx, miny, maxx, maxy }
	end
end

function map.init()
	local contents, size = love.filesystem.read("res/worldmap.svg")
	local parsed = lovesvg.parseSVG(contents)

	local AABB = recursive_render(parsed) -- renders the worldmap,
	                                      -- saves each region to map.regions,
	                                      -- and calculates AABB for the world

	map.AABB = AABB
end


--- Returns a random point on land
function map.randomPoint()
	local region = utils.choose(map.regions)
	local triangle = utils.choose(region.renderer.triangles)

	return (triangle[1] + triangle[3] + triangle[5]) / 3,
	       (triangle[2] + triangle[4] + triangle[6]) / 3
end

function map.update(dt)

end

function map.draw()
	-- only draw the regions in map.regions
	for i, region in ipairs(map.regions) do
		region:draw()
	end
end

return map