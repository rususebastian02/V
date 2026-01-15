--[[
    OFFLINEEARNINGSMANAGER.LUA
    Calcola e assegna earnings offline per player con il gamepass "Offline Earnings"
]]

local Config = require(script.Parent.Config)

local OfflineEarningsManager = {}

-- ==================== CALCULATE OFFLINE EARNINGS ====================

function OfflineEarningsManager.CalculateOfflineEarnings(player, profile)
    -- Check se player ha il gamepass
    if not profile:Get("Gamepasses").OfflineEarnings then
        return 0, 0 -- nessun earning offline
    end

    local currentTime = os.time()
    local lastLogin = profile:Get("LastLogin") or currentTime

    -- Calcola tempo offline in secondi
    local offlineTime = currentTime - lastLogin

    if offlineTime <= 0 then
        return 0, 0 -- player appena loggato o errore timestamp
    end

    -- Cap al massimo (12 ore di default)
    local maxOfflineSeconds = Config.Economy.MaxOfflineHours * 3600
    offlineTime = math.min(offlineTime, maxOfflineSeconds)

    -- Calcola income rate (usa i moltiplicatori gamepass del player, ma NON boost temporanei)
    local baseIncome = Config.Economy.BaseCashPerSecond
    local multiplier = 1.0

    -- x2 Income gamepass
    if profile:Get("Gamepasses").x2Income then
        multiplier = multiplier * Config.Gamepasses.x2Income.Multiplier
    end

    -- AFK Boost gamepass
    if profile:Get("Gamepasses").AFKBoost then
        multiplier = multiplier * Config.Gamepasses.AFKBoost.Multiplier
    end

    local incomePerSecond = baseIncome * multiplier
    local totalEarnings = incomePerSecond * offlineTime

    print(string.format("[OfflineEarnings] %s era offline per %.0f secondi (%.2f ore)",
        player.Name, offlineTime, offlineTime / 3600))
    print(string.format("[OfflineEarnings] Income rate: %.2f/sec, Total earnings: %.0f",
        incomePerSecond, totalEarnings))

    return totalEarnings, offlineTime
end

-- ==================== GRANT OFFLINE EARNINGS ====================

function OfflineEarningsManager.GrantOfflineEarnings(player, profile)
    local earnings, offlineTime = OfflineEarningsManager.CalculateOfflineEarnings(player, profile)

    if earnings > 0 then
        -- Aggiungi cash
        profile:Increment("Cash", earnings)
        profile:Increment("Stats", "TotalCashEarned", earnings)

        print(string.format("[OfflineEarnings] Assegnato %.0f cash a %s per %s di offline",
            earnings, player.Name, OfflineEarningsManager.FormatTime(offlineTime)))

        return earnings, offlineTime
    end

    return 0, 0
end

-- ==================== UTILITY ====================

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
