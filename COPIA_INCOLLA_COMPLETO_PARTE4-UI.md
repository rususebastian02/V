# 🎮 PARTE 4: UI SCRIPTS E SETUP

# 📦 UI SCRIPTS (StarterGui)

## 1️⃣ ShopGUI_Script.lua
**Path:** StarterGui → **ScreenGui** "ShopGUI" → **LocalScript** "ShopScript"

Prima crea la struttura UI (vedi sotto), poi metti questo script dentro ShopGUI:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = require(Modules.Config)

local Events = ReplicatedStorage:WaitForChild("Events")
local PromptGamepassEvent = Events:WaitForChild("PromptGamepass")
local PromptDevProductEvent = Events:WaitForChild("PromptDevProduct")

local ShopGUI = script.Parent
local MainFrame = ShopGUI:WaitForChild("MainFrame")
local CloseButton = MainFrame:WaitForChild("CloseButton")
local GamepassFrame = MainFrame:WaitForChild("GamepassFrame")
local DevProductsFrame = MainFrame:WaitForChild("DevProductsFrame")
local TabButtons = MainFrame:WaitForChild("TabButtons")
local GamepassTab = TabButtons:WaitForChild("GamepassTab")
local DevProductsTab = TabButtons:WaitForChild("DevProductsTab")

local ShopButton = ShopGUI:WaitForChild("ShopButton")

local isShopOpen = false

local function ToggleShop()
    isShopOpen = not isShopOpen
    MainFrame.Visible = isShopOpen

    if isShopOpen then
        GamepassFrame.Visible = true
        DevProductsFrame.Visible = false
    end
end

ShopButton.MouseButton1Click:Connect(ToggleShop)
CloseButton.MouseButton1Click:Connect(ToggleShop)

GamepassTab.MouseButton1Click:Connect(function()
    GamepassFrame.Visible = true
    DevProductsFrame.Visible = false
end)

DevProductsTab.MouseButton1Click:Connect(function()
    GamepassFrame.Visible = false
    DevProductsFrame.Visible = true
end)

local function CreateGamepassButton(gamepassKey, gamepassInfo, parent)
    local button = Instance.new("TextButton")
    button.Name = gamepassKey .. "Button"
    button.Size = UDim2.new(1, -20, 0, 80)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Text = string.format("%s\n%d R$\n%s",
        gamepassInfo.Name,
        gamepassInfo.Price,
        gamepassInfo.Description)
    button.Parent = parent

    button.MouseButton1Click:Connect(function()
        PromptGamepassEvent:FireServer(gamepassKey)
    end)

    return button
end

local function CreateDevProductButton(productKey, productInfo, parent)
    local button = Instance.new("TextButton")
    button.Name = productKey .. "Button"
    button.Size = UDim2.new(1, -20, 0, 70)
    button.BackgroundColor3 = Color3.fromRGB(60, 100, 60)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true

    local buttonText = productInfo.Name .. "\n" .. productInfo.Price .. " R$"
    if productInfo.Type == "InstantCash" then
        buttonText = string.format("+%s Cash\n%d R$",
            FormatNumber(productInfo.Amount),
            productInfo.Price)
    elseif productInfo.Type == "ServerBoost" then
        buttonText = string.format("Boost %s\n%d R$ (x2 for all!)",
            productInfo.Duration >= 3600 and "1h" or "10min",
            productInfo.Price)
    end

    button.Text = buttonText
    button.Parent = parent

    button.MouseButton1Click:Connect(function()
        PromptDevProductEvent:FireServer(productKey)
    end)

    return button
end

local function FormatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
end

local gamepassContainer = GamepassFrame:WaitForChild("Container")
local gamepassList = Instance.new("UIListLayout")
gamepassList.Padding = UDim.new(0, 10)
gamepassList.Parent = gamepassContainer

for key, info in pairs(Config.Gamepasses) do
    CreateGamepassButton(key, info, gamepassContainer)
end

local devProductsContainer = DevProductsFrame:WaitForChild("Container")
local devProductsList = Instance.new("UIListLayout")
devProductsList.Padding = UDim.new(0, 10)
devProductsList.Parent = devProductsContainer

