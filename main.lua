local strict = require "strict"

function love.load(args)
  local util = require "util"

  rawset(_G, "DEBUG", util.hasValue(args, "--debug"))

  love.window.setMode(1280, 720)
  love.window.setFullscreen(not util.hasValue(args, "--fullscreen=false"), "exclusive")

  local systems = require "systems"
  local world = systems.createWorld()

  for k, _ in pairs(systems.callbacks) do
    love[k] = function(...)
      world:callback(k, ...)
    end
  end
end
