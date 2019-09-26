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

function module.ifilter(t, fn)
  local r = {}
  for i, v in ipairs(t) do
    if fn(v, i) then r[#r+1] = v end
  end
  return r
end

function module.zip(keys, values)
  local hash = {}
  for i, key in ipairs(keys) do
    hash[key] = values[i]
  end
  return hash
end

function module.hasValue(t, v)
  for _, v2 in pairs(t) do
    if v == v2 then return true end
  end
  return false
end

function module.shuffle(t)
  for i = #t, 2, -1 do
    local r = love.math.random(i)
    t[i], t[r] = t[r], t[i]
  end
end

function module.rpick(t)
  return t[love.math.random(#t)]
end

function module.remap(value, minValue, maxValue, minReturn, maxReturn)
  return minReturn + (maxReturn - minReturn) * ((value - minValue) / (maxValue - minValue))
end

-- function module.clampRemap(value, minValue, maxValue, minReturn, maxReturn)
--   return module.clamp(module.remap(value, minValue, maxValue, minReturn, maxReturn), minReturn, maxReturn)
-- end

function module.spawn(n, entity, cls)
  if not entity.newEntities then
    entity.newEntities = {}
  end
  local r = entity.radius
  for i = 1, n do
    table.insert(entity.newEntities, cls(entity.pos.x + love.math.random(-r, r), entity.pos.y + love.math.random(-r, r)))
  end
end

-- time constants to make things more readable
module.time = {}
module.time.second = 1
module.time.minute = 60 * module.time.second
module.time.hour   = 60 * module.time.minute
module.time.day    = 24 * module.time.hour
module.time.week   = 7  * module.time.day

return module
