local module = {}

function module.findCollisions(entity, entities)
  local colliding = {}

  for i, other in ipairs(entities) do
    if entity ~= other then
      local r = other.radius + entity.radius
      local xd = math.abs(other.pos.x - entity.pos.x)
      local yd = math.abs(other.pos.y - entity.pos.y)
      if xd < r and yd < r and math.sqrt(xd*xd + yd*yd) < r then
        table.insert(colliding, other)
      end
    end
  end

  return colliding
end

function module.clearDeadEntities(entities, entitiesByTag)
  local i = 1
  for _, entity in ipairs(entities) do
    if entity.dead then
      -- remove from tag => entities mapping
      for tag, _ in pairs(entity.tags) do
        assert(entitiesByTag[tag][entity.eid] ~= nil)
        entitiesByTag[tag][entity.eid] = nil
      end
    else
      entities[i] = entity
      i = i + 1
    end
  end

  for j = i, #entities do
    entities[j] = nil
  end
end

return module
