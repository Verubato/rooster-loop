local _, addon = ...
---@class Utils
local M = {}
addon.Utils = M

function M:CopyTable(src, dst)
	if type(dst) ~= "table" then
		dst = {}
	end

	for k, v in pairs(src) do
		if type(v) == "table" then
			dst[k] = M:CopyTable(v, dst[k])
		elseif dst[k] == nil then
			dst[k] = v
		end
	end

	return dst
end

-- 12.0 hands tainted code a secret number for the player's speed, and comparing one throws.
-- Older clients have no secrets, so the predicate is only called when the client defines it.
local function ReadSpeed()
	local speed = GetUnitSpeed("player")

	if issecretvalue and issecretvalue(speed) then
		return nil
	end

	return speed
end

function M:IsWalking()
	if UnitAffectingCombat("player") then
		-- they might be affected by a movement impairment debuff
		return false
	end

	local speed = ReadSpeed()

	-- 0 = not moving at all
	if not speed or speed <= 0 then
		return false
	end

	-- Normal run speed is ~7.0 yards/sec
	-- Walking is ~2.5–3.5 yards/sec
	return speed < 6.5
end

function M:IsStandingStill()
	local currentSpeed = ReadSpeed()

	-- an unreadable speed isn't proof of standing still
	if not currentSpeed then
		return false
	end

	if IsFlying() then
		return false
	end

	return currentSpeed <= 0
end

function M:IsFishing()
	local name, _, _, _, _, _, spellID = UnitChannelInfo("player")
	return spellID == 131474 or name == PROFESSIONS_FISHING
end

function M:IsAuctionHouseShown()
	if AuctionHouseFrame and AuctionHouseFrame.IsShown then
		return AuctionHouseFrame:IsShown()
	end

	if AuctionFrame and AuctionFrame.IsShown then
		return AuctionFrame:IsShown()
	end

	return false
end
