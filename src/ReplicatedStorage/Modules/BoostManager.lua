--[[
    BOOSTMANAGER.LUA
    Gestisce i boost server-wide temporanei (acquistati via dev products)
]]

local BoostManager = {}

-- Active boost tracking
local ActiveBoost = {
    Active = false,
    Multiplier = 1.0,
    EndTime = 0,
    ActivatedBy = nil
}

-- Eventi (da settare)
local BoostActivatedEvent = nil
local BoostEndedEvent = nil

-- ==================== BOOST LOGIC ====================

function BoostManager.ActivateBoost(player, duration, multiplier)
    if ActiveBoost.Active then
        -- Estendi il boost esistente
        local remainingTime = ActiveBoost.EndTime - tick()
        ActiveBoost.EndTime = ActiveBoost.EndTime + duration

        print(string.format("[BoostManager] Boost esteso di %ds da %s (totale: %.0fs)",
            duration, player.Name, ActiveBoost.EndTime - tick()))
    else
        -- Attiva nuovo boost
        ActiveBoost.Active = true
        ActiveBoost.Multiplier = multiplier
        ActiveBoost.EndTime = tick() + duration
        ActiveBoost.ActivatedBy = player.Name

        print(string.format("[BoostManager] Boost attivato da %s: x%.1f per %ds",
            player.Name, multiplier, duration))
    end

    -- Notifica tutti i player
    if BoostActivatedEvent then
        BoostActivatedEvent:FireAllClients({
            Multiplier = ActiveBoost.Multiplier,
            EndTime = ActiveBoost.EndTime,
            ActivatedBy = player.Name
        })
    end
end

function BoostManager.DeactivateBoost()
    if not ActiveBoost.Active then return end

    ActiveBoost.Active = false
    ActiveBoost.Multiplier = 1.0
    ActiveBoost.EndTime = 0
    ActiveBoost.ActivatedBy = nil

    print("[BoostManager] Boost terminato")

    -- Notifica tutti i player
    if BoostEndedEvent then
        BoostEndedEvent:FireAllClients()
    end
end

-- ==================== GETTERS ====================

function BoostManager.IsBoostActive()
    return ActiveBoost.Active and tick() < ActiveBoost.EndTime
end

function BoostManager.GetCurrentMultiplier()
    if BoostManager.IsBoostActive() then
        return ActiveBoost.Multiplier
    end
    return 1.0
end

function BoostManager.GetRemainingTime()
    if not BoostManager.IsBoostActive() then
        return 0
    end
    return math.max(0, ActiveBoost.EndTime - tick())
end

function BoostManager.GetBoostInfo()
    if BoostManager.IsBoostActive() then
        return {
            Active = true,
            Multiplier = ActiveBoost.Multiplier,
            RemainingTime = BoostManager.GetRemainingTime(),
            ActivatedBy = ActiveBoost.ActivatedBy
        }
    else
        return {
            Active = false,
            Multiplier = 1.0,
            RemainingTime = 0,
            ActivatedBy = nil
        }
    end
end

-- ==================== UPDATE ====================

function BoostManager.Update()
    if ActiveBoost.Active and tick() >= ActiveBoost.EndTime then
        BoostManager.DeactivateBoost()
    end
end

-- ==================== INITIALIZATION ====================

function BoostManager.Init(activatedEvent, endedEvent)
    BoostActivatedEvent = activatedEvent
    BoostEndedEvent = endedEvent
    print("[BoostManager] Inizializzato")
end

return BoostManager
