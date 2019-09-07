local Image = require "image"
local Point = require "point"
local Actor = require "actor"

function create(clsname, imgpath, clsAttr)
  local cls = Actor:extend(clsname)
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
  Axe = create("Axe", "resources/axe.png", {
    weight = 5,
    pathable = true,
    tags = {treecutter = 1}
  })
}
