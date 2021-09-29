--[[============================================================
--=
--=  LuaPreprocess example: Selective functionality.
--=
--=  Here we decide what code should be included and run in the
--=  final program with some flags set in the metaprogram.
--=
--============================================================]]

quitGame = false

function addNormalLevelsToArray(levels)  print("Adding normal levels")    end
function addTestLevelsToArray(levels)    print("(*) Adding test levels")  end

function getPlayableLevels()
	local levels = {}
	addNormalLevelsToArray(levels)

	return levels
end

function loadAssets()                print("Loading assets")            end
function showLevelsToPlayer(levels)  print("Showing levels to player")  end
function readInput()                 print("Reading input")             end
function updateGameState()           print("Updating game state")       end
function render()                    print("Rendering")                 end

function initConsole()    print("(*) Initting console")  end
function updateConsole()  print("(*) Updating console")  end

function runGame()
	print("Starting game")

	loadAssets()

	initConsole()

	local levels = getPlayableLevels()
	showLevelsToPlayer(levels)

	-- Main game loop.
	repeat
		readInput()

		updateConsole()

		updateGameState()
		render()

		-- In this example, don't run the loop forever!
		quitGame = true
	until quitGame

	print("Quitting game")
end

runGame()
