---- (c) Feilkin 2017
-- "the" game state

local nk = require "nuklear"
local Camera = require "hump.camera"
local inspect = require "inspect"
local lovesvg = require "lovesvg"

local utils = require "utils"
local worldmap = require "worldmap"

local game = {}

utils.requireShards({
	"game_loaders",
	"game_ui",
	"game_logic"
	}, game)

function game:log(...)
	table.insert(self.gui.log, {...})
end

function game:init()
	nk.init()
	self:resetUI()

	worldmap.init()
	self:setupSystems()

	self.camera = Camera(950 / 2, 620 / 2)

	self:loadScripts()
	self:loadNodeGenerators()
end

function game:resetUI()
	nk.shutdown()
	nk.init()
	self.gui = { -- load GUI resources here, rest will be initialized on enter
		fonts = {
			medium = love.graphics.newFont("res/tewi-medium-11.bdf", 11),
			bold   = love.graphics.newFont("res/tewi-bold-11.bdf",   11),
		},
		pointers = {
			cursor = love.mouse.newCursor("res/cursor.png", 2, 6),
			pointinghand = love.mouse.newCursor("res/pointinghand.png", 8, 3)
		},
	}

	love.mouse.setCursor(self.gui.pointers.cursor)

	local style = love.filesystem.load("mod/skin.lua")
	nk.stylePush(style())

	self:clearUI()
end

function game:clearUI()
	-- manually reset everything but loaded resources,
	-- use :resetUI() for complete reload
	self.gui.log = {}
	self.gui.region_list_filter = { value = '' }
	self.gui.node_list_filter = { value = '' }
	self.gui.editors = {}
	self.gui.nodes = {}
	self.gui.wires = {}

	if self.gui.selected_region then
		self.gui.selected_region.style.fill = nil
		self.gui.selected_region = nil
	end

end

function game:enter(previous, ...)
	self:clearUI()

	local nodes = {}
	for i = 1, 128 do
		local node = self.nodeGenerators["pc"]()
		table.insert(nodes, node)
		self.world:addEntity(node)
	end
	local success = love.filesystem.write("nodes.lua", inspect(nodes))
	self.nodes = nodes

	love.graphics.setBackgroundColor(21, 23, 27)
	-- ends here
end

function game:leave()
	nk.shutdown()
end

function game:resume()

end


function game:updateWires()
	local wires = {}

	for i, node in ipairs(self.nodes) do
		for j, socket in ipairs(node.sockets) do
			if socket.connected then
				local wire = {}
				local x1, y1 = self.camera:cameraCoords(node.position.x,
				                                        node.position.y)

				if self.gui.nodes[node] and self.gui.sockets[socket] then
					-- draw a line from the socket to the node
					local sx, sy, sw, sh = unpack(self.gui.sockets[socket])
					utils.iextend(wire, {
						sx, sy + sh / 2,
						sx - 24, sy + sh / 2
						})
				end

				utils.iextend(wire, { x1, y1 })

				local x2, y2 = self.camera:cameraCoords(
				                           socket.connected.node.position.x,
					                       socket.connected.node.position.y)
				utils.iextend(wire, { x2, y2 })

				table.insert(wires, wire)
			end
		end
	end

	self.gui.wires = wires
end

function game:update(dt)
	love.mouse.setCursor(self.gui.pointers.cursor)
	love.window.setTitle(string.format("[%d FPS; Camera: (%0.2f, %0.2f) %0.2f]",
		love.timer.getFPS(), self.camera.x, self.camera.y, self.camera.scale))

	self.world:update(dt)

	-- make sure the world is in the screen
	do
		local cx, cy = self.camera:position()

		if cx < 0 then cx = worldmap.AABB[1] end
		if cy < 0 then cy = worldmap.AABB[2] end
		if cx > worldmap.AABB[3] then cx = worldmap.AABB[3] end
		if cy > worldmap.AABB[4] then cy = worldmap.AABB[4] end

		self.camera:lookAt(cx, cy)
	end

	-- UI

	if self.__reset_ui then
		self:resetUI()
		self.__reset_ui = nil
	end

	nk.frameBegin()


	-- check if we are hovering over a node
	do
		for _, node in ipairs(self.nodes) do
			node.is_hovered = nil
		end

		local mx, my = self.camera:mousePosition()
		local node = self:getNodeAt(mx, my)

		if node then
			love.mouse.setCursor(self.gui.pointers.pointinghand)
			node.is_hovered = true
		end
	end

	self:uiLeftSideBar()
	self:uiOutput()
	self:uiEditors()
	self:uiNodesOld()

	nk.frameEnd()

	self:updateWires()
	
