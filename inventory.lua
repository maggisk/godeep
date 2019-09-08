local Object = require "classic"
local Inventory = Object:extend()

function Inventory:new()
  self.weight = 0.0
  self.capacity = 100.0
  self.items = {}
  self.handslot = nil
  self.headslot = nil
end

function Inventory:addOne(item)
  item.enabled = false
  item.pos.x = 0
  item.pos.y = 0
  if self.handslot == nil and item.tags.inhand then
    self.handslot = item
  else
    self.weight = self.weight + item.weight
    table.insert(self.items, item)
  end
end

function Inventory:draw()
  love.graphics.setColor(0, 0, 0, 1)
  local w, h = love.graphics.getDimensions()
  love.graphics.rectangle("fill", 0, h - 60, w, 60)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle("fill", 0, h - 5, w * (self.weight / self.capacity), 5)

  love.graphics.push()
  for i, obj in ipairs(self.items) do
    love.graphics.translate(i * 40, h - 15)
    obj:draw()
  end
  love.graphics.pop()
end

return Inventory
