-- ██████╗ ██╗   ██╗██╗██╗     ██████╗ 
-- ██╔══██╗██║   ██║██║██║     ██╔══██╗
-- ██████╔╝██║   ██║██║██║     ██║  ██║
-- ██╔══██╗██║   ██║██║██║     ██║  ██║
-- ██████╔╝╚██████╔╝██║███████╗██████╔╝
-- ╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝ 
-- build must happen first so that the correct version of the playbit module is loaded

local build = require("build")

build.build({ 
  verbose = false,
  assert = true,
  debug = true,
  -- we don't really need to test actual platform specific APIs, so just compile those out
  platform = "fakeplatformfortesting",
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

-- ████████╗███████╗███████╗████████╗███████╗
-- ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝██╔════╝
--    ██║   █████╗  ███████╗   ██║   ███████╗
--    ██║   ██╔══╝  ╚════██║   ██║   ╚════██║
--    ██║   ███████╗███████║   ██║   ███████║
--    ╚═╝   ╚══════╝╚══════╝   ╚═╝   ╚══════╝
-- Tests for various systems. Should be updated regularly. ads 

function CreateAppInstance()
  local game = pb.app.new()
  game:load()

  game:registerSystem(pb.systems.collisionDetector)
  game:registerSystem(pb.systems.parentManager)
  game:registerSystem(pb.systems.particleSystem)
  game:registerSystem(pb.systems.graphicRenderer)

  return game
end

-- Test basic system functionality
function Test_System()
  local game = pb.app.new()

  local componentAId = game:registerComponent("ComponentA", {})
  local componentBId = game:registerComponent("ComponentB", {})
  local componentCId = game:registerComponent("ComponentC", {})
  assert(componentAId == 1, "Component ID is expected to be 1.")
  assert(componentBId == 2, "Component ID is expected to be 2.")
  assert(componentCId == 3, "Component ID is expected to be 3.")
  
  for i = 1, 24, 1 do
    game:registerComponent(tostring(i), {})
  end

  local componentDId = game:registerComponent("ComponentD", {})
  assert(componentDId == 28, "Component ID is expected to be 28.")

  local systemAId = game:registerSystem({ name="SystemA",   components={ "ComponentA" } })
  local systemBId = game:registerSystem({ name="SystemB",   components={ "ComponentB" } })
  local systemCId = game:registerSystem({ name="SystemC",   components={ "ComponentC" } })
  local systemBCId = game:registerSystem({ name="SystemBC", components={ "ComponentB", "ComponentC" } })
  assert(systemAId == 1, "System ID is expected to be 1.")
  assert(systemBId == 2, "System ID is expected to be 2.")
  assert(systemCId == 3, "System ID is expected to be 3.")
  assert(systemBCId == 4, "System ID is expected to be 4.")

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
  
  assert(#scene.systemEntityIds[systemAId].entities == 1, "System A should match with 1 entity.")
  assert(#scene.systemEntityIds[systemBId].entities == 2, "System B should match with 2 entities.")
  assert(#scene.systemEntityIds[systemCId].entities == 2, "System C should match with 2 entities.")
  assert(#scene.systemEntityIds[systemBCId].entities == 1, "System BC should match with 1 entity.")
end

-- Tests misc util functions
function Test_Utils()
  local tableA = {
    x=0,
    y=1004,
    z=20,
  }
  local tableB = {}
  pb.util.shallowCopy(tableB, tableA)
  assert(tableB.x == 0, "TableB's x value should equal TableA's x value of 0.")
  assert(tableB.y == 1004, "TableB's y value should equal TableA's y value of 1004.")
  assert(tableB.z == 20, "TableB's z value should equal TableA's z value of 20.")

  tableA.x = 40000
  assert(tableB.x == 0, "TableB.x should still be 0 and not change when TableA.x is set.")

  tableB.x = 1000
  assert(tableA.x == 40000, "TableA.x should still be 40000 and not change when TableB.x is set.")
end

-- Tests bitfields
function Test_Bitfield()
  local emptyBitfield = pb.bitfield.new()
  assert(emptyBitfield.value == 0, "Value should be 0 with no flags set.")
  assert(not emptyBitfield:has(0), "Flag 0 should not be set.")
  assert(not emptyBitfield:has(1), "Flag 1 should not be set.")
  assert(not emptyBitfield:has(10), "Flag 10 should not be set.")
  assert(not emptyBitfield:has(26), "Flag 26 should not be set.")
  assert(not emptyBitfield:has(31), "Flag 31 should not be set.")

  local allFlags = {}
  for i = 1, 32, 1 do
    allFlags[i] = i - 1
  end

  local fullBitfield = pb.bitfield.new(allFlags)
  assert(fullBitfield.value == 4294967295, "Value should be 4294967295 with all flags set.")
  assert(fullBitfield:has(0), "Flag 0 should be set.")
  assert(fullBitfield:has(1), "Flag 1 should be set.")
  assert(fullBitfield:has(10), "Flag 10 should be set.")
  assert(fullBitfield:has(26), "Flag 26 should be set.")
  assert(fullBitfield:has(31), "Flag 31 should be set.")

  local evenFlags = {}
  for i = 0, 31, 1 do
    if i % 2 == 0 then
      table.insert(evenFlags, i)
    end
  end

  local evenBitfield = pb.bitfield.new(evenFlags)
  assert(evenBitfield.value == 1431655765, "Value should be 1431655765 with all even flags set.")
  assert(evenBitfield:has(0), "Flag 0 should be set.")
  assert(not evenBitfield:has(1), "Flag 1 should not be set.")
  assert(evenBitfield:has(2), "Flag 2 should be set.")
  assert(not evenBitfield:has(21), "Flag 21 should not be set.")
  assert(evenBitfield:has(30), "Flag 30 should be set.")

  local bitfield = pb.bitfield.new()
  bitfield:set(31)
  assert(bitfield.value == 2147483648, "Value should be 2147483648 with flag 31 set.")
  assert(not bitfield:has(0), "Flag 0 should not be set.")
  assert(not bitfield:has(7), "Flag 7 should not be set.")
  assert(bitfield:has(31), "Flag 31 should be set.")

  bitfield:set(7)
  assert(bitfield.value == 2147483776, "Value should be 2147483776 with flag 31 and 7 set.")
  assert(not bitfield:has(0), "Flag 0 should not be set.")
  assert(bitfield:has(7), "Flag 7 should be set.")
  assert(bitfield:has(31), "Flag 31 should be set.")

  bitfield:unset(31)
  assert(bitfield.value == 128, "Value should be 128 with flag 7 set.")
  assert(not bitfield:has(0), "Flag 0 should not be set.")
  assert(bitfield:has(7), "Flag 7 should be set.")
  assert(not bitfield:has(31), "Flag 31 should not be set.")

  bitfield:unset(7)
  assert(bitfield.value == 0, "Value should be 0 with no flags set.")
  assert(not bitfield:has(0), "Flag 0 should not be set.")
  assert(not bitfield:has(7), "Flag 7 should not be set.")
  assert(not bitfield:has(31), "Flag 31 should not be set.")
end

-- Test component arrays
function Test_ComponentArrays()
  local componentArray = require("playbit.component-array")
  local arr = componentArray.new()

  arr:add(0, { value="A"})
  arr:add(1, { value="B"})
  arr:add(2, { value="C"})
  assert(#arr.components == 3, "Adding components should increased component count.")

  arr:remove(1)
  assert(#arr.components == 2, "Removing a component should reduce component count.")
  assert(arr:get(2).value == "C", "Removing a component should not affect other components.")

  arr:add(3, { value="D"})
  assert(#arr.components == 3, "Adding another component should increased component count.")
  assert(arr:get(2).value == "C", "Adding another component should not affect other components.")
  assert(arr:get(3).value == "D", "Adding another component should not affect other components.")

  arr:remove(0)
  arr:remove(2)
  arr:remove(3)
  assert(#arr.components == 0, "Removing all components should result in empty array.")
end

-- Tests entities
function Test_Entities()
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
  assert(scene.entityCount == 1, "Adding an entity should increase entity count.")

  local transformComponent = scene:getComponent(tempId, pb.components.Transform.name)
  assert(transformComponent.x == 5, "x value should be the original value of 5.")
  assert(transformComponent.y == 0, "y value was not set and should be 0.")

  scene:removeEntity(tempId)
  scene:update()
  assert(scene.entityCount == 0, "Removing an entity should reduce entity count.")

  local playerName = "Player"
  local playerId = scene:addEntity({ 
    [pb.components.Name.name] = { name=playerName },
    ["ComponentA"] = { x=0, y=0 },
  })
  scene:update()

  assert(playerId == 1, "PlayerId should be 1.")
  assert(scene:findEntity(playerName) == playerId, "Returned entity id should match player id of 1.")
  assert(scene:findEntity("does not exist") == -1, "Entity should not be able to be found and return special value of -1.")

  assert(scene:hasComponentId(playerId, nameId), "Player entity should have name component.")
  assert(scene:hasComponentId(playerId, componentAId), "Player entity should have ComponentA.")
  assert(not scene:hasComponentId(playerId, componentBId), "Player entity should not have ComponentB.")
  assert(not scene:hasComponentId(playerId, transformId), "Player entity should not have transform component.")
  
  scene:addComponent(playerId, "ComponentB", {})
  scene:update()

  assert(scene:hasComponentId(playerId, componentBId), "Player entity should now have ComponentB.")

  scene:removeComponent(playerId, "ComponentA")
  scene:update()

  assert(scene:hasComponentId(playerId, nameId), "Removing ComponentA should not have removed name component.")
  assert(not scene:hasComponentId(playerId, componentAId), "Player entity should have had ComponentA removed.")
  assert(scene:hasComponentId(playerId, componentBId), "Removing ComponentA should not have removed ComponentB.")

  local entityA = scene:addEntity({ 
    ["ComponentA"] = { x=0, y=0 },
  })
  scene:update()
  assert(entityA == 2, "Adding a second entity should have result in an id of 2.")
  assert(scene.entityCount == 2, "Adding a new entity should have increased entity count.")

  local entityB = scene:addEntity({ 
    ["ComponentA"] = { x=0, y=0 },
  })
  scene:update()
  assert(entityB == 3, "Adding a second entity should have result in an id of 3.")
  assert(scene.entityCount == 3, "Adding a new entity should have increased entity count.")

  scene:removeEntity(entityA)
  scene:update()
  assert(scene.entityCount == 2, "Removing an entity should have reduced entity count.")

  local entityC = scene:addEntity({ 
    ["ComponentA"] = { x=0, y=0 },
  })
  scene:update()
  assert(entityC == 2, "Adding a third entity after one was removed should have result in the reuse of entity id 2.")
  assert(scene.entityCount == 3, "Adding a new entity should have increased entity count.")

  scene:removeEntity(playerId)
  scene:update()
  assert(scene.entityCount == 2, "Removing an entity should have reduced entity count.")

  assert(scene:findEntity(playerName) == -1, "Removing the player should have caused the entity to not have been found by name.")
end

function Test_App()
  local game = CreateAppInstance()

  local nameId = game:getComponentId("name")
  assert(nameId ~= nil, "Component id should have been returned.")
end

-- ██████╗ ██╗   ██╗███╗   ██╗
-- ██╔══██╗██║   ██║████╗  ██║
-- ██████╔╝██║   ██║██╔██╗ ██║
-- ██╔══██╗██║   ██║██║╚██╗██║
-- ██║  ██║╚██████╔╝██║ ╚████║
-- ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
-- Run all test cases and print results                          

local testsToRun = {
  { name="App Tests", testFunction=Test_App },
  { name="Bitfield Tests", testFunction=Test_Bitfield },
  { name="Misc Util Tests", testFunction=Test_Utils },
  { name="System Tests", testFunction=Test_System },
  { name="Component Tests", testFunction=Test_ComponentArrays },
  { name="Entity Tests", testFunction=Test_Entities },
}

local totalStartTime = os.clock()
for k,v in ipairs(testsToRun) do
  local startTime = os.clock()
  v.testFunction()
  local endTime = os.clock()
  print("'" .. v.name .. "' completed in " .. (endTime - startTime) .. "ms")
end
local totalEndTime = os.clock()

print("\nAll tests succeeded in " .. (totalEndTime - totalStartTime) .. "ms")