end

function game:drawWires()
	local old_join = love.graphics.getLineJoin()
	love.graphics.setLineJoin("none")

	for i, wire in ipairs(self.gui.wires) do
		love.graphics.line(wire)
	end

	love.graphics.setLineJoin(old_join)
end

function game:drawNewWire()
	local old_join = love.graphics.getLineJoin()
	love.graphics.setLineJoin("none")

	if self.gui.new_wire then
		if not self.gui.new_wire.hover then
			love.graphics.setColor(0, 255, 255, 255)
		elseif self.gui.new_wire.hover == 'invalid' then
			love.graphics.setColor(255, 0, 0, 255)
		elseif self.gui.new_wire.hover == 'valid' then
			love.graphics.setColor(0, 255, 0, 255)
		end

		local mx, my = love.mouse.getPosition()
		local wb = self.gui.sockets[self.gui.new_wire.start.socket]
		love.graphics.line(wb[1] + 18, wb[2] + wb[4] / 2 , mx, my)
		love.graphics.setColor(255, 255, 255, 255)
	end

	love.graphics.setLineJoin(old_join)
end

function game:drawNodes()
	local cs = self.camera.scale

	for i, node in ipairs(self.nodes) do
		if node.is_hovered or self.gui.nodes[node] then
			love.graphics.setColor(255, 255, 255, 200)
		else
			love.graphics.setColor(102, 217, 239, 200)    
		end
		love.graphics.circle("fill",
			node.position.x, node.position.y,
			1 + 2/cs, 24 + cs * 8)
	end

	love.graphics.setColor(255, 255, 255, 255)
end

function game:draw()
	self.camera:attach()
		worldmap.draw()
		self:drawNodes()
	self.camera:detach()

	self:drawWires()
	nk.draw()
	self:drawNewWire()
end

function game:focus()

end

function game:keypressed(key, scancode, isrepeat)
	nk.keypressed(key, scancode, isrepeat)
end

function game:keyreleased(key, scancode)
	nk.keyreleased(key, scancode)
end

function game:getNodeAt(x, y)
	local r = (1 + 2/self.camera.scale)^2

	for i, node in ipairs(self.nodes) do
		if ((x - node.position.x)^2 + (y - node.position.y)^2) < r then
			return node
		end
	end
end

function game:mousepressed(x, y, button, istouch)
	if not nk.mousepressed(x, y, button, istouch) then
		if button == 1 then
			-- check if player clicked on a node
			local wx, wy = self.camera:worldCoords(x, y)
			local node = self:getNodeAt(wx, wy)
			if node then
				if self.gui.nodes[node] then
					utils.ifilter(self.gui.nodes, function (v)
						return v ~= node
					end)
					self.gui.nodes[node] = nil
				else
					table.insert(self.gui.nodes, node)
					self.gui.nodes[node] = true
				end
			else
				self.camera.drag_map = true
				love.mouse.setGrabbed(true)
			end
		end
	end
end

function game:mousereleased(x, y, button, istouch)
	if self.camera.drag_map then
		self.camera.drag_map = false
		love.mouse.setGrabbed(false)
	else
		nk.mousereleased(x, y, button, istouch)
	end

end

function game:mousemoved(x, y, dx, dy, istouch)
	if self.camera.drag_map then
		self.camera:move(-(dx / self.camera.scale), -(dy / self.camera.scale))
	else
		nk.mousemoved(x, y, dx, dy, istouch)
	end
end

function game:joystickpressed()

end

function game:joystickreleased()

end

function game:textinput(text)
	nk.textinput(text)
end

function game:wheelmoved(x, y)
	if not nk.wheelmoved(x, y) then
		local ds = 0.05 * y

		self.camera:zoom(1 + ds)

		-- zoom to mouse
		local cx, cy = self.camera:position()
		local mx, my = self.camera:mousePosition()
		local dx, dy = mx - cx, my - cy

		self.camera:move(dx * ds, dy * ds)
	end
end

function game:quit()

end

return game