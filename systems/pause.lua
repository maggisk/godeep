local Object = require "classic"
local loveutil = require "loveutil"

local Pause = Object:extend()
function Pause:new()
  self.state = {isPaused = false}
  self.font = love.graphics.newFont(60)
end

function Pause:update(next)
  if not self.state.isPaused then
    return next
  end
end

function Pause:draw(next)
  next()
  if self.state.isPaused then
    local rollback = loveutil.snapshot("color", "font")

    local sw, sh = love.graphics.getDimensions()
    love.graphics.setColor({0, 0, 0, 0.6})
    love.graphics.rectangle("fill", 0, 0, sw, sh)

    love.graphics.setColor({1, 1, 1, 1})
    love.graphics.setFont(self.font)
    local tw = self.font:getWidth("PAUSED")
    local th = self.font:getHeight()
    love.graphics.print("PAUSED", (sw - tw) / 2, (sh - th) / 2)

    rollback()
  end
end

function Pause:KEYPRESSED(event)
  if event.key == "pause" then
    self.state.isPaused = not self.state.isPaused
    return false
  end

  if self.state.isPaused then return false end
end

function Pause:CATCHALL()
  if self.state.isPaused then return false end
end

return Pause
