--[[============================================================
--=
--=  LuaPreprocess example: Pre-parse a data file.
--=
--=  Here we convert a JSON data string to a more appropriate
--=  data format in the metaprogram. The final program will not
--=  contain anything related to JSON - just a nice Lua table
--=  literal with all data.
--=
--============================================================]]

-- Metaprogram.
--==============================================================



-- The program.
--==============================================================

local characters = {{actions={{slot="left",title="Slash"},{slot="right",title="Block"}},id=1,name="Warrior",type="melee"},{actions={{slot="left",title="Fireball"},{slot="right",title="Illuminate"},{slot="familiar",title="Swoop"}},id=2,name="Spell Caster",type="magic"}}

function printAvailableCharacters()
	print("Available characters:")

	for i, character in ipairs(characters) do
		print(string.format(
			"%d. %s (type: %s, actions: x%d)",
			i,
			character.name,
			character.type,
			#character.actions
		))
	end
end

printAvailableCharacters()

--==============================================================
