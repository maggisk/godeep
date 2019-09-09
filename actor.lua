local Point = require "point"
local Object = require "classic"
local Actor = Object:extend()
Actor.enabled = true
Actor.count = 1
Actor.radius = 0
Actor.tags = {}

local _eid = 1

function Actor:new()
  self.eid = _eid
  _eid = _eid + 1
end

function Actor:getImage()
  -- hook to override in child classes if more complex logic is required
  return self.image
end

function Actor:isVisibleAt(worldPos)
  local image = self:getImage()
  if not image or not self.pos then
    return false
  end

  -- todo: move this logic to Image class
  local x = worldPos.x - (self.pos.x - image:getWidth() / 2)
  local y = worldPos.y - (self.pos.y - image:getHeight())
  return image:isVisibleAt(Point(x, y))
end

function Actor:merge(other)
  if self.clsname and self.clsname == other.clsname and self.durability and other.durability then
    self.durability = self.durability + other.durability
    self.count = math.ceil(self.durability / self.tags.durability)
    other.dead = true
    return true
  end

  return false
end

function Actor:draw()
end

function Actor:update()
end

return Actor
