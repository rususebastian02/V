--[[
    GLOBALLEADERBOARDMANAGER.LUA
    Gestisce la leaderboard globale Top 100 usando OrderedDataStore
    Mostra classifica AFK Time e Cash con avatar dei player
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Config = require(script.Parent.Config)

local GlobalLeaderboardManager = {}

-- OrderedDataStores
local AFKTimeLeaderboard = DataStoreService:GetOrderedDataStore("GlobalLeaderboard_AFKTime")
local CashLeaderboard = DataStoreService:GetOrderedDataStore("GlobalLeaderboard_Cash")

-- Cache
local CachedAFKTop100 = {}
local CachedCashTop100 = {}
local LastUpdate = 0

-- ==================== UPDATE PLAYER SCORE ====================

function GlobalLeaderboardManager.UpdatePlayerScore(userId, afkTime, cash)
    -- Update AFK Time leaderboard
    pcall(function()
        AFKTimeLeaderboard:SetAsync(tostring(userId), math.floor(afkTime))
    end)

    -- Update Cash leaderboard
    pcall(function()
        CashLeaderboard:SetAsync(tostring(userId), math.floor(cash))
    end)
end

-- ==================== FETCH TOP 100 ====================

function GlobalLeaderboardManager.FetchTop100AFK()
    local success, pages = pcall(function()
        return AFKTimeLeaderboard:GetSortedAsync(false, 100)
    end)

    if not success then
        warn("[GlobalLeaderboard] Errore nel fetch top 100 AFK")
        return CachedAFKTop100
    end

    local top100 = {}
    local entries = pages:GetCurrentPage()

    for rank, entry in ipairs(entries) do
        local userId = tonumber(entry.key)
        local afkTime = entry.value

        -- Fetch username
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
        warn("[GlobalLeaderboard] Errore nel fetch top 100 Cash")
        return CachedCashTop100
    end

    local top100 = {}
    local entries = pages:GetCurrentPage()

    for rank, entry in ipairs(entries) do
        local userId = tonumber(entry.key)
        local cash = entry.value

        -- Fetch username
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

-- ==================== GET CACHED ====================

function GlobalLeaderboardManager.GetCachedTop100AFK()
    return CachedAFKTop100
end

function GlobalLeaderboardManager.GetCachedTop100Cash()
    return CachedCashTop100
end

-- ==================== UPDATE LOOP ====================

function GlobalLeaderboardManager.StartUpdateLoop()
    spawn(function()
        while true do
            wait(Config.Leaderboard.UpdateInterval)

            print("[GlobalLeaderboard] Aggiornamento top 100...")

            -- Fetch in parallel
            spawn(function()
                GlobalLeaderboardManager.FetchTop100AFK()
            end)

            spawn(function()
                GlobalLeaderboardManager.FetchTop100Cash()
            end)

            LastUpdate = tick()
            print("[GlobalLeaderboard] Aggiornamento completato")
        end
    end)

    print("[GlobalLeaderboard] Update loop avviato (ogni " .. Config.Leaderboard.UpdateInterval .. "s)")
end

-- ==================== FORMAT UTILITIES ====================

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
