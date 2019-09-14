local Object = require "classic"
local Image = Object:extend()

function Image:new(path, options)
  assert(path:len() > 0)
  options = options or {}
  self.path = path
  self.frames = options.frames or 1
  self.columns = options.columns or self.frames
  self.duration = options.duration
  self.elapsed = 0.0
  self.animating = false
  self.loop = options.loop or false
  self.ratio = options.ratio or 1
  self.offsetX = options.offsetX or 0
  self.offsetY = options.offsetY or 0
  self.data = options.data or love.image.newImageData(path)
  self.image = options.image or love.graphics.newImage(self.data)
  self.width = self.image:getWidth() / self.columns
  self.height = self.image:getHeight() / math.ceil(self.frames / self.columns)
  self.quads = options.quads or {}
  if #self.quads == 0 then
    for i = 0, self.frames - 1 do
      local x = self.width * (i % self.columns)
      local y = self.height * math.floor(i / self.columns)
      table.insert(self.quads, love.graphics.newQuad(x, y, self.width, self.height, self.image:getDimensions()))
    end
  end
end

function Image:copy()
  return Image(self.path, self)
end

function Image:getWidth()
  return self.width * self.ratio
end

function Image:getHeight()
  return self.height * self.ratio
end

function Image:update(dt)
  if self.animating then
    self.elapsed = self.elapsed + dt
    if self.elapsed > self.duration then
      if self.loop then
        self.elapsed = self.elapsed % self.duration
      else
        self:stop()
      end
    end
  end
end

function Image:draw(point)
  love.graphics.draw(self.image, self:currentQuad(), point.x + self.offsetX, point.y + self.offsetY, 0, 1, 1, self:getWidth() / 2, self:getHeight())
end

function Image:currentQuad()
  if not self.animating then
    return self.quads[1]
  end
  return self.quads[1 + math.floor(self.elapsed / self.duration * self.frames)]
end

function Image:animate()
  self.animating = true
  self.elapsed = 0.0
  return self
end

function Image:loop()
  self.loop = true
  return self
end

function Image:stop()
  self.animating = false
  self.elapsed = 0.0
  return self
end

function Image:isVisibleAt(entityPos, worldPos)
  local x = math.floor((worldPos.x - (entityPos.x + self.offsetX - self:getWidth() / 2)) / self.ratio)
  local y = math.floor((worldPos.y - (entityPos.y + self.offsetY - self:getHeight()   )) / self.ratio)

  if x < 0 or x >= self.width or y < 0 or y >= self.height then
    return false
  end

  local qx, qy, qw, qh = self:currentQuad():getViewport()
  local r, g, b, a = self.data:getPixel(x + qx, y + qy)
  return a > 0.1
end

return Image
