--[[============================================================
--=
--=  LuaPreprocess example: Named constants.
--=
--=  Here we use named constants in the code but the final
--=  program will only have literal values.
--=
--============================================================]]

function newAnimation(totalDuration, name)
	name = name or "my_animation"

	local animation = {}

	animation.name            = name
	animation.totalDuration   = totalDuration
	animation.currentPosition = 0

	return animation
end

function updateAnimation(animation, deltaTime)
	local deltaPosition = deltaTime * 2

	animation.currentPosition = (animation.currentPosition + deltaPosition) % animation.totalDuration
end

function testAnimationStuff()
	local animation = newAnimation(5)

	for i = 1, 5 do
		updateAnimation(animation, 0.1)

		print(animation.name.." position: "..animation.currentPosition)
	end
end

testAnimationStuff()
