local Image = require "image"
local Point = require "point"
local Object = require "classic"

local module = {}

-- factory to create simple world entities
function module.create(imgpath, clsAttr)
  local cls = Object:extend()
  cls.radius = 0

  for k, v in pairs(clsAttr or {}) do
    cls[k] = v
  end

  local image = Image(imgpath)
  function cls:new(x, y)
    self.pos = Point(x, y)
    self.image = image
  end

  function cls:draw()
    self.image:draw(self.pos)
  end

  return cls
end

return module
