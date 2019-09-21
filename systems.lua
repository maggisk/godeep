local Object = require "classic"
local Point = require "point"
local ep = require "eventprocessing"
local Pause = require "systems/pause"
local Camera = require "systems/camera"
local Planting = require "systems/planting"
local Entities = require "systems/entities"
local PlayerControl = require "systems/playercontrol"

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
  local i = 0
  function updateNext()
    i = i + 1
    if i <= #self.names then
      if self.byName[self.names[i]].update then
        self.byName[self.names[i]]:update(updateNext, self.state, dt)
      else
        updateNext()
      end
    end
  end
  updateNext()
end

function System:draw()
  local i = 0
  function drawNext()
    i = i + 1
    if i <= #self.names then
      if self.byName[self.names[i]].draw then
        self.byName[self.names[i]]:draw(drawNext, self.state)
      else
        drawNext()
      end
    end
  end
  drawNext()
end

function System:dispatch(action, obj)
  for _, name in ipairs(self.names) do
    local method = self.byName[name][action]
    if method and method(self.byName[name], obj, self.state) == false then
      break
    end
  end
end

function System:mousepressed(x, y, button, istouch, presses)
  self:dispatch("MOUSE_PRESSED", ep.Event("mouse", "click", {
    button = button,
    istouch = istouch,
    presses = presses,
    screen = Point(x, y),
    world = self.state.camera:screenToWorldPos(Point(x, y))
  }))
end

function System:keypressed(key, scancode, isrepeat)
  self:dispatch("KEY_PRESSED", ep.Event("keyboard", "keypressed", {
    key = key,
    scancode = scancode,
    isrepeat = isrepeat,
  }))
end

local Inventory = Object:extend()
function Inventory:MOUSE_PRESSED(event, state)
  state.entities.player.inventory:processMouseEvent(event)
  return not event.halted
end

local AbsoluteUI = Object:extend()
function AbsoluteUI:draw(next, state)
  love.graphics.push()
  love.graphics.origin()
  state.entities.player.inventory:draw()
  state.entities.player.speech:draw()
  love.graphics.pop()
  next()
end

function createWorld()
  local system = System()
  system:add('pause', Pause())
  system:add('camera', Camera())
  system:add('inventory', Inventory())
  system:add('entities', Entities())
  system:add('planting', Planting())
  system:add('player', PlayerControl())
  system:add('ui', AbsoluteUI())
  system:ready()
  return system
end

return {createWorld = createWorld}
