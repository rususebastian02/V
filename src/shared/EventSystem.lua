--[[
    LIFE TEXT RPG - Sistema Eventi
    Gestisce gli eventi narrativi e le scelte del giocatore.

    Tipi di eventi:
    - DAILY: Piccole scelte quotidiane (+/- 10-30)
    - MORAL: Scelte difficili (+/- 50-150)
    - KEY: Cambiano la run (+/- 300-700)
    - POINT_OF_NO_RETURN: Bloccano contenuti
]]

local ReputationSystem = require(script.Parent.ReputationSystem)
local PlayerData = require(script.Parent.PlayerData)

local EventSystem = {}

-- Tipi di evento
EventSystem.EventType = {
    DAILY = "DAILY",
    MORAL = "MORAL",
    KEY = "KEY",
    POINT_OF_NO_RETURN = "POINT_OF_NO_RETURN"
}

-- Range di reputazione per tipo
EventSystem.ReputationRanges = {
    DAILY = { min = 10, max = 30 },
    MORAL = { min = 50, max = 150 },
    KEY = { min = 300, max = 700 },
    POINT_OF_NO_RETURN = { min = 500, max = 1000 }
}

-- Struttura di un evento
--[[
Event = {
    id = "unique_id",
    type = EventType,
    title = "Titolo evento",
    context = "Descrizione della situazione...",

    -- Requisiti per vedere l'evento
    requirements = {
        minReputation = nil,
        maxReputation = nil,
        faction = nil, -- "Celeste", "Cremisi", o nil per tutti
        requiredEvents = {}, -- Eventi che devono essere stati completati
        excludedEvents = {}, -- Eventi che NON devono essere stati completati
        minCoherence = nil, -- Minimo di scelte consecutive
    },

    -- Scelte disponibili
    choices = {
        {
            id = "choice_1",
            text = "Testo della scelta...",
            reputationChange = 50, -- Positivo = Celeste, Negativo = Cremisi
            consequence = "Descrizione della conseguenza...",

            -- Effetti aggiuntivi
            effects = {
                unlockEvent = nil, -- Sblocca un evento futuro
                blockEvent = nil, -- Blocca un evento futuro
                setFlag = nil, -- Imposta un flag nella memoria
                triggerEvent = nil, -- Triggera immediatamente un altro evento
            }
        },
        -- ... altre scelte
    },

    -- Memoria a lungo termine
    rememberedAs = "Breve descrizione per riferimenti futuri",

    -- NPC coinvolti (per reazioni future)
    involvedNPCs = {}
}
]]

-- Registro eventi (verrà popolato da StoryEvents.lua)
EventSystem.Events = {}

-- Registra un nuovo evento
function EventSystem.RegisterEvent(event)
    if not event.id then
        error("Event must have an id")
    end
    EventSystem.Events[event.id] = event
end

-- Ottieni un evento per ID
function EventSystem.GetEvent(eventId)
    return EventSystem.Events[eventId]
end

-- Controlla se un player può vedere un evento
function EventSystem.CanPlayerSeeEvent(event, playerData)
    local req = event.requirements
    if not req then return true end

    -- Controlla reputazione minima
    if req.minReputation and playerData.reputation < req.minReputation then
        return false, "Reputazione troppo bassa"
    end

    -- Controlla reputazione massima
    if req.maxReputation and playerData.reputation > req.maxReputation then
        return false, "Reputazione troppo alta"
    end

    -- Controlla fazione
    if req.faction then
        local playerFaction = ReputationSystem.GetFaction(playerData.reputation)
        if playerFaction ~= req.faction then
            return false, "Fazione non corrispondente"
        end
    end

    -- Controlla eventi richiesti
    if req.requiredEvents then
        for _, reqEventId in ipairs(req.requiredEvents) do
            if not PlayerData.RemembersEvent(playerData, reqEventId) then
                return false, "Evento prerequisito mancante"
            end
        end
    end

    -- Controlla eventi esclusi
    if req.excludedEvents then
        for _, exclEventId in ipairs(req.excludedEvents) do
            if PlayerData.RemembersEvent(playerData, exclEventId) then
                return false, "Evento già completato in modo incompatibile"
            end
        end
    end

    -- Controlla coerenza minima
    if req.minCoherence then
        local maxConsecutive = math.max(
            playerData.consecutiveCelesteChoices,
            playerData.consecutiveCremisiChoices
        )
        if maxConsecutive < req.minCoherence then
            return false, "Coerenza morale insufficiente"
        end
    end

    return true
end

