local Object = require "classic"
local Camera = require "camera"
local Point = require "point"
local ent = require "entities"
local shaders = require "shaders"
local EntityManager = require "entitymanager"
local systems = require "systems"
local ep = require "eventprocessing"

function randomEntities(EntityClass, n, entities)
  local i = 0
  while i < n do
    local entity = EntityClass(love.math.random(-5000, 5000), love.math.random(-5000, 5000))
    if #entities:findCollisions(entity) == 0 then
      entities:add(entity)
      i = i + 1
    end
  end
end

local World = Object:extend()

function World:new()
  self.player = ent.Player(0, 0)
  self.entities = EntityManager()
  self.visibleEntities = {}
  self.hoveringEntity = nil
  self.events = {}
  self.camera = Camera()
  self.systems = {
    systems.Planter(),
    systems.WorldMouseClick(),
  }

  self.entities:add(self.player)
  randomEntities(ent.Axe, 100, self.entities)
  randomEntities(ent.PineCone, 100, self.entities)
  randomEntities(ent.Tree, 1000, self.entities)
  randomEntities(ent.Rock, 100, self.entities)
end

function World:update(dt)
  self.entities:updateAll({dt = dt, entities = self.entities})
  self.entities:addNewEntities()
  self.entities:clearDead()
  self.entities:fixCollisions()
  local left, top, right, bottom = self.camera:visibleRect()
  self.visibleEntities = self.entities:findVisibleEntitiesInRect(top, left, right, bottom)
  self.hoveringEntity = self:findHoveringEntity(self.visibleEntities)
  self.camera:follow(self.player.pos)
  self.camera:update(dt)

  -- we pass to the systems all public attributes of the world object
  local state = {}
  for k, v in pairs(self) do
    if k:sub(1, 1) ~= "_" then
      state[k] = v
    end
  end

  for _, system in ipairs(self.systems) do
    system:update(state, dt)
  end

  self.events = {}
end

function World:draw()
  love.graphics.clear(0.0, 59.0/255.0, 111.0/255.0, 1.0)

  love.graphics.push()
  self.camera:apply()

  for _, entity in ipairs(self.visibleEntities) do
    local hovering = (entity == self.hoveringEntity)
    if hovering then love.graphics.setShader(shaders.brighten) end
    entity:draw()
    if hovering then love.graphics.setShader() end
  end

  for _, system in ipairs(self.systems) do
    system:draw()
  end

  love.graphics.pop()

  self.player:drawAbsolute()
  love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
end

function World:mousepressed(x, y, button, istouch, presses)
  local event = ep.Event("mouse", "click", {
    button = button,
    istouch = istouch,
    presses = presses,
    screen = Point(x, y),
    world = self.camera:screenToWorldPos(Point(x, y))
  })
  -- TODO: make inventory mouse event handler into a system
  event:callMethod(self.player.inventory, "processMouseEvent")
  event:callFunc(function() table.insert(self.events, event) end)
end

function World:findHoveringEntity(entities)
  local x, y = love.mouse.getPosition()
  local mousePos = self.camera:screenToWorldPos(Point(x, y))

  for i = #entities, 1, -1 do
    local e = entities[i]
    if e ~= self.player and e.image:isVisibleAt(e.pos, mousePos) then
      return e
    end
  end
end

return World