for key, info in pairs(Config.DevProducts) do
    CreateDevProductButton(key, info, devProductsContainer)
end
```

---

## 2️⃣ VIP_GUI_Script.lua
**Path:** StarterGui → **ScreenGui** "VIPGUI" → **LocalScript** "VIPScript"

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local Events = ReplicatedStorage:WaitForChild("Events")
local TeleportToVIPEvent = Events:WaitForChild("TeleportToVIP")
local RequestDataFunction = Events:WaitForChild("RequestData")

local VIPGUI = script.Parent
local VIPButton = VIPGUI:WaitForChild("VIPButton")

local function CheckVIPStatus()
    local success, data = pcall(function()
        return RequestDataFunction:InvokeServer()
    end)

    if success and data then
        local hasVIP = data.Gamepasses and data.Gamepasses.VIPStatus
        VIPButton.Visible = hasVIP
    else
        VIPButton.Visible = false
    end
end

task.wait(2)
CheckVIPStatus()

VIPButton.MouseButton1Click:Connect(function()
    TeleportToVIPEvent:FireServer()
end)

VIPButton.MouseEnter:Connect(function()
    VIPButton.BackgroundColor3 = Color3.fromRGB(255, 235, 0)
end)

VIPButton.MouseLeave:Connect(function()
    VIPButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
end)
```

---

# 🎨 SETUP UI COMPLETO

## ScreenGui 1: HUD

**Crea in StarterGui:**

1. **ScreenGui** → Nome: `HUD`

2. Dentro HUD crea:

### CashFrame
- **Frame** → Nome: `CashFrame`
- Position: `{0, 20}, {0, 20}`
- Size: `{0, 300}, {0, 80}`
- BackgroundColor3: `30, 30, 30`
- BackgroundTransparency: `0.3`

Dentro CashFrame:
- **TextLabel** → Nome: `CashLabel`
  - Size: `{1, -10}, {0.5, 0}`
  - Position: `{0, 5}, {0, 0}`
  - Text: "💰 0"
  - TextScaled: true
  - Font: GothamBold
  - BackgroundTransparency: 1

- **TextLabel** → Nome: `IncomeLabel`
  - Size: `{1, -10}, {0.5, 0}`
  - Position: `{0, 5}, {0.5, 0}`
  - Text: "+1/sec"
  - TextScaled: true
  - Font: Gotham
  - BackgroundTransparency: 1

### RankFrame
- **Frame** → Nome: `RankFrame`
- Position: `{1, -320}, {0, 20}`
- Size: `{0, 300}, {0, 80}`
- BackgroundColor3: `30, 30, 30`
- BackgroundTransparency: `0.3`

Dentro RankFrame:
- **TextLabel** → Nome: `RankLabel`
  - Size: `{1, -10}, {1, -10}`
  - Position: `{0, 5}, {0, 5}`
  - Text: "🏆 Lazy"
  - TextScaled: true
  - Font: GothamBold
  - BackgroundTransparency: 1

### AFKFrame
- **Frame** → Nome: `AFKFrame`
- Position: `{0, 20}, {0, 110}`
- Size: `{0, 300}, {0, 60}`
- BackgroundColor3: `30, 30, 30`
- BackgroundTransparency: `0.3`

Dentro AFKFrame:
- **TextLabel** → Nome: `AFKTimeLabel`
  - Size: `{1, -10}, {1, -10}`
  - Position: `{0, 5}, {0, 5}`
  - Text: "⏱️ 0s"
  - TextScaled: true
  - Font: GothamBold
  - BackgroundTransparency: 1

### BoostFrame
- **Frame** → Nome: `BoostFrame`
- Position: `{0.5, -200}, {0, 20}`
- Size: `{0, 400}, {0, 50}`
- BackgroundColor3: `255, 200, 0`
- BackgroundTransparency: `0.2`
- Visible: **false**

Dentro BoostFrame:
- **TextLabel** → Nome: `BoostLabel`
  - Size: `{1, -10}, {1, -10}`
  - Position: `{0, 5}, {0, 5}`
  - Text: "🚀 SERVER BOOST x2"
  - TextScaled: true
  - Font: GothamBlack
  - BackgroundTransparency: 1

