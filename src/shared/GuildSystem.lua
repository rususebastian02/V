--[[
    LIFE TEXT RPG - Sistema Gilde
    Endgame sociale con gilde di fazione.
    Accesso: ±3.000 reputazione minima
]]

local GuildSystem = {}

-- Requisito minimo per entrare in una gilda
GuildSystem.MIN_REPUTATION = 3000

-- Struttura gilda
--[[
Guild = {
    id = "guild_id",
    name = "Nome Gilda",
    faction = "Celeste" o "Cremisi",
    motto = "Motto della gilda",
    createdAt = timestamp,
    leaderId = userId,
    members = { userId = { joinedAt, rank, contribution } },
    totalContribution = 0,
    rank = 0, -- Ranking globale
    chronicle = {} -- Storia della gilda
}
]]

-- Ranks nella gilda
GuildSystem.Ranks = {
    RECRUIT = { name = "Recluta", minContribution = 0 },
    MEMBER = { name = "Membro", minContribution = 100 },
    VETERAN = { name = "Veterano", minContribution = 500 },
    ELITE = { name = "Elite", minContribution = 1500 },
    OFFICER = { name = "Ufficiale", minContribution = 3000 },
    LEADER = { name = "Leader", minContribution = 0 }, -- Speciale
}

-- Crea una nuova gilda
function GuildSystem.CreateGuild(guildId, name, faction, leaderId)
    if faction ~= "Celeste" and faction ~= "Cremisi" then
        return nil, "Fazione non valida"
    end

    local guild = {
        id = guildId,
        name = name,
        faction = faction,
        motto = faction == "Celeste" and "Per la Luce" or "Il Potere e' Tutto",
        createdAt = os.time(),
        leaderId = leaderId,
        members = {},
        totalContribution = 0,
        rank = 0,
        seasonRank = 0,
        chronicle = {},
        banner = "default",
    }

    -- Aggiungi il leader
    guild.members[leaderId] = {
        joinedAt = os.time(),
        rank = "LEADER",
        contribution = 0,
    }

    -- Prima voce nelle cronache
    table.insert(guild.chronicle, {
        timestamp = os.time(),
        text = name .. " e' stata fondata da un nuovo leader."
    })

    return guild
end

-- Controlla se un player puo' entrare in una gilda
function GuildSystem.CanJoinGuild(playerReputation, guildFaction)
    local absRep = math.abs(playerReputation)

    if absRep < GuildSystem.MIN_REPUTATION then
        return false, "Reputazione insufficiente (minimo: " .. GuildSystem.MIN_REPUTATION .. ")"
    end

    local playerFaction
    if playerReputation > 0 then
        playerFaction = "Celeste"
    else
        playerFaction = "Cremisi"
    end

    if playerFaction ~= guildFaction then
        return false, "Puoi unirti solo a gilde della tua fazione"
    end

    return true
end

-- Aggiungi membro alla gilda
function GuildSystem.AddMember(guild, playerId)
    if guild.members[playerId] then
        return false, "Gia' membro"
    end

    guild.members[playerId] = {
        joinedAt = os.time(),
        rank = "RECRUIT",
        contribution = 0,
    }

    table.insert(guild.chronicle, {
        timestamp = os.time(),
        text = "Un nuovo membro si e' unito alla gilda."
    })

    return true
end

-- Rimuovi membro dalla gilda
function GuildSystem.RemoveMember(guild, playerId)
    if not guild.members[playerId] then
        return false, "Non e' un membro"
    end

    if playerId == guild.leaderId then
        return false, "Il leader non puo' lasciare la gilda"
    end

    guild.members[playerId] = nil
    return true
end

-- Aggiungi contributo (dalla reputazione guadagnata)
function GuildSystem.AddContribution(guild, playerId, amount)
    local member = guild.members[playerId]
    if not member then return false end

    amount = math.abs(amount) -- Contributo sempre positivo
    member.contribution = member.contribution + amount
    guild.totalContribution = guild.totalContribution + amount

    -- Aggiorna rank del membro
    GuildSystem.UpdateMemberRank(guild, playerId)

    return true
end

