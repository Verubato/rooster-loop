local addonName, addon = ...
local db
local utils = addon.Utils
local soundPath = "Interface\\AddOns\\RoosterLoop\\WhistleStop.mp3"
local channel = "Master"
local soundLengthSeconds = 89
local ticker
local evalTicker
local isPlaying = false
local enabled = false
local soundHandle = nil
local randomState = {}
local randomActiveKey = nil
local randomInitialised = false
local randomPickChance = 0.10
local M = {}
addon.Rooster = M

local function Notify(msg)
	print(string.format("RoosterLoop - %s", msg))
end

local function RollChance(p)
	return math.random() < p
end

local function IsConditionTrue(key, conditions)
	local fn = conditions[key]

	if not fn then
		return false
	end

	return fn()
end

local function RandomConditions()
	return {
		-- exclude these from our random conditions:
		-- Resting
		Walking = function()
			return utils:IsWalking()
		end,
		StandingStill = function()
			return utils:IsStandingStill()
		end,
		Flying = function()
			return IsFlying()
		end,
		Mounted = function()
			return IsMounted()
		end,
		Swimming = function()
			return IsSwimming()
		end,
		Afk = function()
			return UnitIsAFK("player")
		end,
		Ghost = function()
			return UnitIsGhost("player")
		end,
		Dead = function()
			return UnitIsDead("player")
		end,
		Fishing = function()
			return utils:IsFishing()
		end,
		AuctionHouse = function()
			return utils:IsAuctionHouseShown()
		end,
	}
end

---@return boolean changed one or more of the states changed
---@return table trueKeys set of conditions that are true
local function UpdateRandomSnapshot(stateMap)
	local changed = false
	local trueKeys = {}

	for key in pairs(stateMap) do
		local now = IsConditionTrue(key, stateMap)
		local prev = randomState[key]

		if not randomInitialised or prev ~= now then
			changed = true
		end

		randomState[key] = now

		if now then
			trueKeys[#trueKeys + 1] = key
		end
	end

	randomInitialised = true
	return changed, trueKeys
end

local function PickRandom(array)
	local count = #array

	if count == 0 then
		return nil
	end

	return array[math.random(1, count)]
end

local function StopEvaluator()
	if evalTicker then
		evalTicker:Cancel()
		evalTicker = nil
	end
end

local function StartEvaluator()
	if evalTicker then
		return
	end

	evalTicker = C_Timer.NewTicker(0.5, function()
		M:PlayOrStop()
	end)
end

local function StopLoop()
	enabled = false
	isPlaying = false
	randomActiveKey = nil

	if ticker then
		ticker:Cancel()
		ticker = nil
	end

	if type(soundHandle) == "number" then
		pcall(StopSound, soundHandle)
	end

	soundHandle = nil
end

local function StartLoop()
	if ticker then
		ticker:Cancel()
		ticker = nil
	end

	enabled = true

	local ok, handle = PlaySoundFile(soundPath, channel)

	if ok then
		soundHandle = handle
		isPlaying = true
	else
		Notify("Failed to play song.")
		soundHandle = nil
		isPlaying = false
	end

	ticker = C_Timer.NewTicker(soundLengthSeconds, function()
		if not enabled then
			return
		end

		ok, handle = PlaySoundFile(soundPath, channel)

		if ok then
			soundHandle = handle
			isPlaying = true
		else
			Notify("Failed to play song.")
			soundHandle = nil
			isPlaying = false
		end
	end)
end

function M:Stop()
	StopLoop()
end

function M:PlayRandom()
	local stateMap = RandomConditions()

	-- detect state changes since last tick
	local changed, trueKeys = UpdateRandomSnapshot(stateMap)

	-- if we have an active key, keep playing until that key becomes false
	if randomActiveKey then
		if randomState[randomActiveKey] then
			M:Play()
			return true
		end

		-- chosen condition turned false
		randomActiveKey = nil
		M:Stop()
	end

	-- check if state changed
	if not changed then
		return false
	end

	-- check if random roll hits
	if not RollChance(randomPickChance) then
		return false
	end

	local picked = PickRandom(trueKeys)

	if picked then
		randomActiveKey = picked
		M:Play()
		return true
	end

	return false
end

function M:Play()
	if isPlaying then
		return
	end

	StartLoop()
end

function M:PlayOrStop()
	if not db or not db.PlayWhen then
		return
	end

	local inInstance = IsInInstance()

	if db.DontPlayWhen.InInstance and inInstance then
		M:Stop()
		return
	end

	if db.DontPlayWhen.InCombat and UnitAffectingCombat("player") then
		M:Stop()
		return
	end

	if db.PlayWhen.Always then
		M:Play()
		return
	end

	if db.PlayWhen.Random then
		local played = M:PlayRandom()

		if played then
			return
		end
	end

	if db.PlayWhen.Resting and IsResting() then
		M:Play()
		return
	end

	if db.PlayWhen.Walking and utils:IsWalking() then
		M:Play()
		return
	end

	if db.PlayWhen.StandingStill and utils:IsStandingStill() then
		M:Play()
		return
	end

	if db.PlayWhen.Flying and IsFlying() then
		M:Play()
		return
	end

	if db.PlayWhen.Mounted and IsMounted() then
		M:Play()
		return
	end

	if db.PlayWhen.Swimming and IsSwimming() then
		M:Play()
		return
	end

	if db.PlayWhen.Afk and UnitIsAFK("player") then
		M:Play()
		return
	end

	if db.PlayWhen.Ghost and UnitIsGhost("player") then
		M:Play()
		return
	end

	if db.PlayWhen.Dead and UnitIsDead("player") then
		M:Play()
		return
	end

	if db.PlayWhen.Fishing and utils:IsFishing() then
		M:Play()
		return
	end

	if db.PlayWhen.AuctionHouse and utils:IsAuctionHouseShown() then
		M:Play()
		return
	end

	M:Stop()
end

function M:Init()
	-- play sound in the background
	SetCVar("Sound_EnableSoundWhenGameIsInBG", 1)

	addon.Config:Init()

	db = RoosterLoopDB

	StartEvaluator()
	M:PlayOrStop()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")

frame:SetScript("OnEvent", function(_, event, arg1)
	if event == "ADDON_LOADED" and arg1 == addonName then
		M:Init()
	elseif event == "PLAYER_LOGOUT" then
		StopEvaluator()
		M:Stop()
	end
end)
