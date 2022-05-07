import("playbit/pb")
pb.import("scripts/game")

pb.app.load()

function playdate.update()
  pb.app.update()
end

function playdate.cranked(change, acceleratedChange)
  pb.input.cranked(change, acceleratedChange)
end

function playdate.AButtonDown()
  pb.input.handleKeyPressed("a")
end

function playdate.AButtonUp()
  pb.input.handleKeyReleased("a")
end

function playdate.BButtonDown()
  pb.input.handleKeyPressed("b")
end

function playdate.BButtonUp()
  pb.input.handleKeyReleased("b")
end

function playdate.upButtonDown()
  pb.input.handleKeyPressed("up")
end

function playdate.upButtonUp()
  pb.input.handleKeyReleased("up")
end

function playdate.downButtonDown()
  pb.input.handleKeyPressed("down")
end

function playdate.downButtonUp()
  pb.input.handleKeyReleased("down")
end

function playdate.leftButtonDown()
  pb.input.handleKeyPressed("left")
end

function playdate.leftButtonUp()
  pb.input.handleKeyReleased("left")
end

function playdate.rightButtonDown()
  pb.input.handleKeyPressed("right")
end

function playdate.rightButtonUp()
  pb.input.handleKeyReleased("right")
end