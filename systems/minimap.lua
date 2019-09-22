local Object = require "classic"
local util = require "util"

-- TODO:
-- * ground texture
-- * cursor should stay at same world coordinates when zooming in/out
-- * update Camera class to handle the zooming

local MIN_ZOOM = 2
local MAX_ZOOM = 15
local SCROLL_SPEED = 800 -- px per second

local Minimap = Object:extend()
function Minimap:new()
  self.state = {isOpen = false, zoom = 5, offset = {x = 0, y = 0}}
  self.images = {}
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
    return next()
  end
end

function Minimap:maybeMove(coord, dt, cond)
  if cond then
    self.state.offset[coord] = self.state.offset[coord] + dt * self.state.zoom * SCROLL_SPEED
  end
end

function Minimap:draw(next, state)
  if not self.state.isOpen then
    return next()
  end

  love.graphics.push()
  love.graphics.scale(1 / self.state.zoom)
  love.graphics.translate(-state.entities.player.pos.x - self.state.offset.x + love.graphics.getWidth() / 2 * self.state.zoom,
                          -state.entities.player.pos.y - self.state.offset.y + love.graphics.getHeight() / 2 * self.state.zoom)
  for _, entity in ipairs(self.state.entities) do
    self:getImage(entity):draw(entity.pos)
  end
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

function Minimap:KEY_PRESSED(event, state)
  if event.key == "tab" then
    self.state.entities = {}
    self.state.offset = {x = 0, y = 0}
    self.state.isOpen = not self.state.isOpen

    if self.state.isOpen then
      self.state.entities = util.keys(state.entities.entities:byTag("minimap"))
      table.sort(self.state.entities, function(a, b) return a.pos.y < b.pos.y end)
    end
  end
end

function Minimap:WHEEL_MOVED(event)
  self.state.zoom = util.clamp(self.state.zoom - event.y, MIN_ZOOM, MAX_ZOOM)
end

return Minimap
