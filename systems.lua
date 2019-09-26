local Object = require "classic"
local Point = require "point"
local Event = require "event"
local util = require "util"
local Pause = require "systems/pause"
local Camera = require "systems/camera"
local Planting = require "systems/planting"
local World = require "systems/world"
local PlayerControl = require "systems/playercontrol"
local GroundTexture = require "systems/groundtexture"
local FPS = require "systems/fps"
local Minimap = require "systems/minimap"
local BunnyBehaviour = require "systems/bunnybehaviour"

-- love2d callbacks we need in the game
local callbacks = {
  update        = {"dt"},
  draw          = {},
  quit          = {},
  keypressed    = {"key", "scancode", "isrepeat"},
  keyreleased   = {"key", "scancode"},
  textedited    = {"text", "start", "length"},
  textinput     = {"text"},
  mousepressed  = {"x", "y", "button", "istouch", "presses"},
  mousereleased = {"x", "y", "button", "istouch", "presses"},
  mousemoved    = {"x", "y", "dx", "dy", "istouch"},
  wheelmoved    = {"x", "y"},
}

local System = Object:extend()
function System:new()
  self.names = {}
  self.byName = {}
  self.state = {}
end

function System:add(name, subsystem)
  table.insert(self.names, name)
  self.byName[name] = subsystem
  self.state[name] = subsystem.state
end

function System:ready()
  for _, name in ipairs(self.names) do
    if self.byName[name].init then
      self.byName[name]:init()
    end
  end
end

function System:update(dt)
  self:callSubsystems("update", dt)
end

function System:draw()
  self:callSubsystems("draw")
end

function System:callSubsystems(methodName, arg1)
  local i = 0
  function loop()
    i = i + 1
    local system = self.byName[self.names[i]]
    if system and (not system[methodName] or system[methodName](system, loop, self.state, arg1) == loop) then
      return loop() -- lua eliminates tail call, so there is no function call overhead here
    end
  end
  loop()
end

function System:dispatch(action, event)
  for _, name in ipairs(self.names) do
    local method = self.byName[name][action] or self.byName[name].CATCHALL
    if method and method(self.byName[name], event, self.state) == false then
      break
    end
  end
end

function System:callback(name, ...)
  if self[name] then
    self[name](self, ...)
  else
    local event = Event(name, util.zip(callbacks[name], {...}))
    self:dispatch(name:upper(), event)
  end
end

local Inventory = Object:extend()
function Inventory:MOUSEPRESSED(event, state)
  state.world.player.inventory:processMouseEvent(event)
  return not event.halted
end

local AbsoluteUI = Object:extend()
function AbsoluteUI:draw(next, state)
  love.graphics.push()
  love.graphics.origin()
  state.world.player.inventory:draw()
  state.world.player.speech:draw()
  love.graphics.pop()
  next()
end

function createWorld()
  local system = System()
  system:add('fps', FPS())
  system:add('minimap', Minimap())
  system:add('pause', Pause())
  system:add('camera', Camera())
  --system:add('ground', GroundTexture())
  system:add('inventory', Inventory())
  system:add('world', World())
  system:add('bunnies', BunnyBehaviour())
  system:add('planting', Planting())
  system:add('player', PlayerControl())
  system:add('ui', AbsoluteUI())
  system:ready()
  return system
end

return {
  createWorld = createWorld,
  callbacks = callbacks,
}
