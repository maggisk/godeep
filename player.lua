local Actor = require "actor"
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

local SPEED = 200 -- pixels per second

local Player = Actor:extend()
Player.speed = SPEED -- TODO: make dynamic
Player.radius = 10
Player.tags = {type = "player", alive = true, swingTime = 0.5, range = 1}

function Player:new(x, y)
  Player.super.new(self)
  self.pos = Point(x, y)
  self.orientation = Point(0, 1)
  self.command = commands.idle
  self.inventory = Inventory()
  self.hitpoints = 1000
  self.speech = SpeechBubble()
end

function Player:getImage()
  return images[direction.fromPoint(self.orientation)]
end

function Player:say(text, ttl)
  self.speech:say(text, ttl)
end

function Player:moveTo(p)
  self.command = commands.Move(p)
end

function Player:hit(obj)
  if rules.canPickUp(self, obj) then
    self.command = commands.PickUp(obj)
  elseif rules.canAttack(self, obj) then
    self.command = commands.Attack(obj)
  else
    self.command = commands.idle
    if obj.attemptToHit then
      obj:attemptToHit(self)
    else
      self:say("I can not do that")
    end
  end
end

function Player:update(args)
  self.speech:update(args.dt)

  self.command = commands.KeyboardMove.maybe() or self.command
  self.command = self.command:update(self, args.dt)
  assert(self.command)
end

function Player:draw()
  self:getImage():draw(self.pos)
end

function Player:drawAbsolute()
  self.speech:draw()
  self.inventory:draw()
end

return Player
