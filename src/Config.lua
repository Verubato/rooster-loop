local addonName, addon = ...
---@type MiniFramework
local mini = addon.Framework
local DB_VERSION = 2
local CHECKBOX_COLUMNS = 4
---@class Db
local dbDefaults = {
	Version = DB_VERSION,
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
---@type PlayCondition[]
local PLAY_WHEN = {
	{ Key = "Always", Label = "Always", Tooltip = "Play everywhere." },
	{ Key = "Random", Label = "Random", Tooltip = "Play randomly." },
	{ Key = "Resting", Label = "Resting", Tooltip = "Play when resting." },
	{ Key = "Walking", Label = "Walking", Tooltip = "Play when RP walking." },
	{ Key = "StandingStill", Label = "Standing still", Tooltip = "Play when standing still." },
	{ Key = "Mounted", Label = "Mounted", Tooltip = "Play when mounted." },
	{ Key = "Swimming", Label = "Swimming", Tooltip = "Play when swimming." },
	{ Key = "Flying", Label = "Flying", Tooltip = "Play when flying." },
	{ Key = "Afk", Label = "AFK", Tooltip = "Play when afk." },
	{ Key = "Dead", Label = "Dead", Tooltip = "Play when in dead." },
	{ Key = "Ghost", Label = "Ghost", Tooltip = "Play when in ghost form (while dead)." },
	{ Key = "Fishing", Label = "Fishing", Tooltip = "Play when in fishing." },
	{ Key = "AuctionHouse", Label = "Browsing the AH", Tooltip = "Play when browsing the auction house." },
}
---@type PlayCondition[]
local DONT_PLAY_WHEN = {
	{ Key = "InInstance", Label = "In Instance", Tooltip = "Allow playing when inside an instance." },
	{ Key = "InCombat", Label = "In Combat", Tooltip = "Allow playing when in combat." },
}
---@class Config
local M = {}
addon.Config = M

local function GetAndUpgradeDb()
	local existing = RoosterLoopDB
	local version = existing and existing.Version
	local db = mini:GetSavedVars(dbDefaults)

	-- An older shape is thrown away rather than migrated.
	if existing and version ~= DB_VERSION then
		db = mini:ResetSavedVars(dbDefaults)
	end

	return db
end

---Lays checkboxes out left to right, wrapping onto a new row every CHECKBOX_COLUMNS.
---@param parent table
---@param anchor table region the top row hangs below
---@param conditions PlayCondition[]
---@param store table the saved-variable subtable each checkbox reads and writes
---@return table rowStart the leftmost checkbox of the bottom row, to anchor whatever follows
local function BuildCheckboxGrid(parent, anchor, conditions, store)
	local columnWidth = mini:ColumnWidth(CHECKBOX_COLUMNS, 0, 0)
	local rowStart

	for index, condition in ipairs(conditions) do
		local key = condition.Key
		local checkbox = mini:Checkbox({
			Parent = parent,
			LabelText = condition.Label,
			Tooltip = condition.Tooltip,
			GetValue = function()
				return store[key]
			end,
			SetValue = function(value)
				store[key] = value
			end,
		})

		local column = (index - 1) % CHECKBOX_COLUMNS

		if column == 0 then
			checkbox:SetPoint("TOPLEFT", rowStart or anchor, "BOTTOMLEFT", 0, -mini.VerticalSpacing)
			rowStart = checkbox
		else
			-- One LEFT point, so every checkbox on the row shares the row's centre line.
			checkbox:SetPoint("LEFT", rowStart, "LEFT", columnWidth * column, 0)
		end
	end

	return rowStart
end

function M:Init()
	-- A styled button clashes with the stock Blizzard art around it in the settings screen.
	mini:SetCustomStyling(true, { Button = false })

	local db = GetAndUpgradeDb()

	local panel = CreateFrame("Frame")
	panel.name = addonName

	local category = mini:AddCategory(panel)

	if not category then
		return
	end

	local header = mini:PanelHeader({
		Parent = panel,
		Description = "Dee de de da dee da do do",
		Gap = 6,
		Divider = "Play when",
		Reset = {
			OnAccept = function()
				mini:ResetSavedVars(dbDefaults)
			end,
		},
	})

	mini:RegisterSlashCommand(category, panel, {
		"/rooster",
		"/roosterloop",
	})

	local lastPlayWhenRow = BuildCheckboxGrid(panel, header.Anchor, PLAY_WHEN, db.PlayWhen)

	local dontPlayWhen = mini:Divider({ Parent = panel, Text = "Don't play when" })
	dontPlayWhen:SetPoint("TOPLEFT", lastPlayWhenRow, "BOTTOMLEFT", 0, -mini.VerticalSpacing)
	dontPlayWhen:SetPoint("RIGHT", panel, "RIGHT", 0, 0)

	BuildCheckboxGrid(panel, dontPlayWhen, DONT_PLAY_WHEN, db.DontPlayWhen)
end

---@class PlayCondition
---@field Key string the field it reads and writes inside its saved-variable subtable
---@field Label string
---@field Tooltip string
