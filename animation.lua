local Object = require "classic"
local util = require "util"

local Animating = Object:extend()

function Animating:new(quads, duration, frames)
  self.quads = quads
  self.duration = duration
  self.frames = frames
  self.elapsed = 0
end

function Animating:update(dt)
  self.elapsed = self.elapsed + dt
end

function Animating:is_over()
  return self.elapsed > self.duration
end

function Animating:reset()
  self.elapsed = 0
end

function Animating:getQuad()
  local nFrame = 1 + math.floor(self.elapsed / self.duration * self.frames)
  if nFrame > self.frames then return self.quads[1] end
  return self.quads[util.clamp(nFrame, 1, self.frames)]
end

function createQuads(image, frames)
  local w = image:getWidth() / frames
  local quads = {}
  for i = 0, frames - 1 do
    table.insert(quads, love.graphics.newQuad(w * i, 0, w, image:getHeight(), image:getDimensions()))
  end
  return quads
end

local Animation = Object:extend()

function Animation:new(image, options)
  self.image = image
  self.duration = options.duration
  self.frames = options.frames
  self.quads = options.quads or createQuads(image, self.frames)
end

function Animation:start()
  return Animating(self.quads, self.duration, self.frames)
end

function Animation:is_over()
  return false
end

function Animation:reset()
  return self:start()
end

function Animation:update(dt)
end

function Animation:getQuad()
  return self.quads[1]
end

return Animation
