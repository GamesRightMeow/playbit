local bitfield = require("playbit.bitfield")

function BitflagContains()
  local hashmap = { [1]=true, [2]=true, [6]=true, [8]=true }
  local flags = {1, 2, 6, 8}
  local bf = bitfield.new(flags)
  local bfRaw = 1 << 1 | 1 << 2 | 1 << 6 | 1 << 8

  local flagSearch = { 1, 2, 9 }
  local bitSearch = 1 << 1 | 1 << 2 | 1 << 9

  local function hasBitFlags(flags)
    return bfRaw & flags == flags
  end

  local function hasHashFlags(flags)
    for i = 1, #flags, 1 do
      if hashmap[i] == nil then  
        return false
      end
    end
    return true
  end

  local iterations = 1000000

  local startTime = os.clock()
  for j = 1, iterations, 1 do
    local a = bfRaw & bitSearch == bitSearch
  end
  local endTime = os.clock()
  print("raw="..endTime - startTime) -- fastest!

  local startTime = os.clock()
  for j = 1, iterations, 1 do
    local a = hasBitFlags(bitSearch)
  end
  local endTime = os.clock()
  print("rawFunc="..endTime - startTime)

  local startTime = os.clock()
  for j = 1, iterations, 1 do
    local a = bf:hasBit(bitSearch)
  end
  local endTime = os.clock()
  print("bf="..endTime - startTime)

  local startTime = os.clock()
  for j = 1, iterations, 1 do
    for i = 1, #flagSearch, 1 do
      if hashmap[i] == nil then  
        local a = 10
      end
    end
  end
  local endTime = os.clock()
  print("hashmap="..endTime - startTime)

  local startTime = os.clock()
  for j = 1, iterations, 1 do
    hasHashFlags(flagSearch)
  end
  local endTime = os.clock()
  print("hashMapFunc="..endTime - startTime)

  local startTime = os.clock()
  for j = 1, iterations, 1 do
    for fs = 1, #flagSearch, 1 do
      for f = 1, #flags, 1 do
        if flags[f] == flagSearch[fs] then
          break
        end
      end
    end
  end
  local endTime = os.clock()
  print("dumpLoop="..endTime - startTime)
end

function BitflagSet()
  local iterations = 1000000
  local add0 = 0
  local add1 = 0
  local add2 = bitfield.new()
  local add3 = bitfield.new()
  local add4 = bitfield.new()
  local add5 = {}

  local bits = {}
  local allBits = 4294967295
  for i = 0, 31, 1 do
    bits[i+1] = 1 << i
  end

  local startTime = os.clock()
  for j = 1, iterations, 1 do
    for i = 0, 31, 1 do
      add0 = add0 | i
    end
  end
  local endTime = os.clock()
  print("setInline="..endTime - startTime)

  local startTime = os.clock()
  for j = 1, iterations, 1 do
      add1 = add1 | allBits
  end
  local endTime = os.clock()
  print("setInline(all)="..endTime - startTime)

  local startTime = os.clock()
  for j = 1, iterations, 1 do
    for i = 0, 31, 1 do
      add2:set(i)
    end
  end
  local endTime = os.clock()
  print("bf.set="..endTime - startTime)

  local startTime = os.clock()
  for j = 1, iterations, 1 do
    for i = 1, #bits, 1 do
      add3:setBit(bits[i])
    end
  end
  local endTime = os.clock()
  print("bf.setBit="..endTime - startTime)

  local startTime = os.clock()
  for j = 1, iterations, 1 do
    add4:setBit(allBits)
  end
  local endTime = os.clock()
  print("bf.setBit(all)="..endTime - startTime)

  local startTime = os.clock()
  for j = 1, iterations, 1 do
    for i = 1, 32, 1 do
      add5[i] = i
    end
  end
  local endTime = os.clock()
  print("setHashmap="..endTime - startTime)
end

function ArrayVsHashmap()
  local numHashmap = { [1]=true, [5]=true, [6]=true }
  local array = {true,false,false,false,true,true}
  local stringHashmap = {}
  stringHashmap["1"] = true
  stringHashmap["5"] = true
  stringHashmap["6"] = true

  local searchNum = { 1, 5, 6, 2 }
  local searchStr = { "1", "5", "6", "2" }

  local iterations = 1000000

  local startTime = os.clock()
  for j = 1, iterations, 1 do
    for i = 1, #searchNum, 1 do
      if array[searchNum[i]] then
        local a = 2 * 2
      end
    end
  end
  local endTime = os.clock()
  print("array="..endTime - startTime)

  local startTime = os.clock()
  for j = 1, iterations, 1 do
    for i = 1, #searchNum, 1 do
      if numHashmap[searchNum[i]] then
        local a = 2 * 2
      end
    end
  end
  local endTime = os.clock()
  print("numHashmap="..endTime - startTime)

  local startTime = os.clock()
  for j = 1, iterations, 1 do
    for i = 1, #searchNum, 1 do
      if stringHashmap[searchStr[i]] then
        local a = 2 * 2
      end
    end
  end
  local endTime = os.clock()
  print("stringHashmap="..endTime - startTime)
end

function InlineFunction()
  local iterations = 1000000

  local function test()
    return 2 + 2
  end

  local startTime = os.clock()
  for j = 1, iterations, 1 do
    local a = test()
  end
  local endTime = os.clock()
  print("function="..endTime - startTime)

  local startTime = os.clock()
  for j = 1, iterations, 1 do
    local a = 2 + 2
  end
  local endTime = os.clock()
  print("inline="..endTime - startTime)
end

function ECS()
  -- about the same perf with lower entity counts, but ecs wins out with more entities
  local iterations = 10000
  local entityCount = 100

  local objectMeta = { value=0, update=function(self) self.value = self.value + 1 end };
  objectMeta.__index = objectMeta

  local objects = {}
  for i = 1, entityCount, 1 do
    objects[i] = {}
    setmetatable(objects[i], objectMeta)
  end

  local entityMeta = { value=0 }
  entityMeta.__index = entityMeta

  local entities = {}
  for i = 1, entityCount, 1 do
    entities[i] = {}
    setmetatable(entities[i], entityMeta)
  end

  local startTime = os.clock()
  for j = 1, iterations, 1 do
    for i = 1, #objects, 1 do
      objects[i]:update()
    end
  end
  local endTime = os.clock()
  print("objects="..endTime - startTime)

  local startTime = os.clock()
  for j = 1, iterations, 1 do
    for i = 1, #entities, 1 do
      entities[i].value = entities[i].value + 1
    end
  end
  local endTime = os.clock()
  print("entities="..endTime - startTime)
end

local benchmarks = {
  { name="BitflagContains", func=BitflagContains },
  { name="BitflagSet", func=BitflagSet },
  { name="ArrayVsHashmap", func=ArrayVsHashmap },
  { name="InlineFunction", func=InlineFunction },
  { name="ECS", func=ECS },
}

for i = 1, #benchmarks, 1 do
  print("\n>>>"..benchmarks[i].name)
  benchmarks[i].func()
end