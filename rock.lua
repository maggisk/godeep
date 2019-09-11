local Point = require "point"
local Image = require "image"
local Object = require "classic"
local properties = require "properties"

local images = {
  Image("resources/rock-crack-6.png"),
  Image("resources/rock-crack-5.png"),
  Image("resources/rock-crack-4.png"),
  Image("resources/rock-crack-3.png"),
  Image("resources/rock-crack-2.png"),
  Image("resources/rock-crack-1.png"),
  Image("resources/rock.png"),
}

local Rock = Object:extend()
properties.getters(Rock, {image = "getImage"})

Rock.radius = 75
Rock.tags = {type = "rock", takesDamageFrom = {treecutter = true}}

function Rock:new(x, y)
  self.pos = Point(x, y)
  self.hitpoints = 7
end

function Rock:getImage()
  return images[self.hitpoints]
end

function Rock:draw()
  self.image:draw(self.pos)
end

return Rock
