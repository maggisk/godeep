local Object = require "classic"
local EntityManager = require "entitymanager"
local ent = require "entities"
local shaders = require "shaders"
local World = require "world"
local Point = require "point"

local WorldSystem = Object:extend()
function WorldSystem:new()
  self.state = self.state or {}
  self.state.world = World()
  self.state.entities = self.state.world.entities
  self.state.player = ent.Player(0, 0)
  self.state.entities:add(self.state.player)
  self.state.world:generate()
  for e, _ in pairs(self.state.entities.all) do
    if e.atWorldCreation then e:atWorldCreation() end
  end
end

function WorldSystem:init(state)
  self.state.visibleEntities = self.state.entities:findVisibleEntitiesInRect(state.camera:visibleRect())
  self.state.hoveringEntity = self:findHoveringEntity(self.state.visibleEntities, state.camera)
end

function WorldSystem:update(next, state, dt)
  self.state.entities:updateAll({dt = dt, entities = self.entities})
  self.state.entities:addNewEntities()
  self.state.entities:clearDead()
  self.state.entities:fixCollisions()
  for entity, _ in pairs(self.state.entities:byTag("alive")) do
    self.state.world:contain(entity)
  end
  self.state.visibleEntities = self.state.entities:findVisibleEntitiesInRect(state.camera:visibleRect())
  self.state.hoveringEntity = self:findHoveringEntity(self.state.visibleEntities, state.camera)
  return next
end

function WorldSystem:findHoveringEntity(entities, camera)
  local x, y = love.mouse.getPosition()
  local mousePos = camera:screenToWorldPos(Point(x, y))

  for i = #entities, 1, -1 do
    local e = entities[i]
    if e ~= self.state.player and e.image:isVisibleAt(e.pos, mousePos) then
      return e
    end
  end
end

function WorldSystem:draw(next)
  self.state.world:draw()
  local shader = love.graphics.getShader()

  for _, entity in pairs(self.state.visibleEntities) do
    local hovering = (entity == self.state.hoveringEntity)
    if hovering then love.graphics.setShader(shaders.brighten) end
    entity:draw()
    if hovering then love.graphics.setShader(shader) end
  end

  return next
end

return WorldSystem
