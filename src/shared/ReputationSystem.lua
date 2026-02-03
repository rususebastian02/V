--[[
    LIFE TEXT RPG - Sistema Reputazione
    Il cuore assoluto del gioco.

    Range: -10.000 (Cremisi) ⇄ +10.000 (Celeste)
    Il player diventa ciò che sceglie, non ciò che dichiara.
]]

local ReputationSystem = {}

-- Costanti
ReputationSystem.MIN = -10000
ReputationSystem.MAX = 10000
ReputationSystem.START = 0

-- Soglie narrative
ReputationSystem.Thresholds = {
    FIRST_JUDGMENT = 250,      -- Primo giudizio del mondo
    FACTION_RECOGNIZED = 1000, -- Fazione riconosciuta
    GUILD_ACCESS = 3000,       -- Accesso alle gilde
    ELITE = 6000,              -- Status elite
    LEGEND = 9000,             -- Leggenda vivente
}

-- Titoli Celesti (positivi)
ReputationSystem.CelesteTitles = {
    { threshold = 1000,  title = "Protettore",         description = "Difendi chi non può difendersi" },
    { threshold = 2500,  title = "Giudice",            description = "La tua parola porta equilibrio" },
    { threshold = 5000,  title = "Redentore",          description = "Offri seconde possibilità" },
    { threshold = 7500,  title = "Martire",            description = "Sacrifichi te stesso per altri" },
    { threshold = 9500,  title = "Araldo della Luce",  description = "Sei la speranza incarnata" },
}

-- Titoli Cremisi (negativi)
ReputationSystem.CremisiTitles = {
    { threshold = -1000,  title = "Predatore",              description = "Cacci chi è più debole" },
    { threshold = -2500,  title = "Boia",                   description = "Esegui senza esitazione" },
    { threshold = -5000,  title = "Tiranno",                description = "Governi con il terrore" },
    { threshold = -7500,  title = "Flagello",               description = "Lasci solo cenere" },
    { threshold = -9500,  title = "Incarnazione del Terrore", description = "Il tuo nome non viene pronunciato" },
}

-- Determina la fazione del giocatore
function ReputationSystem.GetFaction(reputation)
    if reputation > 0 then
        return "Celeste"
    elseif reputation < 0 then
        return "Cremisi"
    else
        return "Neutrale"
    end
end

-- Ottieni il titolo corrente
function ReputationSystem.GetTitle(reputation)
    local titles
    local absRep = math.abs(reputation)

    if reputation >= 0 then
        titles = ReputationSystem.CelesteTitles
    else
        titles = ReputationSystem.CremisiTitles
    end

    local currentTitle = nil
    for _, titleData in ipairs(titles) do
        local threshold = math.abs(titleData.threshold)
        if absRep >= threshold then
            currentTitle = titleData
        end
    end

    return currentTitle
end

-- Ottieni la soglia narrativa raggiunta
function ReputationSystem.GetNarrativeStage(reputation)
    local absRep = math.abs(reputation)

    if absRep >= ReputationSystem.Thresholds.LEGEND then
        return "LEGEND", "Leggenda Vivente"
    elseif absRep >= ReputationSystem.Thresholds.ELITE then
        return "ELITE", "Elite"
    elseif absRep >= ReputationSystem.Thresholds.GUILD_ACCESS then
        return "GUILD_ACCESS", "Membro di Gilda"
    elseif absRep >= ReputationSystem.Thresholds.FACTION_RECOGNIZED then
        return "FACTION_RECOGNIZED", "Riconosciuto"
    elseif absRep >= ReputationSystem.Thresholds.FIRST_JUDGMENT then
        return "FIRST_JUDGMENT", "Giudicato"
    else
        return "UNKNOWN", "Sconosciuto"
    end
end

-- Genera descrizione dinamica del giocatore
function ReputationSystem.GetPlayerDescription(reputation)
    local faction = ReputationSystem.GetFaction(reputation)
    local absRep = math.abs(reputation)

    -- Descrizioni Celesti
    local celesteDescriptions = {
        [250] = "Qualcuno ha notato la tua gentilezza.",
        [1000] = "Sei noto per aver aiutato chi non poteva difendersi.",
        [3000] = "Il tuo nome porta conforto a chi soffre.",
        [6000] = "Le storie parlano di te come un faro nella tempesta.",
        [9000] = "Sei diventato leggenda. I bambini ascoltano le tue gesta.",
    }

    -- Descrizioni Cremisi
    local cremisiDescriptions = {
        [250] = "Qualcuno ha notato la tua freddezza.",
        [1000] = "Il tuo nome viene sussurrato, non pronunciato.",
        [3000] = "La gente attraversa la strada quando ti vede.",
        [6000] = "Le madri usano il tuo nome per spaventare i figli.",
        [9000] = "Sei diventato l'ombra. Il terrore che non ha volto.",
    }

    local descriptions = faction == "Celeste" and celesteDescriptions or cremisiDescriptions
    local result = "Nessuno ti conosce ancora."

    for threshold, desc in pairs(descriptions) do
        if absRep >= threshold then
            result = desc
        end
    end

    return result
end

-- Applica modifica reputazione con limiti
function ReputationSystem.ModifyReputation(currentRep, delta)
    local newRep = currentRep + delta
    newRep = math.max(ReputationSystem.MIN, math.min(ReputationSystem.MAX, newRep))
    return newRep
end

-- Calcola se il giocatore può accedere a una zona
function ReputationSystem.CanAccessZone(reputation, zoneType)
    local faction = ReputationSystem.GetFaction(reputation)

    if zoneType == "CELESTE_SAFE" then
        return faction == "Celeste" or faction == "Neutrale"
    elseif zoneType == "CREMISI_DARK" then
        return faction == "Cremisi" or faction == "Neutrale"
    elseif zoneType == "NEUTRAL" then
        return true
    end

    return false
end

-- Calcola il rischio di entrare in territorio opposto
function ReputationSystem.GetTerritoryRisk(reputation, zoneType)
    local faction = ReputationSystem.GetFaction(reputation)
    local absRep = math.abs(reputation)

    -- Più sei estremo, più è rischioso entrare nel territorio opposto
    if (faction == "Celeste" and zoneType == "CREMISI_DARK") or
       (faction == "Cremisi" and zoneType == "CELESTE_SAFE") then
        if absRep >= 6000 then
            return "EXTREME", "Sarai attaccato a vista"
        elseif absRep >= 3000 then
            return "HIGH", "Molto pericoloso"
        elseif absRep >= 1000 then
            return "MEDIUM", "Rischioso"
        else
            return "LOW", "Sguardi ostili"
        end
    end

    return "NONE", "Sicuro"
end

return ReputationSystem
