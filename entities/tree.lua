local Object = require "classic"
local Point = require "point"
local Image = require "image"
local simple = require "entities/simple_entities"
local util = require "util"

local Tree = Object:extend()

Tree.radius = 30
Tree.tags = {static = true, takesDamageFrom = {treecutter = true}}

local image = Image("resources/treeshake.png", {frames = 7, duration = 0.3, offsetY = 30, offsetX = -10})

function Tree:new(x, y)
  self.pos = Point(x, y)
  self.hitpoints = 10
  self.image = image:copy()
  self.image.ratio = 0.8
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
  self:_getImageCopy():animate()
end

function Tree:planted()
  --self:_getImageCopy().ratio = love.math.random() / 2 + 0.5
end

function Tree:_getImageCopy()
  -- copy the image the first time we change something about it so we can share an image object for all trees initially
  if self.image == image then
    self.image = image:copy()
  end
  return self.image
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
