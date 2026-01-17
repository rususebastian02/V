--[[
    CONFIG.LUA
    Configurazione centrale per "DO NOTHING TO GET RICH"
    Contiene tutti gli ID, settings e costanti del gioco
]]

local Config = {}

-- ==================== GAME SETTINGS ====================
Config.GameName = "DO NOTHING TO GET RICH"
Config.Motto = "The less you play, the richer you get."

-- ==================== ECONOMY ====================
Config.Economy = {
    -- Cash base income
    BaseCashPerSecond = 1,

    -- Scaling automatico ogni minuto
    ScalingInterval = 60, -- secondi
    ScalingMultiplier = 1.005, -- +0.5% ogni minuto
    ScalingCap = 2.0, -- massimo x2.0 dalla scaling

    -- Offline earnings cap (se player ha gamepass)
    MaxOfflineHours = 12, -- max 12 ore di earnings offline
}

-- ==================== GAMEPASS IDs ====================
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

-- ==================== DEV PRODUCTS IDs ====================
Config.DevProducts = {
    -- Boost temporanei server-wide
    Boost10Min = {
        ID = 3513599959,
        Name = "Boost 10 min",
        Price = 29,
        Duration = 600, -- 10 minuti in secondi
        Multiplier = 2.0,
        Type = "ServerBoost"
    },
    Boost1Hour = {
        ID = 3513600071,
        Name = "Boost 1h",
        Price = 200,
        Duration = 3600, -- 1 ora in secondi
        Multiplier = 2.0,
        Type = "ServerBoost"
    },

    -- Skip Rank
    SkipRank = {
        ID = 3513600561,
        Name = "Skip Rank",
        Price = 49,
        Type = "SkipRank"
    },

    -- Cash istantanei
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
    },

    -- Donazioni
    Donation10 = {
        ID = 3513602045,
        Name = "Donate 10 Robux",
        Price = 10,
        Amount = 10,
        Type = "Donation"
    },
    Donation100 = {
        ID = 3513602192,
        Name = "Donate 100 Robux",
        Price = 100,
        Amount = 100,
        Type = "Donation"
    },
    Donation1K = {
        ID = 3513602335,
        Name = "Donate 1.000 Robux",
        Price = 1000,
        Amount = 1000,
        Type = "Donation"
    },
    Donation10K = {
        ID = 3513602509,
        Name = "Donate 10.000 Robux",
        Price = 10000,
        Amount = 10000,
        Type = "Donation"
    },
    Donation100K = {
        ID = 3513602649,
        Name = "Donate 100.000 Robux",
        Price = 100000,
        Amount = 100000,
        Type = "Donation"
    }
}

-- Helper: Get dev product by ID
function Config.GetDevProductByID(productId)
    for _, product in pairs(Config.DevProducts) do
        if product.ID == productId then
            return product
        end
    end
    return nil
end

-- ==================== RANK SYSTEM ====================
Config.Ranks = {
    {Name = "Lazy", TimeRequired = 60, Color = Color3.fromRGB(150, 150, 150)}, -- 1 min
    {Name = "Chill", TimeRequired = 300, Color = Color3.fromRGB(100, 200, 255)}, -- 5 min
    {Name = "Clean", TimeRequired = 900, Color = Color3.fromRGB(255, 255, 255)}, -- 15 min
    {Name = "Rich", TimeRequired = 1800, Color = Color3.fromRGB(255, 215, 0)}, -- 30 min
    {Name = "Millionaire", TimeRequired = 3600, Color = Color3.fromRGB(255, 165, 0)}, -- 1h
    {Name = "Billionaire", TimeRequired = 10800, Color = Color3.fromRGB(255, 100, 255)}, -- 3h
    {Name = "Prince of Lazyness", TimeRequired = 21600, Color = Color3.fromRGB(138, 43, 226)}, -- 6h
    {Name = "God of Nothing", TimeRequired = 43200, Color = Color3.fromRGB(255, 0, 0)}, -- 12h
    {Name = "AFK Deity", TimeRequired = 86400, Color = Color3.fromRGB(0, 255, 255)}, -- 24h
}

-- Get rank based on AFK time
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

-- Get next rank
function Config.GetNextRank(currentRankName)
    for i, rank in ipairs(Config.Ranks) do
        if rank.Name == currentRankName then
            return Config.Ranks[i + 1]
        end
    end
    return nil
end

-- ==================== AURA SETTINGS ====================
Config.Auras = {
    -- Aura sbloccate a certi rank
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

-- ==================== LEADERBOARD SETTINGS ====================
Config.Leaderboard = {
    UpdateInterval = 300, -- Aggiorna leaderboard globale ogni 5 minuti
    Top100Entries = 100,
    LocalUpdateInterval = 5, -- Aggiorna leaderboard locale ogni 5 secondi
}

-- ==================== VIP AREA ====================
Config.VIPArea = {
    SpawnLocation = Vector3.new(0, 100, 0), -- Placeholder, da configurare in Studio
    RequiresGamepass = true
}

-- ==================== DATA STORE ====================
Config.DataStore = {
    Name = "PlayerData_V1",
    AutoSaveInterval = 60, -- Salva ogni 60 secondi
}

-- ==================== DEFAULT PLAYER DATA ====================
Config.DefaultPlayerData = {
    Cash = 0,
    TotalAFKTime = 0,
    CurrentRank = "Lazy",
    FirstJoin = os.time(),
    RobuxSpent = 0,
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
