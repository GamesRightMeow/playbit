Object = {}
Object.__index = Object
Object.class = Object
Object.className = 'Object'

-- Override to initialize 
function Object:init(...) end

-- Override to base a subclass on an already existing table
function Object.baseObject()
	return {}
end

local __NewClass = {}

function class(ClassName, properties)
    __NewClass.className = ClassName
    __NewClass.properties = properties
	return __NewClass
end

function __NewClass.extends(Parent)
	if type(Parent) == 'string' then
    -- error("Usage of _G[Parent] not implemented! Needs to way to reference global ")
    Parent = _G[Parent]
    -- Remove _G if avoiding global class storage ??
  elseif Parent == nil then 
    Parent = Object
	end

	local Child = __NewClass.properties or {}
	Child.__index = Child
	Child.class = Child
	Child.className = __NewClass.className
	Child.super = Parent

	-- Preserve Lua Metamethod Inheritance
	for _, meta in ipairs({
		"__gc", "__newindex", "__mode", "__tostring",
		"__len", "__unm", "__add", "__sub",
		"__mul", "__div", "__mod", "__pow",
		"__concat", "__eq", "__lt", "__le"
	}) do
		Child[meta] = Parent[meta]
	end

	local mt = {
		__index = Parent,
		__call = function(self, ...)
			local instance = Child.baseObject()
			setmetatable(instance, Child)
			instance.super = Child
			Child.init(instance, ...)
			return instance
		end
	}

	setmetatable(Child, mt)

	-- Remove global namespace modification
	__NewClass.properties = nil
	__NewClass.className = nil
end

-- Check if an object is an instance of a class or subclass
function Object:isa(Class)
	local currentClass = self
	while currentClass do
		if currentClass == Class then return true end
		currentClass = currentClass.super
	end
	return false
end

-- Debugging: Print a table's key/value pairs and hierarchy
function Object:tableDump(indent, table)
	local function printFormattedKeyValue(indent, k, v)
		v = v or ''
		print(string.rep('  ', indent) .. k .. ': ' .. tostring(v))
	end

	table = table or self
	indent = indent or 0
	local super = nil
	
	for k, v in pairs(table) do
		if k == "super" then
			super = v
		elseif type(v) == "table" then
			printFormattedKeyValue(indent, k)
			Object.tableDump(indent + 1, v)
		else
			printFormattedKeyValue(indent, k, v)
		end
	end

	if super and super.className ~= "Object" then
		print("\nSuper Class (" .. super.className .. ")")
		super:tableDump(indent + 1)
	end
end

-- Utility: Pretty print tables
local function repeatString(s, t)
	return string.rep(s, t)
end

local function sortAny(val1, val2)
	local type1, type2 = type(val1), type(val2)
	local num1, num2 = tonumber(val1), tonumber(val2)
	if num1 and num2 then return num1 < num2 end
	if type1 ~= type2 then return type1 < type2 end
	if type1 == "string" then return val1 < val2 end
	if type1 == "boolean" then return val1 end
	return tostring(val1) < tostring(val2)
end

local function pairsByKey(t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f or sortAny)
	local i = 0
	return function()
		i = i + 1
		if not a[i] then return nil else return a[i], t[a[i]] end
	end
end

local encounteredTables = {}

local function tableToString(o, path, t)
	path = path or '/'
	if encounteredTables[o] then
		return 'reference: ' .. encounteredTables[o]
	end
	encounteredTables[o] = path
	
	t = t or 1
	local lines = {'{'}
	local tabs = repeatString('\t', t)
	t = t + 1
	
	for k, v in pairsByKey(o) do
		local key = type(k) ~= "number" and "[" .. tostring(k) .. "] = " or ""
		local value = type(v) == "table" and tableToString(v, path .. k .. '/', t) or tostring(v)
		table.insert(lines, tabs .. key .. value .. ',')
	end
	
	table.insert(lines, repeatString('\t', t - 2) .. '}')
	return table.concat(lines, '\n')
end

function printTable(...)
	encounteredTables = {}
	local args = {...}
	for i = 1, #args do
		if type(args[i]) == "table" then
			args[i] = tableToString(args[i])
		end
	end
	print(table.unpack(args))
	encounteredTables = nil
end
