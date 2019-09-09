local Actor = require "actor"
local Point = require "point"
local Inventory = require "inventory"
local Image = require "image"
local MessageBox = require "messagebox"
local rules = require "gamerules"

local direction = { up = 1, down = 2, left = 3, right = 4 }

function direction:fromPoint(p)
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
Player.radius = 10
Player.tags = {type = "player", alive = true}

function Player:new(x, y)
  Player.super.new(self)
  self.pos = Point(x, y)
  self.direction = direction.down
  self.action = {k = "idle"}
  self.inventory = Inventory()
  self.swingTTL = -1
  self.hitpoints = 1000
  self.mb = MessageBox()
end

function Player:getImage()
  return images[self.direction]
end

function Player:say(text, ttl)
  self.mb:say(text, ttl)
end

function Player:moveTo(p)
  self.action = {k = "move", to = p, drop = self.inventory:getMouseItem()}
  self:_faceTowards(p)
end

function Player:hit(obj)
  if rules.canPickUp(self, obj) or rules.canAttack(self, obj) then
    self.action = {k = "hit", target = obj}
  elseif obj.attemptToHit then
    obj:attemptToHit(self)
  else
    self:say("I can't do that")
  end
end

function Player:update(args)
  self.mb:update(args.dt)
  self.swingTTL = self.swingTTL - args.dt

  local kbm = Point(0, 0)
  if love.keyboard.isDown("left", "a") then
    kbm.x = kbm.x - 1
  end
  if love.keyboard.isDown("right", "d") then
    kbm.x = kbm.x + 1
  end
  if love.keyboard.isDown("up", "w") then
    kbm.y = kbm.y - 1
  end
  if love.keyboard.isDown("down", "s") then
    kbm.y = kbm.y + 1
  end

  local speed = SPEED * args.dt

  if math.abs(kbm.x) == 1 or math.abs(kbm.y) == 1 then
    -- keyboard movement
    self.action = {k = "idle"}
    self.direction = direction:fromPoint(kbm)
    self.pos:add(kbm:setLength(speed))
  elseif self.action.k == "move" then
    -- movecommand by mouseclick
    self:_moveCloserTo(self.action.to, speed)
    if self.pos:eq(self.action.to) then
      if self.action.drop and self.action.drop == self.inventory:getMouseItem() then
        self.inventory:drop(self.inventory:getMouseItem(), self.pos)
      end
      self.action = {k = "idle"}
    end
  elseif self.action.k == "hit" then
    -- some world object clicked
    self:_faceTowards(self.action.target.pos)
    self:_moveCloserTo(self.action.target.pos, speed)
    if self.pos:distanceTo(self.action.target.pos) <= self.radius + self.action.target.radius then
      if rules.canPickUp(self, self.action.target) then
        self.inventory:add(self.action.target)
      elseif rules.canAttack(self, self.action.target) and self.swingTTL <= 0 then
        rules.doAttack(self, self.action.target)
      end
      self.action = {k = "idle"}
    end
  end
end

function Player:_faceTowards(pos)
  self.direction = direction:fromPoint(pos:copy():subtract(self.pos))
end

function Player:_moveCloserTo(p, speed)
  if self.pos:distanceTo(p) > speed then
    self.pos:add(p:copy():subtract(self.pos):setLength(speed))
  else
    self.pos:set(p)
  end
end

function Player:draw()
  images[self.direction]:draw(self.pos)
end

function Player:drawAbsolute()
  self.mb:draw()
  self.inventory:draw()
end

return Player
