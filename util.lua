local M = {}

function M.clamp(v, lower, upper)
  return math.max(lower, math.min(upper, v))
end

return M
