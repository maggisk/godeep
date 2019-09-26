local entities = {
  Player = require "entities/player",
  Tree = require "entities/tree",
  Rock = require "entities/rock",
  Bunny = require "entities/bunny",
}

for k, v in pairs(require("entities/simple_entities")) do
  assert(entities[k] == nil, k .. " defined twice")
  entities[k] = v
end

for k, cls in pairs(entities) do
  -- set default count to 1 for entities that have weight
  if cls.weight and not cls.count then
    cls.count = 1
  end
end

return entities
