local Object = require "classic"
local Point = require "point"
local util = require "util"
local loveutil = require "loveutil"
local ent = require "entities"
local EntityManager = require "entitymanager"

local MIN_RADIUS = 2500
local MAX_RADIUS = 4000

local AreaTypes = {
  grass = {84/255, 171/255, 71/255, 1},
  forest = {0, 46 / 255, 0, 1},
  stone = {0.6, 0.6, 0.6, 1},
  desert = {0.76, 0.7, 0.5, 1},
}

local Area = Object:extend()
function Area:new(x, y, type, seed)
  self.pos = Point(x, y)
  self.type = type
  self.seed = seed or love.math.random() * 10000 + love.math.random()

  self.outlines = {}
  for i = 0, 360 do
    local angle = (math.pi * 2) * (i / 360)
    local radius = self:getRadius(angle)
    table.insert(self.outlines, radius * math.cos(angle))
    table.insert(self.outlines, radius * math.sin(angle))
  end

  self.polygons = love.math.triangulate(self.outlines)
end

function Area:getRadius(angle)
  local r = love.math.noise(self.seed + math.cos(angle), self.seed + math.sin(angle))
  return util.remap(r, 0, 1, MIN_RADIUS, MAX_RADIUS)
end

function Area:getBorderPoint(angle)
  return self.pos:copy():move(angle, self:getRadius(angle))
end

function Area:contains(p, padding)
  if p.x < self.pos.x - MAX_RADIUS or p.x > self.pos.x + MAX_RADIUS or
     p.y < self.pos.y - MAX_RADIUS or p.y > self.pos.y + MAX_RADIUS then
     return false
  end

  local vec = p:copy():subtract(self.pos)
  return vec:length() + (padding or 0) <= self:getRadius(vec:getAngle())
end


local World = Object:extend()
World.AreaTypes = AreaTypes

function World:new()
  self.entities = EntityManager()
  self.areas = {}
end

function World:draw()
  love.graphics.clear(0, 0.312, 0.48, 1)
  local rollback = loveutil.snapshot("color", "linewidth")

  -- draw black border between ocean and land
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.setLineWidth(10)
  for _, area in ipairs(self.areas) do
    love.graphics.push()
    love.graphics.translate(area.pos.x, area.pos.y)
    love.graphics.line(area.outlines)
    love.graphics.pop()
  end

  -- draw the ground
  for _, area in ipairs(self.areas) do
    love.graphics.push()
    love.graphics.translate(area.pos.x, area.pos.y)
    love.graphics.setColor(area.type)
    for _, polygon in ipairs(area.polygons) do
      love.graphics.polygon("fill", polygon)
    end
    love.graphics.pop()
  end

  rollback()
end

function World:generate()
  table.insert(self.areas, Area(0, 0, AreaTypes.grass))

  local types = {}
  for t, count in pairs({
    [AreaTypes.grass] = love.math.random(3, 5),
    [AreaTypes.forest] = love.math.random(3, 5),
    [AreaTypes.stone] = love.math.random(2, 3),
    [AreaTypes.desert] = love.math.random(1, 2),
  }) do
    for i = 1, count do
      table.insert(types, t)
    end
  end

  util.shuffle(types)
  for _, t in ipairs(types) do
    while true do
      local sibling = util.rpick(self.areas)
      local angle = love.math.random() * math.pi * 2
      local radius = sibling:getRadius(angle + math.pi)
      local x = sibling.pos.x - (radius + MIN_RADIUS * 0.99) * math.cos(angle)
      local y = sibling.pos.y - (radius + MIN_RADIUS * 0.99) * math.sin(angle)
      local area = Area(x, y, t)
      if self:minDistToAreaCenter(area.pos) >= MIN_RADIUS * 1.5 then
        table.insert(self.areas, area)
        break
      end
    end
  end

  self:makeEntities(ent.Tree, AreaTypes.forest, love.math.random(800, 1200))
  self:makeEntities(ent.Tree, AreaTypes.grass, love.math.random(80, 150))
  self:makeEntities(ent.Rock, AreaTypes.stone, love.math.random(300, 400))
  self:makeEntities(ent.Axe, AreaTypes.forest, 20)
  self:makeEntities(ent.PineCone, AreaTypes.forest, 100)
  self:makeEntities(ent.Bunny, AreaTypes.forest, 100)
  self:makeEntities(ent.Bush, AreaTypes.grass, 100)
end

function World:minDistToAreaCenter(pos)
  local min = math.huge
  for _, area in ipairs(self.areas) do
    min = math.min(min, pos:distanceTo(area.pos))
  end
  return min
end

function World:makeEntities(cls, type, n)
  local areas = util.ifilter(self.areas, function(a) return a.type == type end)

  while n > 0 do
    local area = util.rpick(areas)
    local x = area.pos.x + math.floor(util.remap(love.math.random(), 0, 1, -MAX_RADIUS, MAX_RADIUS))
    local y = area.pos.y + math.floor(util.remap(love.math.random(), 0, 1, -MAX_RADIUS, MAX_RADIUS))
    local pos = Point(x, y)
    if self:findArea(pos) == area and area:contains(pos, (cls.radius or 0) * 2) then
      local entity = cls(x, y)
      if self.entities:canAddWithoutCollisions(entity) then
        self.entities:add(entity)
        n = n - 1
      end
    end
  end
end

function World:findArea(p)
  for i = #self.areas, 1, -1 do
    if self.areas[i]:contains(p) then
      return self.areas[i]
    end
  end
end

function World:bestAreaMatch(pos)
  local distance = -math.huge
  local best = nil

  for _, area in ipairs(self.areas) do
    local angle = pos:copy():subtract(area.pos):getAngle()
    local distFromBorder = area:getRadius(angle) - pos:distanceTo(area.pos)
    if distFromBorder > distance then
      distance = distFromBorder
      best = area
    end
  end

  return best, distance
end

function World:contain(entity)
  local area, _ = self:bestAreaMatch(entity.pos)
  local angle = entity.pos:copy():subtract(area.pos):getAngle()
  local border = area:getBorderPoint(angle)

  if border:distanceTo(entity.pos) < entity.radius then
    local distance = entity.radius - border:distanceTo(entity.pos)
    local angle = border:copy():subtract(area.pos):getAngle()
    local p1 = area:getBorderPoint(angle - 0.01)
    local p2 = area:getBorderPoint(angle + 0.01)
    entity.pos:add(p2:subtract(p1):rotate(math.pi / 2):setLength(distance))
  end
end

return World
