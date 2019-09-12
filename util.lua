local module = {}

function module.clamp(v, lower, upper)
  return math.max(lower, math.min(upper, v))
end

function module.toboolean(v)
  return not not v
end

function module.spawn(n, entity, cls)
  if not entity.newEntities then
    entity.newEntities = {}
  end
  local r = entity.radius
  for i = 1, n do
    table.insert(entity.newEntities, cls(entity.pos.x + love.math.random(-r, r), entity.pos.y + love.math.random(-r, r)))
  end
end

return module
