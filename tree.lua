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
  self.newEntities = {}
end

function Tree:getImage()
  return self.image or image
end

function Tree:update(args)
  if self.image then
    self.image:update(args.dt)
  end
end

function Tree:draw()
  self:getImage():draw(self.pos)
end

function Tree:tookHit()
  self.image = self.image or image:copy()
  self.image:animate()
end

function Tree:die()
  local Log = require('entities').Log
  for i = 1, 4 do
    table.insert(self.newEntities, Log(self.pos.x + love.math.random(-20, 20), self.pos.y + love.math.random(-20, 20)))
  end
end

function Tree:attemptToHit(player)
  if player.inventory:get("hand") then
    player:say("That's the wrong tool!")
  else
    player:say("I can't do that with my bare hands!")
  end
end

return Tree
