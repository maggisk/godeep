local Object = require "classic"
local ent = require "entities"
local commands = require "commands"
local Point = require "point"
local rules = require "gamerules"
local U = require "underscore"
local ep = require "eventprocessing"

local Planter = Object:extend()
function Planter:update(state)
  self.entity = nil

  local item = state.player.inventory:getMouseItem()
  if item and item.tags.plants and not state.hoveringEntity then
    local x, y = love.mouse.getPosition()
    local pos = state.camera:screenToWorldPos(Point(x, y))
    self.entity = ent[item.tags.plants](pos.x, pos.y, {planting = true})
    self.canPlant = state.entities:canAddWithoutCollisions(self.entity, state.player)
    if self.canPlant then
      for _, event in ipairs(ep.filter(state.events, {type = "click", halted = false, button = 2})) do
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
function WorldMouseClick:new()
  self.visuals = {}
  self.duration = 0.5
end

function WorldMouseClick:update(state, dt)
  for i, v in ipairs(self.visuals) do
    v.duration = v.duration + dt
  end

  while self.visuals[1] and self.visuals[1].duration > self.duration do
    table.remove(self.visuals, 1)
  end

  for _, event in ipairs(ep.filter(state.events, {halted = false, button = 1})) do
    table.insert(self.visuals, {duration = 0, x = event.world.x, y = event.world.y})

    if not state.hoveringEntity and state.player.inventory:getMouseItem() then
      state.player.command = commands.Drop(state.player, state.player.inventory:getMouseItem(), event.world)
    elseif not state.hoveringEntity then
      state.player.command = commands.Move(Point(event.world.x, event.world.y), state.player.radius)
    elseif rules.canPickUp(state.player, state.hoveringEntity) then
      state.player.command = commands.PickUp(state.hoveringEntity, state.player)
    elseif rules.canAttack(state.player, state.hoveringEntity) then
      if getmetatable(state.player.command) ~= commands.Swing or state.player.command.target ~= state.hoveringEntity then
        state.player.command = commands.Attack(state.hoveringEntity)
      end
    else
      state.player:say("I can't do that")
    end
  end
end

function WorldMouseClick:draw()
  for _, v in ipairs(self.visuals) do
    love.graphics.setColor(0.1, 1, 0.1, 1 - v.duration / self.duration)
    love.graphics.circle("line", v.x, v.y, v.duration / self.duration * 20)
  end
  love.graphics.setColor(1, 1, 1, 1)
end

return {
  Planter = Planter,
  WorldMouseClick = WorldMouseClick,
}
