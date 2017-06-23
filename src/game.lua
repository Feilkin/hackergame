---- (c) Feilkin 2017
-- "the" game state

local nk = require "nuklear"
local Camera = require "hump.camera"

local utils = require "utils"
local worldmap = require "worldmap"

local game = {}


do
	local scriptFolder = "mod/scripts"

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
end

function game:clearGUI()
	-- manually reset everything but loaded resources,
	-- use :resetUI() for complete reload
	self.gui.log = {}
	self.gui.region_list_filter = { value = '' }
	self.gui.editors = {}

	if self.gui.selected_region then
		self.gui.selected_region.style.fill = nil
		self.gui.selected_region = nil
	end

end

function game:enter(previous, ...)
	self:clearGUI()

	self.nodes = {
		{
			name = "node1",
			cpu = { freq = 1300, cores = 2 },
			sockets = {
				{
					name = "eth0",
					type = "ethernet",
					speed = 100
				},
				{
					name = "wlan0",
					type = "wlan",
					speed = 10
				}
			},
			scriptable = true,
			script = ''
		}
	}

	self.gui.editors = {
		{
			target = self.nodes[1],
			value = ""
		}
	}

	nk.init()
	nk.stylePush {
		['font'] = self.gui.fonts.medium,
	}
end

function game:leave()
	nk.shutdown()
end

function game:resume()

end

function game:uiOutput()
	local cw, ch = love.graphics.getDimensions()
	local ww, wh, wp = 400,300, 12
	if nk.windowBegin('OUTPUT',
	                           (cw - ww - wp),(ch - wh - wp), ww,wh,
	                           'border', 'title', 'movable', 'scalable',
	                           'scrollbar') then
		nk.layoutRow('dynamic', 13, 1)

		for i, line in ipairs(self.gui.log) do
			nk.label(line)
		end
	end
	nk.windowEnd()
end

function game:uiRegionList()
	local cw, ch = love.graphics.getDimensions()
	local ww, wh, wp = 150,300, 12

	if nk.windowBegin('REGIONS',
	                           wp,wp, ww,wh,
	                           'border', 'title', 'movable') then
		nk.layoutRow('dynamic', 24, 1)
		nk.edit('field', self.gui.region_list_filter)

		nk.layoutRow('dynamic', wh - 28*2, 1)
		nk.groupBegin('region list', 'scrollbar')
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
	end
	nk.windowEnd()
end

function game:uiEditors()	
	local cw, ch = love.graphics.getDimensions()
	local ww, wh, wp = 300,400, 12

	for i, editor in ipairs(self.gui.editors) do
		if nk.windowBegin(string.format('EDIT %s.script', editor.target.name),
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

				nk.comboboxEnd()
			end

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
	self.gui.editors = utils.ifilter(self.gui.editors, function (v) return not v.close end )

end

function game:update(dt)
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

	self:uiRegionList()
	self:uiOutput()
	self:uiEditors()

	nk.frameEnd()
end

function game:draw()
	self.camera:attach()
		worldmap.draw()
	self.camera:detach()
	nk.draw()
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