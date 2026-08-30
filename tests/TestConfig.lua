-- Drives the settings panel the way a player does: find a control by the label it shows,
-- click it, and read the saved variable back.

local fw = require("TestFramework")
local harness = require("AddonHarness")
local WowMock = require("WowMock")

local COLUMNS = 4
local SLASH_SLOTS = 4

local PLAY_WHEN_LABELS = {
	"Always",
	"Random",
	"Resting",
	"Walking",
	"Standing still",
	"Mounted",
	"Swimming",
	"Flying",
	"AFK",
	"Dead",
	"Ghost",
	"Fishing",
	"Browsing the AH",
}

local DONT_PLAY_WHEN_LABELS = {
	"In Instance",
	"In Combat",
}

-- Which saved-variable field each label writes, so a test can assert the click landed on
-- the setting the label promised.
local KEYS = {
	["Always"] = { "PlayWhen", "Always" },
	["Random"] = { "PlayWhen", "Random" },
	["Resting"] = { "PlayWhen", "Resting" },
	["Walking"] = { "PlayWhen", "Walking" },
	["Standing still"] = { "PlayWhen", "StandingStill" },
	["Mounted"] = { "PlayWhen", "Mounted" },
	["Swimming"] = { "PlayWhen", "Swimming" },
	["Flying"] = { "PlayWhen", "Flying" },
	["AFK"] = { "PlayWhen", "Afk" },
	["Dead"] = { "PlayWhen", "Dead" },
	["Ghost"] = { "PlayWhen", "Ghost" },
	["Fishing"] = { "PlayWhen", "Fishing" },
	["Browsing the AH"] = { "PlayWhen", "AuctionHouse" },
	["In Instance"] = { "DontPlayWhen", "InInstance" },
	["In Combat"] = { "DontPlayWhen", "InCombat" },
}

-- Mirrors dbDefaults in src/Config.lua, written out again so this pins the actual defaults
-- rather than comparing a saved value against itself.
local DEFAULTS = {
	["Always"] = false,
	["Random"] = true,
	["Resting"] = false,
	["Walking"] = false,
	["Standing still"] = false,
	["Mounted"] = false,
	["Swimming"] = false,
	["Flying"] = false,
	["AFK"] = false,
	["Dead"] = false,
	["Ghost"] = false,
	["Fishing"] = false,
	["Browsing the AH"] = false,
	["In Instance"] = false,
	["In Combat"] = true,
}

