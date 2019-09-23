local module = {}

function module.clamp(v, lower, upper)
  return math.max(lower, math.min(upper, v))
end

function module.toboolean(v)
  return not not v
end

function module.keys(t)
  local keys = {}
  for k, _ in pairs(t) do
    table.insert(keys, k)
  end
  return keys
end

function module.hasValue(t, v)
  for _, v2 in pairs(t) do
    if v == v2 then return true end
  end
  return false
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
