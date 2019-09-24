local Object = require "classic"

local FPS = Object:extend()
function FPS:new()
  self.state = {showFPS = false}
end

function FPS:draw(next)
  if self.state.showFPS then
    love.graphics.push()
    love.graphics.origin()
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    love.graphics.pop()
  end

  return next
end

function FPS:KEYPRESSED(event)
  if event.key == "f" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lalt") then
    self.state.showFPS = not self.state.showFPS
    return false
  end
end

return FPS
