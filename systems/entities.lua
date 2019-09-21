local Object = require "classic"
local EntityManager = require "entitymanager"
local ent = require "entities"
local shaders = require "shaders"
local Point = require "point"

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

local Entities = Object:extend()
function Entities:new()
  self.state = {
    player = ent.Player(0, 0),
    entities = EntityManager(),
    visibleEntities = {},
    hoveringEntity = nil,
  }
  self.state.entities:add(self.state.player)
  randomEntities(ent.Axe, 100, self.state.entities)
  randomEntities(ent.PineCone, 100, self.state.entities)
  randomEntities(ent.Tree, 1000, self.state.entities)
  randomEntities(ent.Rock, 100, self.state.entities)
end

function Entities:update(next, state, dt)
  self.state.entities:updateAll({dt = dt, entities = self.entities})
  self.state.entities:addNewEntities()
  self.state.entities:clearDead()
  self.state.entities:fixCollisions()
  local left, top, right, bottom = state.camera:visibleRect()
  self.state.visibleEntities = self.state.entities:findVisibleEntitiesInRect(top, left, right, bottom)
  self.state.hoveringEntity = self:findHoveringEntity(self.state.visibleEntities, state.camera)
  next()
end

function Entities:findHoveringEntity(entities, camera)
  local x, y = love.mouse.getPosition()
  local mousePos = camera:screenToWorldPos(Point(x, y))

  for i = #entities, 1, -1 do
    local e = entities[i]
    if e ~= self.state.player and e.image:isVisibleAt(e.pos, mousePos) then
      return e
    end
  end
end

function Entities:draw(next)
  love.graphics.clear(0.1, 0.2, 0, 1)
  for _, entity in pairs(self.state.visibleEntities) do
    local hovering = (entity == self.state.hoveringEntity)
    if hovering then love.graphics.setShader(shaders.brighten) end
    entity:draw()
    if hovering then love.graphics.setShader() end
  end

  next()
end

return Entities
