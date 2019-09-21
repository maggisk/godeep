local Object = require "classic"
local Camera = require "camera"

local CameraSystem = Object:extend()
function CameraSystem:new()
  self.camera = Camera()
  self.state = self.camera
end

function CameraSystem:update(next, state, dt)
  self.camera:follow(state.entities.player.pos)
  self.camera:update(dt)
  next()
end

function CameraSystem:draw(next)
  love.graphics.push()
  self.camera:apply()
  next()
  love.graphics.pop()
end

return CameraSystem
