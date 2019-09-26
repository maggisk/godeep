local Object = require "classic"
local Point = require "point"
local rules = require "gamerules"

local idle
idle = {update = function() return idle end}

local function chain(first, ...)
  local cmd = first
  for _, nextcmd in ipairs({...}) do
    cmd._next = nextcmd
    cmd = nextcmd
  end
  return first
end

local function getNext(cmd)
  return cmd._next or idle
end

local function maybeNext(cmd)
  if cmd.done then return getNext(cmd) end
  return cmd
end

local function tryGetTool(entity, slot)
  slot = slot or "hand"
  if entity.inventory and entity.inventory:get(slot) then
    return entity.inventory:get(slot)
  end
  return entity
end

local function moveCloserTo(entity, target, distance)
  if entity.pos:distanceTo(target) > distance then
    entity.pos:add(target:copy():subtract(entity.pos):setLength(distance))
    return false -- not there yet
  else
    entity.pos:set(target)
    return true -- we're there
  end
end

local Move = Object:extend()
function Move:new(pos, gap)
  self.pos = pos
  self.gap = (gap or 0) + 0.001
end

function Move:update(entity, dt)
  entity.orientation = self.pos:copy():subtract(entity.pos)
  self.done = moveCloserTo(entity, self.pos, entity.speed * dt) or
              entity.pos:distanceTo(self.pos) < self.gap
  return maybeNext(self)
end

local KeyboardMove = Object:extend()
function KeyboardMove:new(movement)
  self.movement = movement
end

function KeyboardMove:update(entity, dt)
  entity.orientation = self.movement:copy()
  entity.pos:add(self.movement:copy():setLength(entity.speed * dt))
  return idle
end

function KeyboardMove.maybe()
  local kbm = Point(0, 0)
  -- TODO: allow remapping keys
  if love.keyboard.isDown("left", "a")  then kbm.x = kbm.x - 1 end
  if love.keyboard.isDown("right", "d") then kbm.x = kbm.x + 1 end
  if love.keyboard.isDown("up", "w")    then kbm.y = kbm.y - 1 end
  if love.keyboard.isDown("down", "s")  then kbm.y = kbm.y + 1 end

  if kbm.x ~= 0 or kbm.y ~= 0 then
    return KeyboardMove(kbm)
  end
end

local Swing = Object:extend()
function Swing:new(target)
  self.target = target
  self.elapsed = 0.0
end

function Swing:update(entity, dt)
  self.elapsed = self.elapsed + dt

  if self.tool == nil then
    self.tool = tryGetTool(entity)
  end

  if tryGetTool(entity) ~= self.tool then
    -- abort swing if player changes hand tool mid-swing
    self.done = true
  elseif self.elapsed >= self.tool.tags.swingTime then
    self.done = true
    -- only do the attack if the target hasn't moved out of range while we swang our weapon
    if entity.pos:distanceTo(self.target.pos) <= entity.radius + self.target.radius + self.tool.tags.range then
      rules.doAttack(entity, self.target)
    end
  end

  return maybeNext(self)
end

local Attack = Object:extend()
function Attack:new(target)
  self.target = target
  self.move = Move(target.pos)
end

function Attack:update(entity, dt)
  if entity.pos:distanceTo(self.target.pos) <= entity.radius + self.target.radius + tryGetTool(entity).tags.range then
    return chain(Swing(self.target), self._next)
  end
  self.move:update(entity, dt)
  return self
end

local PickUp = Object:extend()
function PickUp:new(target, source)
  self.target = target
  self.source = source
  self.move = Move(target.pos, math.max(target.radius, source.radius))
end

function PickUp:update(entity, dt)
  self.move:update(entity, dt)
  if self.move.done then
    entity.inventory:add(self.target)
    return getNext(self)
  end
  return self
end

local Plant = Object:extend()
function Plant:new(source, target, entities)
  self.source = source
  self.target = target
  self.entities = entities
  self.move = Move(target.pos, target.radius)
end

function Plant:update(entity, dt)
  self.move:update(entity, dt)
  if self.move.done then
    self.entities:add(self.target)
    rules.decrement(self.source)
    if self.target.planted then self.target:planted() end
    return getNext(self)
  end
  return self
end

local Drop = Object:extend()
function Drop:new(source, item, target)
  self.target = target
  self.item = item
  self.move = Move(target, source.radius)
end

function Drop:update(entity, dt)
  self.move:update(entity, dt)
  if self.move.done then
    entity.inventory:drop(self.item, self.target)
    return getNext(self)
  end
  return self
end

local Harvest = Object:extend()
function Harvest:new(player, target, entities)
  self.target = target
  self.entities = entities
  self.move = Move(target.pos, player.radius + target.radius)
end

function Harvest:update(entity, dt)
  self.move:update(entity, dt)
  if self.move.done then
    if self.target.harvested then self.target:harvested() end
    local harvest = self.target.tags.provides(0, 0)
    self.entities:add(harvest)
    entity.inventory:add(harvest)
    return getNext(self)
  end
  return self
end

local Timer = Object:extend()
function Timer:new(duration, cmd)
  self.ttl = duration
  self.cmd = cmd
end

function Timer:update(entity, dt)
  self.ttl = self.ttl - dt
  if self.ttl < 0 then
    return getNext(self)
  end

  self.cmd:update(entity, dt)
  self.done = self.cmd.done
  return maybeNext(self)
end

return {
  idle = idle,
  chain = chain,
  Move = Move,
  KeyboardMove = KeyboardMove,
  Attack = Attack,
  PickUp = PickUp,
  Drop = Drop,
  Plant = Plant,
  Swing = Swing,
  Harvest = Harvest,
  Timer = Timer,
}
