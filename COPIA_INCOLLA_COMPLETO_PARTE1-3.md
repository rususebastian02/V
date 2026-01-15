# 🎮 TUTTI GLI SCRIPT - COPIA E INCOLLA

## 📍 PRIMA COSA: Setup Cartelle

**In ReplicatedStorage:**
1. Crea **Folder** → Nome: `Modules`
2. Crea **Folder** → Nome: `Events`

**In ReplicatedStorage/Events crea:**
- **RemoteEvent** → Nome: `DataUpdated`
- **RemoteEvent** → Nome: `RankUp`
- **RemoteEvent** → Nome: `BoostActivated`
- **RemoteEvent** → Nome: `BoostEnded`
- **RemoteEvent** → Nome: `PromptGamepass`
- **RemoteEvent** → Nome: `PromptDevProduct`
- **RemoteEvent** → Nome: `TeleportToVIP`
- **RemoteFunction** → Nome: `RequestData`

---

# 📦 PARTE 1: MODULI (11 script)

## 1️⃣ Config.lua
**Path:** ReplicatedStorage → Modules → **ModuleScript** "Config"

```lua
local Config = {}

Config.GameName = "DO NOTHING TO GET RICH"

Config.Economy = {
    BaseCashPerSecond = 1,
    ScalingInterval = 60,
    ScalingMultiplier = 1.005,
    ScalingCap = 2.0,
    MaxOfflineHours = 12,
}

Config.Gamepasses = {
    x2Income = {
        ID = 1671785492,
        Name = "x2 Income",
        Price = 199,
        Description = "Raddoppia il tuo guadagno permanentemente!",
        Multiplier = 2.0
    },
    VIPStatus = {
        ID = 1671265879,
        Name = "VIP Status",
        Price = 149,
        Description = "Rank esclusivo + accesso alla VIP Area!",
        SpecialRank = "VIP"
    },
    AFKBoost = {
        ID = 1671407720,
        Name = "AFK Boost",
        Price = 99,
        Description = "Aumenta il guadagno del 50%!",
        Multiplier = 1.5
    },
    OfflineEarnings = {
        ID = 1671275763,
        Name = "Offline Earnings",
        Price = 129,
        Description = "Guadagni anche quando sei offline!"
    }
}

Config.DevProducts = {
    Boost10Min = {
        ID = 3513599959,
        Name = "Boost 10 min",
        Price = 29,
        Duration = 600,
        Multiplier = 2.0,
        Type = "ServerBoost"
    },
    Boost1Hour = {
        ID = 3513600071,
        Name = "Boost 1h",
        Price = 200,
        Duration = 3600,
        Multiplier = 2.0,
        Type = "ServerBoost"
    },
    SkipRank = {
        ID = 3513600561,
        Name = "Skip Rank",
        Price = 49,
        Type = "SkipRank"
    },
    Cash500 = {
        ID = 3513601163,
        Name = "+500 Cash",
        Price = 9,
        Amount = 500,
        Type = "InstantCash"
    },
    Cash5K = {
        ID = 3513601306,
        Name = "+5.000 Cash",
        Price = 90,
        Amount = 5000,
        Type = "InstantCash"
    },
    Cash50K = {
        ID = 3513601445,
        Name = "+50.000 Cash",
        Price = 250,
        Amount = 50000,
        Type = "InstantCash"
    },
    Cash500K = {
        ID = 3513601593,
        Name = "+500.000 Cash",
        Price = 650,
        Amount = 500000,
        Type = "InstantCash"
    },
    Cash5M = {
        ID = 3513601782,
        Name = "+5.000.000 Cash",
        Price = 999,
        Amount = 5000000,
        Type = "InstantCash"
    }
}

function Config.GetDevProductByID(productId)
    for _, product in pairs(Config.DevProducts) do
        if product.ID == productId then return product end
    end
    return nil
end

Config.Ranks = {
    {Name = "Lazy", TimeRequired = 60, Color = Color3.fromRGB(150, 150, 150)},
    {Name = "Chill", TimeRequired = 300, Color = Color3.fromRGB(100, 200, 255)},
    {Name = "Clean", TimeRequired = 900, Color = Color3.fromRGB(255, 255, 255)},
    {Name = "Rich", TimeRequired = 1800, Color = Color3.fromRGB(255, 215, 0)},
    {Name = "Millionaire", TimeRequired = 3600, Color = Color3.fromRGB(255, 165, 0)},
    {Name = "Billionaire", TimeRequired = 10800, Color = Color3.fromRGB(255, 100, 255)},
    {Name = "Prince of Lazyness", TimeRequired = 21600, Color = Color3.fromRGB(138, 43, 226)},
    {Name = "God of Nothing", TimeRequired = 43200, Color = Color3.fromRGB(255, 0, 0)},
    {Name = "AFK Deity", TimeRequired = 86400, Color = Color3.fromRGB(0, 255, 255)},
}

function Config.GetRankForTime(afkTime)
    local currentRank = Config.Ranks[1]
    for _, rank in ipairs(Config.Ranks) do
        if afkTime >= rank.TimeRequired then
            currentRank = rank
        else
            break
        end
    end
    return currentRank
end

function Config.GetNextRank(currentRankName)
    for i, rank in ipairs(Config.Ranks) do
        if rank.Name == currentRankName then
            return Config.Ranks[i + 1]
        end
    end
    return nil
end

Config.Auras = {
    ["Billionaire"] = {
        ParticleColor = ColorSequence.new(Color3.fromRGB(255, 100, 255)),
        Size = NumberSequence.new(1),
        Transparency = NumberSequence.new(0.5),
        Enabled = true
    },
    ["Prince of Lazyness"] = {
        ParticleColor = ColorSequence.new(Color3.fromRGB(138, 43, 226)),
        Size = NumberSequence.new(1.5),
        Transparency = NumberSequence.new(0.3),
        Enabled = true
    },
    ["God of Nothing"] = {
        ParticleColor = ColorSequence.new(Color3.fromRGB(255, 0, 0)),
        Size = NumberSequence.new(2),
        Transparency = NumberSequence.new(0.2),
        Enabled = true
    },
    ["AFK Deity"] = {
        ParticleColor = ColorSequence.new(Color3.fromRGB(0, 255, 255)),
        Size = NumberSequence.new(2.5),
        Transparency = NumberSequence.new(0.1),
        Enabled = true
    }
}

Config.Leaderboard = {
    UpdateInterval = 300,
    Top100Entries = 100,
    LocalUpdateInterval = 5,
}

Config.DataStore = {
    Name = "PlayerData_V1",
    AutoSaveInterval = 60,
}

Config.DefaultPlayerData = {
    Cash = 0,
    TotalAFKTime = 0,
    CurrentRank = "Lazy",
    Gamepasses = {
        x2Income = false,
        VIPStatus = false,
        AFKBoost = false,
        OfflineEarnings = false
    },
    Settings = {
        MusicEnabled = true,
        SFXEnabled = true
    },
    Stats = {
        TotalCashEarned = 0,
        HighestRank = "Lazy",
        TotalPlayTime = 0
    },
    LastLogin = os.time()
}

return Config
```

