local Object = require "classic"
local properties = require "properties"
local Point = require "point"
local Inventory = require "inventory"
local Image = require "image"
local SpeechBubble = require "speechbubble"
local rules = require "gamerules"
local commands = require "commands"

local direction = { up = 1, down = 2, left = 3, right = 4 }

function direction.fromPoint(p)
  if p.x <= -math.abs(p.y) then
    return direction.left
  elseif p.x >= math.abs(p.y) then
    return direction.right
  elseif p.y <= -math.abs(p.x) then
    return direction.up
  else
    return direction.down
  end
end

local images = {
  [direction.left] = Image("resources/eric-left.png"),
  [direction.right] = Image("resources/eric-right.png"),
  [direction.down] = Image("resources/eric-front.png"),
  [direction.up] = Image("resources/eric-back.png"),
}

local SPEED = 300 -- pixels per second

local Player = Object:extend()
properties.getters(Player, {image = "getImage"})
Player.minimapImage = images[direction.down]
Player.speed = SPEED -- TODO: make dynamic
Player.radius = 10
Player.tags = {player = true, alive = true, minimap = true, damage = 1, swingTime = 0.5, range = 1}

function Player:new(x, y)
  self.pos = Point(x, y)
  self.newEntities = {}
  self.orientation = Point(0, 1)
  self.command = commands.idle
  self.inventory = Inventory()
  self.inventory.newEntities = self.newEntities
  self.hitpoints = 1000
  self.speech = SpeechBubble()
end

function Player:getImage()
  return images[direction.fromPoint(self.orientation)]
end

function Player:say(text, ttl)
  self.speech:say(text, ttl)
end

function Player:update(args)
  self.speech:update(args.dt)

  self.command = commands.KeyboardMove.maybe() or self.command
  self.command = self.command:update(self, args.dt)
  assert(self.command)

  self.inventory:update()
end

function Player:draw()
  self:getImage():draw(self.pos)
end

return Player
