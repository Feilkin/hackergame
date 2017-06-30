--
--

local Gamestate

function love.load ()
	-- seed random
	love.math.setRandomSeed(os.time())

	-- create required folders if they don't exists
	local save_folders = {
		"save"
	}

	for i, f in ipairs(save_folders) do
		if not love.filesystem.isDirectory(f) then
			love.filesystem.createDirectory(f)
		end
	end

	love.filesystem.setRequirePath("src/?.lua;src/?/init.lua;lib/?.lua;lib/?/init.lua")
	love.keyboard.setKeyRepeat(true)

	Gamestate = require "hump.gamestate"
	Gamestate.registerEvents()

	local splash = require "splash"
	Gamestate.switch(splash)
end