-- Processa una scelta del giocatore
function EventSystem.ProcessChoice(event, choiceId, playerData)
    local choice = nil
    for _, c in ipairs(event.choices) do
        if c.id == choiceId then
            choice = c
            break
        end
    end

    if not choice then
        return false, "Scelta non valida"
    end

    local result = {
        eventId = event.id,
        choiceId = choiceId,
        choiceText = choice.text,
        consequence = choice.consequence,
        reputationChange = 0,
        newReputation = playerData.reputation,
        newTitle = nil,
        coherenceBonus = nil,
        effects = {}
    }

    -- Calcola il cambio di reputazione con bonus coerenza
    local baseChange = choice.reputationChange
    local coherenceMultiplier, coherenceName = PlayerData.GetCoherenceBonus(playerData)

    -- Applica bonus solo se la scelta è coerente con la direzione attuale
    local isCoherent = false
    if baseChange > 0 and playerData.consecutiveCelesteChoices > 0 then
        isCoherent = true
    elseif baseChange < 0 and playerData.consecutiveCremisiChoices > 0 then
        isCoherent = true
    end

    local finalChange = baseChange
    if isCoherent and coherenceMultiplier > 1 then
        finalChange = math.floor(baseChange * coherenceMultiplier)
        result.coherenceBonus = {
            name = coherenceName,
            multiplier = coherenceMultiplier,
            bonusAmount = finalChange - baseChange
        }
    end

    -- Applica la modifica
    local actualChange = PlayerData.UpdateReputation(playerData, finalChange)
    result.reputationChange = actualChange
    result.newReputation = playerData.reputation

    -- Controlla nuovo titolo
    local newTitle, titleData = PlayerData.CheckNewTitles(playerData)
    if newTitle then
        result.newTitle = titleData
    end

    -- Registra nella memoria
    PlayerData.RememberEvent(playerData, event.id, choiceId, {
        consequence = choice.consequence,
        reputationChange = actualChange
    })

    -- Processa effetti aggiuntivi
    if choice.effects then
        result.effects = choice.effects
    end

    -- Aggiorna contatore eventi
    playerData.totalEventsPlayed = playerData.totalEventsPlayed + 1
    playerData.eventsCompleted[event.id] = true

    return true, result
end

-- Ottieni eventi disponibili per un player
function EventSystem.GetAvailableEvents(playerData, eventType)
    local available = {}

    for eventId, event in pairs(EventSystem.Events) do
        -- Filtra per tipo se specificato
        if eventType and event.type ~= eventType then
            continue
        end

        -- Non mostrare eventi già completati (a meno che non siano ripetibili)
        if playerData.eventsCompleted[eventId] and not event.repeatable then
            continue
        end

        -- Controlla requisiti
        local canSee, reason = EventSystem.CanPlayerSeeEvent(event, playerData)
        if canSee then
            table.insert(available, event)
        end
    end

    return available
end

-- Genera testo narrativo basato sulla fazione
function EventSystem.GetNarrativeText(text, playerData)
    local faction = ReputationSystem.GetFaction(playerData.reputation)

    -- Sostituzioni dinamiche
    text = string.gsub(text, "{FACTION}", faction)
    text = string.gsub(text, "{TITLE}", playerData.currentTitle or "Sconosciuto")

    -- Descrizione dinamica
    local description = ReputationSystem.GetPlayerDescription(playerData.reputation)
    text = string.gsub(text, "{DESCRIPTION}", description)

    return text
end

-- Ottieni eventi casuali del giorno
function EventSystem.GetDailyEvents(playerData, count)
    local available = EventSystem.GetAvailableEvents(playerData, EventSystem.EventType.DAILY)
    local selected = {}

    -- Mescola e prendi i primi 'count' eventi
    for i = #available, 2, -1 do
        local j = math.random(i)
        available[i], available[j] = available[j], available[i]
    end

    for i = 1, math.min(count, #available) do
        table.insert(selected, available[i])
    end

    return selected
end

-- Controlla se c'è un evento chiave disponibile
function EventSystem.HasKeyEventAvailable(playerData)
    local keyEvents = EventSystem.GetAvailableEvents(playerData, EventSystem.EventType.KEY)
    return #keyEvents > 0, keyEvents[1]
end

-- Controlla eventi di instabilità (per player che cambiano spesso)
function EventSystem.CheckInstabilityEvent(playerData)
    if PlayerData.IsUnstable(playerData) then
        -- Cerca un evento specifico per l'instabilità
        local instabilityEvents = {}
        for eventId, event in pairs(EventSystem.Events) do
            if event.triggerOnInstability then
                local canSee = EventSystem.CanPlayerSeeEvent(event, playerData)
                if canSee then
                    table.insert(instabilityEvents, event)
                end
            end
        end

        if #instabilityEvents > 0 then
            return true, instabilityEvents[math.random(#instabilityEvents)]
        end
    end

    return false, nil
end

return EventSystem
