local util = require "util"

local world

function love.load(args)
  love.window.setMode(1280, 720)
  love.window.setFullscreen(not util.hasValue(args, "--fullscreen=false"), "exclusive")

  world = require("systems").createWorld()
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
