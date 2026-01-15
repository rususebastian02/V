--[[
    RANKMANAGER.LUA
    Gestisce il sistema di rank basato sul tempo AFK
    Lazy → Chill → Clean → Rich → Millionaire → Billionaire → Prince of Lazyness → God of Nothing → AFK Deity
]]

local Config = require(script.Parent.Config)

local RankManager = {}

-- Eventi per rank up (da creare in ReplicatedStorage/Events)
local RankUpEvent = nil

-- ==================== RANK LOGIC ====================

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
        -- Rank massimo raggiunto
        return 1.0, currentRank, nil
    end

    local timeInCurrentRank = afkTime - currentRank.TimeRequired
    local timeNeededForNext = nextRank.TimeRequired - currentRank.TimeRequired
    local progress = timeInCurrentRank / timeNeededForNext

    return math.clamp(progress, 0, 1), currentRank, nextRank
end

-- ==================== UPDATE RANK ====================

function RankManager.UpdatePlayerRank(player, profile)
    local afkTime = profile:Get("TotalAFKTime")
    local currentRankName = profile:Get("CurrentRank")

    -- Calcola rank attuale basato sul tempo
    local newRank = RankManager.GetCurrentRank(afkTime)

    -- Check se player ha VIP Status gamepass
    if profile:Get("Gamepasses").VIPStatus then
        -- VIP Status override (rank speciale)
        if currentRankName ~= "VIP" then
            profile:Set("CurrentRank", "VIP")
            print("[RankManager] " .. player.Name .. " ha ottenuto VIP Status!")

            -- Fire rank up event
            if RankUpEvent then
                RankUpEvent:FireClient(player, "VIP", {
                    Name = "VIP",
                    Color = Color3.fromRGB(255, 215, 0)
                })
            end
        end
        return "VIP"
    end

    -- Check se rank è cambiato
    if newRank.Name ~= currentRankName then
        local oldRank = currentRankName
        profile:Set("CurrentRank", newRank.Name)

        -- Update highest rank
        local highestRank = profile:Get("Stats").HighestRank or "Lazy"
        if RankManager.IsRankHigher(newRank.Name, highestRank) then
            local stats = profile:Get("Stats")
            stats.HighestRank = newRank.Name
            profile:Set("Stats", stats)
        end

        print(string.format("[RankManager] %s ha raggiunto il rank: %s (era: %s)",
            player.Name, newRank.Name, oldRank))

        -- Fire rank up event
        if RankUpEvent then
            RankUpEvent:FireClient(player, newRank.Name, newRank)
        end

        return newRank.Name, true -- Rank changed
    end

    return currentRankName, false
end

-- ==================== SKIP RANK ====================

function RankManager.SkipToNextRank(player, profile)
    local currentRankName = profile:Get("CurrentRank")

    -- Se è VIP, non può skippare
    if currentRankName == "VIP" then
        return false, "VIP Status è il rank massimo speciale!"
    end

    local nextRank = Config.GetNextRank(currentRankName)

    if not nextRank then
        return false, "Sei già al rank massimo!"
    end

    -- Aggiorna il tempo AFK per matchare il requirement del prossimo rank
    local currentAFKTime = profile:Get("TotalAFKTime")
    local newAFKTime = math.max(currentAFKTime, nextRank.TimeRequired)

    profile:Set("TotalAFKTime", newAFKTime)
    profile:Set("CurrentRank", nextRank.Name)

    -- Update highest rank
    local stats = profile:Get("Stats")
    if RankManager.IsRankHigher(nextRank.Name, stats.HighestRank or "Lazy") then
        stats.HighestRank = nextRank.Name
        profile:Set("Stats", stats)
    end

    print(string.format("[RankManager] %s ha skippato al rank: %s", player.Name, nextRank.Name))

    -- Fire rank up event
    if RankUpEvent then
        RankUpEvent:FireClient(player, nextRank.Name, nextRank)
    end

    return true, nextRank.Name
end

-- ==================== UTILITY ====================

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

-- ==================== INITIALIZATION ====================

function RankManager.Init(rankUpRemoteEvent)
    RankUpEvent = rankUpRemoteEvent
    print("[RankManager] Inizializzato")
end

return RankManager
