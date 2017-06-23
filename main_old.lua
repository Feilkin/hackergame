--[[
	I'll demo some stuff, see if I can accidentally into game
--]]

local nk = require 'nuklear'
local bitser = require 'bitser'
local lovesvg = require 'lovesvg'

local map = { offset_x = 0, offset_y = 0, zoom = 1,
              has_mouse = false,
              polygons = {},
              countries = {},
              draw = function (self)
              	for i, c in ipairs(self.countries) do
              		if c.renderer.mesh and true then
          				local style = c.attributes.style
              			if style then
              				if style.fill then
              					love.graphics.setColor(style.fill)
              				end
              			end

              			love.graphics.draw(c.renderer.mesh, 0, 0)
              		else
              			love.graphics.setColor(255, 0, 0, 255)
	              		love.graphics.points(c.renderer.polygon)
	              	end
          			love.graphics.setColor(255, 255, 255, 255)
              	end
              end }

local logo

function love.load()
	nk.init()

	-- load the world map SVG

	local contents, size = love.filesystem.read("worldmap.svg")
	local parsed = lovesvg.parseSVG(contents)

	local options = { depth = 4 }
	local function recursive_render(obj)
		if obj.renderer then
			obj.renderer:render(options)
			map.countries[#map.countries + 1] = obj

			if obj.attributes.id then
				map.countries[obj.attributes.id] = obj
			end

			-- quick and dirty
			local style = {}
			local fill_text

			local style_text = obj.attributes.style
			if style_text then
				fill_text = style_text:match("fill:#(%x%x%x%x%x%x)")
			end

			if obj.attributes.fill then
				fill_text = obj.attributes.fill:match("#(%x%x%x%x%x%x)")
			end

			if fill_text then
				local r = tonumber(fill_text:sub(1, 2), 16)
				local g = tonumber(fill_text:sub(3, 4), 16)
				local b = tonumber(fill_text:sub(5, 6), 16)
				style.fill = { r, g, b }
			end
			obj.attributes.style = style
		end

		if obj.children then
			for i, child in ipairs(obj.children) do
				recursive_render(child)
			end
		end
	end

	recursive_render(parsed)
	print("countries: " .. #map.countries)

	love.graphics.setLineWidth(0.5)
end

local combo = {value = 1, items = {'A', 'B', 'C'}}

function love.update(dt)
	nk.frameBegin()
	if nk.windowBegin('Simple Example', 100, 100, 200, 160,
			'border', 'title', 'movable') then
		nk.layoutRow('dynamic', 30, 1)
		nk.label(string.format("FPS: %d", love.timer.getFPS()))
	end
	nk.windowEnd()
	nk.frameEnd()
end

function love.draw()

	do
		love.graphics.push()
		love.graphics.translate(map.offset_x, map.offset_y)
		love.graphics.scale(map.zoom, map.zoom)
		map:draw()
		love.graphics.pop()
	end

	do

	end

	nk.draw()
end

function love.keypressed(key, scancode, isrepeat)
	nk.keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
	nk.keyreleased(key, scancode)
end

function love.mousepressed(x, y, button, istouch)
	if not nk.mousepressed(x, y, button, istouch) then
		map.has_mouse = true
	end
end

function love.mousereleased(x, y, button, istouch)
	if not nk.mousereleased(x, y, button, istouch) then
		map.has_mouse = false
	end
end

function love.mousemoved(x, y, dx, dy, istouch)
	if not map.has_mouse then
		nk.mousemoved(x, y, dx, dy, istouch)
	else
		map.offset_x = map.offset_x + dx
		map.offset_y = map.offset_y + dy
	end
end

function love.textinput(text)
	nk.textinput(text)
end

function love.wheelmoved(x, y)
	if not nk.wheelmoved(x, y) then
		local r = 0.5
		map.zoom = map.zoom + y * r
	end
end