local Object = require "classic"

function getOrSetEmpty(t, k)
  if not t[k] then t[k] = {} end
  return t[k]
end

function isColliding(a, b)
  return (a.pos.x - b.pos.x)^2 + (a.pos.y - b.pos.y)^2 < (a.radius + b.radius)^2
end

local Bucketer = Object:extend()
function Bucketer:new(gridSize)
  self.buckets = {}
  self.entityToBucket = {}
  self.gridSize = gridSize or 100
end

function Bucketer:floor(n)
  return math.floor(n / self.gridSize)
end

function Bucketer:getBucket(x, y)
  local xBuckets = getOrSetEmpty(self.buckets, self:floor(x))
  return getOrSetEmpty(xBuckets, self:floor(y))
end

function Bucketer:add(entity)
  local bucket = self:getBucket(entity.pos.x, entity.pos.y)
  bucket[entity] = entity.pos:copy()
  self.entityToBucket[entity] = bucket
end

function Bucketer:remove(entity)
  self.entityToBucket[entity][entity] = nil
  self.entityToBucket[entity] = nil
end

function Bucketer:update()
  for entity, bucket in pairs(self.entityToBucket) do
    if not entity.pos:eq(bucket[entity]) then
      self:remove(entity)
      self:add(entity)
    end
  end
end

function Bucketer:findInBucketRadius(pos, radius)
  local entities = {}

  for x = self:floor(pos.x - radius), self:floor(pos.x + radius) do
    for y = self:floor(pos.y - radius), self:floor(pos.y + radius) do
      if self.buckets[x] and self.buckets[x][y] then
        for entity, _ in pairs(self.buckets[x][y]) do
          table.insert(entities, entity)
        end
      end
    end
  end

  return entities
end

local EntityManager = Object:extend()
function EntityManager:new()
  self.all = {}
  self.entitiesByTag = {}
  self.buckets = Bucketer()
  self.maxEntityRadius = 0
end

function EntityManager:byTag(tag)
  return self.entitiesByTag[tag] or {}
end

function EntityManager:add(entity)
  assert(self.all[entity] == nil, "can not add the same entity twice")
  self.buckets:add(entity)
  self.maxEntityRadius = math.max(self.maxEntityRadius, entity.radius or 0)

  self.all[entity] = entity
  for tag, _ in pairs(entity.tags) do
    if self.entitiesByTag[tag] == nil then
      self.entitiesByTag[tag] = {}
    end
    self.entitiesByTag[tag][entity] = entity
  end
end

function EntityManager:remove(entity)
  assert(self.all[entity])
  self.buckets:remove(entity)

  self.all[entity] = nil
  for tag, _ in pairs(entity.tags) do
    assert(self.entitiesByTag[tag][entity])
    self.entitiesByTag[tag][entity] = nil
  end
end

function EntityManager:clearDead()
  for entity, _ in pairs(self.all) do
    if entity.dead then
      self:remove(entity)
    end
  end
end

function EntityManager:addNewEntities()
  for entity, _ in pairs(self.all) do
    if entity.newEntities then
      while entity.newEntities[1] do
        self:add(table.remove(entity.newEntities))
      end
    end
  end
end

function EntityManager:updateAll(args)
  for entity, _ in pairs(self.all) do
    if entity.update and not entity.dead and not entity.disabled then
      entity:update(args)
    end
  end
  self.buckets:update()
end

function EntityManager:fixCollisions()
  for being, _ in pairs(self:byTag("alive")) do
    for _, entity in ipairs(self.buckets:findInBucketRadius(being.pos, being.radius + self.maxEntityRadius)) do
      if entity ~= being and isColliding(entity, being) then
        being.pos:subtract(entity.pos):setLength(being.radius + entity.radius):add(entity.pos)
      end
    end
  end
end

function EntityManager:canAddWithoutCollisions(entity, exclude, entities)
  for _, other in ipairs(self:findCollisions(entity, entities)) do
    if other ~= exclude and not other.disabled then
      return false
    end
  end
  return true
end

function EntityManager:findCollisions(entity, entities)
  local colliding = {}

  for other, _ in pairs(entities or self.all) do
    if entity ~= other and isColliding(entity, other) then
      table.insert(colliding, other)
    end
  end

  return colliding
end

function EntityManager:findVisibleEntitiesInRect(top, left, right, bottom, threshold)
  visibleEntities = {}
  threshold = threshold or 100

  for e, _ in pairs(self.all) do
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
