--[[============================================================
--=
--=  LuaPreprocess example: Optimize data access.
--=
--=  Here we have all data defined in one single place in the
--=  metaprogram, then we export parts of the data into multiple
--=  smaller tables that are easy and fast to access in the
--=  final program.
--=
--============================================================]]

-- Array of character IDs, excluding special characters if we're not in developer mode.
CHARACTER_IDS = {
	"war1",
	"war2",
	"mage1",
	"mage2",
	"arch1",
	"arch2",
}

-- Maps between character IDs and other parameters.
CHARACTER_NAMES = {
	war1 = "Steve",
	war2 = "Bog",
	mage1 = "Elise",
	mage2 = "Cyan",
	arch1 = "Di",
	arch2 = "#&%€",
	dev = "Dev",
}
CHARACTER_TYPES = {
	war1 = "warrior",
	war2 = "warrior",
	mage1 = "mage",
	mage2 = "mage",
	arch1 = "archer",
	arch2 = "archer",
	dev = "dev",
}
CHARACTERS_UNLOCKED_BY_DEFAULT = {
	war1 = true,
	mage1 = true,
	arch1 = true,
	dev = true,
}

-- Instead of iterating over the CHARACTERS array until we find
-- the character with the specified ID, we use the maps above to
-- get the information we want through a single table lookup.
function getCharacterName(charId)
	return CHARACTER_NAMES[charId]
end
function getCharacterType(charId)
	return CHARACTER_TYPES[charId]
end
function isCharacterUnlockedByDefault(charId)
	return CHARACTERS_UNLOCKED_BY_DEFAULT[charId] == true
end

function printCharacterInfo()
	for _, charId in ipairs(CHARACTER_IDS) do
		print(getCharacterName(charId))
		print("  Type ...... "..getCharacterType(charId))
		print("  Unlocked .. "..tostring(isCharacterUnlockedByDefault(charId)))
	end
end

printCharacterInfo()
print("Type of 'war1': "..getCharacterType("war1"))
print("Is 'mage2' unlocked by default: "..tostring(isCharacterUnlockedByDefault("mage2")))
