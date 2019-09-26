local Image = require "image"
local Point = require "point"
local Object = require "classic"
local util = require "util"

local module = {}

-- factory to create simple world entities
function module.create(imgpath, clsAttr)
  local cls = Object:extend()
  cls.radius = 0

  for k, v in pairs(clsAttr or {}) do
    cls[k] = v
  end

  cls.image = Image(imgpath)
  function cls:new(x, y)
    self.pos = Point(x, y)
  end

  function cls:draw()
    self.image:draw(self.pos)
  end

  return cls
end


function module.createPlant(imgpath, clsAttr)
  assert(clsAttr.tags and clsAttr.tags.provides, "A plant must provide a harvest")

  local cls = module.create(imgpath, clsAttr)
  local timeToProvideHarvest = cls.timeToProvideHarvest or util.time.hour

  function cls:new(x, y)
    self.pos = Point(x, y)
    self.harvestTTL = timeToProvideHarvest
    self.hasHarvest = false
  end

  function cls:update(args)
    self.harvestTTL = self.harvestTTL - args.dt
    self.hasHarvest = self.harvestTTL <= 0
  end

  function cls:harvested()
    self.harvestTTL = timeToProvideHarvest
    self.canHarvest = false
  end

  function cls:atWorldCreation()
    self.harvestTTL = 0
    self.hasHarvest = true
  end

  return cls
end

return module