-- Aggiorna il rank di un membro
function GuildSystem.UpdateMemberRank(guild, playerId)
    local member = guild.members[playerId]
    if not member or member.rank == "LEADER" then return end

    local contribution = member.contribution
    local newRank = "RECRUIT"

    if contribution >= GuildSystem.Ranks.OFFICER.minContribution then
        newRank = "OFFICER"
    elseif contribution >= GuildSystem.Ranks.ELITE.minContribution then
        newRank = "ELITE"
    elseif contribution >= GuildSystem.Ranks.VETERAN.minContribution then
        newRank = "VETERAN"
    elseif contribution >= GuildSystem.Ranks.MEMBER.minContribution then
        newRank = "MEMBER"
    end

    if newRank ~= member.rank then
        local oldRank = member.rank
        member.rank = newRank
        table.insert(guild.chronicle, {
            timestamp = os.time(),
            text = "Un membro e' stato promosso a " .. GuildSystem.Ranks[newRank].name
        })
    end
end

-- Ottieni statistiche gilda
function GuildSystem.GetGuildStats(guild)
    local memberCount = 0
    local totalContrib = 0

    for _, member in pairs(guild.members) do
        memberCount = memberCount + 1
        totalContrib = totalContrib + member.contribution
    end

    return {
        name = guild.name,
        faction = guild.faction,
        motto = guild.motto,
        memberCount = memberCount,
        totalContribution = totalContrib,
        rank = guild.rank,
        seasonRank = guild.seasonRank,
        createdAt = guild.createdAt,
    }
end

-- Ottieni membri ordinati per contributo
function GuildSystem.GetMemberRanking(guild)
    local ranking = {}

    for playerId, member in pairs(guild.members) do
        table.insert(ranking, {
            playerId = playerId,
            rank = member.rank,
            contribution = member.contribution,
            joinedAt = member.joinedAt,
        })
    end

    table.sort(ranking, function(a, b)
        return a.contribution > b.contribution
    end)

    return ranking
end

-- Aggiungi voce alle cronache
function GuildSystem.AddChronicleEntry(guild, text, playerId)
    table.insert(guild.chronicle, {
        timestamp = os.time(),
        text = text,
        playerId = playerId,
    })

    -- Mantieni solo le ultime 100 voci
    while #guild.chronicle > 100 do
        table.remove(guild.chronicle, 1)
    end
end

-- Registra un'impresa leggendaria
function GuildSystem.RecordLegendaryDeed(guild, playerName, deed)
    local text = playerName .. ": " .. deed
    GuildSystem.AddChronicleEntry(guild, text)
end

-- Reset stagionale (mantiene cronache e banner)
function GuildSystem.SeasonReset(guild)
    -- Salva rank finale della stagione
    guild.previousSeasonRank = guild.seasonRank

    -- Reset contributi ma non membership
    for playerId, member in pairs(guild.members) do
        member.contribution = 0
        if member.rank ~= "LEADER" then
            member.rank = "RECRUIT"
        end
    end

    guild.totalContribution = 0
    guild.seasonRank = 0

    table.insert(guild.chronicle, {
        timestamp = os.time(),
        text = "=== NUOVA STAGIONE ==="
    })
end

-- Confronta gilde per ranking
function GuildSystem.CompareGuilds(guildA, guildB)
    return guildA.totalContribution > guildB.totalContribution
end

-- Calcola ranking globale
function GuildSystem.CalculateRankings(allGuilds, faction)
    local factionGuilds = {}

    for _, guild in ipairs(allGuilds) do
        if not faction or guild.faction == faction then
            table.insert(factionGuilds, guild)
        end
    end

    table.sort(factionGuilds, GuildSystem.CompareGuilds)

    for i, guild in ipairs(factionGuilds) do
        guild.seasonRank = i
    end

    return factionGuilds
end

-- Ottieni descrizione rank
function GuildSystem.GetRankDescription(rank)
    local rankData = GuildSystem.Ranks[rank]
    if rankData then
        return rankData.name
    end
    return "Sconosciuto"
end

-- Missioni di gilda (struttura)
GuildSystem.GuildMissions = {
    celeste = {
        { id = "protect_weak", name = "Proteggi i Deboli", description = "Completa 5 eventi aiutando qualcuno", reward = 100 },
        { id = "spread_light", name = "Diffondi la Luce", description = "Raggiungi +500 reputazione questa settimana", reward = 150 },
        { id = "redemption", name = "Via della Redenzione", description = "Converti un membro Cremisi", reward = 300 },
    },
    cremisi = {
        { id = "show_power", name = "Mostra il Potere", description = "Completa 5 eventi con scelte oscure", reward = 100 },
        { id = "spread_fear", name = "Semina il Terrore", description = "Raggiungi -500 reputazione questa settimana", reward = 150 },
        { id = "corruption", name = "Via della Corruzione", description = "Converti un membro Celeste", reward = 300 },
    },
}

return GuildSystem
