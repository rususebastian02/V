# Quick Setup Guide

## Step-by-Step Installation

### 1. Prepare Your Roblox Game

1. Open Roblox Studio
2. Create a new place or open existing one
3. Build the minimalist room:
   - Grey walls (Color: 128, 128, 128)
   - Neutral lighting (no colored lights)
   - Remove all ambient sounds
   - Optional: Add a clock with no numbers, a door that doesn't open

### 2. Enable DataStore

1. Go to **Home** tab
2. Click **Game Settings**
3. Navigate to **Security** tab
4. Enable **Enable Studio Access to API Services**
5. Click **Save**

### 3. Insert Scripts

#### ServerScriptService
1. Right-click **ServerScriptService** in Explorer
2. Insert **Script** (not LocalScript!)
3. Name it `MainGameScript`
4. Copy contents from `/src/MainGameScript.lua`
5. Repeat for `MonetizationScript`

#### StarterPlayer > StarterPlayerScripts
1. Navigate to **StarterPlayer** > **StarterPlayerScripts**
2. Insert **LocalScript**
3. Name it `UIClientScript`
4. Copy contents from `/src/UIClientScript.lua`
5. Repeat for `MonetizationUIClient`

#### Workspace (Leaderboard)
1. Insert a **Part** in Workspace
2. Position it where you want the leaderboard
3. Insert **Script** inside the Part
4. Name it `LeaderboardScript`
5. Copy contents from `/src/LeaderboardScript.lua`

### 4. Create Roblox Products

#### Create Gamepass
1. Go to Roblox Creator Dashboard
2. Navigate to your game
3. Click **Monetization** > **Passes**
4. Create new pass:
   - Name: `Silence`
   - Price: 49 Robux
   - Description: "For people who don't want to be reminded."
5. **Important:** Note the Gamepass ID
6. Update line 15 in `MainGameScript.lua` with your Gamepass ID:
   ```lua
   return game:GetService("MarketplaceService"):UserOwnsGamePassAsync(player.UserId, YOUR_GAMEPASS_ID)
   ```

#### Create Dev Products
1. In Creator Dashboard, go to **Monetization** > **Developer Products**
2. Create these products:

| Product Name | Price | Description |
|--------------|-------|-------------|
| Support Logging (R$5) | 5 Robux | "This action has no effect on your session." |
| Support Logging (R$10) | 10 Robux | "This action has no effect on your session." |
| Support Logging (R$25) | 25 Robux | "This action has no effect on your session." |
| Support Logging (R$50) | 50 Robux | "This action has no effect on your session." |
| Acknowledged | 29 Robux | "One-time acknowledgement. No other effects." |
| View Partial Log | 59 Robux | "View your session log. Some entries unavailable." |
| System Load | 25 Robux | "Increases system load. No visible effects." |
| Why | 9 Robux | "Why?" |

3. **Important:** Note each Product ID
4. Update `MonetizationScript.lua` (lines 15-28) with your Product IDs:
   ```lua
   local PRODUCTS = {
       DONATION_5 = YOUR_PRODUCT_ID_HERE,
       DONATION_10 = YOUR_PRODUCT_ID_HERE,
       -- etc...
   }
   ```

### 5. Test in Studio

1. Click **Play** (F5) in Roblox Studio
2. Check console for these messages:
   - `Minimalist Game Room - Main Script Loaded`
   - `Minimalist Game Room - Monetization Script Loaded`
   - `Minimalist Game Room - UI Client Script Loaded`
   - `Minimalist Game Room - Monetization UI Client Loaded`
3. Wait 30 seconds to see first message appear
4. Check leaderboard updates after 5 seconds

### 6. Test DataStore (Important!)

Since DataStore doesn't work in Studio **Play Solo**:

1. Click **File** > **Publish to Roblox**
2. Publish your game
3. In Creator Dashboard, enable:
   - **Make game public** (or unlisted for testing)
4. Launch game from Roblox website
5. Stay for 1-2 minutes
6. Leave and rejoin
7. You should see: "You came back." and "Last time you stayed X minutes."

### 7. Create Shop UI (Optional)

To let players purchase products in-game:

1. Create a ScreenGui in **StarterGui**
2. Add buttons for each product:
   ```lua
   script.Parent.MouseButton1Click:Connect(function()
       game:GetService("MarketplaceService"):PromptProductPurchase(
           game.Players.LocalPlayer,
           PRODUCT_ID_HERE
       )
   end)
   ```
3. Or use proximity prompts on parts in the room

### 8. Final Checklist

- [ ] All scripts are in correct locations
- [ ] DataStore is enabled in Game Settings
- [ ] Console shows all "Loaded" messages
- [ ] First message appears after 30 seconds
- [ ] Leaderboard displays on the part
- [ ] Gamepass ID is updated in MainGameScript
- [ ] Product IDs are updated in MonetizationScript
- [ ] Game is published to Roblox
- [ ] Tested return visit detection

---

## Common Issues

### Messages Don't Appear
- Check if "Silence" gamepass is owned (removes messages)
- Verify UIClientScript is in StarterPlayerScripts
- Check console for errors

### DataStore Not Working
- Must test in published game, not Studio
- Verify "Enable Studio Access to API Services" is checked
- Check that you're using the correct DataStore name

### Leaderboard Empty
- Wait 60 seconds after first player joins
- Players must leave for data to save to leaderboard
- Check console for DataStore errors

### Products Not Working
- Verify Product IDs match in MonetizationScript
- Check that ProcessReceipt is set correctly
- Test purchases in published game (not Studio)

---

## Publishing Recommendations

### Game Settings
- **Genre:** Adventure, Simulation
- **Tags:** psychological, minimalist, experimental, afk
- **Description:** "An empty room. No objectives. Just you and time."

### Thumbnails
- Show the empty grey room
- Simple, clean, mysterious
- Text overlay: "Why are you still here?"

### Game Icon
- Minimalist design
- Grey color scheme
- Question mark or clock imagery

---

## Next Steps

1. Playtest with friends
2. Gather feedback on message timing
3. Adjust messages if needed
4. Monitor analytics (session time, retention)
5. Observe player comments and reactions

---

**Remember:** The power of this game is in its simplicity. Don't add features. Let players experience the void.
