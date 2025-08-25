Object = {}
Object.class = Object
Object.className = "Object"
Object.__index = Object

function Object:init(...)
end

function Object.baseObject()
  return {}
end

function Object:isa(class)
  local current = self
  while current ~= nil do
    if current == class then
      return true
    end
    current = current.super
  end
  return false
end

local classTemp = {}

function class(name, properties, namespace)
  classTemp.className = name
  classTemp.properties = properties
  classTemp.namespace = namespace
  return classTemp
end

function classTemp.extends(parent)
  if parent == nil then
    parent = Object
  elseif type(parent) == "string" then
    parent = _G[parent]
  end

  local subclass = classTemp.properties or {}
  subclass.class = subclass
  subclass.className = classTemp.className
  subclass.super = parent
  
  subclass.__index = subclass
  subclass.__gc = parent.__gc
  subclass.__newindex = parent.__newindex
  subclass.__mode = parent.__mode
  subclass.__tostring = parent.__tostring
  subclass.__len = parent.__len
  subclass.__unm = parent.__unm
  subclass.__add = parent.__add
  subclass.__sub = parent.__sub
  subclass.__mul = parent.__mul
  subclass.__div = parent.__div
  subclass.__mod = parent.__mod
  subclass.__pow = parent.__pow
  subclass.__concat = parent.__concat
  subclass.__eq = parent.__eq
  subclass.__lt = parent.__lt
  subclass.__le = parent.__le

  local meta = {}
  meta.__index = parent
  meta.__call = function (self, ...)
    local instance = subclass.baseObject()
    setmetatable(instance, subclass)
    instance.super = subclass
    subclass.init(instance, ...)
    return instance
  end
  setmetatable(subclass, meta)

  if classTemp.namespace == nil then
    -- if no namespace, put in global var
    _G[classTemp.className] = subclass
  else
    -- otherwise place in namespace object
    classTemp.namespace[classTemp.className] = subclass
  end

  classTemp.className = nil
  classTemp.properties = nil
  classTemp.namespace = nil
end