local factory = require "entities/classfactory"

return {
  Axe = factory.create("resources/axe.png", {weight = 5, durability = 30,
    tags = {durability = 30, wearable = "hand", damage = 10, range = 5, treecutter = 1, swingTime = 0.3}}),
  Log = factory.create("resources/log.png", {weight = 5, tags = {}}),
  Stone = factory.create("resources/stone.png", {weight = 10, true, tags = {}}),
  PineCone = factory.create("resources/pinecone.png", {weight = 2, tags = {plants = "Tree"}}),
}