---

## 2️⃣ DataManager.lua
**Path:** ReplicatedStorage → Modules → **ModuleScript** "DataManager"

```lua
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Config = require(script.Parent.Config)

local DataManager = {}
local ProfileCache = {}
local PlayerDataStore = DataStoreService:GetDataStore(Config.DataStore.Name)

local function DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

local Profile = {}
Profile.__index = Profile

function Profile.new(player, data)
    local self = setmetatable({}, Profile)
    self.Player = player
    self.Data = data
    self.IsLoaded = true
    self._saveConnection = nil
    return self
end

function Profile:Get(key)
    return self.Data[key]
end

function Profile:Set(key, value)
    self.Data[key] = value
end

function Profile:Increment(key, amount)
    if type(self.Data[key]) == "number" then
        self.Data[key] = self.Data[key] + amount
    end
end

function Profile:Save()
    if not self.IsLoaded then
        warn("[DataManager] Tentativo di salvare profilo non caricato")
        return false
    end

    local userId = self.Player.UserId
    local success, errorMessage = pcall(function()
        PlayerDataStore:SetAsync("Player_" .. userId, self.Data)
    end)

    if success then
        print("[DataManager] Dati salvati per " .. self.Player.Name)
        return true
    else
        warn("[DataManager] Errore nel salvare dati: " .. errorMessage)
        return false
    end
end

function Profile:Release()
    self.IsLoaded = false
    if self._saveConnection then
        self._saveConnection:Disconnect()
    end
    ProfileCache[self.Player.UserId] = nil
end

function DataManager.LoadProfile(player)
    local userId = player.UserId

    if ProfileCache[userId] then
        return ProfileCache[userId]
    end

    local data = nil
    local success, errorMessage = pcall(function()
        data = PlayerDataStore:GetAsync("Player_" .. userId)
    end)

    if not success then
        warn("[DataManager] Errore nel caricare dati: " .. errorMessage)
        data = nil
    end

    if not data then
        data = DeepCopy(Config.DefaultPlayerData)
    else
        local defaultData = DeepCopy(Config.DefaultPlayerData)
        for key, value in pairs(data) do
            defaultData[key] = value
        end
        data = defaultData
    end

    local profile = Profile.new(player, data)
    ProfileCache[userId] = profile
    return profile
end

function DataManager.GetProfile(player)
    return ProfileCache[player.UserId]
end

function DataManager.SaveProfile(player)
    local profile = ProfileCache[player.UserId]
    if profile then
        return profile:Save()
    end
    return false
end

function DataManager.ReleaseProfile(player)
    local profile = ProfileCache[player.UserId]
    if profile then
        profile:Save()
        profile:Release()
    end
end

function DataManager.SaveAllProfiles()
    local count = 0
    for userId, profile in pairs(ProfileCache) do
        if profile:Save() then
            count = count + 1
        end
    end
    print("[DataManager] Salvati " .. count .. " profili")
end

return DataManager
```

---

## 3️⃣ CashManager.lua
**Path:** ReplicatedStorage → Modules → **ModuleScript** "CashManager"

```lua
local Config = require(script.Parent.Config)

local CashManager = {}
local PlayerTracking = {}

function CashManager.InitializePlayer(player, profile)
    if PlayerTracking[player.UserId] then return end

    PlayerTracking[player.UserId] = {
        Profile = profile,
        JoinTime = tick(),
        LastCashUpdate = tick(),
        LastScalingUpdate = tick(),
        CurrentScalingMultiplier = 1.0,
        IsTracking = true
    }
end

function CashManager.RemovePlayer(player)
    PlayerTracking[player.UserId] = nil
end

function CashManager.GetBaseIncome()
    return Config.Economy.BaseCashPerSecond
end

function CashManager.CalculateTotalMultiplier(player, profile, serverBoostMultiplier)
    local multiplier = 1.0

    if profile:Get("Gamepasses").x2Income then
        multiplier = multiplier * Config.Gamepasses.x2Income.Multiplier
    end

    if profile:Get("Gamepasses").AFKBoost then
        multiplier = multiplier * Config.Gamepasses.AFKBoost.Multiplier
    end

    if serverBoostMultiplier and serverBoostMultiplier > 1 then
        multiplier = multiplier * serverBoostMultiplier
    end

    local tracking = PlayerTracking[player.UserId]
    if tracking then
        multiplier = multiplier * tracking.CurrentScalingMultiplier
    end

    return multiplier
end

function CashManager.CalculateIncome(player, profile, serverBoostMultiplier)
    local baseIncome = CashManager.GetBaseIncome()
    local multiplier = CashManager.CalculateTotalMultiplier(player, profile, serverBoostMultiplier or 1.0)
    return baseIncome * multiplier
end

function CashManager.UpdateScaling(player)
    local tracking = PlayerTracking[player.UserId]
    if not tracking then return end

    local timeSinceLastScaling = tick() - tracking.LastScalingUpdate

    if timeSinceLastScaling >= Config.Economy.ScalingInterval then
        local intervals = math.floor(timeSinceLastScaling / Config.Economy.ScalingInterval)

        for i = 1, intervals do
            tracking.CurrentScalingMultiplier = tracking.CurrentScalingMultiplier * Config.Economy.ScalingMultiplier

            if tracking.CurrentScalingMultiplier > Config.Economy.ScalingCap then
                tracking.CurrentScalingMultiplier = Config.Economy.ScalingCap
                break
            end
        end

        tracking.LastScalingUpdate = tick()
    end
end

function CashManager.UpdateCash(player, profile, serverBoostMultiplier)
    local tracking = PlayerTracking[player.UserId]
    if not tracking or not tracking.IsTracking then return end

    local now = tick()
    local deltaTime = now - tracking.LastCashUpdate

    CashManager.UpdateScaling(player)

    local income = CashManager.CalculateIncome(player, profile, serverBoostMultiplier)
    local cashToAdd = income * deltaTime

    profile:Increment("Cash", cashToAdd)
    profile:Increment("Stats", "TotalCashEarned", cashToAdd)
    profile:Increment("TotalAFKTime", deltaTime)
    profile:Increment("Stats", "TotalPlayTime", deltaTime)

    tracking.LastCashUpdate = now

    return cashToAdd, income
end

function CashManager.GetCurrentIncome(player, profile, serverBoostMultiplier)
    return CashManager.CalculateIncome(player, profile, serverBoostMultiplier or 1.0)
end

function CashManager.GetSessionTime(player)
    local tracking = PlayerTracking[player.UserId]
    if not tracking then return 0 end
    return tick() - tracking.JoinTime
end

function CashManager.GetScalingMultiplier(player)
    local tracking = PlayerTracking[player.UserId]
    if not tracking then return 1.0 end
    return tracking.CurrentScalingMultiplier
end

function CashManager.AddCash(player, profile, amount)
    if amount <= 0 then return false end
    profile:Increment("Cash", amount)
    profile:Increment("Stats", "TotalCashEarned", amount)
    return true
end

function CashManager.RemoveCash(player, profile, amount)
    if amount <= 0 then return false end
    local currentCash = profile:Get("Cash")
    if currentCash < amount then return false end

    profile:Set("Cash", currentCash - amount)
    return true
end

return CashManager
```

