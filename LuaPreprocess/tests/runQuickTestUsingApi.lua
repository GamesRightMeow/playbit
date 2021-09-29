io.stdout:setvbuf("no")
io.stderr:setvbuf("no")

local pp = require"preprocess"

local info, err = pp.processFile{
	pathIn   = "tests/quickTest.lua2p",
	pathOut  = "tests/quickTest.lua",
	pathMeta = "tests/quickTest.meta.lua",
	debug    = true,
}

if not info then
	print("Oh no! Processing failed!")
	os.exit(1)
end
