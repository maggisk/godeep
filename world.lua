local Object = require "classic"
local Camera = require "camera"
local Point = require "point"
local ent = require "entities"
local shaders = require "shaders"

local World = Object:extend()

function World:new()
  self.player = ent.Player(0, 0)
  self.entities = {self.player, ent.Tree(100, 100), ent.Axe(400, 200)}
  self.visibleEntities = {}
  self.hoveringEntity = nil
  self.camera = Camera()
end

function World:update(dt)
  self:collectVisibleEntities()
  self:setHoveringEntity()

  local args = {dt = dt, world = self}
  for i = 1, #self.entities do
    self.entities[i]:update(args)
  end

  self:dumpTheDead()
  self:fixCollisions()
  self.camera:set(self.player.pos)
end

function World:draw()
  love.graphics.clear(0.0, 59.0/255.0, 111.0/255.0, 1.0)

  love.graphics.push()
  self.camera:set(self.player.pos)

  local x, y = love.mouse.getPosition()
  local mousePos = self.camera:s2w(Point(x, y))

  for i, obj in pairs(self.visibleEntities) do
    if obj == self.hoveringEntity then
      love.graphics.setShader(shaders.brighten)
      obj:draw()
      love.graphics.setShader()
    elseif obj.enabled then
      obj:draw()
    end
  end

  love.graphics.pop()

  self.player.inventory:draw()
  love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
end

function World:mousepressed(x, y, button, istouch, presses)
  if self.hoveringEntity then
    self.player:hit(self.hoveringEntity)
  else
    self.player:move_to(self.camera:s2w(Point(x, y)))
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
  table.sort(self.visibleEntities, function(a, b) return a.pos.y < b.pos.y end)
end

function World:setHoveringEntity()
  self.hoveringEntity = nil

  local x, y = love.mouse.getPosition()
  local mousePos = self.camera:s2w(Point(x, y))

  for i = #self.visibleEntities, 1, -1 do
    local e = self.visibleEntities[i]
    if e ~= self.player and e:isVisibleAt(mousePos) then
      self.hoveringEntity = e
      break
    end
  end
end

function World:dumpTheDead()
  local insertAt = 1
  for i, obj in ipairs(self.entities) do
    if not obj.dead then
      self.entities[insertAt] = obj
      insertAt = insertAt + 1
    end
  end
  while #self.entities >= insertAt do
    table.remove(self.entities)
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
