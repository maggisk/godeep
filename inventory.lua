local U = require "underscore"
local UIBox = require "uibox"
local Point = require "point"
local Object = require "classic"
local Inventory = Object:extend()

local HEIGHT = 60
local PADDING = 10

function Inventory:new()
  self.capacity = 100

  self.state = {
    slots = {},
    mouse = nil,
  }

  local w, h = love.graphics.getDimensions()
  self.rect = UIBox(nil, 0, h - 60, w, 60, {
    color = {0, 0, 0, 1},
    click = function(e) e:halt() end,
    draw = function() self:drawSticky() end,
  })

  self.uiboxes = {}
  for i = 1, 20 do
    self:_addBox(({"hand", "head", "body"})[i])
  end
end

function Inventory:_addBox(slotKey)
  slotKey = slotKey or #self.uiboxes + 1
  self.uiboxes[slotKey] = UIBox(self.rect, #U.keys(self.uiboxes) * HEIGHT, PADDING, HEIGHT - PADDING * 2, HEIGHT - PADDING * 2, {
    slot = slotKey,
    color = {1, 1, 1, 1},
    click = function(e, box) self:handleSlotClick(e, slotKey) end,
    draw = function() self:drawSlot(slotKey) end,
  })
end

function Inventory:get(key)
  assert(type(key) == "number" or key == "hand" or key == "head" or key == "body")
  return self.state.slots[key]
end

function Inventory:getMouseItem()
  return self.state.mouse
end

function Inventory:add(item)
  item.enabled = false
  if self.state.slots["hand"] == nil and item.tags.inhand then
    self.state.slots["hand"] = item
  else
    for key, slotItem in pairs(self.state.slots) do
      if type(key) == "number" and slotItem.clsname == item.clsname then
        slotItem:merge(item)
        return
      end
    end
    table.insert(self.state.slots, item)
  end
end

function Inventory:processMouseEvent(e)
  e:callMethod(self.rect, "processMouseEvent")
end

function Inventory:handleSlotClick(e, key)
  if self.state.mouse and self.state.slots[key] and self.state.slots[key]:merge(self.state.mouse) then
    self.state.mouse = nil
  else
    self.state.mouse, self.state.slots[key] = self.state.slots[key], self.state.mouse
  end
end

function Inventory:drop(item, pos)
  item.enabled = true
  item.pos:set(pos)

  if self.state.mouse and self.state.mouse == item then
    self.state.mouse = nil
  end
  for k, v in pairs(self.state.slots) do
    if v.enabled then
      self.state.slots[k] = nil
    end
  end
end

function Inventory:getWeight()
  local w = 0
  for _, item in pairs(self.state.slots) do
    w = w + item.weight * item.count
  end
  return w
end

function Inventory:draw()
  self.rect:layout()
  self.rect:draw()

  if self.state.mouse then
    self.state.mouse:getImage():draw(Point(love.mouse.getX(), love.mouse.getY() + self.state.mouse:getImage():getHeight() / 2))
  end
end

function Inventory:drawSticky()
  -- background
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle("fill", 0, 0, self.rect.width, self.rect.height)

  -- progressbar to show how much is in backpack
  love.graphics.setColor(0, 0, 0.8, 1)
  love.graphics.rectangle("fill", 0, HEIGHT - 5, self.rect.width * (self:getWeight() / self.capacity), 5)

  love.graphics.setColor(1, 1, 1, 1)
end

function Inventory:drawSlot(slot)
  local item = self.state.slots[slot]
  if item then
    item:getImage():draw(Point(30, 40))
    if item.count > 1 then
      love.graphics.print({{0, 0, 0, 1}, item.count}, 2, 2)
    end
  elseif type(slot) == "string" then
    love.graphics.print({{0, 0, 0, 1}, slot}, 15, 5, 0.8)
  end
end

return Inventory
