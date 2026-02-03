--[[
    LIFE TEXT RPG - Sistema Eventi
    Gestisce gli eventi narrativi e le scelte.
]]

local EventSystem = {}

EventSystem.EventType = {
    DAILY = "DAILY",
    MORAL = "MORAL",
    KEY = "KEY",
    POINT_OF_NO_RETURN = "POINT_OF_NO_RETURN"
}

EventSystem.Events = {}

function EventSystem.RegisterEvent(event)
    if not event.id then
        error("Event must have an id")
    end
    EventSystem.Events[event.id] = event
end

function EventSystem.GetEvent(eventId)
    return EventSystem.Events[eventId]
end

function EventSystem.CanPlayerSeeEvent(event, playerData, PlayerDataModule)
    local req = event.requirements
    if not req then return true end

    if req.minReputation and playerData.reputation < req.minReputation then
        return false
    end

    if req.maxReputation and playerData.reputation > req.maxReputation then
        return false
    end

    if req.requiredEvents then
        for _, reqEventId in ipairs(req.requiredEvents) do
            if not PlayerDataModule.RemembersEvent(playerData, reqEventId) then
                return false
            end
        end
    end

    if req.excludedEvents then
        for _, exclEventId in ipairs(req.excludedEvents) do
            if PlayerDataModule.RemembersEvent(playerData, exclEventId) then
                return false
            end
        end
    end

    return true
end

function EventSystem.ProcessChoice(event, choiceId, playerData, ReputationSystem, PlayerDataModule)
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

    local baseChange = choice.reputationChange
    local coherenceMultiplier, coherenceName = PlayerDataModule.GetCoherenceBonus(playerData)

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

    local actualChange = PlayerDataModule.UpdateReputation(playerData, finalChange, ReputationSystem)
    result.reputationChange = actualChange
    result.newReputation = playerData.reputation

    local newTitle, titleData = PlayerDataModule.CheckNewTitles(playerData, ReputationSystem)
    if newTitle then
        result.newTitle = titleData
    end

    PlayerDataModule.RememberEvent(playerData, event.id, choiceId, {
        consequence = choice.consequence,
        reputationChange = actualChange
    })

    if choice.effects then
        result.effects = choice.effects
    end

    playerData.totalEventsPlayed = playerData.totalEventsPlayed + 1
    playerData.eventsCompleted[event.id] = true

    return true, result
end

function EventSystem.GetAvailableEvents(playerData, eventType, PlayerDataModule)
    local available = {}

    for eventId, event in pairs(EventSystem.Events) do
        if eventType and event.type ~= eventType then
            continue
        end

        if playerData.eventsCompleted[eventId] and not event.repeatable then
            continue
        end

        local canSee = EventSystem.CanPlayerSeeEvent(event, playerData, PlayerDataModule)
        if canSee then
            table.insert(available, event)
        end
    end

    return available
end

function EventSystem.GetDailyEvents(playerData, count, PlayerDataModule)
    local available = EventSystem.GetAvailableEvents(playerData, EventSystem.EventType.DAILY, PlayerDataModule)
    local selected = {}

    for i = #available, 2, -1 do
        local j = math.random(i)
        available[i], available[j] = available[j], available[i]
    end

    for i = 1, math.min(count, #available) do
        table.insert(selected, available[i])
    end

    return selected
end

function EventSystem.HasKeyEventAvailable(playerData, PlayerDataModule)
    local keyEvents = EventSystem.GetAvailableEvents(playerData, EventSystem.EventType.KEY, PlayerDataModule)
    return #keyEvents > 0, keyEvents[1]
end

function EventSystem.CheckInstabilityEvent(playerData, PlayerDataModule)
    if PlayerDataModule.IsUnstable(playerData) then
        for eventId, event in pairs(EventSystem.Events) do
            if event.triggerOnInstability then
                local canSee = EventSystem.CanPlayerSeeEvent(event, playerData, PlayerDataModule)
                if canSee then
                    return true, event
                end
            end
        end
    end
    return false, nil
end

return EventSystem
