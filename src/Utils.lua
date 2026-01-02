local _, addon = ...
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

function M:IsWalking()
	if UnitAffectingCombat("player") then
		-- they might be affected by a movement impairment debuff
		return false
	end

	local speed = GetUnitSpeed("player")

	-- 0 = not moving at all
	if not speed or speed <= 0 then
		return false
	end

	-- Normal run speed is ~7.0 yards/sec
	-- Walking is ~2.5–3.5 yards/sec
	return speed < 6.5
end

function M:IsStandingStill()
	local currentSpeed = GetUnitSpeed("player")

	if IsFlying() then
		return false
	end

	return not currentSpeed or currentSpeed <= 0
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
