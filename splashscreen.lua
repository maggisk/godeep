local Object = require "classic"

local DURATION = 1
local FADE = 1
local image = love.graphics.newImage("resources/splashscreen.png")

local SplashScreen = Object:extend()
function SplashScreen:new()
  self.dt = 0
  local w, h = love.graphics.getDimensions()
  self.image = love.graphics.newCanvas(w, h)
  self.image:renderTo(function()
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(image, w / 2 - image:getWidth() / 2, 0)
  end)
end

function SplashScreen:update(next, _, dt)
  self.dt = self.dt + dt
  if self.dt >= DURATION + FADE then
    return next
  end
end

function SplashScreen:draw(next)
  if self.dt < DURATION + FADE then
    next()
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(1, 1, 1, 1 - math.max(0, (self.dt - DURATION) / FADE))
    love.graphics.draw(self.image, 0, 0)
    love.graphics.setColor(r, g, b, a)
  else
    return next
  end
end

function SplashScreen:CATCHALL()
  if self.dt < DURATION + FADE then return false end
end

return SplashScreen
