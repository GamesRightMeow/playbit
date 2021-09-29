--[[
	Blah.
]]
-- Preprocessor line.

local a = "a" -- Comment A.
print("a", a)

-- More preprocessor lines.

a = a.."b"..a -- Comment, string concat.

print("Aaaaand...")
print(2)

print("Aaaaand...")
print(4)

print("Aaaaand...")
print(6)

print"Get wrapped! Also, dogs..."

print"Get wrapped! Also, clouds..."

local data = 'a\n1Ü2"\n\255\255\0003'



local c   = 115
local str = "Included string #64.\nargs[1] is what"
print(str)

_G.global3 = 99



-- Extended preprocessor line. (Balanced brackets.)

local z = 137



-- Dual code. (Outputs both both preprocessor code and normal Lua. Can only be used for assignment statements.)
local alpha, alphanum = "[%a_]", "[%a%d_]"
local num             = "%d"
local ident           = "[%a_][%a%d_]*"
local funcCall        = "[%a_][%a%d_]*%(.-%)"

local s = [[:: 2 * hello5( foo ){ ... }]]
print(s:match(ident))    -- "hello5"
print(s:match(num))      -- "2"
print(s:match(funcCall)) -- "hello5( foo )"



-- File inserts.

local uhh1 = 7
local uhh2 = 7 -- @@ means the same as @insert.
print("Final program - uhh: "..uhh1..", "..uhh2)



-- Macros.

print("Blargh!")
print("Blargh!")
-- !@insert BLARGH() -- Error: Macro inside metaprogram.

print(string.format('We are at %s:%d!', "tests/quickTest.lua2p", 95))

local ok = 1==1

if not (ok) then error("Oh "..tonumber("7",10).." noes!") end
-- @insert ASSERT ( 1 1 ) -- Syntax error!
-- @insert ASSERT ( ok , ) -- Syntax error!
-- @insert ASSERT ( , ok ) -- Syntax error!
-- @insert ASSERT ( --[[]] , ok ) -- Syntax error!

local s = "foo"
local t = { 496, b=true } -- @@ means the same as @insert.

-- local s = @@PASS_THROUGH `foo`

local f = function(a, b)
	while true do
		repeat until arePlanetsAligned("mars", "jupiter")
		-- repeat until arePlanetsAligned(`mars`, `jupiter`)
		break
	end
	return "", nil
end

local a = 1+2*3
local b = 2
local c = { 1 + 2 + 3 }
local d = {1+2}

local n = 58



-- Misc.
print("dataFromCommandLine: Hello, world!")
print("This file and line: tests/quickTest.lua2p:145")

for i = 1, 3 do
	do
		break
	end
	break
end

local HUGE_POSITIVE = (1/0)
local HUGE_NEGATIVE = (-1/0)
local NAN           = (0/0)

print("The end.")