---

## ScreenGui 2: ShopGUI

**Crea in StarterGui:**

1. **ScreenGui** → Nome: `ShopGUI`

2. **TextButton** → Nome: `ShopButton` (dentro ShopGUI)
- Position: `{1, -120}, {1, -120}`
- Size: `{0, 100}, {0, 100}`
- Text: "🛒 SHOP"
- TextScaled: true
- Font: GothamBold
- BackgroundColor3: `50, 150, 50`

3. **Frame** → Nome: `MainFrame` (dentro ShopGUI)
- AnchorPoint: `0.5, 0.5`
- Position: `{0.5, 0}, {0.5, 0}`
- Size: `{0, 600}, {0, 500}`
- BackgroundColor3: `40, 40, 40`
- Visible: **false**

Dentro MainFrame:

### CloseButton
- **TextButton** → Nome: `CloseButton`
- Position: `{1, -60}, {0, 10}`
- Size: `{0, 50}, {0, 50}`
- Text: "X"
- TextScaled: true
- Font: GothamBold
- BackgroundColor3: `200, 0, 0`

### TabButtons
- **Frame** → Nome: `TabButtons`
- Position: `{0, 0}, {0, 0}`
- Size: `{1, 0}, {0, 50}`
- BackgroundColor3: `30, 30, 30`

Dentro TabButtons:
- **TextButton** → Nome: `GamepassTab`
  - Position: `{0, 0}, {0, 0}`
  - Size: `{0.5, 0}, {1, 0}`
  - Text: "GAMEPASS"
  - TextScaled: true
  - BackgroundColor3: `50, 50, 50`

- **TextButton** → Nome: `DevProductsTab`
  - Position: `{0.5, 0}, {0, 0}`
  - Size: `{0.5, 0}, {1, 0}`
  - Text: "DEV PRODUCTS"
  - TextScaled: true
  - BackgroundColor3: `50, 50, 50`

### GamepassFrame
- **Frame** → Nome: `GamepassFrame`
- Position: `{0, 0}, {0, 50}`
- Size: `{1, 0}, {1, -50}`
- BackgroundTransparency: 1
- Visible: true

Dentro GamepassFrame:
- **ScrollingFrame** → Nome: `Container`
  - Size: `{1, 0}, {1, 0}`
  - BackgroundTransparency: 1
  - ScrollBarThickness: 10

### DevProductsFrame
- **Frame** → Nome: `DevProductsFrame`
- Position: `{0, 0}, {0, 50}`
- Size: `{1, 0}, {1, -50}`
- BackgroundTransparency: 1
- Visible: false

Dentro DevProductsFrame:
- **ScrollingFrame** → Nome: `Container`
  - Size: `{1, 0}, {1, 0}`
  - BackgroundTransparency: 1
  - ScrollBarThickness: 10

4. **Aggiungi il LocalScript** "ShopScript" dentro ShopGUI e copia lo script sopra

---

## ScreenGui 3: VIPGUI

**Crea in StarterGui:**

1. **ScreenGui** → Nome: `VIPGUI`

2. **TextButton** → Nome: `VIPButton`
- Position: `{0.5, -100}, {1, -120}`
- Size: `{0, 200}, {0, 60}`
- Text: "⭐ VIP AREA"
- TextScaled: true
- Font: GothamBold
- BackgroundColor3: `255, 215, 0`
- Visible: **false**

3. **Aggiungi il LocalScript** "VIPScript" dentro VIPGUI e copia lo script sopra

---

## ScreenGui 4: RankUpNotification

**Crea in StarterGui:**

1. **ScreenGui** → Nome: `RankUpNotification`

2. **Frame** (dentro RankUpNotification)
- AnchorPoint: `0.5, 0`
- Position: `{0.5, 0}, {-0.2, 0}`
- Size: `{0, 400}, {0, 150}`
- BackgroundColor3: `40, 40, 40`
- BackgroundTransparency: `0.2`
- Visible: **false**

