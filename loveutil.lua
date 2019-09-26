local loveProperties = {}

for name, getter in pairs(love.graphics) do
  local setter = love.graphics["set" .. name:sub(4, -1)]
  if name:sub(1, 3) == "get" and type(getter) == "function" and type(setter) == "function" then
    loveProperties[name:sub(4, -1):lower()] = {get = getter, set = setter}
  end
end

local function pack(...)
  return {...}
end

local function snapshot(...)
  local state = {}
  for _, k in ipairs({...}) do
    state[k] = pack(loveProperties[k].get())
  end

  return function()
    for k, v in pairs(state) do
      assert(#v <= 6)
      loveProperties[k].set(v[1], v[2], v[3], v[4], v[5], v[6])
    end
  end
end

-- returns a new canvas identical to the given one. is there an easier way to do this?
local function copyCanvas(original)
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
  snapshot = snapshot,
  copyCanvas = copyCanvas,
}