---

## 4️⃣ RankManager.lua
**Path:** ReplicatedStorage → Modules → **ModuleScript** "RankManager"

```lua
local Config = require(script.Parent.Config)

local RankManager = {}
local RankUpEvent = nil

function RankManager.GetCurrentRank(afkTime)
    return Config.GetRankForTime(afkTime)
end

function RankManager.GetNextRank(currentRankName)
    return Config.GetNextRank(currentRankName)
end

function RankManager.GetProgressToNextRank(afkTime)
    local currentRank = Config.GetRankForTime(afkTime)
    local nextRank = Config.GetNextRank(currentRank.Name)

    if not nextRank then
        return 1.0, currentRank, nil
    end

    local timeInCurrentRank = afkTime - currentRank.TimeRequired
    local timeNeededForNext = nextRank.TimeRequired - currentRank.TimeRequired
    local progress = timeInCurrentRank / timeNeededForNext

    return math.clamp(progress, 0, 1), currentRank, nextRank
end

function RankManager.UpdatePlayerRank(player, profile)
    local afkTime = profile:Get("TotalAFKTime")
    local currentRankName = profile:Get("CurrentRank")

    local newRank = RankManager.GetCurrentRank(afkTime)

    if profile:Get("Gamepasses").VIPStatus then
        if currentRankName ~= "VIP" then
            profile:Set("CurrentRank", "VIP")

            if RankUpEvent then
                RankUpEvent:FireClient(player, "VIP", {
                    Name = "VIP",
                    Color = Color3.fromRGB(255, 215, 0)
                })
            end
        end
        return "VIP"
    end

    if newRank.Name ~= currentRankName then
        local oldRank = currentRankName
        profile:Set("CurrentRank", newRank.Name)

        local highestRank = profile:Get("Stats").HighestRank or "Lazy"
        if RankManager.IsRankHigher(newRank.Name, highestRank) then
            local stats = profile:Get("Stats")
            stats.HighestRank = newRank.Name
            profile:Set("Stats", stats)
        end

        if RankUpEvent then
            RankUpEvent:FireClient(player, newRank.Name, newRank)
        end

        return newRank.Name, true
    end

    return currentRankName, false
end

function RankManager.SkipToNextRank(player, profile)
    local currentRankName = profile:Get("CurrentRank")

    if currentRankName == "VIP" then
        return false, "VIP Status è il rank massimo speciale!"
    end

    local nextRank = Config.GetNextRank(currentRankName)

    if not nextRank then
        return false, "Sei già al rank massimo!"
    end

    local currentAFKTime = profile:Get("TotalAFKTime")
    local newAFKTime = math.max(currentAFKTime, nextRank.TimeRequired)

    profile:Set("TotalAFKTime", newAFKTime)
    profile:Set("CurrentRank", nextRank.Name)

    local stats = profile:Get("Stats")
    if RankManager.IsRankHigher(nextRank.Name, stats.HighestRank or "Lazy") then
        stats.HighestRank = nextRank.Name
        profile:Set("Stats", stats)
    end

    if RankUpEvent then
        RankUpEvent:FireClient(player, nextRank.Name, nextRank)
    end

    return true, nextRank.Name
end

function RankManager.IsRankHigher(rankName1, rankName2)
    local rank1Index = nil
    local rank2Index = nil

    for i, rank in ipairs(Config.Ranks) do
        if rank.Name == rankName1 then
            rank1Index = i
        end
        if rank.Name == rankName2 then
            rank2Index = i
        end
    end

    if not rank1Index or not rank2Index then
        return false
    end

    return rank1Index > rank2Index
end

function RankManager.GetRankColor(rankName)
    for _, rank in ipairs(Config.Ranks) do
        if rank.Name == rankName then
            return rank.Color
        end
    end
    return Color3.fromRGB(255, 255, 255)
end

function RankManager.HasAura(rankName)
    return Config.Auras[rankName] ~= nil
end

function RankManager.GetAuraSettings(rankName)
    return Config.Auras[rankName]
end

function RankManager.Init(rankUpRemoteEvent)
    RankUpEvent = rankUpRemoteEvent
end

return RankManager
```

---

## 5️⃣ GamepassManager.lua
**Path:** ReplicatedStorage → Modules → **ModuleScript** "GamepassManager"

