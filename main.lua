local World = require "world"

local world = World()

function love.load()
  love.window.setMode(1280, 720)
  love.window.setFullscreen(true)
end

function love.update(dt)
  world:update(dt)
end

function love.draw()
  world:draw()
end

function love.mousepressed(x, y, button, istouch, presses)
  world:mousepressed(x, y, button, istouch, pressed)
end
