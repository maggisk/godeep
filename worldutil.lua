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
end

return module