```lua
local MarketplaceService = game:GetService("MarketplaceService")
local Config = require(script.Parent.Config)

local GamepassManager = {}
local GamepassCache = {}

function GamepassManager.PlayerOwnsGamepass(player, gamepassId)
    local cacheKey = player.UserId .. "_" .. gamepassId
    if GamepassCache[cacheKey] ~= nil then
        return GamepassCache[cacheKey]
    end

    local success, ownsGamepass = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepassId)
    end)

    if success then
        GamepassCache[cacheKey] = ownsGamepass
        return ownsGamepass
    else
        return false
    end
end

function GamepassManager.SyncGamepasses(player, profile)
    local gamepasses = profile:Get("Gamepasses")
    local anyChanged = false

    local ownsX2 = GamepassManager.PlayerOwnsGamepass(player, Config.Gamepasses.x2Income.ID)
    if ownsX2 and not gamepasses.x2Income then
        gamepasses.x2Income = true
        anyChanged = true
    end

    local ownsVIP = GamepassManager.PlayerOwnsGamepass(player, Config.Gamepasses.VIPStatus.ID)
    if ownsVIP and not gamepasses.VIPStatus then
        gamepasses.VIPStatus = true
        anyChanged = true
    end

    local ownsAFKBoost = GamepassManager.PlayerOwnsGamepass(player, Config.Gamepasses.AFKBoost.ID)
    if ownsAFKBoost and not gamepasses.AFKBoost then
        gamepasses.AFKBoost = true
        anyChanged = true
    end

    local ownsOffline = GamepassManager.PlayerOwnsGamepass(player, Config.Gamepasses.OfflineEarnings.ID)
    if ownsOffline and not gamepasses.OfflineEarnings then
        gamepasses.OfflineEarnings = true
        anyChanged = true
    end

    if anyChanged then
        profile:Set("Gamepasses", gamepasses)
    end

    return gamepasses
end

function GamepassManager.PromptGamepassPurchase(player, gamepassKey)
    local gamepassInfo = Config.Gamepasses[gamepassKey]
    if not gamepassInfo then
        return false
    end

    if GamepassManager.PlayerOwnsGamepass(player, gamepassInfo.ID) then
        return false
    end

    local success, errorMessage = pcall(function()
        MarketplaceService:PromptGamePassPurchase(player, gamepassInfo.ID)
    end)

    if not success then
        warn("[GamepassManager] Errore nel prompt gamepass: " .. errorMessage)
        return false
    end

    return true
end

function GamepassManager.OnGamepassPurchased(player, profile, gamepassId)
    local cacheKey = player.UserId .. "_" .. gamepassId
    GamepassCache[cacheKey] = true

    local gamepasses = profile:Get("Gamepasses")

    if gamepassId == Config.Gamepasses.x2Income.ID then
        gamepasses.x2Income = true
    elseif gamepassId == Config.Gamepasses.VIPStatus.ID then
        gamepasses.VIPStatus = true
    elseif gamepassId == Config.Gamepasses.AFKBoost.ID then
        gamepasses.AFKBoost = true
    elseif gamepassId == Config.Gamepasses.OfflineEarnings.ID then
        gamepasses.OfflineEarnings = true
    end

    profile:Set("Gamepasses", gamepasses)
    profile:Save()
end

function GamepassManager.GetGamepassInfo(gamepassKey)
    return Config.Gamepasses[gamepassKey]
end

function GamepassManager.GetAllGamepasses()
    return Config.Gamepasses
end

function GamepassManager.ClearCache(player)
    for cacheKey in pairs(GamepassCache) do
        if string.find(cacheKey, tostring(player.UserId)) then
            GamepassCache[cacheKey] = nil
        end
    end
end

return GamepassManager
```

---

## 6️⃣ DevProductsManager.lua
**Path:** ReplicatedStorage → Modules → **ModuleScript** "DevProductsManager"

```lua
local MarketplaceService = game:GetService("MarketplaceService")
local Config = require(script.Parent.Config)

local DevProductsManager = {}

local Handlers = {
    OnServerBoostActivated = nil,
    OnSkipRank = nil,
    OnInstantCash = nil
}

function DevProductsManager.ProcessReceipt(receiptInfo)
    local player = game.Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end

    local productId = receiptInfo.ProductId
    local product = Config.GetDevProductByID(productId)

    if not product then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    if product.Type == "ServerBoost" then
        if Handlers.OnServerBoostActivated then
            Handlers.OnServerBoostActivated(player, product)
        end

    elseif product.Type == "SkipRank" then
        if Handlers.OnSkipRank then
            Handlers.OnSkipRank(player)
        end

    elseif product.Type == "InstantCash" then
        if Handlers.OnInstantCash then
            Handlers.OnInstantCash(player, product.Amount)
        end
    end

    return Enum.ProductPurchaseDecision.PurchaseGranted
end

function DevProductsManager.SetServerBoostHandler(handler)
    Handlers.OnServerBoostActivated = handler
end

function DevProductsManager.SetSkipRankHandler(handler)
    Handlers.OnSkipRank = handler
end

function DevProductsManager.SetInstantCashHandler(handler)
    Handlers.OnInstantCash = handler
end

function DevProductsManager.PromptPurchase(player, productKey)
    local product = Config.DevProducts[productKey]
    if not product then
        return false
    end

    local success, errorMessage = pcall(function()
        MarketplaceService:PromptProductPurchase(player, product.ID)
    end)

    if not success then
        warn("[DevProductsManager] Errore: " .. errorMessage)
        return false
    end

    return true
end

function DevProductsManager.GetProductInfo(productKey)
    return Config.DevProducts[productKey]
end

function DevProductsManager.GetAllProducts()
    return Config.DevProducts
end

function DevProductsManager.GetProductsByType(productType)
    local products = {}
    for key, product in pairs(Config.DevProducts) do
        if product.Type == productType then
            table.insert(products, {Key = key, Product = product})
        end
    end
    return products
end

function DevProductsManager.Init()
    MarketplaceService.ProcessReceipt = DevProductsManager.ProcessReceipt
end

return DevProductsManager
```

---

## 7️⃣ BoostManager.lua
**Path:** ReplicatedStorage → Modules → **ModuleScript** "BoostManager"

```lua
local BoostManager = {}

local ActiveBoost = {
    Active = false,
    Multiplier = 1.0,
    EndTime = 0,
    ActivatedBy = nil
}

local BoostActivatedEvent = nil
local BoostEndedEvent = nil

function BoostManager.ActivateBoost(player, duration, multiplier)
    if ActiveBoost.Active then
        local remainingTime = ActiveBoost.EndTime - tick()
        ActiveBoost.EndTime = ActiveBoost.EndTime + duration
    else
        ActiveBoost.Active = true
        ActiveBoost.Multiplier = multiplier
        ActiveBoost.EndTime = tick() + duration
        ActiveBoost.ActivatedBy = player.Name
    end

    if BoostActivatedEvent then
        BoostActivatedEvent:FireAllClients({
            Multiplier = ActiveBoost.Multiplier,
            EndTime = ActiveBoost.EndTime,
            ActivatedBy = player.Name
        })
    end
end

function BoostManager.DeactivateBoost()
    if not ActiveBoost.Active then return end

    ActiveBoost.Active = false
    ActiveBoost.Multiplier = 1.0
    ActiveBoost.EndTime = 0
    ActiveBoost.ActivatedBy = nil

    if BoostEndedEvent then
        BoostEndedEvent:FireAllClients()
    end
end

function BoostManager.IsBoostActive()
    return ActiveBoost.Active and tick() < ActiveBoost.EndTime
end

function BoostManager.GetCurrentMultiplier()
    if BoostManager.IsBoostActive() then
        return ActiveBoost.Multiplier
    end
    return 1.0
end

function BoostManager.GetRemainingTime()
    if not BoostManager.IsBoostActive() then
        return 0
    end
    return math.max(0, ActiveBoost.EndTime - tick())
end

function BoostManager.GetBoostInfo()
    if BoostManager.IsBoostActive() then
        return {
            Active = true,
            Multiplier = ActiveBoost.Multiplier,
            RemainingTime = BoostManager.GetRemainingTime(),
            ActivatedBy = ActiveBoost.ActivatedBy
        }
    else
        return {
            Active = false,
            Multiplier = 1.0,
            RemainingTime = 0,
            ActivatedBy = nil
        }
    end
end

function BoostManager.Update()
    if ActiveBoost.Active and tick() >= ActiveBoost.EndTime then
        BoostManager.DeactivateBoost()
    end
end

function BoostManager.Init(activatedEvent, endedEvent)
    BoostActivatedEvent = activatedEvent
    BoostEndedEvent = endedEvent
end

return BoostManager
```

