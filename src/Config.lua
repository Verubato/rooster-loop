local addonName, addon = ...
local utils = addon.Utils
local verticalSpacing = 20
local checkboxesPerLine = 4
local checkboxWidth = 150
local M = {}
addon.Config = M

local dbDefaults = {
	Version = 2,
	PlayWhen = {
		Always = false,
		Random = true,
		Walking = false,
		Resting = false,
		StandingStill = false,
		Swimming = false,
		Mounted = false,
		Flying = false,
		Afk = false,
		Ghost = false,
		Dead = false,
		Fishing = false,
		AuctionHouse = false,
	},
	DontPlayWhen = {
		InInstance = false,
		InCombat = true,
	},
}

local function GetAndUpgradeDb()
	RoosterLoopDB = RoosterLoopDB or {}
	local db = RoosterLoopDB

	if not db.Version or db.Version == 1 then
		-- reset back to defaults
		RoosterLoopDB = {}
		db = utils:CopyTable(dbDefaults, RoosterLoopDB)

		db.Version = 2
	else
		db = utils:CopyTable(dbDefaults, RoosterLoopDB)
	end

	return db
end

local function SettingsSize()
	local settingsContainer = SettingsPanel and SettingsPanel.Container

	if settingsContainer then
		return settingsContainer:GetWidth(), settingsContainer:GetHeight()
	end

	if InterfaceOptionsFramePanelContainer then
		return InterfaceOptionsFramePanelContainer:GetWidth(), InterfaceOptionsFramePanelContainer:GetHeight()
	end

	return 600, 600
end

local function CreateSettingCheckbox(panel, setting)
	local checkbox = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
	checkbox.Text:SetText(" " .. setting.Name)
	checkbox.Text:SetFontObject("GameFontNormal")
	checkbox:SetChecked(setting.Enabled())
	checkbox:HookScript("OnClick", function()
		setting.OnChanged(checkbox:GetChecked())
	end)

	checkbox:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(setting.Name, 1, 0.82, 0)
		GameTooltip:AddLine(setting.Tooltip, 1, 1, 1, true)
		GameTooltip:Show()
	end)

	checkbox:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	return checkbox
end

local function LayoutSettings(settings, panel, relativeTo, xOffset, yOffset)
	local x = xOffset
	local y = yOffset
	local lastCheckbox = nil

	for i, setting in ipairs(settings) do
		local checkbox = CreateSettingCheckbox(panel, setting)
		checkbox:SetPoint("TOPLEFT", relativeTo, "TOPLEFT", x, y)

		lastCheckbox = checkbox

		if i % checkboxesPerLine == 0 then
			y = y - (verticalSpacing * 2)
			x = xOffset
		else
			x = x + checkboxWidth
		end
	end

	return lastCheckbox
end

function CanOpenOptionsDuringCombat()
	if LE_EXPANSION_LEVEL_CURRENT == nil or LE_EXPANSION_MIDNIGHT == nil then
		return true
	end

	return LE_EXPANSION_LEVEL_CURRENT < LE_EXPANSION_MIDNIGHT
end

local function AddCategory(panel)
	if Settings then
		local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
		Settings.RegisterAddOnCategory(category)

		return category
	elseif InterfaceOptions_AddCategory then
		InterfaceOptions_AddCategory(panel)

		return panel
	end

	return nil
end

