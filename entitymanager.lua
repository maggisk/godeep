local Object = require "classic"

local EntityManager = Object:extend()
function EntityManager:new()
  self.entities = {}
  self.entitiesByTag = {}
end

function EntityManager:byTag(tag)
  return self.entitiesByTag[tag] or {}
end

function EntityManager:add(entity)
  assert(self.entities[entity] == nil, "can not add the same entity twice")
  self.entities[entity] = entity
  for tag, _ in pairs(entity.tags) do
    if self.entitiesByTag[tag] == nil then
      self.entitiesByTag[tag] = {}
    end
    self.entitiesByTag[tag][entity] = entity
  end
end

function EntityManager:remove(entity)
  self.entities[entity] = nil
  for tag, _ in pairs(entity.tags) do
    self.entitiesByTag[entity] = nil
  end
end

function EntityManager:clearDead()
  for entity, _ in pairs(self.entities) do
    if entity.dead then
      self:remove(entity)
    end
  end
end

function EntityManager:addNewEntities()
  for entity, _ in pairs(self.entities) do
    if entity.newEntities then
      while entity.newEntities[1] do
        self:add(table.remove(entity.newEntities))
      end
    end
  end
end

function EntityManager:updateAll(args)
  for entity, _ in pairs(self.entities) do
    if entity.update and not entity.dead and not entity.disabled then
      entity:update(args)
    end
  end
end

function EntityManager:fixCollisions()
  for being, _ in pairs(self:byTag("alive")) do
    for _, entity in ipairs(self:findCollisions(being, self:byTag("static"))) do
      if not entity.pathable then
        being.pos:subtract(entity.pos):setLength(being.radius + entity.radius):add(entity.pos)
      end
    end
  end
end

function EntityManager:findCollisions(entity, entities)
  local colliding = {}

  for other, _ in pairs(entities or self.entities) do
    if entity ~= other then
      local r = other.radius + entity.radius
      local xd = math.abs(other.pos.x - entity.pos.x)
      local yd = math.abs(other.pos.y - entity.pos.y)
      if xd < r and yd < r and math.sqrt(xd * xd + yd * yd) < r then
        table.insert(colliding, other)
      end
    end
  end

  return colliding
end

function EntityManager:findVisibleEntitiesInRect(top, left, right, bottom, threshold)
  visibleEntities = {}
  threshold = threshold or 100

  for e, _ in pairs(self.entities) do
    local image = e.image
    if not e.disabled and
       e.pos.x + threshold + image:getWidth() / 2 > left and
       e.pos.x - threshold - image:getWidth() / 2 < right and
       e.pos.y + threshold > top and
       e.pos.y - threshold - image:getHeight() then
      table.insert(visibleEntities, e)
    end
  end

  -- sort top to bottom
  table.sort(visibleEntities, function(a, b)
    if a.pos.y ~= b.pos.y then return a.pos.y < b.pos.y end
    return a.pos.x < b.pos.x
  end)

  return visibleEntities
end

return EntityManager
