local soundPath = "Interface\\AddOns\\RoosterLoop\\WhistleStop.mp3"
local channel = "Master"
local soundLengthSeconds = 89
local enabled = false
local ticker
local soundHandle

local function Notify(msg)
	print(string.format("RoosterLoop - %s", msg))
end

local function StopLoop()
	enabled = false

	if ticker then
		ticker:Cancel()
		ticker = nil
	end

	if not soundHandle then
		return
	end

	StopSound(soundHandle)
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
	else
		Notify("Failed to play song.")
		soundHandle = nil
	end

	ticker = C_Timer.NewTicker(soundLengthSeconds, function()
		if not enabled then
			return
		end

		ok, handle = PlaySoundFile(soundPath, channel)

		if ok then
			soundHandle = handle
		else
			Notify("Failed to play song.")
			soundHandle = nil
		end
	end)
end

SLASH_ROOSTER1 = "/rooster"

SlashCmdList.ROOSTER = function()
	if enabled then
		StopLoop()
		Notify("Rooster loop stopping.")
	else
		StartLoop()
		Notify("Rooster loop starting.")
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_LOGOUT")

frame:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_LOGIN" then
		-- keep playing in the background
		SetCVar("Sound_EnableSoundWhenGameIsInBG", 1)
		StartLoop()
		Notify("/rooster to toggle the music, but honestly why would you want to stop it?")
	elseif event == "PLAYER_LOGOUT" then
		StopLoop()
	end
end)

SlashCmdList.WHISTLE = function()
	if enabled then
		StopLoop()
		Notify("Whistle loop stopping.")
	else
		StartLoop()
		Notify("Whistle loop starting.")
	end
end
