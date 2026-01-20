# Minimalist Game Room

> The game doesn't give you objectives.
> It just watches you choose to stay.

A deeply psychological Roblox experience that explores boredom, choice, and the nature of gaming itself.

---

## 🧠 Core Concept

An empty room with grey walls, neutral light, and complete silence. No objectives, no rewards, no gameplay mechanics. Just you, the room, and the question: **Why are you still here?**

---

## 📁 Project Structure

```
/src
├── MainGameScript.lua          # Core timer, DataStore, session management
├── UIClientScript.lua          # Message timeline, UI effects
├── LeaderboardScript.lua       # "People Who Stayed" leaderboard
├── MonetizationScript.lua      # Dev products and gamepass handlers
└── MonetizationUIClient.lua    # Purchase UI effects
```

---

## 🛠️ Installation Guide

### 1. Game Setup
Create a minimal Roblox game with:
- **Empty room** (grey walls, neutral lighting)
- **No decorations**
- **No background music**
- Optional: Clock with no numbers, door that doesn't open

### 2. Script Placement

#### ServerScriptService
- `MainGameScript.lua`
- `MonetizationScript.lua`

#### StarterPlayer > StarterPlayerScripts
- `UIClientScript.lua`
- `MonetizationUIClient.lua`

#### Workspace > Part (for leaderboard)
- Create a `Part` in the workspace
- Insert `LeaderboardScript.lua` into the Part
- The script will auto-create a SurfaceGui

### 3. Enable DataStore
- Go to **Game Settings** > **Security**
- Enable **Studio Access to API Services**

### 4. Configure Products (Required)

#### Gamepass
- **Silence** - 49 Robux
  - ID: `1676198849`
  - Description: "For people who don't want to be reminded."

#### Dev Products

| Product | Price | ID |
|---------|-------|-----|
| Support Logging (R$5) | 5 Robux | `3518100664` |
| Support Logging (R$10) | 10 Robux | `3518100760` |
| Support Logging (R$25) | 25 Robux | `3518100838` |
| Support Logging (R$50) | 50 Robux | `3518100909` |
| Acknowledged | 29 Robux | `3518101639` |
| View Partial Log | 59 Robux | `3518101838` |
| System Load | 25 Robux | `3518102101` |
| Why | 9 Robux | `3518102356` |

> **Note:** Create these products in Roblox Creator Dashboard with the exact IDs above, or update the IDs in `MonetizationScript.lua`.

---

## ⏱️ Message Timeline

The game observes how long you stay and responds:

| Time | Message |
|------|---------|
| **Start** | "You're still here." (persistent, bottom) |
| **30s** | "Most people would have left by now." |
| **2min** | "Nothing is happening because you're waiting." |
| **5min** | "You didn't miss anything." |
| **10min** | "Staying won't make this better." |
| **15min** | "You can leave whenever you want." + Leave button |
| **20min** | "Why didn't you?" |
| **30min** | "We know how long you stayed." (screen almost empty) |

---

## 🔁 Return Visit Detection

When a player returns:

1. **Immediate**: "You came back."
2. **After 10s**: "Last time you stayed X minutes."
3. **After 30s**: "You didn't have to."

---

## 👥 Fake Multiplayer

Creates the illusion of other players without showing them:

- Random disconnect messages: "Player left.", "Another player disconnected."
- Appears every 45-200 seconds
- Server seems to empty over time
- **No actual multiplayer functionality**

---

## 🏆 Leaderboard

**"People Who Stayed"**

- Shows username and total time wasted
- No rewards, no prizes
- Just exposure
- Updates every 60 seconds

---

## 💰 Monetization (Ethical but Disturbing)

### Gamepass: Silence (49 Robux)
- Removes all timed messages
- Only silence remains
- "For people who don't want to be reminded."

### Dev Products

#### 1. Support Logging (5/10/25/50 Robux)
- **Effect:** None
- **Description:** "This action has no effect on your session."
- **What happens:** Global message appears: "A contribution was recorded." (no name)
- **Psychology:** People donate to see if anything happens

#### 2. Acknowledged (29 Robux)
- **Effect:** One-time message: "Input acknowledged."
- **Limitation:** Only works once per session
- **Tone:** Cold, distant

#### 3. View Partial Log (59 Robux)
- **Shows:** Session count, total time, last visit
- **Catch:** Always displays: "Some entries are unavailable."
- **Psychology:** Incomplete transparency

#### 4. System Load (25 Robux)
- **Effect:** Global message: "System load increased."
- **No gameplay impact**
- **Creates collective tension**

#### 5. Why (9 Robux)
- **Effect:** Absolutely nothing
- **No log, no UI, no feedback**
- **The most meta purchase**

---

## 🔧 Customization

### Changing Message Timing
Edit `MainGameScript.lua` line ~120:
```lua
local messages = {
    {time = 30, text = "Your message here"},
    -- Add more messages...
}
```

### Changing Product IDs
Edit `MonetizationScript.lua` line ~15:
```lua
local PRODUCTS = {
    DONATION_5 = YOUR_PRODUCT_ID,
    -- etc...
}
```

### Leaderboard Customization
Edit `LeaderboardScript.lua` to change:
- Title text (line ~40)
- Number of entries shown (line ~135)
- Update frequency (line ~220)

---

## 🚀 Why This Works on Roblox

✅ **Discover-Friendly**
- Keywords: "AFK", "Stand Here", "Psychological"
- High engagement time metrics

✅ **TOS-Compliant**
- No violence
- No inappropriate content
- Ethical monetization (purchases are clearly labeled)

✅ **Viral Potential**
- Players comment: "bro this game is weird"
- Creates clips and discussion
- Not "good" or "bad" – just **memorable**

✅ **Psychological Hook**
- People stay to "see what happens"
- Then stay because they've **already stayed**
- Sunk cost fallacy as gameplay

---

## 📊 Expected Player Behavior

1. **0-30s:** Confusion ("Is this it?")
2. **30s-2min:** Curiosity ("Maybe something happens...")
3. **2-5min:** Commitment ("I've come this far...")
4. **5-15min:** Realization ("Nothing is happening.")
5. **15min+:** Defiance or submission ("I'm staying anyway.")

---

## 🧪 Testing Checklist

- [ ] DataStore saving/loading works
- [ ] Messages appear at correct times
- [ ] Return visit detection shows previous session time
- [ ] Fake disconnect messages appear
- [ ] Leaderboard updates correctly
- [ ] Silence gamepass removes messages
- [ ] All dev products process correctly
- [ ] Global messages broadcast to all players
- [ ] Acknowledgement only works once per session

---

## 🎯 Design Philosophy

> **Less is more.**
> **Boredom is gameplay.**
> **The choice to stay is the mechanic.**

This game is not about fun. It's about **presence**, **choice**, and **observation**.

---

## 📝 Notes

- All text is in English
- Messages use slow fade-in effects (2-3 seconds)
- UI is minimal and monochrome
- No jump scares, no twists
- The game respects the player's choice to leave at any time

---

## 🧠 Concept Credit

Inspired by:
- *The Stanley Parable* (choice as commentary)
- *Getting Over It* (frustration as design)
- *Universal Paperclips* (commitment loops)
- Minimalist art installations

---

## ⚖️ License

This is an experimental art project. Use responsibly and ethically.

---

**"You're still reading."**
