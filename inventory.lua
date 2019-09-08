local U = require "underscore"
local Rectangle = require "rectangle"
local Point = require "point"
local Object = require "classic"
local Inventory = Object:extend()

local HAND_SLOT_INDEX = 1
local HEAD_SLOT_INDEX = 2
local BODY_SLOT_INDEX = 3
local REST_SLOT_INDEX = 4

function Inventory:new()
  self.weight = 0.0
  self.capacity = 100.0
  self.space = 10
  self.items = {}

  local w, h = love.graphics.getDimensions()
  self.rect = Rectangle(0, h - 60, w, 60, {
    color = {0, 0, 0, 1},
    click = function(e) e:halt() end,
  })

  for i = 1, self.space + 3 do
    table.insert(self.items, {
      type = nil,
      things = {},
      rect = Rectangle((i-1) * 60 + 10, self.rect.y + 10, 40, 40, {
        index = i,
        color = {1, 1, 1, 1},
        click = function(e, rect) self:handleItemClick(e, self.items[rect.options.index]) end,
      })
    })
  end

  self.items[HAND_SLOT_INDEX].label = "hand"
  self.items[HEAD_SLOT_INDEX].label = "head"
  self.items[BODY_SLOT_INDEX].label = "body"
end

function Inventory:inHand()
  return self.items[HAND_SLOT_INDEX].things[1]
end

function Inventory:onHead()
  return self.items[HEAD_SLOT_INDEX].things[1]
end

function Inventory:onBody()
  return self.items[BODY_SLOT_INDEX].things[1]
end

function Inventory:addOne(item)
  item.enabled = false
  item.pos.x = 0
  item.pos.y = 0
  if #self.items[HAND_SLOT_INDEX].things == 0 and item.tags.inhand then
    table.insert(self.items[HAND_SLOT_INDEX].things, item)
  else
    self.weight = self.weight + item.weight
    table.insert(self.items, item)
  end
end

function Inventory:processMouseEvent(e, item)
  for _, item in pairs(self.items) do
    e:callMethod(item.rect, "processMouseEvent")
  end
  e:callMethod(self.rect, "processMouseEvent")
end

function Inventory:handleItemClick(e, item)
  print("item click", item.rect.options.index)
end

function Inventory:draw()
  self.rect:draw(function()
    -- background
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, 0, self.rect.width, self.rect.height)
    -- progressbar to show how much is in backpack
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", 0, self.rect.height - 5, self.rect.width * (self.weight / self.capacity), 5)
  end)

  -- draw each thing in the inventory
  for i, item in pairs(self.items) do
    item.rect:draw(function()
      if #item.things > 0 then
        item.things[1].image:draw(Point(30, 40))
      elseif item.label then
        love.graphics.print({{0, 0, 0, 1}, item.label}, 15, 5, 0.8)
      end
    end)
  end
end

return Inventory