---Every styled toggle the panel built, in the order Config.lua created them.
---@return table[]
local function Toggles()
	local found = {}

	for _, frame in ipairs(WowMock.Frames) do
		if frame.Knob and frame.Text then
			found[#found + 1] = frame
		end
	end

	return found
end

---@return table? toggle carrying the given label
local function ToggleFor(label)
	for _, toggle in ipairs(Toggles()) do
		if toggle.Text:GetText() == label then
			return toggle
		end
	end
end

---A section rule shows its label in capitals, which is how a player picks it out.
---@return table? divider
local function DividerFor(text)
	for _, frame in ipairs(WowMock.Frames) do
		if frame.Label and frame.Label.GetText and frame.Label:GetText() == text:upper() then
			return frame
		end
	end
end

---The reset button is a frame the framework owns, so a test reaches it by its label.
---@return table? button
local function FindButton(label)
	for _, frame in ipairs(WowMock.Frames) do
		if frame.GetText and frame:GetText() == label and frame.Click then
			return frame
		end
	end
end

---The client does nothing with a prompt in the mock, so a test stands in for it.
---@param open fun()
local function AcceptConfirm(open)
	local seen
	local real = StaticPopup_Show

	StaticPopup_Show = function(which, _, _, data)
		seen = { Which = which, Data = data }
	end

	local ok, err = pcall(open)

	StaticPopup_Show = real

	if not ok then
		error(err, 0)
	end

	if not seen then
		error("no confirmation was opened")
	end

	StaticPopupDialogs[seen.Which].OnAccept(nil, seen.Data)
end

fw.describe("RoosterLoop - settings panel", function()
	local mini

	fw.before_each(function()
		-- Saved variables survive an install, so each case builds its panel from the defaults.
		_G.RoosterLoopDB = nil

		local context = harness.Run("RoosterLoop")
		mini = context.Addon.Framework
	end)

	fw.it("turns the accented styling on and holds buttons back to the stock art", function()
		fw.eq(mini.CustomStyling, true, "custom styling on")
		fw.eq(mini.CustomStylingOverrides.Button, false, "stock buttons")
	end)

	fw.it("separates the two groups of settings with a section rule each", function()
		fw.not_nil(DividerFor("Play when"), "the header's own section rule")
		fw.not_nil(DividerFor("Don't play when"), "the rule above the two filters")
	end)

	fw.it("builds one checkbox per saved setting and no more", function()
		for _, label in ipairs(PLAY_WHEN_LABELS) do
			fw.not_nil(ToggleFor(label), "a checkbox labelled " .. label)
		end

		for _, label in ipairs(DONT_PLAY_WHEN_LABELS) do
			fw.not_nil(ToggleFor(label), "a checkbox labelled " .. label)
		end

		fw.eq(#Toggles(), #PLAY_WHEN_LABELS + #DONT_PLAY_WHEN_LABELS, "no setting was added or dropped")
	end)

	fw.it("starts every checkbox and saved variable at its documented default", function()
		for label, path in pairs(KEYS) do
			local default = DEFAULTS[label]

			fw.eq(RoosterLoopDB[path[1]][path[2]], default, label .. " defaults in the saved variable")
			fw.eq(ToggleFor(label):GetChecked(), default, label .. " defaults on the checkbox")
		end
	end)

	fw.it("writes the setting its own label names, and nothing else", function()
		for label, path in pairs(KEYS) do
			local group, key = path[1], path[2]
			local before = RoosterLoopDB[group][key]

			ToggleFor(label):Click()

			fw.eq(RoosterLoopDB[group][key], not before, label .. " flipped " .. group .. "." .. key)

			ToggleFor(label):Click()

			fw.eq(RoosterLoopDB[group][key], before, label .. " flipped back")
		end
	end)

	fw.it("re-reads the saved variables when the panel is refreshed", function()
		local always = ToggleFor("Always")

		RoosterLoopDB.PlayWhen.Always = true
		always:GetParent():MiniRefresh()

		fw.eq(always:GetChecked(), true, "the control followed the saved variable it did not write itself")
	end)

	fw.it("resets every setting to its default once the player confirms", function()
		-- Flip one setting each way, so a reset that did nothing or reset in the wrong
		-- direction would still show up.
		ToggleFor("Always"):Click()
		ToggleFor("Random"):Click()
		fw.eq(RoosterLoopDB.PlayWhen.Always, true, "Always is dirty before the reset")
		fw.eq(RoosterLoopDB.PlayWhen.Random, false, "Random is dirty before the reset")

		AcceptConfirm(function()
			FindButton("Reset to Defaults"):Click()
		end)

		fw.eq(RoosterLoopDB.PlayWhen.Always, false, "Always came back to its default")
		fw.eq(RoosterLoopDB.PlayWhen.Random, true, "Random came back to its default")
		fw.eq(ToggleFor("Random"):GetChecked(), true, "the checkbox followed the reset saved variable")
	end)

	fw.it("wraps the play-when checkboxes onto rows of four", function()
		local columnWidth = mini:ColumnWidth(COLUMNS, 0, 0)
		local toggles = Toggles()

		for index = 1, #PLAY_WHEN_LABELS do
			local toggle = toggles[index]
			local point, relativeTo, relativePoint, x, y = toggle:GetPoint(1)

			fw.eq(toggle:GetNumPoints(), 1, PLAY_WHEN_LABELS[index] .. " is pinned by exactly one point")

			if (index - 1) % COLUMNS == 0 then
				fw.eq(point, "TOPLEFT", PLAY_WHEN_LABELS[index] .. " starts a row")
				fw.eq(relativePoint, "BOTTOMLEFT", PLAY_WHEN_LABELS[index] .. " hangs below the row above")
				fw.eq(x, 0, PLAY_WHEN_LABELS[index] .. " sits at the panel's left edge")
				fw.eq(y, -mini.VerticalSpacing, PLAY_WHEN_LABELS[index] .. " drops one row gap")
			else
				fw.eq(point, "LEFT", PLAY_WHEN_LABELS[index] .. " shares its row's centre line")
				fw.eq(relativeTo, toggles[index - (index - 1) % COLUMNS], PLAY_WHEN_LABELS[index] .. " hangs off its row start")
				fw.eq(x, columnWidth * ((index - 1) % COLUMNS), PLAY_WHEN_LABELS[index] .. " sits in its own column")
				fw.eq(y, 0, PLAY_WHEN_LABELS[index] .. " stays on the row")
			end
		end
	end)

	fw.it("claims both slash commands the addon shipped with", function()
		local claimed = {}

		for index = 1, SLASH_SLOTS do
			local command = _G["SLASH_ROOSTERLOOP" .. index]

			if command then
				claimed[command] = true
			end
		end

		fw.truthy(claimed["/rooster"], "the short alias")
		fw.truthy(claimed["/roosterloop"], "the full name")
		fw.not_nil(SlashCmdList.ROOSTERLOOP, "a handler is registered for the claimed slots")
	end)
end)

fw.describe("RoosterLoop - saved variable migration", function()
	fw.it("throws an older database version away and rebuilds it from defaults", function()
		_G.RoosterLoopDB = { Version = 1, PlayWhen = { Always = true } }

		harness.Run("RoosterLoop")

		fw.eq(RoosterLoopDB.PlayWhen.Always, false, "the stale value did not survive the upgrade")
		fw.eq(RoosterLoopDB.Version, 2, "the database now carries the current version")
	end)

	fw.it("leaves a database already on the current version untouched", function()
		_G.RoosterLoopDB = { Version = 2, PlayWhen = { Always = true } }

		harness.Run("RoosterLoop")

		fw.eq(RoosterLoopDB.PlayWhen.Always, true, "a matching version does not trigger the reset")
	end)
end)
