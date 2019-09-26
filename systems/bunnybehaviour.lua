local Object = require "classic"
local Bunny = require "entities/bunny"
local commands = require "commands"
local World = require "world"
local util = require "util"

local Bunnies = Object:extend()

function Bunnies:update(next, state, dt)
  for bunny, _ in pairs(state.entities.entities:byTag("bunny")) do
    if bunny.command == commands.idle then
      self:wander(bunny, state.entities.world)
    end
  end

  return next
end

function Bunnies:wander(bunny, world)
  -- attempt move in a random direction
  local target = bunny.pos:copy():move(love.math.random() * math.pi * 2, love.math.random(200, 600))

  -- don't move out of forest area
  local area = world:findArea(target)
  if not area or area.type ~= World.AreaTypes.forest then
    return
  end

  -- don't move to where it is in collision
  if not world.entities:canAddWithoutCollisions(Bunny(target.x, target.y), nil, world.entities:byTag("static")) then
    return
  end

  -- otherwise we're good
  local move = commands.Timer(10, commands.Move(target))
  local rest = commands.Timer(util.remap(love.math.random(), 0, 1, 2, 4), commands.idle)
  bunny.command = commands.chain(move, rest)
end

return Bunnies
