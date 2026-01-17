--[[
    GLOBALLEADERBOARDMANAGER.LUA
    Gestisce 3 leaderboard globali Top 100 usando OrderedDataStore:
    - AFK Time
    - Cash
    - Robux Spent
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Config = require(script.Parent.Config)

local GlobalLeaderboardManager = {}

-- OrderedDataStores
local AFKTimeLeaderboard = DataStoreService:GetOrderedDataStore("GlobalLeaderboard_AFKTime")
local CashLeaderboard = DataStoreService:GetOrderedDataStore("GlobalLeaderboard_Cash")
local RobuxSpentLeaderboard = DataStoreService:GetOrderedDataStore("GlobalLeaderboard_RobuxSpent")

-- Cache
local CachedAFKTop100 = {}
local CachedCashTop100 = {}
local CachedRobuxSpentTop100 = {}
local LastUpdate = 0

-- ==================== UPDATE PLAYER SCORE ====================

function GlobalLeaderboardManager.UpdatePlayerScore(userId, playerName, afkTime, cash, robuxSpent)
    -- Update AFK Time leaderboard
    pcall(function()
        AFKTimeLeaderboard:SetAsync(tostring(userId), math.floor(afkTime or 0))
    end)

    -- Update Cash leaderboard
    pcall(function()
        CashLeaderboard:SetAsync(tostring(userId), math.floor(cash or 0))
    end)

    -- Update RobuxSpent leaderboard
    pcall(function()
        RobuxSpentLeaderboard:SetAsync(tostring(userId), math.floor(robuxSpent or 0))
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
        local username = "Player_" .. userId
        local success, fetchedName = pcall(function()
            return Players:GetNameFromUserIdAsync(userId)
        end)

        if success and fetchedName then
            username = fetchedName
            print("[GlobalLeaderboard] Fetched username for " .. userId .. ": " .. username)
        else
            warn("[GlobalLeaderboard] Fallito fetch username per userId: " .. userId)
        end

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
        local username = "Player_" .. userId
        local success, fetchedName = pcall(function()
            return Players:GetNameFromUserIdAsync(userId)
        end)

        if success and fetchedName then
            username = fetchedName
        else
            warn("[GlobalLeaderboard] Fallito fetch username per userId: " .. userId)
        end

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

function GlobalLeaderboardManager.FetchTop100RobuxSpent()
    local success, pages = pcall(function()
        return RobuxSpentLeaderboard:GetSortedAsync(false, 100)
    end)

    if not success then
        warn("[GlobalLeaderboard] Errore nel fetch top 100 RobuxSpent")
        return CachedRobuxSpentTop100
    end

    local top100 = {}
    local entries = pages:GetCurrentPage()

    for rank, entry in ipairs(entries) do
        local userId = tonumber(entry.key)
        local robuxSpent = entry.value

        -- Fetch username
        local username = "Player_" .. userId
        local success, fetchedName = pcall(function()
            return Players:GetNameFromUserIdAsync(userId)
        end)

        if success and fetchedName then
            username = fetchedName
        else
            warn("[GlobalLeaderboard] Fallito fetch username per userId: " .. userId)
        end

        table.insert(top100, {
            Rank = rank,
            UserId = userId,
            Username = username,
            Score = robuxSpent
        })
    end

    CachedRobuxSpentTop100 = top100
    return top100
end

-- ==================== GET CACHED ====================

function GlobalLeaderboardManager.GetCachedTop100AFK()
    return CachedAFKTop100
end

function GlobalLeaderboardManager.GetCachedTop100Cash()
    return CachedCashTop100
end

function GlobalLeaderboardManager.GetCachedTop100RobuxSpent()
    return CachedRobuxSpentTop100
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

            spawn(function()
                GlobalLeaderboardManager.FetchTop100RobuxSpent()
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

function GlobalLeaderboardManager.FormatRobux(robux)
    if robux >= 1000000 then
        return string.format("%.1fM R$", robux / 1000000)
    elseif robux >= 1000 then
        return string.format("%.1fK R$", robux / 1000)
    else
        return tostring(math.floor(robux)) .. " R$"
    end
end

return GlobalLeaderboardManager
