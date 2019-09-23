local Object = require "classic"
local ent = require "entities"
local Point = require "point"
local commands = require "commands"

local Planting = Object:extend()
function Planting:update(next, state)
  self.entity = nil
  self.canPlant = false
  self.item = state.entities.player.inventory:getMouseItem()

  if self.item and self.item.tags.plants and not state.entities.hoveringEntity then
    local x, y = love.mouse.getPosition()
    local pos = state.camera:screenToWorldPos(Point(x, y))
    self.entity = ent[self.item.tags.plants](pos.x, pos.y)
    if self.entity.toBePlanted then
      self.entity:toBePlanted()
    end
    self.canPlant = state.entities.entities:canAddWithoutCollisions(self.entity, state.entities.player)
  end

  return next
end

function Planting:draw(next)
  if self.entity and self.canPlant then
    love.graphics.setColor(1, 1, 1, 0.8)
    self.entity:draw()
    love.graphics.setColor(1, 1, 1, 1)
  end
  return next
end

function Planting:MOUSEPRESSED(event, state)
  if self.entity and self.canPlant then
    state.entities.player.command = commands.Plant(self.item, self.entity, state.entities.entities)
  end
end

return Planting
