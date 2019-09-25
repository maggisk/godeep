local Object = require "classic"
local EntityManager = require "entitymanager"
local ent = require "entities"
local shaders = require "shaders"
local World = require "world"
local Point = require "point"

local Entities = Object:extend()
function Entities:new()
  self.state = self.state or {}
  self.state.world = World()
  self.state.entities = self.state.world.entities
  self.state.player = ent.Player(0, 0)
  self.state.entities:add(self.state.player)
  self.state.visibleEntities = {}
  self.state.hoveringEntity = nil
  self.state.world:generate()
end

function Entities:update(next, state, dt)
  self.state.entities:updateAll({dt = dt, entities = self.entities})
  self.state.entities:addNewEntities()
  self.state.entities:clearDead()
  self.state.entities:fixCollisions()
  for entity, _ in pairs(self.state.entities:byTag("alive")) do
    self.state.world:contain(entity)
  end
  local left, top, right, bottom = state.camera:visibleRect()
  self.state.visibleEntities = self.state.entities:findVisibleEntitiesInRect(top, left, right, bottom)
  self.state.hoveringEntity = self:findHoveringEntity(self.state.visibleEntities, state.camera)
  return next
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
  self.state.world:draw()
  for _, entity in pairs(self.state.visibleEntities) do
    local hovering = (entity == self.state.hoveringEntity)
    if hovering then love.graphics.setShader(shaders.brighten) end
    entity:draw()
    if hovering then love.graphics.setShader() end
  end

  return next
end

return Entities
