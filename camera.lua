local Object = require "classic"
local Camera = Object:extend()
local Point = require "point"

function Camera:new()
  self.pos = Point(0, 0)
end

function Camera:set(p)
  self.pos:set(p)
  love.graphics.translate(-p.x + love.graphics.getWidth() / 2, -p.y + love.graphics.getHeight() / 2)
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
