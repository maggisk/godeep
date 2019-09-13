local factory = require "entities/classfactory"

return {
  Axe = factory.create("resources/axe.png", {weight = 5, pathable = true, durability = 30, count = 1,
    tags = {durability = 30, wearable = "hand", damage = 10, range = 5, treecutter = 1, swingTime = 0.3}}),
  Log = factory.create("resources/log.png", {weight = 5, pathable = true, count = 1, tags = {}}),
  Stone = factory.create("resources/stone.png", {weight = 10, pathable = true, count = 1, tags = {}}),
  PineCone = factory.create("resources/pinecone.png", {weight = 2, pathable = true, count = 1, tags = {plants = "Tree"}}),
}
