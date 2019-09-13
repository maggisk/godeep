local Object = require "classic"
local ent = require "entities"
local commands = require "commands"
local Point = require "point"
local rules = require "gamerules"

local Planter = Object:extend()

function Planter:update(state)
  self.entity = nil

  local item = state.player.inventory:getMouseItem()
  if item and item.tags.plants and not state.hoveringEntity then
    local x, y = love.mouse.getPosition()
    local pos = state.camera:screenToWorldPos(Point(x, y))
    self.entity = ent[item.tags.plants](pos.x, pos.y)
    self.canPlant = state.entities:canAddWithoutCollisions(self.entity, state.player)
    for _, event in ipairs(state.events.mouse) do
      if event.button == 2 and self.canPlant then
        state.player.command = commands.Plant(item, self.entity, state.entities)
        event:halt()
      end
    end
  end
end

function Planter:draw()
  if self.entity and self.canPlant then
    love.graphics.setColor(1, 1, 1, 0.8)
    self.entity:draw()
    love.graphics.setColor(1, 1, 1, 1)
  end
end

local WorldMouseClick = Object:extend()
function WorldMouseClick:update(state)
  for _, event in ipairs(state.events.mouse) do
    if not event.halted and event.button == 1 then
      if not state.hoveringEntity and state.player.inventory:getMouseItem() then
        state.player.command = commands.Drop(state.player, state.player.inventory:getMouseItem(), event.worldPos)
      elseif not state.hoveringEntity then
        state.player.command = commands.Move(Point(event.worldPos.x, event.worldPos.y), state.player.radius)
      elseif rules.canPickUp(state.player, state.hoveringEntity) then
        state.player.command = commands.PickUp(state.hoveringEntity, state.player)
      elseif rules.canAttack(state.player, state.hoveringEntity) then
        state.player.command = commands.Attack(state.hoveringEntity)
      else
        state.player:say("I can't do that")
      end
    end
  end
end

function WorldMouseClick:draw() end

return {
  Planter = Planter,
  WorldMouseClick = WorldMouseClick,
}
