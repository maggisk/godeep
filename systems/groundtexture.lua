local Object = require "classic"
local shaders = require "shaders"

local SQR_SIZE = 15
local CANVAS_SIZE = SQR_SIZE * 10
local BLUR_RADIUS = 10

local GroundTexture = Object:extend()
function GroundTexture:new()
  self.canvases = {}
end

function GroundTexture:draw(next, state)
  local w, h = love.graphics.getDimensions()
  local top, left = findTopLeft(state.camera.pos)

  -- draw visible canvases
  for x = left, state.camera.pos.x + w / 2, CANVAS_SIZE do
    for y = top, state.camera.pos.y + h / 2, CANVAS_SIZE do
      love.graphics.draw(self:getCanvas(x, y), x, y)
    end
  end

  -- prevent having to create multiple canvases (possibly causing lag) in a single draw
  -- by creating canvases just out of frame 1 at a time
  for x = left - SQR_SIZE, state.camera.pos.x + w / 2 + SQR_SIZE, CANVAS_SIZE do
    for y = top - SQR_SIZE, state.camera.pos.y + h / 2 + SQR_SIZE, CANVAS_SIZE do
      if not self.canvases[mkKey(x, y)] then
        self.canvases[mkKey(x, y)] = self:createCanvas(x, y)
        return next()
      end
    end
  end

  next()
end

function GroundTexture:getCanvas(x, y)
  local k = mkKey(x, y)
  if not self.canvases[k] then
    self.canvases[k] = self:createCanvas(x, y)
  end
  return self.canvases[k]
end

function GroundTexture:createCanvas(xStart, yStart)
  love.graphics.push()
  love.graphics.origin()

  -- the sharp canvas has a SQR_SIZE padding so the blurring is correct when canvases are tiled
  local sharpCanvasSize = CANVAS_SIZE + 2 * SQR_SIZE
  local sharpCanvas = love.graphics.newCanvas(sharpCanvasSize, sharpCanvasSize)
  love.graphics.setCanvas(sharpCanvas)

  -- draw rectangles with random yet deterministic color
  for x = 0, sharpCanvasSize, SQR_SIZE do
    for y = 0, sharpCanvasSize, SQR_SIZE do
      local green = 0.2 + 0.05 * love.math.noise(x + xStart - SQR_SIZE, y + yStart - SQR_SIZE)
      love.graphics.setColor(0.08, green, 0.08, 1)
      love.graphics.rectangle("fill", x, y, SQR_SIZE, SQR_SIZE)
    end
  end

  love.graphics.setColor(1, 1, 1, 1)

  -- render the rectangles canvas with a blur shader to get the final texture canvas
  local blurredCanvas = love.graphics.newCanvas(CANVAS_SIZE, CANVAS_SIZE)
  love.graphics.setCanvas(blurredCanvas)
  love.graphics.setShader(shaders.boxblur)
  shaders.boxblur:send("radius", BLUR_RADIUS)
  love.graphics.draw(sharpCanvas, -SQR_SIZE, -SQR_SIZE)

  love.graphics.setCanvas()
  love.graphics.setShader()
  love.graphics.pop()

  return blurredCanvas
end

function mkKey(x, y)
  return x .. '-' .. y
end

function findTopLeft(center)
  local w, h = love.graphics.getDimensions()
  local left = math.floor(center.x - w / 2)
  left = left - (left % CANVAS_SIZE)
  local top = math.floor(center.y - h / 2)
  top = top - (top % CANVAS_SIZE)
  return top, left
end

return GroundTexture
