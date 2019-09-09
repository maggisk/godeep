local util = require "util"

local module = {}

function kill(entity)
  -- call the entity's die method if it has one
  if entity.die then
    entity:die()
  end

  -- if the die method did not prevent death, then mark it as dead
  if entity.hitpoints <= 0 then
    entity.dead = true
  end
end

function flattenTags(entity)
  local tags = {}

  for key, value in pairs(entity.tags) do
    table.insert(tags, {entity = entity, key = key, value = value})
  end

  if entity.inventory then
    for _, slot in ipairs(entity.inventory.WEARABLE_SLOTS) do
      local item = entity.inventory:get(slot)
      if item then
        for key, value in pairs(item.tags) do
          table.insert(tags, {entity = item, key = key, value = value})
        end
      end
    end
  end

  return tags
end

function findDamageDealer(a, b)
  local match = {value = -math.huge}

  for _, tag in ipairs(flattenTags(a)) do
    -- if we have a weapon equipped we can use it if we are attacking a living thing
    if (b.tags.alive and tag.key == "damage") and match.value < tag.value then
      match = {entity = tag.entity, value = tag.value}
    end

    -- otherwise we might have a tool that can destroy some dead entities
    if b.tags.takesDamageFrom and b.tags.takesDamageFrom[tag.key] and match.value < tag.value then
      match = {entity = tag.entity, value = tag.value}
    end
  end

  return match.entity, (match.entity and match.value)
end

function module.canAttack(a, b)
  -- dead things can never attack anything
  if not a.tags.alive then return false end
  assert(a.hitpoints ~= nil, "all living entities must have hitpoints")

  -- check if the entity itself can attack, or anything it's wearing enables us to attack
  if b.tags.takesDamageFrom then
    for _, tag in ipairs(flattenTags(a)) do
      if b.tags.takesDamageFrom[tag.key] then
        return true
      end
    end
  end

  -- otherwise live entities can attack other live entities
  return b.tags.alive == true
end

function module.doAttack(a, b)
  assert(module.canAttack(a, b), "attempted attack that is not allowed")

  local entity, damage = findDamageDealer(a, b)

  -- decrement durability if the damage dealing entity has any
  if entity.durability ~= nil then
    entity.durability = entity.durability - 1

    -- kill it if it has run out
    if entity.durability <= 0 then
      kill(entity)
    end
  end

  -- TODO: armour

  -- deal damage
  b.hitpoints = b.hitpoints - damage

  if b.hitpoints <= 0 then
    -- no hitpoints left - kill it
    kill(b)
  elseif b.tookHit then
    -- allow entity to take action in response to getting hit - e.g. start animation
    b:tookHit()
  end

  -- set entity time to live until next swing
  assert(entity.tags.swingTime ~= nil, entity.clsname .. " does not have swingTime tag")
  a.swingTTL = entity.tags.swingTime
end

function module.canPickUp(a, b)
  -- live entities can pick up anything that has weight
  return a.tags.alive and b.weight ~= nil
end

return module
