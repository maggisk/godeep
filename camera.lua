local Object = require "classic"
local Camera = Object:extend()
local Point = require "point"

function Camera:new()
  self.pos = Point(0, 0)
  self.target = Point(0, 0)
end

function Camera:follow(p)
  self.target:set(p)
end

function Camera:update(dt)
  self.pos:add(self.target:copy():subtract(self.pos):multiply(dt * 8))
end

function Camera:apply()
  love.graphics.translate(-self.pos.x + love.graphics.getWidth() / 2, -self.pos.y + love.graphics.getHeight() / 2)
end

-- screen coordinates to world coordinates
function Camera:s2w(p)
  return self.pos:copy():add(p):subtract(Point(love.graphics.getWidth()/2, love.graphics.getHeight()/2))
end

function Camera:visibleRect()
  local w, h = love.graphics.getDimensions()
  return self.pos.x - w / 2, self.pos.y - h / 2, self.pos.x + w / 2, self.pos.y + h / 2
end

return Camera