function M:Init()
	local db = GetAndUpgradeDb()

	local panel = CreateFrame("Frame")
	panel.name = addonName

	local category = AddCategory(panel)

	if not category then
		return
	end

	-- since we have 4 checkboxes per line
	-- divide into 6 blocks, so we have 1 block of space on either side
	local settingsWidth, _ = SettingsSize()
	local start = (settingsWidth / (checkboxesPerLine + 2)) - checkboxWidth / 2

	local version = C_AddOns.GetAddOnMetadata(addonName, "Version")
	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", start, -verticalSpacing)
	title:SetText(string.format("%s - %s", addonName, version))

	local description = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
	description:SetPoint("TOPLEFT", title, 0, -verticalSpacing)
	description:SetText("Dee de de da dee da do do")

	local settings = {
		{
			Name = "Always",
			Tooltip = "Play everywhere.",
			Enabled = function()
				return db.PlayWhen.Always
			end,
			OnChanged = function(enabled)
				db.PlayWhen.Always = enabled
			end,
		},
		{
			Name = "Random",
			Tooltip = "Play randomly.",
			Enabled = function()
				return db.PlayWhen.Random
			end,
			OnChanged = function(enabled)
				db.PlayWhen.Random = enabled
			end,
		},
		{
			Name = "Resting",
			Tooltip = "Play when resting.",
			Enabled = function()
				return db.PlayWhen.Resting
			end,
			OnChanged = function(enabled)
				db.PlayWhen.Resting = enabled
			end,
		},
		{
			Name = "Walking",
			Tooltip = "Play when RP walking.",
			Enabled = function()
				return db.PlayWhen.Walking
			end,
			OnChanged = function(enabled)
				db.PlayWhen.Walking = enabled
			end,
		},
		{
			Name = "Standing still",
			Tooltip = "Play when standing still.",
			Enabled = function()
				return db.PlayWhen.StandingStill
			end,
			OnChanged = function(enabled)
				db.PlayWhen.StandingStill = enabled
			end,
		},
		{
			Name = "Mounted",
			Tooltip = "Play when mounted.",
			Enabled = function()
				return db.PlayWhen.Mounted
			end,
			OnChanged = function(enabled)
				db.PlayWhen.Mounted = enabled
			end,
		},
		{
			Name = "Swimming",
			Tooltip = "Play when swimming.",
			Enabled = function()
				return db.PlayWhen.Swimming
			end,
			OnChanged = function(enabled)
				db.PlayWhen.Swimming = enabled
			end,
		},
		{
			Name = "Flying",
			Tooltip = "Play when flying.",
			Enabled = function()
				return db.PlayWhen.Flying
			end,
			OnChanged = function(enabled)
				db.PlayWhen.Flying = enabled
			end,
		},
		{
			Name = "AFK",
			Tooltip = "Play when afk.",
			Enabled = function()
				return db.PlayWhen.Afk
			end,
			OnChanged = function(enabled)
				db.PlayWhen.Afk = enabled
			end,
		},
		{
			Name = "Dead",
			Tooltip = "Play when in dead.",
			Enabled = function()
				return db.PlayWhen.Dead
			end,
			OnChanged = function(enabled)
				db.PlayWhen.Dead = enabled
			end,
		},
		{
			Name = "Ghost",
			Tooltip = "Play when in ghost form (while dead).",
			Enabled = function()
				return db.PlayWhen.Ghost
			end,
			OnChanged = function(enabled)
				db.PlayWhen.Ghost = enabled
			end,
		},
		{
			Name = "Fishing",
			Tooltip = "Play when in fishing.",
			Enabled = function()
				return db.PlayWhen.Fishing
			end,
			OnChanged = function(enabled)
				db.PlayWhen.Fishing = enabled
			end,
		},
		{
			Name = "Browsing the AH",
			Tooltip = "Play when browsing the auction house.",
			Enabled = function()
				return db.PlayWhen.AuctionHouse
			end,
			OnChanged = function(enabled)
				db.PlayWhen.AuctionHouse = enabled
			end,
		},
	}

	local filters = {
		{
			Name = "In Instance",
			Tooltip = "Allow playing when inside an instance.",
			Enabled = function()
				return db.DontPlayWhen.InInstance
			end,
			OnChanged = function(enabled)
				db.DontPlayWhen.InInstance = enabled
			end,
		},
		{
			Name = "In Combat",
			Tooltip = "Allow playing when in combat.",
			Enabled = function()
				return db.DontPlayWhen.InCombat
			end,
			OnChanged = function(enabled)
				db.DontPlayWhen.InCombat = enabled
			end,
		},
	}

	local playWhenHeading = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
	playWhenHeading:SetPoint("TOPLEFT", description, 0, -verticalSpacing * 2)
	playWhenHeading:SetText("Play when:")

	local anchor = LayoutSettings(settings, panel, playWhenHeading, 0, -verticalSpacing)

	local dontPlayWhenHeading = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
	dontPlayWhenHeading:SetPoint("TOPLEFT", anchor, 0, -verticalSpacing * 3)
	dontPlayWhenHeading:SetText("Don't play when:")

	LayoutSettings(filters, panel, dontPlayWhenHeading, 0, -verticalSpacing)

	SLASH_ROOSTER1 = "/rooster"
	SLASH_ROOSTER2 = "/roosterloop"

	SlashCmdList.ROOSTER = function()
		if Settings then
			if not InCombatLockdown() or CanOpenOptionsDuringCombat() then
				Settings.OpenToCategory(category:GetID())
			end
		elseif InterfaceOptionsFrame_OpenToCategory then
			-- workaround the classic bug where the first call opens the Game interface
			-- and a second call is required
			InterfaceOptionsFrame_OpenToCategory(panel)
			InterfaceOptionsFrame_OpenToCategory(panel)
		end
	end
end
