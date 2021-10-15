local components = require("playbit.components")

local System = {}

System.name = "name-allocator"
System.components = { components.Name.name }

return System