--[[
    LIFE TEXT RPG - Dati Giocatore
    Gestisce lo stato persistente del player.
]]

local PlayerData = {}

function PlayerData.CreateNew(playerId)
    return {
        playerId = playerId,
        createdAt = os.time(),
        lastLogin = os.time(),

        reputation = 0,
        previousReputation = 0,

        consecutiveCelesteChoices = 0,
        consecutiveCremisiChoices = 0,
        moralInstability = 0,

        eventsCompleted = {},
        currentEventId = nil,
        totalEventsPlayed = 0,

        unlockedTitles = {},
        currentTitle = nil,

        guildId = nil,
        guildJoinedAt = nil,

        currentSeason = 1,
        seasonStartReputation = 0,

        deaths = 0,
        legacyBonus = 0,
        chronicleEntries = {},

        eventMemory = {},

        stats = {
            totalCelesteChoices = 0,
            totalCremisiChoices = 0,
            totalNeutralChoices = 0,
            biggestSingleGain = 0,
            biggestSingleLoss = 0,
            daysPlayed = 0,
        }
    }
end

function PlayerData.UpdateReputation(playerData, delta, ReputationSystem)
    local oldRep = playerData.reputation
    playerData.previousReputation = oldRep

    playerData.reputation = ReputationSystem.ModifyReputation(oldRep, delta)
    local actualDelta = playerData.reputation - oldRep

    if actualDelta > 0 then
        playerData.stats.totalCelesteChoices = playerData.stats.totalCelesteChoices + 1
        if actualDelta > playerData.stats.biggestSingleGain then
            playerData.stats.biggestSingleGain = actualDelta
        end
    elseif actualDelta < 0 then
        playerData.stats.totalCremisiChoices = playerData.stats.totalCremisiChoices + 1
        if math.abs(actualDelta) > playerData.stats.biggestSingleLoss then
            playerData.stats.biggestSingleLoss = math.abs(actualDelta)
        end
    else
        playerData.stats.totalNeutralChoices = playerData.stats.totalNeutralChoices + 1
    end

    PlayerData.UpdateMoralCoherence(playerData, actualDelta)

    return actualDelta
end

function PlayerData.UpdateMoralCoherence(playerData, delta)
    if delta > 0 then
        if playerData.consecutiveCremisiChoices > 3 then
            playerData.moralInstability = playerData.moralInstability + playerData.consecutiveCremisiChoices
        end
        playerData.consecutiveCelesteChoices = playerData.consecutiveCelesteChoices + 1
        playerData.consecutiveCremisiChoices = 0

    elseif delta < 0 then
        if playerData.consecutiveCelesteChoices > 3 then
            playerData.moralInstability = playerData.moralInstability + playerData.consecutiveCelesteChoices
        end
        playerData.consecutiveCremisiChoices = playerData.consecutiveCremisiChoices + 1
        playerData.consecutiveCelesteChoices = 0
    end

    if playerData.moralInstability > 0 then
        playerData.moralInstability = math.max(0, playerData.moralInstability - 0.1)
    end
end

function PlayerData.CheckNewTitles(playerData, ReputationSystem)
    local titleData = ReputationSystem.GetTitle(playerData.reputation)

    if titleData then
        local titleKey = titleData.title

        if not playerData.unlockedTitles[titleKey] then
            playerData.unlockedTitles[titleKey] = {
                unlockedAt = os.time(),
                reputationAtUnlock = playerData.reputation
            }
            playerData.currentTitle = titleKey
            return true, titleData
        end
    end

    return false, nil
end

function PlayerData.GetCoherenceBonus(playerData)
    local consecutive = math.max(
        playerData.consecutiveCelesteChoices,
        playerData.consecutiveCremisiChoices
    )

    if consecutive >= 10 then
        return 1.5, "Anima Risoluta"
    elseif consecutive >= 5 then
        return 1.25, "Determinazione"
    elseif consecutive >= 3 then
        return 1.1, "Coerenza"
    end

    return 1.0, nil
end

function PlayerData.IsUnstable(playerData)
    return playerData.moralInstability >= 5
end

function PlayerData.RememberEvent(playerData, eventId, choiceId, consequences)
    playerData.eventMemory[eventId] = {
        choiceId = choiceId,
        consequences = consequences,
        timestamp = os.time(),
        reputationAtTime = playerData.reputation
    }
end

function PlayerData.RemembersEvent(playerData, eventId)
    return playerData.eventMemory[eventId] ~= nil
end

function PlayerData.ProcessDeath(playerData, ReputationSystem)
    local deathRecord = {
        reputation = playerData.reputation,
        faction = ReputationSystem.GetFaction(playerData.reputation),
        title = playerData.currentTitle,
        timestamp = os.time(),
        eventsPlayed = playerData.totalEventsPlayed
    }

    table.insert(playerData.chronicleEntries, deathRecord)
    playerData.deaths = playerData.deaths + 1

    local absRep = math.abs(playerData.reputation)
    playerData.legacyBonus = math.floor(absRep * 0.05)

    return deathRecord
end

function PlayerData.SeasonReset(playerData, newSeasonNumber)
    playerData.currentSeason = newSeasonNumber
    playerData.seasonStartReputation = playerData.reputation

    local legacyBonus = playerData.legacyBonus
    playerData.reputation = legacyBonus

    playerData.consecutiveCelesteChoices = 0
    playerData.consecutiveCremisiChoices = 0
    playerData.moralInstability = 0
end

function PlayerData.CanJoinGuild(playerData)
    local absRep = math.abs(playerData.reputation)
    return absRep >= 3000
end

return PlayerData
