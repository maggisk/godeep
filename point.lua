local Object = require 'classic'
local Point = Object:extend("Point")

function Point:new(x, y)
  self:setXY(x, y)
end

function Point:copy()
  return Point(self.x, self.y)
end

function Point:eq(other)
  return self.x == other.x and self.y == other.y
end

function Point:setXY(x, y)
  self.x, self.y = x, y
  return self
end

function Point:set(other)
  return self:setXY(other.x, other.y)
end

function Point:add(other)
  return self:setXY(self.x + other.x, self.y + other.y)
end

function Point:subtract(other)
  return self:setXY(self.x - other.x, self.y - other.y)
end

function Point:length()
  return math.sqrt(self.x * self.x + self.y * self.y)
end

function Point:setLength(length)
  return self:multiply(length / self:length())
end

function Point:normalize()
  return self:setLength(1)
end

function Point:multiply(ratio)
  return self:setXY(self.x * ratio, self.y * ratio)
end

function Point:distanceTo(other)
  return math.sqrt((self.x - other.x)^2 + (self.y - other.y)^2)
end

function Point:rotate(rad)
  local x, y = self.x, self.y
  self.x = x * math.cos(rad) - y * math.sin(rad)
  self.y = x * math.sin(rad) + y * math.cos(rad)
  return self
end

function Point:move(angle, distance)
  return self:setXY(self.x + math.cos(angle) * distance, self.y + math.sin(angle) * distance)
end

function Point:getAngle()
  return math.atan2(self.y, self.x)
end

function Point:setX(x)
  self.x = x
  return self
end

function Point:setY(y)
  self.y = y
  return self
end

function Point:xy()
  return self.x, self.y
end

return Point
