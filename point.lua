local Object = require 'classic'
local Point = Object:extend("Point")

function Point:new(x, y)
  self.x = x
  self.y = y
end

function Point:copy()
  return Point(self.x, self.y)
end

function Point:eq(other)
  return self.x == other.x and self.y == other.y
end

function Point:set(other)
  self.x = other.x
  self.y = other.y
end

function Point:add(other)
  self.x = self.x + other.x
  self.y = self.y + other.y
  return self
end

function Point:subtract(other)
  self.x = self.x - other.x
  self.y = self.y - other.y
  return self
end

function Point:length()
  return math.sqrt(self.x * self.x + self.y * self.y)
end

function Point:setLength(length)
  self:multiply(length / self:length())
  return self
end

function Point:normalize()
  self:setLength(1)
  return self
end

function Point:multiply(ratio)
  self.x = self.x * ratio
  self.y = self.y * ratio
  return self
end

function Point:distanceTo(other)
  diffX = self.x - other.x
  diffY = self.y - other.y
  return math.sqrt(diffX * diffX + diffY * diffY)
end

function Point:rotate(rad)
  x, y = self.x, self.y
  self.x = x * math.cos(rad) - y * math.sin(rad)
  self.y = x * math.sin(rad) + y * math.cos(rad)
  return self
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
