local module = {}

function module.clamp(v, lower, upper)
  return math.max(lower, math.min(upper, v))
end

function module.toboolean(v)
  return not not v
end
