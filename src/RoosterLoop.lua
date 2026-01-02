local addonName, addon = ...
local utils = addon.Utils
local soundPath = "Interface\\AddOns\\RoosterLoop\\WhistleStop.mp3"
local channel = "Master"
local soundLengthSeconds = 89
local ticker
local evalTicker
local isPlaying = false
local enabled = false
local soundHandle = nil
local M = {}
addon.Rooster = M

local function Notify(msg)
	print(string.format("RoosterLoop - %s", msg))
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

function M:Play()
	if isPlaying then
		return
	end

	StartLoop()
end

function M:PlayOrStop()
	local db = RoosterLoopDB

	if not db or not db.PlayWhen then
		return
	end

	local inInstance = IsInInstance()

	if db.PlayWhen.Always then
		M:Play()
		return
	end

	if db.PlayWhen.Resting and IsResting() then
		M:Play()
		return
	end

	if db.PlayWhen.InInstance and inInstance then
		M:Play()
		return
	end

	if db.PlayWhen.NotInInstance and not inInstance then
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
