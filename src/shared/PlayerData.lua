--[[
    LIFE TEXT RPG - Dati Giocatore
    Gestisce lo stato persistente del player.
]]

local ReputationSystem = require(script.Parent.ReputationSystem)

local PlayerData = {}

-- Struttura dati di un nuovo giocatore
function PlayerData.CreateNew(playerId)
    return {
        -- Identificazione
        playerId = playerId,
        createdAt = os.time(),
        lastLogin = os.time(),

        -- Core Stats
        reputation = ReputationSystem.START,
        previousReputation = ReputationSystem.START, -- Per tracciare cambi drastici

        -- Coerenza Morale (meccanica nascosta)
        consecutiveCelesteChoices = 0,
        consecutiveCremisiChoices = 0,
        moralInstability = 0, -- Aumenta con cambi drastici

        -- Progressione
        eventsCompleted = {},
        currentEventId = nil,
        totalEventsPlayed = 0,

        -- Titoli sbloccati (persistono tra stagioni)
        unlockedTitles = {},
        currentTitle = nil,

        -- Gilda
        guildId = nil,
        guildJoinedAt = nil,

        -- Stagione
        currentSeason = 1,
        seasonStartReputation = 0,

        -- Legacy (morte/fine run)
        deaths = 0,
        legacyBonus = 0, -- Bonus dalla run precedente
        chronicleEntries = {}, -- Nomi nelle cronache

        -- Memoria eventi (conseguenze a lungo termine)
        eventMemory = {},

        -- Statistiche
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

-- Aggiorna la reputazione e gestisce la coerenza morale
function PlayerData.UpdateReputation(playerData, delta)
    local oldRep = playerData.reputation
    playerData.previousReputation = oldRep

    -- Applica la modifica
    playerData.reputation = ReputationSystem.ModifyReputation(oldRep, delta)
    local actualDelta = playerData.reputation - oldRep

    -- Aggiorna statistiche
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

    -- Gestione coerenza morale
    PlayerData.UpdateMoralCoherence(playerData, actualDelta)

    -- Controlla nuovi titoli
    PlayerData.CheckNewTitles(playerData)

    return actualDelta
end

-- Sistema di coerenza morale (meccanica nascosta)
function PlayerData.UpdateMoralCoherence(playerData, delta)
    if delta > 0 then
        -- Scelta Celeste
        if playerData.consecutiveCremisiChoices > 3 then
            -- Cambio drastico da Cremisi a Celeste
            playerData.moralInstability = playerData.moralInstability + playerData.consecutiveCremisiChoices
        end
        playerData.consecutiveCelesteChoices = playerData.consecutiveCelesteChoices + 1
        playerData.consecutiveCremisiChoices = 0

    elseif delta < 0 then
        -- Scelta Cremisi
        if playerData.consecutiveCelesteChoices > 3 then
            -- Cambio drastico da Celeste a Cremisi
            playerData.moralInstability = playerData.moralInstability + playerData.consecutiveCelesteChoices
        end
        playerData.consecutiveCremisiChoices = playerData.consecutiveCremisiChoices + 1
        playerData.consecutiveCelesteChoices = 0
    end

    -- L'instabilità decade lentamente
    if playerData.moralInstability > 0 then
        playerData.moralInstability = math.max(0, playerData.moralInstability - 0.1)
    end
end

-- Controlla se il player ha sbloccato nuovi titoli
function PlayerData.CheckNewTitles(playerData)
    local titleData = ReputationSystem.GetTitle(playerData.reputation)

    if titleData then
        local titleKey = titleData.title

        -- Controlla se è un nuovo titolo
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

-- Ottieni bonus coerenza (per eventi narrativi)
function PlayerData.GetCoherenceBonus(playerData)
    local consecutive = math.max(
        playerData.consecutiveCelesteChoices,
        playerData.consecutiveCremisiChoices
    )

    if consecutive >= 10 then
        return 1.5, "Anima Risoluta" -- 50% bonus
    elseif consecutive >= 5 then
        return 1.25, "Determinazione" -- 25% bonus
    elseif consecutive >= 3 then
        return 1.1, "Coerenza" -- 10% bonus
    end

    return 1.0, nil
end

-- Controlla se il player è instabile (per eventi punitivi)
function PlayerData.IsUnstable(playerData)
    return playerData.moralInstability >= 5
end

-- Registra un evento nella memoria
function PlayerData.RememberEvent(playerData, eventId, choiceId, consequences)
    playerData.eventMemory[eventId] = {
        choiceId = choiceId,
        consequences = consequences,
        timestamp = os.time(),
        reputationAtTime = playerData.reputation
    }
end

-- Controlla se il player ricorda un evento
function PlayerData.RemembersEvent(playerData, eventId)
    return playerData.eventMemory[eventId] ~= nil
end

-- Ottieni la scelta fatta in un evento passato
function PlayerData.GetPastChoice(playerData, eventId)
    local memory = playerData.eventMemory[eventId]
    if memory then
        return memory.choiceId, memory.consequences
    end
    return nil, nil
end

-- Gestione morte/fine run
function PlayerData.ProcessDeath(playerData)
    local deathRecord = {
        reputation = playerData.reputation,
        faction = ReputationSystem.GetFaction(playerData.reputation),
        title = playerData.currentTitle,
        timestamp = os.time(),
        eventsPlayed = playerData.totalEventsPlayed
    }

    -- Aggiungi alle cronache
    table.insert(playerData.chronicleEntries, deathRecord)
    playerData.deaths = playerData.deaths + 1

    -- Calcola legacy bonus (5% della reputazione assoluta)
    local absRep = math.abs(playerData.reputation)
    playerData.legacyBonus = math.floor(absRep * 0.05)

    return deathRecord
end

-- Reset per nuova stagione
function PlayerData.SeasonReset(playerData, newSeasonNumber)
    playerData.currentSeason = newSeasonNumber
    playerData.seasonStartReputation = playerData.reputation

    -- Reset reputazione ma mantieni legacy bonus
    local legacyBonus = playerData.legacyBonus
    playerData.reputation = legacyBonus -- Parti con il bonus legacy

    -- Reset contatori coerenza
    playerData.consecutiveCelesteChoices = 0
    playerData.consecutiveCremisiChoices = 0
    playerData.moralInstability = 0

    -- NON resettiamo: titoli, cronache, banner gilda
end

-- Può accedere alle gilde?
function PlayerData.CanJoinGuild(playerData)
    local absRep = math.abs(playerData.reputation)
    return absRep >= ReputationSystem.Thresholds.GUILD_ACCESS
end

-- Serializza per il salvataggio
function PlayerData.Serialize(playerData)
    return game:GetService("HttpService"):JSONEncode(playerData)
end

-- Deserializza dal salvataggio
function PlayerData.Deserialize(jsonString)
    return game:GetService("HttpService"):JSONDecode(jsonString)
end

return PlayerData
