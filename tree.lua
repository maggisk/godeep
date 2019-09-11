local Point = require "point"
local Actor = require "actor"
local Image = require "image"

local Tree = Actor:extend("Tree")
Tree.className = "Tree"
Tree.radius = 25
Tree.tags = {type = "tree", takesDamageFrom = {treecutter = true}}

local image = Image("resources/treeshake.png", {frames = 7, duration = 0.3})

function Tree:new(x, y)
  Tree.super.new(self)
  self.pos = Point(x, y)
  self.hitpoints = 10
  self.image = image:copy()
end

function Tree:update(args)
  self.image:update(args.dt)
end

function Tree:draw()
  self.image:draw(self.pos)
end

function Tree:tookHit()
  self.image:animate()
end

function Tree:attemptToHit(player)
  if player.inventory:get("hand") then
    player:say("That's the wrong tool!")
  else
    player:say("I can't do that with my bare hands!")
  end
end

return Tree
