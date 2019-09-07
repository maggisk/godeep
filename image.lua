local Object = require "classic"
local Image = Object:extend()
local U = require "underscore"

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
  self.data = options._data or love.image.newImageData(path)
  self.image = options._image or love.graphics.newImage(self.data)
  self.width = self.image:getWidth() / self.columns
  self.height = self.image:getHeight() / math.ceil(self.frames / self.columns)
  self.quads = options._quads or {}
  if #self.quads == 0 then
    for i = 0, self.frames do
      local x = self.width * (i % self.columns)
      local y = self.height * math.floor(i / self.columns)
      table.insert(self.quads, love.graphics.newQuad(x, y, self.width, self.height, self.image:getDimensions()))
    end
  end
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
  love.graphics.draw(self.image, self:currentQuad(), point.x, point.y, 0, 1, 1, self:getWidth() / 2, self:getHeight())
end

function Image:currentQuad()
  if not self.animating then
    return self.quads[1]
  end
  return self.quads[1 + math.floor(self.elapsed / self.duration * self.frames)]
end

function Image:copy()
  return Image(self.path, {
    _image = self.image,
    frames = self.frames,
    columns = self.columns,
    duration = self.duration,
    _quads = self.quads,
    loop = self.loop,
  })
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

function Image:isVisibleAt(pos)
  local x = math.floor(pos.x / self.ratio)
  local y = math.floor(pos.y / self.ratio)

  if x < 0 or pos.x >= self.width or pos.y < 0 or pos.y >= self.height then
    return false
  end

  local qx, qy, qw, qh = self:currentQuad():getViewport()
  local r, g, b, a = self.data:getPixel(x + qx, y + qy)
  return a > 0.1
end

return Image
