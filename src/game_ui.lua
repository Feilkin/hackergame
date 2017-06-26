local nk = require "nuklear"
local utils = require "utils"
local worldmap = require "worldmap"

return function (game)
	function game:uiOutput()
		local cw, ch = love.graphics.getDimensions()
		local ww, wh, wp = 400,300, 6
		if nk.windowBegin('OUTPUT',
		                           (cw - ww - wp),wp, ww,wh,
		                           'border', 'title', 'movable', 'scalable',
		                           'scrollbar', 'minimizable') then
			nk.layoutRow('dynamic', 13, 1)

			for i, line in ipairs(self.gui.log) do
				nk.label(table.concat(line, "\t"))
			end
		end
		nk.windowEnd()
	end

	function game:uiRegionList()
		local cw, ch = love.graphics.getDimensions()
		local ww, wh, wp = 150,300, 6

		if nk.treePush('tab', 'REGIONS') then
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

		if nk.treePush('tab', 'NODES') then
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
					--editor.close = true
				end
			else
				editor.close = true
			end
			nk.windowEnd()
		end

		-- remove closed editors
		self.gui.editors = utils.ifilter(self.gui.editors, function (v)
				if v.close then 
					self.gui.editors[v.target] = nil
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
								self.vm:runScript(node.script)
								node.running = true
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

	function game:uiDebugTools()
		if nk.treePush('tab','DEBUG') then
			if nk.button('reset UI') then
				self.__reset_ui = true
			end
			nk.treePop()
		end
	end

	function game:uiLeftSideBar()
		local ww, wh = love.graphics.getDimensions()

		if nk.windowBegin('TOOLS', 6,6, 200, wh - 12, 'border', 'title', 'minimizable') then
			self:uiRegionList()
			self:uiNodeList()
			self:uiDebugTools()
			nk.treePop()
		end
		nk.windowEnd()
	end
end
