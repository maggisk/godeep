local easing = require "easing"
local Object = require "classic"
local SpeechBubble = Object:extend()

local font = love.graphics.newFont(20)

local DEFAULT_TTL = 2
local SHAKE_DISTANCE = 10
local SHAKE_DURATION = 0.4
local SHAKE_COUNT = 2

function SpeechBubble:new()
  self.text = ""
  self.ttl = -1
  self.duration = 0
  self.shake = false
end

function SpeechBubble:say(text, ttl)
  self.shake = self.ttl > 0 and self.text == text
  self.text = text
  self.ttl = ttl or DEFAULT_TTL
  self.duration = 0
end

function SpeechBubble:update(dt)
  if self.ttl >= 0 then
    self.ttl = self.ttl - dt
    self.duration = self.duration + dt
    self.shake = self.shake and self.duration < SHAKE_DURATION
  end
end

function SpeechBubble:draw()
  if self.ttl < 0 then return end

  love.graphics.push()

  if self.shake then
    love.graphics.translate(SHAKE_DISTANCE * easing.shake(SHAKE_COUNT, self.duration, SHAKE_DURATION), 0)
  end

  local origFont = love.graphics.getFont()
  love.graphics.setFont(font)
  local textWidth = font:getWidth(self.text)
  local textHeight = font:getHeight()
  local w, h = love.graphics.getDimensions()
  local x = w / 2 - textWidth / 2
  local y = h / 2 - 200
  love.graphics.setColor(0, 0, 0, 0.5)
  love.graphics.rectangle("fill", x - 10, y - 10, textWidth + 20, textHeight + 20, 10)
  love.graphics.polygon("fill", w / 2 - 10, y + textHeight + 10,  w / 2 + 10, y + textHeight + 10, w / 2, y + textHeight + 20)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print(self.text, x, y)
  love.graphics.setFont(origFont)

  love.graphics.pop()
end

return SpeechBubble
