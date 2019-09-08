local Point = require "point"
local Actor = require "actor"
local Image = require "image"

local Tree = Actor:extend()
Tree.radius = 25
Tree.tags = {tree = true, takesDamageFrom = {treecutter = true}}

local image = Image("resources/treeshake.png", {frames = 7, duration = 0.3})

function Tree:new(x, y)
  Tree.super.new(self)
  self.pos = Point(x, y)
  self.hp = 10
  self.image = image:copy()
end

function Tree:update(args)
  self.image:update(args.dt)
end

function Tree:draw()
  self.image:draw(self.pos)
end

function Tree:takeHit(from, updateArgs)
  local damage = from.tags.treecutter
  if damage == nil or from.inventory:inHand().tags.treecutter > damage then
    damage = from.inventory:inHand().tags.treecutter
  end

  self.hp = self.hp - damage
  if self.hp <= 0 then
    self.dead = true
  else
    self.image:animate()
  end
end

function Tree:attemptToHit(player)
  if player.inventory:inHand() then
    player:say("That's not great tool to cut down a tree!")
  else
    player:say("I can't cut down a tree with my bare hands!")
  end
end

return Tree
