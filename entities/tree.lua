local Object = require "classic"
local Point = require "point"
local Image = require "image"
local simple = require "entities/simple_entities"
local util = require "util"

local Tree = Object:extend()

Tree.radius = 30
Tree.tags = {static = true, takesDamageFrom = {treecutter = true}}
Tree.saplingRatio = 0.4

local image = Image("resources/treeshake.png", {frames = 7, duration = 0.3, offsetY = 30, offsetX = -10})

function Tree:new(x, y, options)
  self.pos = Point(x, y)
  self.hitpoints = 10
  self.image = image:copy()
  self.image.ratio = 0.5 + love.math.random() / 2
  if options and options.planting then
    self.image.ratio = self.saplingRatio
  end
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

function Tree:planted()
  self.image.ratio = self.saplingRatio
end

function Tree:die()
  -- spawn logs when tree dies
  util.spawn(4, self, simple.Log)
  util.spawn(love.math.random(1, 2), self, simple.PineCone)
end

function Tree:attemptToHit(player)
  if player.inventory:get("hand") then
    player:say("That's the wrong tool!")
  else
    player:say("I can't do that with my bare hands!")
  end
end

return Tree