---

## 8️⃣ OfflineEarningsManager.lua
**Path:** ReplicatedStorage → Modules → **ModuleScript** "OfflineEarningsManager"

```lua
local Config = require(script.Parent.Config)

local OfflineEarningsManager = {}

function OfflineEarningsManager.CalculateOfflineEarnings(player, profile)
    if not profile:Get("Gamepasses").OfflineEarnings then
        return 0, 0
    end

    local currentTime = os.time()
    local lastLogin = profile:Get("LastLogin") or currentTime

    local offlineTime = currentTime - lastLogin

    if offlineTime <= 0 then
        return 0, 0
    end

    local maxOfflineSeconds = Config.Economy.MaxOfflineHours * 3600
    offlineTime = math.min(offlineTime, maxOfflineSeconds)

    local baseIncome = Config.Economy.BaseCashPerSecond
    local multiplier = 1.0

    if profile:Get("Gamepasses").x2Income then
        multiplier = multiplier * Config.Gamepasses.x2Income.Multiplier
    end

    if profile:Get("Gamepasses").AFKBoost then
        multiplier = multiplier * Config.Gamepasses.AFKBoost.Multiplier
    end

    local incomePerSecond = baseIncome * multiplier
    local totalEarnings = incomePerSecond * offlineTime

    return totalEarnings, offlineTime
end

function OfflineEarningsManager.GrantOfflineEarnings(player, profile)
    local earnings, offlineTime = OfflineEarningsManager.CalculateOfflineEarnings(player, profile)

    if earnings > 0 then
        profile:Increment("Cash", earnings)
        profile:Increment("Stats", "TotalCashEarned", earnings)
        return earnings, offlineTime
    end

    return 0, 0
end

function OfflineEarningsManager.FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60

    if hours > 0 then
        return string.format("%dh %dm", hours, minutes)
    elseif minutes > 0 then
        return string.format("%dm %ds", minutes, secs)
    else
        return string.format("%ds", secs)
    end
end

return OfflineEarningsManager
```

---

## 9️⃣ LocalLeaderboardManager.lua
**Path:** ReplicatedStorage → Modules → **ModuleScript** "LocalLeaderboardManager"

```lua
local LocalLeaderboardManager = {}

function LocalLeaderboardManager.CreateLeaderboard(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local cash = Instance.new("NumberValue")
    cash.Name = "💰 Cash"
    cash.Value = 0
    cash.Parent = leaderstats

    local afkTime = Instance.new("NumberValue")
    afkTime.Name = "⏱️ AFK Time (min)"
    afkTime.Value = 0
    afkTime.Parent = leaderstats

    return leaderstats
end

function LocalLeaderboardManager.UpdateLeaderboard(player, profile)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then return end

    local cash = leaderstats:FindFirstChild("💰 Cash")
    if cash then
        cash.Value = math.floor(profile:Get("Cash"))
    end

    local afkTime = leaderstats:FindFirstChild("⏱️ AFK Time (min)")
    if afkTime then
        afkTime.Value = math.floor(profile:Get("TotalAFKTime") / 60)
    end
end

function LocalLeaderboardManager.RemoveLeaderboard(player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        leaderstats:Destroy()
    end
end

return LocalLeaderboardManager
```

---

## 🔟 GlobalLeaderboardManager.lua
**Path:** ReplicatedStorage → Modules → **ModuleScript** "GlobalLeaderboardManager"

```lua
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Config = require(script.Parent.Config)

local GlobalLeaderboardManager = {}

local AFKTimeLeaderboard = DataStoreService:GetOrderedDataStore("GlobalLeaderboard_AFKTime")
local CashLeaderboard = DataStoreService:GetOrderedDataStore("GlobalLeaderboard_Cash")

local CachedAFKTop100 = {}
local CachedCashTop100 = {}
local LastUpdate = 0

function GlobalLeaderboardManager.UpdatePlayerScore(userId, afkTime, cash)
    pcall(function()
        AFKTimeLeaderboard:SetAsync(tostring(userId), math.floor(afkTime))
    end)

    pcall(function()
        CashLeaderboard:SetAsync(tostring(userId), math.floor(cash))
    end)
end

function GlobalLeaderboardManager.FetchTop100AFK()
    local success, pages = pcall(function()
        return AFKTimeLeaderboard:GetSortedAsync(false, 100)
    end)

    if not success then
        return CachedAFKTop100
    end

    local top100 = {}
    local entries = pages:GetCurrentPage()

    for rank, entry in ipairs(entries) do
        local userId = tonumber(entry.key)
        local afkTime = entry.value

        local username = "Unknown"
        pcall(function()
            username = Players:GetNameFromUserIdAsync(userId)
        end)

        table.insert(top100, {
            Rank = rank,
            UserId = userId,
            Username = username,
            Score = afkTime
        })
    end

    CachedAFKTop100 = top100
    return top100
end

function GlobalLeaderboardManager.FetchTop100Cash()
    local success, pages = pcall(function()
        return CashLeaderboard:GetSortedAsync(false, 100)
    end)

    if not success then
        return CachedCashTop100
    end

    local top100 = {}
    local entries = pages:GetCurrentPage()

    for rank, entry in ipairs(entries) do
        local userId = tonumber(entry.key)
        local cash = entry.value

        local username = "Unknown"
        pcall(function()
            username = Players:GetNameFromUserIdAsync(userId)
        end)

        table.insert(top100, {
            Rank = rank,
            UserId = userId,
            Username = username,
            Score = cash
        })
    end

    CachedCashTop100 = top100
    return top100
end

function GlobalLeaderboardManager.GetCachedTop100AFK()
    return CachedAFKTop100
end

function GlobalLeaderboardManager.GetCachedTop100Cash()
    return CachedCashTop100
end

function GlobalLeaderboardManager.StartUpdateLoop()
    spawn(function()
        while true do
            wait(Config.Leaderboard.UpdateInterval)

            spawn(function()
                GlobalLeaderboardManager.FetchTop100AFK()
            end)

            spawn(function()
                GlobalLeaderboardManager.FetchTop100Cash()
            end)

            LastUpdate = tick()
        end
    end)
end

function GlobalLeaderboardManager.FormatAFKTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)

    if hours > 0 then
        return string.format("%dh %dm", hours, minutes)
    else
        return string.format("%dm", minutes)
    end
end

function GlobalLeaderboardManager.FormatCash(cash)
    if cash >= 1000000000 then
        return string.format("%.1fB", cash / 1000000000)
    elseif cash >= 1000000 then
        return string.format("%.1fM", cash / 1000000)
    elseif cash >= 1000 then
        return string.format("%.1fK", cash / 1000)
    else
        return tostring(math.floor(cash))
    end
end

return GlobalLeaderboardManager
```

