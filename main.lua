--
--

local Gamestate

function love.load ()
	love.filesystem.setRequirePath("src/?.lua;src/?/init.lua;lib/?.lua;lib/?/init.lua")
	love.keyboard.setKeyRepeat(true)

	Gamestate = require "hump.gamestate"
	Gamestate.registerEvents()

	local splash = require "splash"
	Gamestate.switch(splash)
end