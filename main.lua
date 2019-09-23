local world

function love.load(args)
  love.window.setMode(1280, 720)
  love.window.setFullscreen(not require("util").hasValue(args, "--fullscreen=false"), "exclusive")

  local systems = require "systems"
  world = systems.createWorld()

  for k, _ in pairs(systems.callbacks) do
    love[k] = function(...)
      world:callback(k, ...)
    end
  end
end