---

## 1️⃣1️⃣ VisualEffectsManager.lua
**Path:** ReplicatedStorage → Modules → **ModuleScript** "VisualEffectsManager"

```lua
local Config = require(script.Parent.Config)

local VisualEffectsManager = {}

function VisualEffectsManager.ApplyAura(player, rankName)
    local character = player.Character
    if not character then return end

    VisualEffectsManager.RemoveAura(player)

    local auraSettings = Config.Auras[rankName]
    if not auraSettings or not auraSettings.Enabled then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local attachment = Instance.new("Attachment")
    attachment.Name = "AuraAttachment"
    attachment.Parent = humanoidRootPart

    local particle = Instance.new("ParticleEmitter")
    particle.Name = "AuraParticle"
    particle.Color = auraSettings.ParticleColor
    particle.Size = auraSettings.Size
    particle.Transparency = auraSettings.Transparency
    particle.Lifetime = NumberRange.new(1, 2)
    particle.Rate = 20
    particle.Speed = NumberRange.new(2, 4)
    particle.SpreadAngle = Vector2.new(180, 180)
    particle.LightEmission = 1
    particle.Parent = attachment
end

function VisualEffectsManager.RemoveAura(player)
    local character = player.Character
    if not character then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local attachment = humanoidRootPart:FindFirstChild("AuraAttachment")
    if attachment then
        attachment:Destroy()
    end
end

function VisualEffectsManager.PlayRankUpEffect(player, newRank)
    local character = player.Character
    if not character then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local attachment = Instance.new("Attachment")
    attachment.Name = "RankUpAttachment"
    attachment.Parent = humanoidRootPart

    local particle = Instance.new("ParticleEmitter")
    particle.Name = "RankUpParticle"
    particle.Color = ColorSequence.new(newRank.Color)
    particle.Size = NumberSequence.new(2)
    particle.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    particle.Lifetime = NumberRange.new(1, 1.5)
    particle.Rate = 50
    particle.Speed = NumberRange.new(5, 10)
    particle.SpreadAngle = Vector2.new(180, 180)
    particle.Enabled = true
    particle.Parent = attachment

    wait(1)
    particle.Enabled = false

    game:GetService("Debris"):AddItem(attachment, 3)
end

function VisualEffectsManager.PlayCashEffect(player, amount)
    -- Placeholder per effetto cash
end

function VisualEffectsManager.OnCharacterAdded(player, rankName)
    wait(1)

    if Config.Auras[rankName] then
        VisualEffectsManager.ApplyAura(player, rankName)
    end
end

return VisualEffectsManager
```

---

# 📦 PARTE 2: SERVER SCRIPTS (2 script)

## 1️⃣ MainServer.lua
**Path:** ServerScriptService → **Script** "MainServer"

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = require(Modules.Config)
local DataManager = require(Modules.DataManager)
local CashManager = require(Modules.CashManager)
local RankManager = require(Modules.RankManager)
local GamepassManager = require(Modules.GamepassManager)
local DevProductsManager = require(Modules.DevProductsManager)
local BoostManager = require(Modules.BoostManager)
local OfflineEarningsManager = require(Modules.OfflineEarningsManager)
local LocalLeaderboardManager = require(Modules.LocalLeaderboardManager)
local GlobalLeaderboardManager = require(Modules.GlobalLeaderboardManager)
local VisualEffectsManager = require(Modules.VisualEffectsManager)

local Events = ReplicatedStorage:WaitForChild("Events")
local DataUpdatedEvent = Events:WaitForChild("DataUpdated")
local RankUpEvent = Events:WaitForChild("RankUp")
local BoostActivatedEvent = Events:WaitForChild("BoostActivated")
local BoostEndedEvent = Events:WaitForChild("BoostEnded")
local PromptGamepassEvent = Events:WaitForChild("PromptGamepass")
local PromptDevProductEvent = Events:WaitForChild("PromptDevProduct")
local TeleportToVIPEvent = Events:WaitForChild("TeleportToVIP")
local RequestDataFunction = Events:WaitForChild("RequestData")

print("==============================================")
print("DO NOTHING TO GET RICH - Server Starting...")
print("==============================================")

RankManager.Init(RankUpEvent)
BoostManager.Init(BoostActivatedEvent, BoostEndedEvent)
DevProductsManager.Init()
GlobalLeaderboardManager.StartUpdateLoop()

Players.PlayerAdded:Connect(function(player)
    print("[MainServer] Player joined: " .. player.Name)

    local profile = DataManager.LoadProfile(player)
    if not profile then
        player:Kick("Errore nel caricamento dati. Riprova.")
        return
    end

    GamepassManager.SyncGamepasses(player, profile)

    local offlineEarnings, offlineTime = OfflineEarningsManager.GrantOfflineEarnings(player, profile)

    profile:Set("LastLogin", os.time())

    CashManager.InitializePlayer(player, profile)

    LocalLeaderboardManager.CreateLeaderboard(player)
    LocalLeaderboardManager.UpdateLeaderboard(player, profile)

    RankManager.UpdatePlayerRank(player, profile)

    player.CharacterAdded:Connect(function(character)
        local rankName = profile:Get("CurrentRank")
        VisualEffectsManager.OnCharacterAdded(player, rankName)
    end)

    if offlineEarnings > 0 then
        task.wait(2)
        print(string.format("[MainServer] %s ha guadagnato %.0f cash offline",
            player.Name, offlineEarnings))
    end

    print("[MainServer] " .. player.Name .. " completamente inizializzato")
end)

Players.PlayerRemoving:Connect(function(player)
    local profile = DataManager.GetProfile(player)
    if profile then
        local afkTime = profile:Get("TotalAFKTime")
        local cash = profile:Get("Cash")
        GlobalLeaderboardManager.UpdatePlayerScore(player.UserId, afkTime, cash)

        DataManager.ReleaseProfile(player)
    end

    CashManager.RemovePlayer(player)
    GamepassManager.ClearCache(player)
end)

spawn(function()
    while true do
        task.wait(1)

        BoostManager.Update()

        local serverBoostMultiplier = BoostManager.GetCurrentMultiplier()

        for _, player in ipairs(Players:GetPlayers()) do
            local profile = DataManager.GetProfile(player)
            if profile then
                CashManager.UpdateCash(player, profile, serverBoostMultiplier)

                local _, rankChanged = RankManager.UpdatePlayerRank(player, profile)

                if rankChanged then
                    local rankName = profile:Get("CurrentRank")
                    VisualEffectsManager.ApplyAura(player, rankName)
                end

                LocalLeaderboardManager.UpdateLeaderboard(player, profile)

                DataUpdatedEvent:FireClient(player, {
                    Cash = profile:Get("Cash"),
                    AFKTime = profile:Get("TotalAFKTime"),
                    Rank = profile:Get("CurrentRank"),
                    Income = CashManager.GetCurrentIncome(player, profile, serverBoostMultiplier),
                    ServerBoost = serverBoostMultiplier > 1
                })
            end
        end
    end
end)

