local Actor = require "actor"
local Point = require "point"
local Inventory = require "inventory"
local Image = require "image"

local direction = { up = 1, down = 2, left = 3, right = 4 }

function direction:from_point(p)
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
Player.tags = {animal = true}

function Player:new(x, y)
  Player.super.new(self)
  self.pos = Point(x, y)
  self.direction = direction.down
  self.action = {k = "idle"}
  self.inventory = Inventory()
end

function Player:getImage()
  return images[self.direction]
end

function Player:move_to(p)
  self.action = {k = "move", to = p}
  self:_faceTowards(p)
end

function Player:hit(obj)
  self.action = {k = "hit", target = obj}
end

function Player:update(args)
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

  if math.abs(kbm.x) > 0.5 or math.abs(kbm.y) > 0.5 then
    -- keyboard movement
    self.action = {k = "idle"}
    self.direction = direction:from_point(kbm)
    self.pos:add(kbm:setLength(speed))
  elseif self.action.k == "move" then
    -- movecommand by mouseclick
    self:_moveCloserTo(self.action.to, speed)
    if self.pos:eq(self.action.to) then
      self.action = {k = "idle"}
    end
  elseif self.action.k == "hit" then
    -- some world object clicked
    self:_faceTowards(self.action.target.pos)
    self:_moveCloserTo(self.action.target.pos, speed)
    if self.pos:distanceTo(self.action.target.pos) <= self.radius + self.action.target.radius then
      if self.action.target.weight then
        self.inventory:addOne(self.action.target)
      elseif self.action.target.takeHit and self:canHit(self.action.target) then
        self.action.target:takeHit(self, args)
      end
      self.action = {k = "idle"}
    end
  end
end

function Player:_faceTowards(pos)
  self.direction = direction:from_point(pos:copy():subtract(self.pos))
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

return Player
