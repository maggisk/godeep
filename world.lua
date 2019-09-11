local Object = require "classic"
local Camera = require "camera"
local Point = require "point"
local ent = require "entities"
local shaders = require "shaders"
local wutil = require "worldutil"

local MouseEvent = Object:extend()
function MouseEvent:new(type, x, y, attr)
  self.type = type
  self.x = x
  self.y = y
  for k, v in pairs(attr) do
    self[k] = v
  end
  self.halted = false
end

function MouseEvent:halt()
  self.halted = true
end

function MouseEvent:callFunc(func, ...)
  if not self.halted then
    func(self, ...)
  end
end

function MouseEvent:callMethod(obj, methodName, ...)
  if not self.halted then
    obj[methodName](obj, self, ...)
  end
end

function genTrees(n, world)
  local i = 0
  while i < n do
    local tree = ent.Tree(love.math.random(-10000, 10000), love.math.random(-10000, 10000))
    if #wutil.findCollisions(tree, world.entities) == 0 then
      world:addEntity(tree)
      i = i + 1
    end
  end
end

local World = Object:extend()

function World:new()
  self.player = ent.Player(0, 0)
  self.entities = {}
  self.entitiesByTag = {}
  self.visibleEntities = {}
  self.hoveringEntity = nil
  self.camera = Camera()
  self.nextEntityId = 0

  self:addEntity(self.player)
  self:addEntity(ent.Axe(40, 60))
  self:addEntity(ent.Axe(60, 60))
  self:addEntity(ent.Axe(40, 100))
  self:addEntity(ent.Axe(100, 60))

  genTrees(10000, self)
end

function World:addEntity(entity)
  assert(entity.eid == nil, "entity can not be added twice")
  assert(type(entity.tags) == "table", "entity must have a tags table")
  assert(entity.pos.x)
  assert(entity.pos.y)

  self.nextEntityId = self.nextEntityId + 1
  entity.eid = self.nextEntityId

  table.insert(self.entities, entity)
  for tag, _ in pairs(entity.tags) do
    if self.entitiesByTag[tag] == nil then
      self.entitiesByTag[tag] = {}
    end
    assert(self.entitiesByTag[tag][entity.eid] == nil)
    self.entitiesByTag[tag][entity.eid] = entity
  end
end

function World:update(dt)
  self:collectVisibleEntities()
  self:setHoveringEntity()

  -- call update on all entities in the world
  local args = {dt = dt, world = self}
  for _, entity in ipairs(self.entities) do
    entity:update(args)
  end

  -- add new entities that may have been created in the last update call
  for _, entity in ipairs(self.entities) do
    if entity.newEntities then
      while entity.newEntities[1] do
        self:addEntity(table.remove(entity.newEntities))
      end
    end
  end

  wutil.clearDeadEntities(self.entities, self.entitiesByTag)
  self:fixCollisions()
  self.camera:follow(self.player.pos)
  self.camera:update(dt)
end

function World:draw()
  love.graphics.clear(0.0, 59.0/255.0, 111.0/255.0, 1.0)

  love.graphics.push()
  self.camera:apply()

  local x, y = love.mouse.getPosition()
  local mousePos = self.camera:screenToWorldPos(Point(x, y))

  for i, obj in pairs(self.visibleEntities) do
    local hovering = obj == self.hoveringEntity
    if hovering then love.graphics.setShader(shaders.brighten) end
    obj:draw()
    if hovering then love.graphics.setShader() end
  end

  love.graphics.pop()

  self.player:drawAbsolute()
  love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
end

function World:mousepressed(x, y, button, istouch, presses)
  local e = MouseEvent("click", x, y, {button = button, istouch = istouch, presses = presses})
  e:callMethod(self.player.inventory, "processMouseEvent")
  e:callMethod(self, "handleMouseClick")
end

function World:handleMouseClick(e)
  if self.hoveringEntity then
    self.player:hit(self.hoveringEntity)
  else
    self.player:moveTo(self.camera:screenToWorldPos(Point(e.x, e.y)))
  end
end

function World:collectVisibleEntities(threshold)
  threshold = threshold or 100
  self.visibleEntities = {}

  local left, top, right, bottom = self.camera:visibleRect()
  for i, e in ipairs(self.entities) do
    local image = e:getImage()
    if e.enabled and
       e.pos.x + threshold + image:getWidth() / 2 > left and
       e.pos.x - threshold - image:getWidth() / 2 < right and
       e.pos.y + threshold > top and
       e.pos.y - threshold - image:getHeight() then
      table.insert(self.visibleEntities, e)
    end
  end

  -- sort top to bottom
  table.sort(self.visibleEntities, function(a, b)
    if a.pos.y ~= b.pos.y then return a.pos.y < b.pos.y end
    if a.pos.x ~= b.pos.x then return a.pos.x < b.pos.x end
    -- compare entity id if x and y coordinates are identical to make the sort stable
    return a.eid < b.eid
  end)
end

function World:setHoveringEntity()
  self.hoveringEntity = nil

  local x, y = love.mouse.getPosition()
  local mousePos = self.camera:screenToWorldPos(Point(x, y))

  for i = #self.visibleEntities, 1, -1 do
    local e = self.visibleEntities[i]
    if e ~= self.player and e:isVisibleAt(mousePos) then
      self.hoveringEntity = e
      break
    end
  end
end

function World:fixCollisions()
  for i, obj in ipairs(self:findCollisions(self.player)) do
    if not obj.pathable then
      self.player.pos:subtract(obj.pos):setLength(self.player.radius + obj.radius):add(obj.pos)
    end
  end
end

function World:findCollisions(obj)
  local colliding = {}
  for i, other in ipairs(self.entities) do
    if obj ~= other then
      local r = other.radius + obj.radius
      local xd = math.abs(other.pos.x - obj.pos.x)
      local yd = math.abs(other.pos.y - obj.pos.y)
      if xd < r and yd < r and math.sqrt(xd*xd + yd*yd) < r then
        table.insert(colliding, other)
      end
    end
  end
  return colliding
end

return World
