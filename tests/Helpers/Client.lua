-- Movement, rest and fishing APIs that the shared mock (build/Lua/WowMock.lua) does not carry.
-- WowMock snapshots the globals that exist when it is required, so this file must run first.

local M = {
	Mounted = false,
	Swimming = false,
	Flying = false,
	Resting = false,
	Afk = false,
	-- Normal run speed, which is neither walking nor standing still.
	Speed = 7,
}

_G.IsMounted = function()
	return M.Mounted
end

_G.IsSwimming = function()
	return M.Swimming
end

_G.IsFlying = function()
	return M.Flying
end

_G.IsResting = function()
	return M.Resting
end

_G.UnitIsAFK = function()
	return M.Afk
end

_G.GetUnitSpeed = function()
	return M.Speed
end

-- A real client always has this string.
_G.PROFESSIONS_FISHING = "Fishing"

return M
