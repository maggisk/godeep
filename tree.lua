local Point = require "point"
local Actor = require "actor"
local Image = require "image"

local Tree = Actor:extend()
Tree.radius = 25
Tree.tags = {tree = true, takesDamageFrom = {"treecutter"}}

local image = Image("resources/treeshake.png", {frames = 7, duration = 0.3})

function Tree:new(x, y)
  Tree.super.new(self)
  self.pos = Point(x, y)
  self.hp = 5
  self.image = image:copy()
end

function Tree:update(args)
  self.image:update(args.dt)
end

function Tree:draw()
  self.image:draw(self.pos)
end

function Tree:take_hit(updateArgs)
  self.hp = self.hp - 1
  if self.hp <= 0 then
    self.dead = true
  else
    self.image:animate()
  end
end

return Tree
