# The Waiting Game - Infinite Loading Screen

An ultra-simple but mind-blowing Roblox game where players experience a 20-minute loading screen with random facts and messages... only to discover they've wasted their time!

## 🎮 Game Features

- **Infinite Loading Screen**: A beautiful, progressive loading bar that takes exactly 20 minutes to complete
- **Random Facts & Messages**: Over 40 different messages including:
  - Interesting "Did you know?" facts
  - Fun science facts
  - Humorous loading messages
  - Philosophical quotes
- **Smooth Animations**: Professional loading bar with gradients and smooth progress
- **Epic Reveal**: After 20 minutes, players are greeted with a congratulations screen
- **Sparkling Effects**: Visual celebration when the loading completes

## 📁 Project Structure

```
V/
├── src/
│   └── StarterGui/
│       └── LoadingScreen/
│           └── LoadingScreenGui.lua    # Main loading screen script
├── default.project.json                # Rojo project configuration
└── README.md                           # This file
```

## 🚀 How to Use

### Method 1: Using Rojo (Recommended)

1. Install [Rojo](https://rojo.space/) if you haven't already
2. Clone this repository
3. Open terminal in the project directory
4. Run: `rojo serve`
5. In Roblox Studio, click "Connect" in the Rojo plugin
6. The game will sync automatically!

### Method 2: Manual Installation

1. Open Roblox Studio
2. Create a new place
3. In Explorer, navigate to `StarterGui`
4. Create a new `ScreenGui` and name it "LoadingScreen"
5. Inside the ScreenGui, create a `LocalScript`
6. Copy the contents of `src/StarterGui/LoadingScreen/LoadingScreenGui.lua` into the LocalScript
7. Set ScreenGui properties:
   - ResetOnSpawn: `false`
   - DisplayOrder: `100`
   - ZIndexBehavior: `Sibling`

## ⚙️ Configuration

You can customize the experience by editing these variables in `LoadingScreenGui.lua`:

```lua
local TOTAL_WAIT_TIME = 1200              -- 20 minutes in seconds (change this!)
local MESSAGE_CHANGE_INTERVAL = 8         -- How often messages change (in seconds)
local LOADING_BAR_SPEED = 0.05            -- Speed of loading bar progress
```

## 🎨 Customization Ideas

- Change `TOTAL_WAIT_TIME` to make it shorter/longer
- Add your own messages to the `randomMessages` array
- Modify colors in the loading bar and text
- Change fonts and text sizes
- Add your own logo by replacing the "THE WAITING GAME" text with an ImageLabel

## 📝 Technical Details

- **Language**: Luau (Roblox Lua)
- **Services Used**: Players, TweenService
- **GUI Type**: ScreenGui with LocalScript
- **Platform**: Roblox

## 🎭 The Experience

1. Player joins the game
2. Immediately sees a sleek black loading screen
3. Loading bar slowly progresses
4. Random facts and messages keep them entertained
5. After exactly 20 minutes, loading completes
6. Congratulations screen appears with the message: "You just wasted 20 minutes of your life!"
7. Sparkles celebrate their "achievement"

## 🤔 Why Would Anyone Play This?

Great question! It's a social experiment and a joke game. Perfect for:
- Testing player patience
- Creating funny content for YouTube/TikTok
- Trolling friends
- Appreciating the absurdity of waiting
- A meditation on the value of time

## 📄 License

Free to use and modify. Have fun wasting people's time! 😄

## 🙏 Credits

Created as an ultra-simple but mind-blowing Roblox experience.

---

**Warning**: This game literally does nothing except waste 20 minutes of your time. Play at your own risk!