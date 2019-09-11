local Image = require "image"
local Point = require "point"
local Actor = require "actor"

-- factory to create simple world entities
function create(imgpath, clsAttr)
  local cls = Actor:extend()
  for k, v in pairs(clsAttr or {}) do
    cls[k] = v
  end

  local image = Image(imgpath)
  function cls:new(x, y)
    cls.super.new(self)
    self.pos = Point(x, y)
    self.image = image
  end

  function cls:draw()
    image:draw(self.pos)
  end

  return cls
end

return {
  Player = require "player",
  Tree = require "tree",
  Rock = require "rock",
  Axe = create("resources/axe.png", {weight = 5, pathable = true, durability = 30, count = 1,
    tags = {durability = 30, wearable = "hand", damage = 10, range = 5, treecutter = 1, swingTime = 0.3}}),
  Log = create("resources/log.png", {weight = 5, pathable = true, count = 1, tags = {}}),
}
