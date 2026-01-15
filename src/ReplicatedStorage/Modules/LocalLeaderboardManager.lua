--[[
    LOCALLEADERBOARDMANAGER.LUA
    Gestisce la leaderboard locale (Roblox leaderboard standard nel client)
    Mostra: Cash e AFK Time
]]

local LocalLeaderboardManager = {}

-- ==================== CREATE LEADERBOARD ====================

function LocalLeaderboardManager.CreateLeaderboard(player)
    -- Crea leaderstats folder
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    -- Cash value
    local cash = Instance.new("NumberValue")
    cash.Name = "💰 Cash"
    cash.Value = 0
    cash.Parent = leaderstats

    -- AFK Time value (in minuti per leggibilità)
    local afkTime = Instance.new("NumberValue")
    afkTime.Name = "⏱️ AFK Time (min)"
    afkTime.Value = 0
    afkTime.Parent = leaderstats

    print("[LocalLeaderboard] Leaderboard creata per " .. player.Name)

    return leaderstats
end

-- ==================== UPDATE LEADERBOARD ====================

function LocalLeaderboardManager.UpdateLeaderboard(player, profile)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then return end

    -- Update Cash
    local cash = leaderstats:FindFirstChild("💰 Cash")
    if cash then
        cash.Value = math.floor(profile:Get("Cash"))
    end

    -- Update AFK Time (converti da secondi a minuti)
    local afkTime = leaderstats:FindFirstChild("⏱️ AFK Time (min)")
    if afkTime then
        afkTime.Value = math.floor(profile:Get("TotalAFKTime") / 60)
    end
end

-- ==================== REMOVE LEADERBOARD ====================

function LocalLeaderboardManager.RemoveLeaderboard(player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        leaderstats:Destroy()
    end
end

return LocalLeaderboardManager
