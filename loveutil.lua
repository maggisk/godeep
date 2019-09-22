local _graphics = {}

for k, v in pairs(love.graphics) do
  if type(v) == "function" then
    if k:sub(1, 3) == "get" and love.graphics["set" .. k:sub(4, -1)] then
      _graphics[k:sub(4, -1):lower()] = {
        get = v,
        set = love.graphics["set" .. k:sub(4, -1)],
      }
    end
  end
end

function pack(...)
  return {...}
end

function snapshot(...)
  local state = {}
  for _, k in ipairs({...}) do
    state[k] = pack(_graphics[k].get())
  end

  return function()
    for k, v in pairs(state) do
      _graphics[k].set(v[1], v[2], v[3], v[4])
    end
  end
end

function copyCanvas(original)
  local prev = love.graphics.getCanvas()
  local copy = love.graphics.newCanvas(original:getDimensions())
  love.graphics.setCanvas(copy)
  love.graphics.draw(original, 0, 0)
  love.graphics.setCanvas(prev)
  return copy
end

return {
  graphics = {
    snapshot = snapshot,
    copyCanvas = copyCanvas,
  },
}
