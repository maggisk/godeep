local factory = require "entities/classfactory"

local ent = {}

ent.Axe = factory.create("resources/axe.png", {weight = 5, durability = 30,
    tags = {durability = 30, wearable = "hand", damage = 10, range = 5, treecutter = 1, swingTime = 0.3}})

ent.Log = factory.create("resources/log.png", {weight = 5, tags = {}})

ent.Stone = factory.create("resources/stone.png", {weight = 10, true, tags = {}})

ent.PineCone = factory.create("resources/pinecone.png", {weight = 2, tags = {plants = "Tree"}})

ent.Berry = factory.create("resources/berries.png", {weight = 2, tags = {}})

ent.Bush = factory.createPlant("resources/bush.png", {radius = 20, tags = {provides = ent.Berry, minimap = true}})

return ent
