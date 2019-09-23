local world

function love.load()
  love.window.setMode(1280, 720)
  love.window.setFullscreen(true, "exclusive")

  local systems = require "systems"
  world = systems.createWorld()
end

function love.update(dt)
  world:update(dt)
end

function love.draw()
  world:draw()
end

function love.keypressed(key, scancode, isrepeat)
  world:keypressed(key, scancode, isrepeat)
end

function love.mousepressed(x, y, button, istouch, presses)
  world:mousepressed(x, y, button, istouch, pressed)
end

function love.wheelmoved(x, y)
  world:wheelmoved(x, y)
end
