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
      assert(#v <= 6)
      _graphics[k].set(v[1], v[2], v[3], v[4], v[5], v[6])
    end
  end
end

-- returns a new canvas identical to the given one. is there an easier way to do this?
function copyCanvas(original)
  love.graphics.push()
  love.graphics.origin()
  local prev = love.graphics.getCanvas()
  local copy = love.graphics.newCanvas(original:getDimensions())
  love.graphics.setCanvas(copy)
  love.graphics.draw(original, 0, 0)
  love.graphics.setCanvas(prev)
  love.graphics.pop()
  return copy
end

return {
  graphics = {
    snapshot = snapshot,
    copyCanvas = copyCanvas,
  },
}
