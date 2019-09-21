local U = require "underscore"
local UIBox = require "uibox"
local Point = require "point"
local rules = require "gamerules"
local Object = require "classic"

local HEIGHT = 60
local PADDING = 10

local Inventory = Object:extend()

Inventory.WEARABLE_SLOTS = {"hand", "head", "body"}

function Inventory:new()
  self.capacity = 100

  -- when we split entities in the inventory
  self.newEntities = {}

  self.state = {
    slots = {},
    mouse = nil,
  }

  local w, h = love.graphics.getDimensions()
  self.bar = UIBox(nil, 0, h - 60, w, 60, {
    color = {0, 0, 0, 1},
    click = function(e) e:halt() end,
    draw = function() self:drawSticky() end,
  })

  self.uiboxes = {}
  for i = 1, 20 do
    self:_addBox(Inventory.WEARABLE_SLOTS[i])
  end
end

function Inventory:_addBox(slotKey)
  slotKey = slotKey or #self.uiboxes + 1
  self.uiboxes[slotKey] = UIBox(self.bar, #U.keys(self.uiboxes) * HEIGHT, PADDING, HEIGHT - PADDING * 2, HEIGHT - PADDING * 2, {
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
  item.disabled = true
  if item.tags.wearable and self.state.slots[item.tags.wearable] == nil then
    self.state.slots[item.tags.wearable] = item
  else
    self:_insert(item)
  end
end

function Inventory:_insert(item)
  -- try to merge with existing item
  for slot, slotItem in pairs(self.state.slots) do
    if type(slot) == "number" and rules.tryMergeEntities(slotItem, item) then
      return
    end
  end

  -- otherwise insert into first available slot
  for i = 1, math.huge do
    if self.state.slots[i] == nil then
      self.state.slots[i] = item
      break
    end
  end
end

function Inventory:processMouseEvent(e)
  e:callMethod(self.bar, "processMouseEvent")
end

function Inventory:handleSlotClick(event, slot)
  local item = self.state.slots[slot]

  if event.button == 2 then
    if item.tags.wearable then
      self.state.slots[slot], self.state.slots[item.tags.wearable] = self.state.slots[item.tags.wearable], item
    end
    return
  end

  if love.keyboard.isDown("lctrl") then
    if self.state.mouse == nil or rules.canMergeEntities(self.state.mouse, item) then
      local item, other = rules.trySplitEntity(item)
      if self.state.mouse == nil then
        self.state.mouse = other
      else
        rules.tryMergeEntities(self.state.mouse, other or item)
      end
    end
  elseif self.state.mouse and item and rules.tryMergeEntities(item, self.state.mouse) then
    self.state.mouse = nil
  else
    self.state.mouse, self.state.slots[slot] = item, self.state.mouse
  end
end

function Inventory:drop(item, pos)
  if self.state.mouse and self.state.mouse == item then
    item.disabled = nil
    item.pos:set(pos)
    self.state.mouse = nil
  end
  for slot, item in pairs(self.state.slots) do
    if item.disabled then
      self.state.slots[slot] = nil
    end
  end
end

function Inventory:getWeight()
  local w = 0
  for _, item in pairs(self.state.slots) do
    w = w + item.weight * (item.count or 1)
  end
  return w
end

function Inventory:update(args)
  if self.state.mouse and self.state.mouse.dead then
    self.state.mouse = nil
  end

  for slot, item in pairs(self.state.slots) do
    if item.dead then
      -- remove item from the inventory that has run out
      self.state.slots[slot] = nil
      for i, other in pairs(self.state.slots) do
        if type(slot) == "string" and type(i) == "number" and getmetatable(item) == getmetatable(other) then
          -- replace wearable item that runs out with another identical one in the inventory
          self.state.slots[slot], self.state.slots[i] = self.state.slots[i], nil
          break
        end
      end
    elseif item.update then
      item:update(args)
    end
  end

  self.bar:layout()
end

function Inventory:draw()
  love.graphics.push()
  love.graphics.origin()

  self.bar:draw()

  if self.state.mouse then
    self.state.mouse.image:draw(Point(love.mouse.getX(), love.mouse.getY() + self.state.mouse.image:getHeight() / 2))
  end

  love.graphics.pop()
end

function Inventory:drawSticky()
  -- background
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle("fill", 0, 0, self.bar.width, self.bar.height)

  -- progressbar to show how much is in backpack
  love.graphics.setColor(51/255, 76/255, 122/255, 1)
  love.graphics.rectangle("fill", 0, HEIGHT - 5, self.bar.width * (self:getWeight() / self.capacity), 5)

  love.graphics.setColor(1, 1, 1, 1)
end

local font = love.graphics.newFont(20)

function Inventory:drawSlot(slot)
  local origFont = love.graphics.getFont()
  local item = self.state.slots[slot]
  local box = self.uiboxes[slot]

  if item then
    if item.durability then
      local durability = (item.durability / item.tags.durability) % 1
      if durability == 0 then durability = 1 end
      love.graphics.setColor(39/255, 174/255, 96/255, 1)
      love.graphics.rectangle("fill", 0, (1 - durability) * box.height, box.width, durability * box.height)
      love.graphics.setColor(1, 1, 1, 1)
    end
    item.image:draw(Point(30, 40))
    if not item.tags.wearable then
      love.graphics.setFont(font)
      love.graphics.print({{0, 0, 0, 1}, item.count or 1}, 2, 2)
      love.graphics.setFont(origFont)
    end
  elseif type(slot) == "string" then
    -- TODO: use icons
    love.graphics.print({{0, 0, 0, 1}, slot}, 15, 5, 0.8)
  end
end

return Inventory
