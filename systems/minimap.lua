local Object = require "classic"
local Point = require "point"
local util = require "util"
local loveutil = require "loveutil"

-- TODO:
-- * ground texture
-- * update Camera class to handle the zooming

local MIN_ZOOM = 2
local MAX_ZOOM = 15
local SCROLL_SPEED = 800 -- px per second
local FOG_CANVAS_SIZE = 1000

local FogOfWar = Object:extend()
function FogOfWar:new()
  self.canvases = {}
  -- blank canvas with nothing revealed that we'll copy on-the-fly as needed
  self.blankCanvas = self:createCanvas()
end

function FogOfWar:floor(n)
  -- floor number to the upper/left coordinate of the canvas that contains the pixel
  return n - (n % FOG_CANVAS_SIZE)
end

function FogOfWar:reveal(pos)
  -- don't reveal the same position twice in a row
  if self.lastX == math.floor(pos.x) and self.lastY == math.floor(pos.y) then
    return
  end
  self.lastX = math.floor(pos.x)
  self.lastY = math.floor(pos.y)

  -- the radius revealed is from center of screen to a corner of the screen
  local w, h = love.graphics.getDimensions()
  local radius = math.ceil(math.sqrt(math.pow(w / 2, 2) + math.pow(h / 2, 2)))

  -- x and y coordinates of the canvas the player is located within
  local x = self:floor(pos.x)
  local y = self:floor(pos.y)

  -- position within the main canvas
  local canvasX = math.floor(pos.x % FOG_CANVAS_SIZE)
  local canvasY = math.floor(pos.y % FOG_CANVAS_SIZE)

  -- min/max coordinates of canvases we need to update
  local minX = self:floor(pos.x - radius)
  local maxX = self:floor(pos.x + radius)
  local minY = self:floor(pos.y - radius)
  local maxY = self:floor(pos.y + radius)

  -- and render transparency into canvases that are in range or the player
  local reset = loveutil.graphics.snapshot("canvas", "blendmode", "color")
  for cx = minX, maxX, FOG_CANVAS_SIZE do
    for cy = minY, maxY, FOG_CANVAS_SIZE do
      love.graphics.setCanvas(self:getCanvas(cx, cy))
      love.graphics.setBlendMode("replace")
      love.graphics.setColor(0, 0, 0, 0)
      love.graphics.circle("fill", x - cx + canvasX, y - cy + canvasY, radius)
      reset()
    end
  end
end

function FogOfWar:draw(center, zoom)
  local w, h = love.graphics.getDimensions()

  local left = self:floor(center.x - w / 2 * zoom)
  local top  = self:floor(center.y - h / 2 * zoom)

  for x = left, center.x + w / 2 * zoom, FOG_CANVAS_SIZE do
    for y = top, center.y + h / 2 * zoom, FOG_CANVAS_SIZE do
      love.graphics.draw(self:getCanvas(x, y, self.blankCanvas), x, y)
    end
  end
end

function FogOfWar:getCanvas(x, y, default)
  local k = x .. '_' .. y
  if not self.canvases[k] and not default then
    self.canvases[k] = loveutil.graphics.copyCanvas(self.blankCanvas)
  end
  return self.canvases[k] or default
end

function FogOfWar:createCanvas()
  local reset = loveutil.graphics.snapshot("canvas", "color", "linewidth")
  local canvas = love.graphics.newCanvas(FOG_CANVAS_SIZE, FOG_CANVAS_SIZE)
  love.graphics.setCanvas(canvas)
  love.graphics.setColor(0.08, 0.08, 0.08, 1)
  love.graphics.rectangle("fill", 0, 0, FOG_CANVAS_SIZE, FOG_CANVAS_SIZE)
  love.graphics.setColor(0.2, 0.2, 0.2, 1)
  love.graphics.setLineWidth(5)
  love.graphics.line(0, 0, FOG_CANVAS_SIZE, FOG_CANVAS_SIZE)
  love.graphics.line(FOG_CANVAS_SIZE, 0, 0, FOG_CANVAS_SIZE)
  reset()
  return canvas
end

local Minimap = Object:extend()
function Minimap:new()
  self.state = {isOpen = false, zoom = 5, pos = Point(0, 0)}
  self.images = {}
  self.fogofwar = FogOfWar()
end

function Minimap:update(next, state, dt)
  if self.state.isOpen then
    local x, y = love.mouse.getPosition()
    local w, h = love.graphics.getDimensions()
    self:maybeMove("x", -dt, x == 0     or love.keyboard.isDown("left", "a"))
    self:maybeMove("x",  dt, x == w - 1 or love.keyboard.isDown("right", "d"))
    self:maybeMove("y", -dt, y == 0     or love.keyboard.isDown("up", "w"))
    self:maybeMove("y",  dt, y == h - 1 or love.keyboard.isDown("down", "s"))
  else
    self.fogofwar:reveal(state.entities.player.pos)
    return next
  end
end

function Minimap:maybeMove(coord, dt, cond)
  if cond then
    self.state.pos[coord] = self.state.pos[coord] + dt * self.state.zoom * SCROLL_SPEED
  end
end

function Minimap:draw(next)
  if not self.state.isOpen then
    return next
  end

  love.graphics.push()
  love.graphics.scale(1 / self.state.zoom)
  love.graphics.translate(-self.state.pos.x + love.graphics.getWidth()  / 2 * self.state.zoom,
                          -self.state.pos.y + love.graphics.getHeight() / 2 * self.state.zoom)

  for _, entity in ipairs(self.state.entities) do
    self:getImage(entity):draw(entity.pos)
  end

  self.fogofwar:draw(self.state.pos, self.state.zoom)

  love.graphics.pop()
end

function Minimap:getImage(entity)
  local cls = getmetatable(entity)
  if not self.images[cls] then
    self.images[cls] = cls.minimapImage
    if not self.images[cls] then
      self.images[cls] = entity.image:copy()
      self.images[cls].ratio = 1
    end
  end
  return self.images[cls]
end

function Minimap:KEYPRESSED(event, state)
  if event.key == "tab" then
    self.state.entities = {}
    self.state.pos = state.camera.pos:copy()
    self.state.isOpen = not self.state.isOpen

    if self.state.isOpen then
      self.state.entities = util.keys(state.entities.entities:byTag("minimap"))
      table.sort(self.state.entities, function(a, b) return a.pos.y < b.pos.y end)
    end
  end

  return not self.state.isOpen
end

function Minimap:MOUSEPRESSED()
  return not self.state.isOpen
end

function Minimap:WHEELMOVED(event)
  -- get world coordinates of mouse cursor
  local w, h = love.graphics.getDimensions()
  local x, y = love.mouse.getPosition()
  local wx = self.state.pos.x + (x - w / 2) * self.state.zoom
  local wy = self.state.pos.y + (y - h / 2) * self.state.zoom

  -- set new zoom level
  self.state.zoom = util.clamp(self.state.zoom - event.y, MIN_ZOOM, MAX_ZOOM)

  -- change position so that mouse cursor stays at same world coordinates as before
  self.state.pos:setX(wx - (x - w / 2) * self.state.zoom)
                :setY(wy - (y - h / 2) * self.state.zoom)

  return false -- halt event propagation
end

return Minimap
