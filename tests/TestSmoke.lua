-- Loads the whole addon into a mocked client and drives it through login.
-- The shared body lives in build/Lua/SmokeTest.lua.

local smoke = require("SmokeTest")

-- The client keeps saved variables across an install, so an earlier suite's settings would
-- otherwise decide what this one loads with.
_G.RoosterLoopDB = nil

smoke.Run("RoosterLoop")
