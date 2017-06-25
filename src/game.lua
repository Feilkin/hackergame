---- (c) Feilkin 2017
-- "the" game state

local nk = require "nuklear"
local Camera = require "hump.camera"
local inspect = require "inspect"

local utils = require "utils"
local worldmap = require "worldmap"
local templar = require "templar"

local game = {}

local scriptFolder = "mod/scripts"
local nodeFolder = "mod/nodes"

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

	for i, file in ipairs(files) do
		local name = file:match(".*/([^/]+)%.lua$")
		local chunk = assert(love.filesystem.load(file))

		print(name, file)

		local generator = templar.generator(chunk)
		nodeGenerators[name] = generator
	end

	self.nodeGenerators = nodeGenerators
end

function game:init()
	self.gui = { -- load GUI resources here, rest will be initialized on enter
		fonts = {
			medium = love.graphics.newFont("res/tewi-medium-11.bdf", 11),
			bold   = love.graphics.newFont("res/tewi-bold-11.bdf",   11),
		},
	}

	worldmap.init()

	self.camera = Camera(0, 0)

	self:loadScripts()
	self:loadNodes()
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

	-- TODO: this is for debugging
	local nodes = {}
	for i = 1, 4 do
		table.insert(nodes, self.nodeGenerators["pc"]())
	end
	local success = love.filesystem.write("nodes.lua", inspect(nodes))
	self.nodes = nodes

	local lovesvg = require "lovesvg"
	local logoABM = lovesvg.loadSVG("res/logo_abm.svg", { depth = 1, discard_distance = 0.0001 })
	self.gui.logoABM = logoABM
	-- ends here

	nk.init()
	nk.stylePush { -- TODO: make a style (load from mod/?)
		['font'] = self.gui.fonts.medium,
		['window'] = {
			['background'] = '#2d2d2daa',
			['fixed background'] = '#2d2d2daa',
		}
	}
end

function game:leave()
	nk.shutdown()
end

function game:resume()

end

function game:uiOutput()
	local cw, ch = love.graphics.getDimensions()
	local ww, wh, wp = 400,300, 6
	if nk.windowBegin('OUTPUT',
	                           (cw - ww - wp),wp, ww,wh,
	                           'border', 'title', 'movable', 'scalable',
	                           'scrollbar', 'minimizable') then
		nk.layoutRow('dynamic', 13, 1)

		for i, line in ipairs(self.gui.log) do
			nk.label(line)
		end
	end
	nk.windowEnd()
end

function game:uiRegionList()
	local cw, ch = love.graphics.getDimensions()
	local ww, wh, wp = 150,300, 6

	if nk.treePush('node', 'REGIONS') then
		nk.layoutRow('dynamic', 24, 1)
		nk.edit('field', self.gui.region_list_filter)

		nk.layoutRow('dynamic', wh - 28*2, 1)
		nk.groupBegin('region list', 'scrollbar', 'border')
		do
			nk.layoutRow('dynamic', 24, 1)

			for i, region in ipairs(worldmap.regions) do
				if string.match(region.attributes.id,
				                self.gui.region_list_filter.value ) then
					if nk.button(region.attributes.id) then
						-- center the camera to selected region
						local AABB = region.renderer.AABB
						self.camera:lookAt((AABB[1] + AABB[3]) / 2,
						                   (AABB[2] + AABB[4]) / 2)

						if self.gui.selected_region then
							self.gui.selected_region.style.fill = nil
						end

						self.gui.selected_region = region
						region.style = region.style or {}
						region.style.fill = { 128, 255, 255, 255 }
					end
				end
			end
		end
		nk.groupEnd()
		nk.treePop()
	end
end


