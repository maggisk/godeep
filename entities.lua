local entities = {
  Player = require "entities/player",
  Tree = require "entities/tree",
  Rock = require "entities/rock",
}

for k, v in pairs(require("entities/simple_entities")) do
  assert(entities[k] == nil, k .. " defined twice")
  entities[k] = v
end

return entities
