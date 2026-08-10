# RoosterLoop - support reference

## What it is

RoosterLoop plays the Robin Hood rooster whistle song ("Whistle Stop") on a loop while conditions you pick are true: always, randomly, while resting, walking, standing still, mounted, swimming, flying, AFK, dead, a ghost, fishing, or browsing the auction house. It is a joke/novelty addon with a single options page of checkboxes.

## Facts

| Item | Value |
|---|---|
| Addon version | 1.2.3 |
| Author | Verz |
| Interface versions (TOC) | 120100, 120007, 120001, 120000, 110207, 50504, 40402, 38002, 38000, 30405, 30300, 20506, 11509 (Retail and Classic clients) |
| Saved variables | RoosterLoopDB (account-wide) |
| Slash commands | /rooster, /roosterloop (both open the options panel) |
| Options location | Game Menu -> Options -> AddOns -> RoosterLoop |
| Sound file | WhistleStop.mp3, 89 seconds, played on the Master sound channel |
| CurseForge project | roosterloop (ID 1418786) |

## How it works

- Conditions are checked every 0.5 seconds. When an enabled condition is true, the song starts; when no enabled condition is true, it stops immediately.
- The song restarts itself every 89 seconds while conditions still hold, so it loops seamlessly.
- On login the addon sets the game CVar Sound_EnableSoundWhenGameIsInBG to 1, so sound (including the song) keeps playing while the game window is in the background.
- The song stops on logout.

Evaluation order each tick: the "Don't play when" filters are checked first and force a stop. Then: Always -> Random -> Resting -> Walking -> Standing still -> Flying -> Mounted -> Swimming -> AFK -> Ghost -> Dead -> Fishing -> Browsing the AH. If none apply, stop.

### Condition details

- Walking: you are moving slower than normal run speed (below 6.5 yards/sec, i.e. RP walk), and not in combat.
- Standing still: your speed is exactly 0 and you are not flying.
- Fishing: you are channeling the Fishing spell.
- Browsing the AH: the auction house window is open (works with both the retail and classic auction frames).
- On 12.0+ clients the player's speed can be a protected "secret" value in some situations; when it is unreadable, Walking and Standing still both count as false rather than erroring.

### Random mode

Random watches this set of conditions: Walking, Standing still, Flying, Mounted, Swimming, AFK, Ghost, Dead, Fishing, Browsing the AH (Resting is deliberately excluded). Whenever any of those change state, there is a 10% chance it picks one of the currently-true conditions and starts the song. It then keeps playing until that picked condition stops being true. The 10% chance is fixed in code; there is no setting for it.

## Settings

All settings are checkboxes on one panel. Changes take effect within half a second (the next evaluation tick). There is no volume or sound setting; volume follows your Master channel.

### Play when:

| Checkbox | Default | Tooltip |
|---|---|---|
| Always | Off | Play everywhere. |
| Random | On | Play randomly. |
| Resting | Off | Play when resting. |
| Walking | Off | Play when RP walking. |
| Standing still | Off | Play when standing still. |
| Mounted | Off | Play when mounted. |
| Swimming | Off | Play when swimming. |
| Flying | Off | Play when flying. |
| AFK | Off | Play when afk. |
| Dead | Off | Play when in dead. |
| Ghost | Off | Play when in ghost form (while dead). |
| Fishing | Off | Play when in fishing. |
| Browsing the AH | Off | Play when browsing the auction house. |

### Don't play when:

| Checkbox | Default | Actual effect when checked |
|---|---|---|
| In Instance | Off | The song is stopped/suppressed while inside any instance |
| In Combat | On | The song is stopped/suppressed while in combat |

Note: the in-game tooltips for these two say "Allow playing when...", which is backwards. The section heading is correct: checking the box means the song does NOT play in that situation.

## Version-gated behavior

- Supports Retail and Classic clients (see interface list above). The AH detection checks both the retail AuctionHouseFrame and the classic AuctionFrame.
- The secret-speed guard only matters on 12.0+ retail; older clients always read speed normally.
- If the settings UI cannot be opened during combat (Midnight-era clients), the slash command does nothing until combat ends.

## Troubleshooting

- "It never plays": the only condition on by default is Random, which fires on a 10% roll when your state changes, so long silences are normal. Tick "Always" to verify sound works, or tick specific conditions.
- "It stops when I fight": "In Combat" under "Don't play when:" is on by default. Untick it to allow playing in combat.
- "It won't play in dungeons/raids": check whether "In Instance" under "Don't play when:" is ticked.
- "No sound at all": the song plays on the Master channel; check the game's Master volume and that sound is enabled. If the file itself fails to play, the addon prints "RoosterLoop - Failed to play song." in chat.
- "Walking doesn't trigger it": Walking means RP-walk speed (slower than normal running) while out of combat. Normal running is too fast, and combat always counts as not walking.
- "It keeps playing when I alt-tab": intended; the addon turns on background sound (Sound_EnableSoundWhenGameIsInBG=1) at login. That CVar change persists even if you disable the addon; turn it back off in the game sound options if unwanted.
- "Random plays at odd moments / won't stop": once Random triggers, it plays until the condition it picked (e.g. mounted, swimming) ends. That is by design.
- "My settings reset": settings from addon versions before 1.1.0 (database version 1) are reset to defaults once on upgrade.
