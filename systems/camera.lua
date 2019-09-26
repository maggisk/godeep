local Object = require "classic"
local Camera = require "camera"
local Point = require "point"

local CameraSystem = Object:extend()
function CameraSystem:new()
  self.camera = Camera()
  self.state = self.camera
end

function CameraSystem:update(next, state, dt)
  self.camera:follow(state.world.player.pos)
  self.camera:update(dt)
  return next
end

function CameraSystem:draw(next)
  love.graphics.push()
  self.camera:apply()
  next()
  love.graphics.pop()
end

function CameraSystem:MOUSEPRESSED(e)  self:extend(e) end
function CameraSystem:MOUSERELEASED(e) self:extend(e) end
function CameraSystem:MOUSEMOVED(e)    self:extend(e) end

function CameraSystem:extend(event)
  event.screen = Point(event.x, event.y)
  event.world = self.camera:screenToWorldPos(event.screen)
end

return CameraSystem
