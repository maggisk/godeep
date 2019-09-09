local Point = require "point"
local Object = require "classic"

local UIBox = Object:extend()

function UIBox:new(parent, x, y, width, height, options)
  self.pos = Point(x, y)
  self.absolutePos = self.pos:copy()
  self.width = width
  self.height = height
  self.options = options or {}
  self.children = {}
  if parent then
    self.parent = parent
    table.insert(parent.children, self)
    self.absolutePos:add(parent.pos)
  end
end

function UIBox:layout()
  self.absolutePos = self.pos:copy()
  if self.parent then
    self.absolutePos:add(self.parent.pos)
  end
  for _, child in ipairs(self.children) do
    child:layout()
  end
end

function UIBox:draw()
  love.graphics.push()
  love.graphics.translate(self.pos.x, self.pos.y)
  if self.options.color then
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(self.options.color)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    love.graphics.setColor(r, g, b, a)
  end
  if self.options.draw then
    self.options.draw(self)
  end
  for _, child in ipairs(self.children) do
    child:draw()
  end
  love.graphics.pop()
end

function UIBox:isInside(x, y)
  local pos = self.absolutePos
  return x >= pos.x and y > pos.y and x < pos.x + self.width and y < pos.y + self.height
end

function UIBox:processMouseEvent(e)
  if self:isInside(e.x, e.y) then
    for _, child in ipairs(self.children) do
      e:callMethod(child, "processMouseEvent")
    end
    if self.options[e.type] then
      e:callFunc(self.options[e.type], e, self)
    end
  end
end

return UIBox
