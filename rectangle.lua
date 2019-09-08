local Object = require "classic"

local Rectangle = Object:extend()

function Rectangle:new(x, y, width, height, options)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.options = options or {}
end

function Rectangle:draw(drawFunc)
  love.graphics.push()
  love.graphics.translate(self.x, self.y)
  if self.options.color then
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(self.options.color)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    love.graphics.setColor(r, g, b, a)
  end
  if drawFunc then
    drawFunc()
  end
  love.graphics.pop()
end

function Rectangle:isInside(x, y)
  return x >= self.x and y > self.y and x < self.x + self.width and y < self.y + self.height
end

function Rectangle:processMouseEvent(e)
  if self:isInside(e.x, e.y) and self.options[e.type] then
    self.options[e.type](e, self)
  end
end

return Rectangle
