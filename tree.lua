local Object = require "classic"
local Point = require "point"
local Image = require "image"

local Tree = Object:extend()

Tree.radius = 30
Tree.tags = {type = "tree", takesDamageFrom = {treecutter = true}}

local image = Image("resources/treeshake.png", {frames = 7, duration = 0.3, offsetY = 30, offsetX = -10})

function Tree:new(x, y)
  self.pos = Point(x, y)
  self.hitpoints = 10
  self.newEntities = {}
  self.image = image
end

function Tree:update(args)
  if self.image ~= image then
    self.image:update(args.dt)
  end
end

function Tree:draw()
  self.image:draw(self.pos)
end

function Tree:tookHit()
  -- copy the image the first time we animate it so we can share an image object for all trees initially
  if self.image == image then
    self.image = image:copy()
  end
  self.image:animate()
end

function Tree:die()
  -- spawn logs when tree dies
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