Dentro Frame:

- **TextLabel** → Nome: `TitleLabel`
  - Position: `{0.5, 0}, {0.2, 0}`
  - Size: `{0.8, 0}, {0.3, 0}`
  - AnchorPoint: `0.5, 0`
  - Text: "RANK UP!"
  - Font: GothamBlack
  - TextColor3: `255, 215, 0`
  - TextScaled: true
  - BackgroundTransparency: 1

- **TextLabel** → Nome: `RankNameLabel`
  - Position: `{0.5, 0}, {0.55, 0}`
  - Size: `{0.8, 0}, {0.35, 0}`
  - AnchorPoint: `0.5, 0`
  - Text: ""
  - Font: GothamBold
  - TextColor3: `255, 255, 255`
  - TextScaled: true
  - BackgroundTransparency: 1

---

# 🗺️ MAPPA BASE

## Nel Workspace crea:

### 1. Spawn Platform
1. **Part** → Nome: `SpawnPlatform`
   - Size: `20, 1, 20`
   - Position: `0, 0.5, 0`
   - Anchored: true
   - Material: SmoothPlastic
   - BrickColor: White

2. **SpawnLocation**
   - Position: `0, 3, 0` (sopra la platform)
   - Anchored: true

### 2. VIP Spawn (opzionale)
1. **Part** → Nome: `VIPSpawn`
   - Size: `15, 1, 15`
   - Position: `0, 100, 0`
   - Anchored: true
   - Material: SmoothPlastic
   - BrickColor: Bright yellow

---

# ⚙️ SETTINGS ROBLOX STUDIO

## IMPORTANTE:

1. **Home** → **Game Settings** → **Security**
   - ✅ Abilita "**Enable Studio Access to API Services**"

2. **Game Settings** → **Options**
   - Nome gioco: "DO NOTHING TO GET RICH"
   - Descrizione: "The less you play, the richer you get! AFK Idle Game"

---

# ✅ CHECKLIST FINALE

Prima di testare, verifica:

- [ ] Tutte le cartelle create (Modules, Events)
- [ ] Tutti i 11 ModuleScript in ReplicatedStorage/Modules
- [ ] Tutti gli 8 RemoteEvents/RemoteFunction in ReplicatedStorage/Events
- [ ] MainServer.lua in ServerScriptService
- [ ] GlobalLeaderboardDisplay.lua in ServerScriptService
- [ ] ClientMain.lua in StarterPlayer/StarterPlayerScripts
- [ ] Tutti i 4 ScreenGui in StarterGui (HUD, ShopGUI, VIPGUI, RankUpNotification)
- [ ] ShopScript dentro ShopGUI
- [ ] VIPScript dentro VIPGUI
- [ ] SpawnPlatform + SpawnLocation nel Workspace
- [ ] "Enable Studio Access to API Services" attivato

---

# 🚀 TEST

**Premi F5 in Studio**

Dovresti vedere:
- ✅ HUD con Cash, Rank, AFK Time
- ✅ Cash che aumenta automaticamente
- ✅ Leaderboard che appare sopra la testa
- ✅ Bottone Shop funzionante
- ✅ Dopo 1 minuto: Rank passa da Lazy a Chill

---

# 🎯 MODIFICA PARAMETRI

## Per modificare Cash/sec:
**File:** Config.lua
**Riga:** 6
```lua
BaseCashPerSecond = 1,  -- Cambia questo numero
```

## Per modificare ID Gamepass:
**File:** Config.lua
**Righe:** 15-42
Sostituisci tutti gli ID con i tuoi

## Per modificare ID Dev Products:
**File:** Config.lua
**Righe:** 46-112
Sostituisci tutti gli ID con i tuoi

## Per modificare Rank:
**File:** Config.lua
**Righe:** 120-128
Modifica TimeRequired (in secondi)

---

# 🎉 FATTO!

Tutti gli script sono pronti! Se hai problemi controlla:
1. Console Output per errori
2. Che tutti i nomi siano ESATTI (case-sensitive)
3. Che "Enable Studio Access to API Services" sia attivo
