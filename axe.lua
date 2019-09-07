local Image = require "image"
local Actor = require "actor"
local Point = require "point"

local Axe = Actor:extend("Axe")
Axe.weight = 5
Axe.pathable = true
Axe.radius = 5
Axe.tags = {treecutter = 1}

local image = Image("resources/axe.png")
Axe.image = image

function Axe:new(x, y)
  self.pos = Point(x, y)
end

function Axe:draw()
  image:draw(self.pos)
end

return Axe
