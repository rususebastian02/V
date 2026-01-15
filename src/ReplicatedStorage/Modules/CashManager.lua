--[[
    CASHMANAGER.LUA
    Gestisce il guadagno automatico di Cash e il tracking del tempo AFK
]]

local Config = require(script.Parent.Config)

local CashManager = {}

-- Tracking per ogni player
local PlayerTracking = {}

-- ==================== INIZIALIZZAZIONE ====================

function CashManager.InitializePlayer(player, profile)
    if PlayerTracking[player.UserId] then
        warn("[CashManager] Player già inizializzato: " .. player.Name)
        return
    end

    PlayerTracking[player.UserId] = {
        Profile = profile,
        JoinTime = tick(),
        LastCashUpdate = tick(),
        LastScalingUpdate = tick(),
        CurrentScalingMultiplier = 1.0,
        IsTracking = true
    }

    print("[CashManager] Player inizializzato: " .. player.Name)
end

function CashManager.RemovePlayer(player)
    PlayerTracking[player.UserId] = nil
    print("[CashManager] Player rimosso dal tracking: " .. player.Name)
end

-- ==================== CALCOLO INCOME ====================

function CashManager.GetBaseIncome()
    return Config.Economy.BaseCashPerSecond
end

function CashManager.CalculateTotalMultiplier(player, profile, serverBoostMultiplier)
    local multiplier = 1.0

    -- Gamepass x2 Income
    if profile:Get("Gamepasses").x2Income then
        multiplier = multiplier * Config.Gamepasses.x2Income.Multiplier
    end

    -- Gamepass AFK Boost
    if profile:Get("Gamepasses").AFKBoost then
        multiplier = multiplier * Config.Gamepasses.AFKBoost.Multiplier
    end

    -- Server Boost (da dev products)
    if serverBoostMultiplier and serverBoostMultiplier > 1 then
        multiplier = multiplier * serverBoostMultiplier
    end

    -- Scaling multiplier (tempo-based)
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

-- ==================== UPDATE LOOP ====================

function CashManager.UpdateScaling(player)
    local tracking = PlayerTracking[player.UserId]
    if not tracking then return end

    local timeSinceLastScaling = tick() - tracking.LastScalingUpdate

    -- Ogni minuto, aumenta lo scaling
    if timeSinceLastScaling >= Config.Economy.ScalingInterval then
        local intervals = math.floor(timeSinceLastScaling / Config.Economy.ScalingInterval)

        -- Applica scaling
        for i = 1, intervals do
            tracking.CurrentScalingMultiplier = tracking.CurrentScalingMultiplier * Config.Economy.ScalingMultiplier

            -- Cap al massimo
            if tracking.CurrentScalingMultiplier > Config.Economy.ScalingCap then
                tracking.CurrentScalingMultiplier = Config.Economy.ScalingCap
                break
            end
        end

        tracking.LastScalingUpdate = tick()

        print(string.format("[CashManager] Scaling aggiornato per %s: x%.2f",
            player.Name, tracking.CurrentScalingMultiplier))
    end
end

function CashManager.UpdateCash(player, profile, serverBoostMultiplier)
    local tracking = PlayerTracking[player.UserId]
    if not tracking or not tracking.IsTracking then return end

    local now = tick()
    local deltaTime = now - tracking.LastCashUpdate

    -- Update scaling
    CashManager.UpdateScaling(player)

    -- Calcola cash da aggiungere
    local income = CashManager.CalculateIncome(player, profile, serverBoostMultiplier)
    local cashToAdd = income * deltaTime

    -- Aggiungi cash
    profile:Increment("Cash", cashToAdd)
    profile:Increment("Stats", "TotalCashEarned", cashToAdd)

    -- Update AFK time
    profile:Increment("TotalAFKTime", deltaTime)
    profile:Increment("Stats", "TotalPlayTime", deltaTime)

    tracking.LastCashUpdate = now

    return cashToAdd, income
end

-- ==================== STATS ====================

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

-- ==================== MANUAL OPERATIONS ====================

function CashManager.AddCash(player, profile, amount)
    if amount <= 0 then return false end
    profile:Increment("Cash", amount)
    profile:Increment("Stats", "TotalCashEarned", amount)
    print(string.format("[CashManager] Aggiunto %.0f cash a %s", amount, player.Name))
    return true
end

function CashManager.RemoveCash(player, profile, amount)
    if amount <= 0 then return false end
    local currentCash = profile:Get("Cash")
    if currentCash < amount then return false end

    profile:Set("Cash", currentCash - amount)
    print(string.format("[CashManager] Rimosso %.0f cash da %s", amount, player.Name))
    return true
end

return CashManager
