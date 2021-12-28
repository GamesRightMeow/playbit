local build = require("build")

-- TODO: break build step out so there can be separate tests for different configurations e.g. playdate vs love2d
build.build({ 
  verbose = false,
  assert = true,
  debug = true,
  platform = "playdate",
  output = "_test\\",
  luaFolders = {
    { "playbit", "playbit" }
  },
  copyFiles = {
    { "example\\main.lua", "_test\\main.lua" },
    { "example\\conf.lua", "_test\\conf.lua" },
  },
  runOnSuccess = "",
})

-- update path so that lua uses the version of playbit we just processed
package.path = ".\\_test\\?.lua;" .. package.path

-- set playbit globally
pb = require("_test.playbit.pb")
local components = require("_test.playbit.components")

function CreateAppInstance()
  local game = pb.app.new()
  game:load()

  game:registerSystem(pb.systems.collisionDetector)
  game:registerSystem(pb.systems.parentManager)
  game:registerSystem(pb.systems.particleSystem)
  game:registerSystem(pb.systems.graphicRenderer)

  return game
end

function SystemTests()
  local game = pb.app.new()

  local componentAId = game:registerComponent("ComponentA", {})
  local componentBId = game:registerComponent("ComponentB", {})
  local componentCId = game:registerComponent("ComponentC", {})
  assert(componentAId == 1)
  assert(componentBId == 2)
  assert(componentCId == 3)

  local systemAId = game:registerSystem({ name="SystemA",   components={ "ComponentA" } })
  local systemBId = game:registerSystem({ name="SystemB",   components={ "ComponentB" } })
  local systemCId = game:registerSystem({ name="SystemC",   components={ "ComponentC" } })
  local systemBCId = game:registerSystem({ name="SystemBC", components={ "ComponentB", "ComponentC" } })
  assert(systemAId == 1)
  assert(systemBId == 2)
  assert(systemCId == 3)
  assert(systemBCId == 4)
  
  for i = 1, 24, 1 do
    game:registerComponent(tostring(i), {})
  end

  local componentDId = game:registerComponent("ComponentD", {})
  assert(componentDId == 28)

  local scene = pb.scene.new(game)
  game:changeScene(scene)

  scene:addEntity({
    ["ComponentA"] = {}
  })
  scene:addEntity({
    ["ComponentB"] = {}
  })
  scene:addEntity({
    ["ComponentC"] = {}
  })
  scene:addEntity({
    ["ComponentB"] = {},
    ["ComponentC"] = {},
  })

  scene:update()
  
  assert(#scene.systemEntityIds[systemAId].entities == 1)
  assert(#scene.systemEntityIds[systemBId].entities == 2)
  assert(#scene.systemEntityIds[systemCId].entities == 2)
  assert(#scene.systemEntityIds[systemBCId].entities == 1)
end

function MiscUtilsTests()
  local tableA = {
    x=0,
    y=1004,
    z=20,
  }
  local tableB = {}
  pb.util.shallowCopy(tableB, tableA)
  assert(tableB.x == tableA.x)
  assert(tableB.y == tableA.y)
  assert(tableB.z == tableA.z)

  tableA.x = 40000
  assert(tableB.x ~= tableA.x)

  tableB.x = 1000
  assert(tableB.x ~= tableA.x)
end

function BitfieldTests()
  local emptyBitfield = pb.bitfield.new()
  assert(emptyBitfield.value == 0)
  assert(not emptyBitfield:has(0))
  assert(not emptyBitfield:has(1))
  assert(not emptyBitfield:has(10))
  assert(not emptyBitfield:has(26))
  assert(not emptyBitfield:has(31))

  local allFlags = {}
  for i = 1, 32, 1 do
    allFlags[i] = i - 1
  end

  local fullBitfield = pb.bitfield.new(allFlags)
  assert(fullBitfield.value == 4294967295)
  assert(fullBitfield:has(0))
  assert(fullBitfield:has(1))
  assert(fullBitfield:has(10))
  assert(fullBitfield:has(26))
  assert(fullBitfield:has(31))

  local evenFlags = {}
  for i = 0, 31, 1 do
    if i % 2 == 0 then
      table.insert(evenFlags, i)
    end
  end

  local evenBitfield = pb.bitfield.new(evenFlags)
  assert(evenBitfield.value == 1431655765)
  assert(evenBitfield:has(0))
  assert(not evenBitfield:has(1))
  assert(evenBitfield:has(2))
  assert(not evenBitfield:has(21))
  assert(evenBitfield:has(30))

  local bitfield = pb.bitfield.new()
  assert(bitfield.value == 0)
  assert(not bitfield:has(0))
  assert(not bitfield:has(7))
  assert(not bitfield:has(31))
  
  bitfield:set(31)
  assert(bitfield.value == 2147483648);
  assert(not bitfield:has(0))
  assert(not bitfield:has(7))
  assert(bitfield:has(31))

  bitfield:set(7)
  assert(bitfield.value == 2147483776);
  assert(not bitfield:has(0))
  assert(bitfield:has(7))
  assert(bitfield:has(31))

  bitfield:unset(31)
  assert(bitfield.value == 128);
  assert(not bitfield:has(0))
  assert(bitfield:has(7))
  assert(not bitfield:has(31))

  bitfield:unset(7)
  assert(bitfield.value == 0)
  assert(not bitfield:has(0))
  assert(not bitfield:has(7))
  assert(not bitfield:has(31))
end

function ComponentTests()
  local componentArray = require("playbit.component-array")
  local arr = componentArray.new()

  arr:add(0, { value="A"})
  arr:add(1, { value="B"})
  arr:add(2, { value="C"})
  assert(#arr.components == 3)

  arr:remove(1)
  assert(#arr.components == 2)
  assert(arr:get(2).value == "C")

  arr:add(3, { value="D"})
  assert(#arr.components == 3)
  assert(arr:get(2).value == "C")
  assert(arr:get(3).value == "D")

  arr:remove(0)
  arr:remove(2)
  arr:remove(3)
  assert(#arr.components == 0)
end

function EntityTests()
  local game = CreateAppInstance()
  local nameId = game:getComponentId("name")
  local transformId = game:getComponentId("transform")

  local componentAId = game:registerComponent("ComponentA", {})
  local componentBId = game:registerComponent("ComponentB", {})

  local scene = pb.scene.new(game)
  game:changeScene(scene)

  local tempId = scene:addEntity({
    [pb.components.Name.name] = { },
    [pb.components.Transform.name] = { x = 5 },
  })
  scene:update()
  assert(scene.entityCount == 1)

  local tranformComponent = scene:getComponent(tempId, pb.components.Transform.name)
  assert(tranformComponent.x == 5)
  assert(tranformComponent.y == 0)

  scene:removeEntity(tempId)
  scene:update()
  assert(scene.entityCount == 0)

  local playerName = "Player"
  local playerId = scene:addEntity({ 
    [pb.components.Name.name] = { name=playerName },
    ["ComponentA"] = { x=0, y=0 },
  })
  scene:update()

  local nameSystemId = game:getSystemId("name-allocator")
  assert(#scene.systemEntityIds[nameSystemId].entities == 1)
  assert(playerId == 1)
  assert(scene.entityCount == 1)
  assert(scene:findEntity(playerName) == playerId)
  assert(scene:findEntity("does not exist") == -1)

  assert(scene:hasComponentId(playerId, nameId))
  assert(scene:hasComponentId(playerId, componentAId))
  assert(not scene:hasComponentId(playerId, componentBId))
  assert(not scene:hasComponentId(playerId, transformId))
  
  scene:addComponent(playerId, "ComponentB", {})
  scene:update()

  assert(scene:hasComponentId(playerId, nameId))
  assert(scene:hasComponentId(playerId, componentAId))
  assert(scene:hasComponentId(playerId, componentBId))
  assert(not scene:hasComponentId(playerId, transformId))

  scene:removeComponent(playerId, "ComponentA")
  scene:update()

  assert(scene:hasComponentId(playerId, nameId))
  assert(not scene:hasComponentId(playerId, componentAId))
  assert(scene:hasComponentId(playerId, componentBId))
  assert(not scene:hasComponentId(playerId, transformId))

  local entityA = scene:addEntity({ 
    ["ComponentA"] = { x=0, y=0 },
  })
  scene:update()
  assert(entityA == 2)
  assert(scene.entityCount == 2)

  local entityB = scene:addEntity({ 
    ["ComponentA"] = { x=0, y=0 },
  })
  scene:update()
  assert(entityB == 3)
  assert(scene.entityCount == 3)

  scene:removeEntity(entityA)
  scene:update()
  assert(scene.entityCount == 2)

  local entityC = scene:addEntity({ 
    ["ComponentA"] = { x=0, y=0 },
  })
  scene:update()
  assert(entityC == 2)
  assert(scene.entityCount == 3)

  scene:removeEntity(playerId)
  scene:update()
  assert(scene.entityCount == 2)

  assert(scene:findEntity(playerName) == -1)
end

function AppTests()
  local game = CreateAppInstance()

  local nameId = game:getComponentId("name")
  assert(nameId ~= nil)
end

local testsToRun = {
  { name="App Tests", testFunction=AppTests },
  { name="Bitfield Tests", testFunction=BitfieldTests },
  { name="Misc Util Tests", testFunction=MiscUtilsTests },
  { name="System Tests", testFunction=SystemTests },
  { name="Component Tests", testFunction=ComponentTests },
  { name="Entity Tests", testFunction=EntityTests },
}

for k,v in ipairs(testsToRun) do
  local startTime = os.clock()
  v.testFunction()
  local endTime = os.clock()
  print("'" .. v.name .. "' completed in " .. (endTime - startTime) .. "ms")
end

print("\nAll tests succeeded")