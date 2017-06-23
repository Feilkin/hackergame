---- (c) Feilkin 2017
-- "the" splash state

local Gamestate = require "hump.gamestate"

local splash = {}

local image

function splash:init()
	image = love.graphics.newImage("res/splash.png")
	self.timer = 0.6
end

function splash:enter(previous, ...)
end

function splash:leave()
end

function splash:resume()

end

function splash:update(dt)
	self.timer = self.timer - dt

	if self.timer <= 0 then
		local game = require "game"
		Gamestate.switch(game)
	end
end

function splash:draw()
	love.graphics.draw(image, 0,0)
end

function splash:focus()

end

function splash:keypressed(key, scancode, isrepeat)
end

function splash:keyreleased(key, scancode)
end

function splash:mousepressed(x, y, button, istouch)

end

function splash:mousereleased(x, y, button, istouch)

end

function splash:mousemoved(x, y, dx, dy, istouch)
end

function splash:joystickpressed()

end

function splash:joystickreleased()

end

function splash:textinput(text)
end

function splash:wheelmoved(x, y)
end

function splash:quit()

end

return splash