function game:uiNodeList()
	local cw, ch = love.graphics.getDimensions()
	local ww, wh, wp = 150,300, 6

	if nk.treePush('node', 'NODES') then
		nk.layoutRow('dynamic', 24, 1)
		nk.edit('field', self.gui.node_list_filter)

		nk.layoutRow('dynamic', wh - 28*2, 1)
		nk.groupBegin('node list', 'scrollbar', 'border')
		do
			nk.layoutRow('dynamic', 24, 1)

			for i, node in ipairs(self.nodes) do
				if string.match(node.name,
				                self.gui.node_list_filter.value ) then
					if nk.button(node.name, self.gui.nodes[node] and "circle solid" or nil) then
						if not self.gui.nodes[node] then
							self.camera:lookAt(node.position.x, node.position.y)
							table.insert(self.gui.nodes, node)
							self.gui.nodes[node] = true
						else
							utils.ifilter(self.gui.nodes, function (v)
								return v ~= node
							end)

							self.gui.nodes[node] = nil
						end
					end
				end
			end
		end
		nk.groupEnd()
		nk.treePop()
	end
end

function game:uiEditors()	
	local cw, ch = love.graphics.getDimensions()
	local ww, wh, wp = 300,400, 6

	for i, editor in ipairs(self.gui.editors) do
		if nk.windowBegin(editor.uuid, string.format('EDIT %s.script', editor.target.name),
		                   wp,wp, ww,wh,
		                   'border', 'title', 'movable', 'closable') then
			nk.layoutRow('dynamic', 24, 1)

			if nk.comboboxBegin('SCRIPTS') then
				nk.layoutRow('dynamic', 24, 1)
				for j, script in ipairs(self.scripts) do
					if nk.comboboxItem(script.name) then
						editor.value = script.script
					end
				end

			end

				nk.comboboxEnd()

			nk.layoutRow('dynamic', wh - 98, 1)
			nk.edit('box', editor)

			nk.layoutRow('dynamic', 24, 1)
			if nk.button('SAVE') then
				editor.target.script = editor.value
				editor.close = true
			end
		else
			editor.close = true
		end
		nk.windowEnd()
	end

	-- remove closed editors
	self.gui.editors = utils.ifilter(self.gui.editors, function (v)
			if v.close then 
				self.gui.editors[v.target] = false
			end
			return not v.close
		end )

end

do
	local function calculate_height(node)
		return 64 + (node.cpu and 28 or 0) + (node.scriptable and 28  * 2 or 0) + #node.sockets * 28
	end

	function game:uiNodes()
		local cx, cy = self.camera:position()
		local cw, ch = love.graphics.getDimensions()
		local cs = self.camera.scale

		self.gui.wires = {}
		if self.gui.new_wire then self.gui.new_wire.hover = nil end

		if not self.gui.nodes then return end

		for i, node in ipairs(self.gui.nodes) do
			if nk.windowBegin(node.uuid, node.name,
			                  node.position.x - (cx - cw/2), node.position.y - (cy - ch/2),
			                  200, calculate_height(node),
			                  'border', 'title', 'minimizable') then

				nk.layoutRow('dynamic', 24, 1)

				if node.cpu then
					nk.label(string.format('CPU: %.1fGHz %d cores', node.cpu.freq/1000, node.cpu.cores))
				end

				if node.scriptable then
					if nk.button('EDIT SCRIPT') and not self.gui.editors[node] then
						table.insert(self.gui.editors, {
							target = node,
							value = node.script or "",
							uuid = utils.uuid()
						})
						self.gui.editors[node] = true
					end

					if not node.running then
						if nk.button('RUN SCRIPT') then
						end
					else
						if nk.button('KILL SCRIPT') then
						end
					end
				end

				nk.label 'SOCKETS'
				for j, socket in ipairs(node.sockets) do
					if self.gui.new_wire and (self.gui.new_wire.start.socket == socket) then
						nk.styleSetFont(self.gui.fonts.bold)
					end

					if self.gui.new_wire then
						if (self.gui.new_wire.start.socket == socket) then
							self.gui.wires[socket] = { nk.widgetBounds() }
						else
							if nk.widgetIsHovered() then
								if socket.type == self.gui.new_wire.start.socket.type then
									self.gui.new_wire.hover = 'valid'
								else
									self.gui.new_wire.hover = 'invalid'
								end
							end
						end
					end

					if socket.connected then
						if not self.gui.wires[socket] then
							self.gui.wires[socket] = { nk.widgetBounds() }
						end

						if self.gui.wires[socket.connected.socket] then
							self.gui.wires[#self.gui.wires + 1] = {
								self.gui.wires[socket],
								self.gui.wires[socket.connected.socket],
								start_node = node,
								end_node = socket.connected.node,
							}
						end
					end
					local label = socket.name
					if socket.connected then
						label = label .. ' <' .. socket.connected.node.name .. '-' .. socket.connected.socket.name .. '>'
					end
					if nk.button(label, socket.connected and 'circle solid' or 'circle outline') then
						if socket.connected then
							socket.connected.socket.connected = nil
							socket.connected = nil
						elseif self.gui.new_wire then
							if (self.gui.new_wire.start.socket ~= socket) and (self.gui.new_wire.start.socket.type == socket.type) then
								socket.connected = self.gui.new_wire.start
								self.gui.new_wire.start.socket.connected = {
									socket = socket,
									node = node }
							end
							self.gui.new_wire = nil
						else
						    self.gui.new_wire = {
						    	start = {
						    		socket = socket,
						    		node = node } }

							self.gui.wires[socket] = { nk.widgetBounds() }
						end
					end
					nk.styleSetFont(self.gui.fonts.medium)
				end
			end

			nk.windowSetPosition(
				(node.position.x - cx) * cs + cw/2,
				(node.position.y - cy) * cs + ch/2)
			nk.windowEnd()
		end
	end
