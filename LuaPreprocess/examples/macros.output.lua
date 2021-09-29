--[[============================================================
--=
--=  LuaPreprocess example: Macros.
--=
--=  Here we define a better assert function using a macro.
--=
--============================================================]]

local i = 4

--
-- A call to Lua's normal assert function might look something like this. A
-- problem is that the message expression is evaluated even if the condition
-- is true, which is completely unnecessary. (This example is very simple of
-- course, but imagine more costly operations happening.)
--
assert(i > 1 and i < 7, "Invalid index. It must be 1<=i<=7 but is "..i)

--
-- By prepending @insert we actually call the assert function in the
-- metaprogram which, as we defined above, separates the condition and the
-- message arguments so that the message expression never evaluates as long as
-- the condition is true.
--
if not (i > 1 and i < 7) then  error("Invalid index. It must be 1<=i<=7 but is "..i)  end

-- We also made the default message better by including the condition code
-- itself in the message.
if not (i > 1 and i < 7) then  error("Assertion failed: i > 1 and i < 7")  end

print("'i' is all good!")
