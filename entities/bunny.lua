local Object = require "classic"
local Point = require "point"
local commands = require "commands"
local Image = require "image"
local properties = require "properties"

local images = {
  [true]  = Image("resources/bunny-left.png"),
  [false] = Image("resources/bunny-right.png")
}

local Bunny = Object:extend()
properties.getters(Bunny, {image = "getImage"})

Bunny.radius = 10
Bunny.speed = 100
Bunny.tags = {bunny = true, alive = true}

function Bunny:new(x, y)
  self.pos = Point(x, y)
  self.command = commands.idle
  self.hitpoints = 10

  -- TODO: make them behave differently
  self.gender = "male"
  if love.math.random() < 0.5 then
    self.gender = "female"
  end
end

function Bunny:getImage()
  return images[self.orientation ~= nil and self.orientation.x < 0]
end

function Bunny:update(args)
  self.command = self.command:update(self, args.dt)
end

function Bunny:draw()
  self.image:draw(self.pos)
end

return Bunny
