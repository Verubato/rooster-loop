local addonName, addon = ...
local utils = addon.Utils
local verticalSpacing = 10
local M = {}
addon.Config = M

local dbDefaults = {
	PlayWhen = {
		Always = false,
		Walking = true,
		Resting = false,
		InInstance = false,
		NotInInstance = false,
		StandingStill = false,
		Swimming = true,
		Mounted = true,
		Flying = true,
		Afk = true,
		Ghost = true,
		Dead = true,
		Fishing = true,
		AuctionHouse = true,
	},
}

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
	RoosterLoopDB = RoosterLoopDB or {}
	local db = utils:CopyTable(dbDefaults, RoosterLoopDB)

	local panel = CreateFrame("Frame")
	panel.name = addonName

	local category = AddCategory(panel)

	if not category then
		return
	end

	local version = C_AddOns.GetAddOnMetadata(addonName, "Version")
	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOP", 0, -verticalSpacing)
	title:SetText(string.format("%s - %s", addonName, version))

	local description = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
	description:SetPoint("TOP", title, 0, -20)
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
			Name = "In Instance",
			Tooltip = "Play when inside an instance.",
			Enabled = function()
				return db.PlayWhen.InInstance
			end,
			OnChanged = function(enabled)
				db.PlayWhen.InInstance = enabled
			end,
		},
		{
			Name = "Not in instance",
			Tooltip = "Play when not inside an instance.",
			Enabled = function()
				return db.PlayWhen.NotInInstance
			end,
			OnChanged = function(enabled)
				db.PlayWhen.NotInInstance = enabled
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

	local checkboxesPerLine = 4
	local settingsWidth, _ = SettingsSize()
	local checkboxWidth = 150
	-- since we have 4 checkboxes per line
	-- divide into 6 blocks, so we have 1 block of space on either side
	local start = (settingsWidth / (checkboxesPerLine + 2)) - checkboxWidth / 2
	local yOffset = verticalSpacing * 7
	local xOffset = start

	for i, setting in ipairs(settings) do
		local checkbox = CreateSettingCheckbox(panel, setting)
		checkbox:SetPoint("TOPLEFT", panel, "TOPLEFT", xOffset, -yOffset)

		if i % checkboxesPerLine == 0 then
			yOffset = yOffset + (verticalSpacing * 3)
			xOffset = start
		else
			xOffset = xOffset + checkboxWidth
		end
	end

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