spawn(function()
    while true do
        task.wait(Config.DataStore.AutoSaveInterval)
        DataManager.SaveAllProfiles()
    end
end)

spawn(function()
    while true do
        task.wait(60)

        for _, player in ipairs(Players:GetPlayers()) do
            local profile = DataManager.GetProfile(player)
            if profile then
                local afkTime = profile:Get("TotalAFKTime")
                local cash = profile:Get("Cash")
                GlobalLeaderboardManager.UpdatePlayerScore(player.UserId, afkTime, cash)
            end
        end
    end
end)

PromptGamepassEvent.OnServerEvent:Connect(function(player, gamepassKey)
    GamepassManager.PromptGamepassPurchase(player, gamepassKey)
end)

PromptDevProductEvent.OnServerEvent:Connect(function(player, productKey)
    DevProductsManager.PromptPurchase(player, productKey)
end)

TeleportToVIPEvent.OnServerEvent:Connect(function(player)
    local profile = DataManager.GetProfile(player)
    if not profile then return end

    if not profile:Get("Gamepasses").VIPStatus then
        return
    end

    local vipSpawn = workspace:FindFirstChild("VIPSpawn")
    if vipSpawn and player.Character then
        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = vipSpawn.CFrame + Vector3.new(0, 5, 0)
        end
    end
end)

RequestDataFunction.OnServerInvoke = function(player)
    local profile = DataManager.GetProfile(player)
    if not profile then return nil end

    local serverBoostMultiplier = BoostManager.GetCurrentMultiplier()

    return {
        Cash = profile:Get("Cash"),
        AFKTime = profile:Get("TotalAFKTime"),
        Rank = profile:Get("CurrentRank"),
        Income = CashManager.GetCurrentIncome(player, profile, serverBoostMultiplier),
        Gamepasses = profile:Get("Gamepasses"),
        ServerBoost = BoostManager.GetBoostInfo()
    }
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamepassId, wasPurchased)
    if wasPurchased then
        local profile = DataManager.GetProfile(player)
        if profile then
            GamepassManager.OnGamepassPurchased(player, profile, gamepassId)
        end
    end
end)

DevProductsManager.SetServerBoostHandler(function(player, product)
    BoostManager.ActivateBoost(player, product.Duration, product.Multiplier)
end)

DevProductsManager.SetSkipRankHandler(function(player)
    local profile = DataManager.GetProfile(player)
    if not profile then return end

    local success, newRank = RankManager.SkipToNextRank(player, profile)
    if success then
        VisualEffectsManager.ApplyAura(player, newRank)
    end
end)

DevProductsManager.SetInstantCashHandler(function(player, amount)
    local profile = DataManager.GetProfile(player)
    if not profile then return end

    CashManager.AddCash(player, profile, amount)
    VisualEffectsManager.PlayCashEffect(player, amount)
end)

game:BindToClose(function()
    DataManager.SaveAllProfiles()
    task.wait(3)
end)

print("==============================================")
print("DO NOTHING TO GET RICH - Server Ready!")
print("==============================================")
```

---

## 2️⃣ GlobalLeaderboardDisplay.lua
**Path:** ServerScriptService → **Script** "GlobalLeaderboardDisplay"

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = require(Modules.Config)
local GlobalLeaderboardManager = require(Modules.GlobalLeaderboardManager)

local function FindOrCreateLeaderboardPart(partName, position)
    local part = workspace:FindFirstChild(partName)

    if not part then
        part = Instance.new("Part")
        part.Name = partName
        part.Size = Vector3.new(20, 30, 1)
        part.Position = position
        part.Anchored = true
        part.CanCollide = true
        part.Material = Enum.Material.SmoothPlastic
        part.BrickColor = BrickColor.new("Dark stone grey")
        part.Parent = workspace
    end

    return part
end

local AFKLeaderboardPart = FindOrCreateLeaderboardPart("GlobalLeaderboard_AFK", Vector3.new(0, 20, -50))
local CashLeaderboardPart = FindOrCreateLeaderboardPart("GlobalLeaderboard_Cash", Vector3.new(25, 20, -50))

local function CreateSurfaceGUI(part, title)
    local existingGUI = part:FindFirstChild("LeaderboardGUI")
    if existingGUI then
        existingGUI:Destroy()
    end

    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Name = "LeaderboardGUI"
    surfaceGui.Face = Enum.NormalId.Front
    surfaceGui.AlwaysOnTop = false
    surfaceGui.CanvasSize = Vector2.new(800, 1200)
    surfaceGui.Parent = part

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = surfaceGui

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 80)
    titleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    titleLabel.BorderSizePixel = 0
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    titleLabel.TextScaled = true
    titleLabel.Parent = mainFrame

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Position = UDim2.new(0, 0, 0, 80)
    scrollFrame.Size = UDim2.new(1, 0, 1, -80)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 10
    scrollFrame.Parent = mainFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = scrollFrame

    return surfaceGui, scrollFrame
end

local AFKGui, AFKScrollFrame = CreateSurfaceGUI(AFKLeaderboardPart, "🏆 TOP 100 AFK TIME 🏆")
local CashGui, CashScrollFrame = CreateSurfaceGUI(CashLeaderboardPart, "💰 TOP 100 CASH 💰")

local function CreateLeaderboardEntry(rank, username, userId, scoreText, parent)
    local frame = Instance.new("Frame")
    frame.Name = "Entry_" .. rank
    frame.Size = UDim2.new(1, -10, 0, 60)
    frame.BackgroundColor3 = rank <= 3 and Color3.fromRGB(60, 60, 0) or Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local rankLabel = Instance.new("TextLabel")
    rankLabel.Size = UDim2.new(0, 50, 1, 0)
    rankLabel.Position = UDim2.new(0, 5, 0, 0)
    rankLabel.BackgroundTransparency = 1
    rankLabel.Font = Enum.Font.GothamBold
    rankLabel.Text = "#" .. rank
    rankLabel.TextColor3 = rank == 1 and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 255, 255)
    rankLabel.TextScaled = true
    rankLabel.Parent = frame

    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Size = UDim2.new(0, 50, 0, 50)
    avatarImage.Position = UDim2.new(0, 60, 0, 5)
    avatarImage.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    avatarImage.BorderSizePixel = 0

    local success, thumbnailUrl = pcall(function()
        return Players:GetUserThumbnailAsync(
            userId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size150x150
        )
    end)

    if success then
        avatarImage.Image = thumbnailUrl
    end

    avatarImage.Parent = frame

    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Size = UDim2.new(0, 250, 1, 0)
    usernameLabel.Position = UDim2.new(0, 120, 0, 0)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Font = Enum.Font.GothamBold
    usernameLabel.Text = username
    usernameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    usernameLabel.TextScaled = true
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.Parent = frame

    local scoreLabel = Instance.new("TextLabel")
    scoreLabel.Size = UDim2.new(0, 200, 1, 0)
    scoreLabel.Position = UDim2.new(1, -210, 0, 0)
    scoreLabel.BackgroundTransparency = 1
    scoreLabel.Font = Enum.Font.GothamBold
    scoreLabel.Text = scoreText
    scoreLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    scoreLabel.TextScaled = true
    scoreLabel.TextXAlignment = Enum.TextXAlignment.Right
    scoreLabel.Parent = frame
end

local function UpdateLeaderboardDisplay(scrollFrame, entries, formatFunction)
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    for _, entry in ipairs(entries) do
        local scoreText = formatFunction(entry.Score)
        CreateLeaderboardEntry(
            entry.Rank,
            entry.Username,
            entry.UserId,
            scoreText,
            scrollFrame
        )
    end

    local listLayout = scrollFrame:FindFirstChildOfClass("UIListLayout")
    if listLayout then
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end
end

spawn(function()
    task.wait(5)

    while true do
        local afkTop100 = GlobalLeaderboardManager.GetCachedTop100AFK()
        local cashTop100 = GlobalLeaderboardManager.GetCachedTop100Cash()

        if #afkTop100 > 0 then
            UpdateLeaderboardDisplay(
                AFKScrollFrame,
                afkTop100,
                GlobalLeaderboardManager.FormatAFKTime
            )
        end

        if #cashTop100 > 0 then
            UpdateLeaderboardDisplay(
                CashScrollFrame,
                cashTop100,
                GlobalLeaderboardManager.FormatCash
            )
        end

        task.wait(Config.Leaderboard.UpdateInterval)
    end
end)
```

