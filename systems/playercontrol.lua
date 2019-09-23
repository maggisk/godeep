local Object = require "classic"
local commands = require "commands"
local rules = require "gamerules"
local Point = require "point"

local PlayerControl = Object:extend()

function PlayerControl:MOUSEPRESSED(event, state)
  local player = state.entities.player

  if not event.halted and event.button == 1 then
    if not state.entities.hoveringEntity and player.inventory:getMouseItem() then
      player.command = commands.Drop(player, player.inventory:getMouseItem(), event.world)
    elseif not state.entities.hoveringEntity then
      player.command = commands.Move(Point(event.world.x, event.world.y), player.radius)
    elseif rules.canPickUp(player, state.entities.hoveringEntity) then
      player.command = commands.PickUp(state.entities.hoveringEntity, player)
    elseif rules.canAttack(player, state.entities.hoveringEntity) then
      if getmetatable(player.command) ~= commands.Swing or player.command.target ~= state.entities.hoveringEntity then
        player.command = commands.Attack(state.entities.hoveringEntity)
      end
    else
      player:say("I can't do that")
    end
  end
end

return PlayerControl