end

function game:uiLeftSideBar()
	local ww, wh = love.graphics.getDimensions()

	if nk.windowBegin('TOOLS', 6,6, 200, wh - 12, 'border', 'title', 'minimizable') then
		if nk.treePush('tab', 'SEARCH') then
			self:uiRegionList()
			self:uiNodeList()
			nk.treePop()
		end
		nk.treePop()
	end
	nk.windowEnd()
end

function game:update(dt)
	love.window.setTitle(string.format("[%d FPS; Camera: (%0.2f, %0.2f) %0.2f]",
		love.timer.getFPS(), self.camera.x, self.camera.y, self.camera.scale))

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
	nk.frameBegin()

	self:uiLeftSideBar()
	self:uiOutput()
	self:uiEditors()
	self:uiNodes()

	nk.frameEnd()
end

function game:drawWires()
	local old_join = love.graphics.getLineJoin()
	love.graphics.setLineJoin("none")

	for i, wire in ipairs(self.gui.wires) do
		love.graphics.line(
			wire[1][1],
			wire[1][2] + wire[1][4] / 2,
			wire[1][1] - 24,
			wire[1][2] + wire[1][4] / 2,
			wire[2][1] - 24,
			wire[2][2] + wire[2][4] / 2,
			wire[2][1],
			wire[2][2] + wire[2][4] / 2
			)
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
		local wb = self.gui.wires[self.gui.new_wire.start.socket]
		love.graphics.line(wb[1] + 18, wb[2] + wb[4] / 2 , mx, my)
		love.graphics.setColor(255, 255, 255, 255)
	end

	love.graphics.setLineJoin(old_join)
end

function game:drawNodes()
	love.graphics.setColor(0, 255, 255, 200)

	for i, node in ipairs(self.nodes) do
		love.graphics.circle("fill",
			node.position.x, node.position.y,
			4, 32)
	end

	love.graphics.setColor(255, 255, 255, 255)
end

function game:draw()
	self.camera:attach()
		worldmap.draw()
		self:drawNodes()

		love.graphics.push()
		love.graphics.translate(100, 300)
		self.gui.logoABM:draw()
		love.graphics.pop()

	self.camera:detach()

	nk.draw()
	self:drawWires()
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

function game:mousepressed(x, y, button, istouch)
	if not nk.mousepressed(x, y, button, istouch) then
		if button == 1 then
			self.camera.drag_map = true
			love.mouse.setGrabbed(true)
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