---

# 📦 PARTE 3: CLIENT SCRIPT

## ClientMain.lua
**Path:** StarterPlayer → StarterPlayerScripts → **LocalScript** "ClientMain"

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = require(Modules.Config)

local Events = ReplicatedStorage:WaitForChild("Events")
local DataUpdatedEvent = Events:WaitForChild("DataUpdated")
local RankUpEvent = Events:WaitForChild("RankUp")
local BoostActivatedEvent = Events:WaitForChild("BoostActivated")
local BoostEndedEvent = Events:WaitForChild("BoostEnded")
local RequestDataFunction = Events:WaitForChild("RequestData")

local PlayerData = {
    Cash = 0,
    AFKTime = 0,
    Rank = "Lazy",
    Income = 1,
    ServerBoost = false
}

local function RequestInitialData()
    local success, data = pcall(function()
        return RequestDataFunction:InvokeServer()
    end)

    if success and data then
        PlayerData = {
            Cash = data.Cash or 0,
            AFKTime = data.AFKTime or 0,
            Rank = data.Rank or "Lazy",
            Income = data.Income or 1,
            ServerBoost = data.ServerBoost.Active or false
        }
    end
end

RequestInitialData()

local HUD = playerGui:WaitForChild("HUD")
local CashLabel = HUD:WaitForChild("CashFrame"):WaitForChild("CashLabel")
local IncomeLabel = HUD:WaitForChild("CashFrame"):WaitForChild("IncomeLabel")
local RankLabel = HUD:WaitForChild("RankFrame"):WaitForChild("RankLabel")
local AFKTimeLabel = HUD:WaitForChild("AFKFrame"):WaitForChild("AFKTimeLabel")
local BoostFrame = HUD:WaitForChild("BoostFrame")
local BoostLabel = BoostFrame:WaitForChild("BoostLabel")

local function FormatNumber(num)
    if num >= 1000000000 then
        return string.format("%.2fB", num / 1000000000)
    elseif num >= 1000000 then
        return string.format("%.2fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.2fK", num / 1000)
    else
        return string.format("%.0f", num)
    end
end

local function FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)

    if hours > 0 then
        return string.format("%dh %dm %ds", hours, minutes, secs)
    elseif minutes > 0 then
        return string.format("%dm %ds", minutes, secs)
    else
        return string.format("%ds", secs)
    end
end

local function UpdateUI()
    CashLabel.Text = "💰 " .. FormatNumber(PlayerData.Cash)
    IncomeLabel.Text = "+" .. FormatNumber(PlayerData.Income) .. "/sec"
    RankLabel.Text = "🏆 " .. PlayerData.Rank
    AFKTimeLabel.Text = "⏱️ " .. FormatTime(PlayerData.AFKTime)

    if PlayerData.ServerBoost then
        BoostFrame.Visible = true
        BoostLabel.Text = "🚀 SERVER BOOST ACTIVE x2"
    else
        BoostFrame.Visible = false
    end
end

DataUpdatedEvent.OnClientEvent:Connect(function(data)
    PlayerData.Cash = data.Cash
    PlayerData.AFKTime = data.AFKTime
    PlayerData.Rank = data.Rank
    PlayerData.Income = data.Income
    PlayerData.ServerBoost = data.ServerBoost

    UpdateUI()
end)

RankUpEvent.OnClientEvent:Connect(function(rankName, rankData)
    local RankUpNotification = playerGui:WaitForChild("RankUpNotification")
    local NotifFrame = RankUpNotification:WaitForChild("Frame")
    local RankNameLabel = NotifFrame:WaitForChild("RankNameLabel")

    RankNameLabel.Text = rankName
    RankNameLabel.TextColor3 = rankData.Color or Color3.fromRGB(255, 255, 255)

    NotifFrame.Visible = true
    NotifFrame.Position = UDim2.new(0.5, 0, -0.2, 0)

    NotifFrame:TweenPosition(
        UDim2.new(0.5, 0, 0.2, 0),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Bounce,
        0.5,
        false
    )

    task.wait(3)
    NotifFrame:TweenPosition(
        UDim2.new(0.5, 0, -0.2, 0),
        Enum.EasingDirection.In,
        Enum.EasingStyle.Quad,
        0.3,
        false,
        function()
            NotifFrame.Visible = false
        end
    )
end)

BoostActivatedEvent.OnClientEvent:Connect(function(boostInfo)
    PlayerData.ServerBoost = true
    UpdateUI()
end)

BoostEndedEvent.OnClientEvent:Connect(function()
    PlayerData.ServerBoost = false
    UpdateUI()
end)

spawn(function()
    while true do
        task.wait(0.1)
        UpdateUI()
    end
end)
```

---

**CONTINUA NEL PROSSIMO FILE...**

⚠️ Ho raggiunto il limite del file. Ti mando il resto in un altro file! Dimmi quando sei pronto per la PARTE 4 (UI Scripts).
