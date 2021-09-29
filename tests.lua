local pb = require("playbit.pb")

function SystemTests()
  local game = pb.app.new()

  local componentAId = game:registerComponent("ComponentA")
  local componentBId = game:registerComponent("ComponentB")
  local componentCId = game:registerComponent("ComponentC")
  assert(componentAId == 1)
  assert(componentBId == 2)
  assert(componentCId == 3)

  local systemAId = game:registerSystem("SystemA",   { components={ "ComponentA" } })
  local systemBId = game:registerSystem("SystemB",   { components={ "ComponentB" } })
  local systemCId = game:registerSystem("SystemC",   { components={ "ComponentC" } })
  local systemBCId = game:registerSystem("SystemBC", { components={ "ComponentB", "ComponentC" } })
  assert(systemAId == 1)
  assert(systemBId == 2)
  assert(systemCId == 3)
  assert(systemBCId == 4)
  
  for i = 1, 24, 1 do
    game:registerComponent(tostring(i))
  end

  local componentDId = game:registerComponent("ComponentD")
  assert(componentDId == 28)

  local scene = pb.scene.new(game)
  scene:addEntity({
    [componentAId] = {}
  })
  scene:addEntity({
    [componentBId] = {}
  })
  scene:addEntity({
    [componentCId] = {}
  })
  scene:addEntity({
    [componentBId] = {},
    [componentCId] = {},
  })
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
  local game = pb.app.new()
  game:load()
  
  local COMPONENT_A_ID = game:registerComponent("ComponentA")
  local COMPONENT_B_ID = game:registerComponent("ComponentB")

  local scene = pb.scene.new(game)

  local tempId = scene:addEntity({
    [pb.components.Name.id] = { x=0, y=0 },
  })
  assert(scene.entityCount == 1)

  scene:removeEntity(tempId);
  assert(scene.entityCount == 0)

  local playerName = "Player"
  local playerId = scene:addEntity({ 
    [pb.components.Name.id] = { name=playerName },
    [COMPONENT_A_ID] = { x=0, y=0 },
  })

  local nameSystemId = game:getSystemId("name")
  assert(#scene.systemEntityIds[nameSystemId].entities == 1)
  assert(playerId == 0)
  assert(scene.entityCount == 1)
  assert(scene:findEntity(playerName) == playerId)
  assert(scene:findEntity("does not exist") == -1)

  assert(scene:hasComponent(playerId, pb.components.Name.id))
  assert(scene:hasComponent(playerId, COMPONENT_A_ID))
  assert(not scene:hasComponent(playerId, COMPONENT_B_ID))
  assert(not scene:hasComponent(playerId, pb.components.Transform.id))
  
  scene:addComponent(playerId, COMPONENT_B_ID, {})
  assert(scene:hasComponent(playerId, pb.components.Name.id))
  assert(scene:hasComponent(playerId, COMPONENT_A_ID))
  assert(scene:hasComponent(playerId, COMPONENT_B_ID))
  assert(not scene:hasComponent(playerId, pb.components.Transform.id))

  scene:removeComponent(playerId, COMPONENT_A_ID)
  assert(scene:hasComponent(playerId, pb.components.Name.id))
  assert(not scene:hasComponent(playerId, COMPONENT_A_ID))
  assert(scene:hasComponent(playerId, COMPONENT_B_ID))
  assert(not scene:hasComponent(playerId, pb.components.Transform.id))

  local entityA = scene:addEntity({ 
    [COMPONENT_A_ID] = { x=0, y=0 },
  })
  assert(entityA == 1);
  assert(scene.entityCount == 2)

  local entityB = scene:addEntity({ 
    [COMPONENT_A_ID] = { x=0, y=0 },
  })
  assert(entityB == 2);
  assert(scene.entityCount == 3)

  scene:removeEntity(entityA)
  assert(scene.entityCount == 2)

  local entityC = scene:addEntity({ 
    [COMPONENT_A_ID] = { x=0, y=0 },
  })
  assert(entityC == 1);
  assert(scene.entityCount == 3)

  scene:removeEntity(playerId)
  assert(scene.entityCount == 2)

  assert(scene:findEntity(playerName) == -1)
end

function AppTests()
  local game = pb.app.new()
  game:load()

  local nameId = game:getComponentId("name")
  assert(nameId == pb.components.Name.id)
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