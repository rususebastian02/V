--[[
    ROBLOX ROUND SYSTEM
    Sistema di round completo con countdown, gestione spettatori e leaderboard

    ISTRUZIONI INSTALLAZIONE:
    1. Metti questo script in ServerScriptService
    2. Metti RoundManager.lua in ReplicatedStorage
    3. Crea le zone necessarie nella Workspace (vedi sotto)
    4. Configura i parametri nella sezione CONFIG
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- ==================== CONFIGURAZIONE ====================
local CONFIG = {
    -- Durata del countdown prima dell'inizio del round (secondi)
    COUNTDOWN_TIME = 10,

    -- Tempo minimo tra un round e l'altro (secondi)
    INTERMISSION_TIME = 5,

    -- Tempo massimo di un round (secondi, 0 = infinito)
    MAX_ROUND_TIME = 300,

    -- Minimo numero di giocatori per iniziare
    MIN_PLAYERS = 2,
}

-- ==================== ZONE NELLA WORKSPACE ====================
-- Assicurati di avere queste cartelle/zone nella Workspace:
-- Workspace.SpawnZone (dove i giocatori spawnano all'inizio del round)
-- Workspace.SpectatorZone (dove vanno gli spettatori)
-- Workspace.GameArea (area di gioco, opzionale)

local SpawnZone = Workspace:WaitForChild("SpawnZone", 10)
local SpectatorZone = Workspace:WaitForChild("SpectatorZone", 10)

-- ==================== REMOTE EVENTS ====================
-- Crea RemoteEvents per comunicazione client-server
local RemoteEventsFolder = Instance.new("Folder")
RemoteEventsFolder.Name = "RoundEvents"
RemoteEventsFolder.Parent = ReplicatedStorage

local CountdownEvent = Instance.new("RemoteEvent")
CountdownEvent.Name = "CountdownEvent"
CountdownEvent.Parent = RemoteEventsFolder

local RoundStatusEvent = Instance.new("RemoteEvent")
RoundStatusEvent.Name = "RoundStatusEvent"
RoundStatusEvent.Parent = RemoteEventsFolder

local LeaderboardEvent = Instance.new("RemoteEvent")
LeaderboardEvent.Name = "LeaderboardEvent"
LeaderboardEvent.Parent = RemoteEventsFolder

-- ==================== VARIABILI GLOBALI ====================
local RoundInProgress = false
local PlayersInRound = {}
local PlayerStats = {} -- {Player = {survivalTime = 0, status = "alive"}}
local RoundStartTime = 0

-- ==================== FUNZIONI UTILITÀ ====================

-- Crea zone di default se non esistono
local function CreateDefaultZones()
    if not SpawnZone then
        SpawnZone = Instance.new("Part")
        SpawnZone.Name = "SpawnZone"
        SpawnZone.Size = Vector3.new(50, 1, 50)
        SpawnZone.Position = Vector3.new(0, 10, 0)
        SpawnZone.Anchored = true
        SpawnZone.Transparency = 0.5
        SpawnZone.BrickColor = BrickColor.new("Bright green")
        SpawnZone.Parent = Workspace
        print("[RoundSystem] SpawnZone creata automaticamente")
    end

    if not SpectatorZone then
        SpectatorZone = Instance.new("Part")
        SpectatorZone.Name = "SpectatorZone"
        SpectatorZone.Size = Vector3.new(30, 1, 30)
        SpectatorZone.Position = Vector3.new(0, 50, 0)
        SpectatorZone.Anchored = true
        SpectatorZone.Transparency = 0.5
        SpectatorZone.BrickColor = BrickColor.new("Bright blue")
        SpectatorZone.Parent = Workspace
        print("[RoundSystem] SpectatorZone creata automaticamente")
    end
end

-- Ottiene una posizione random in una zona
local function GetRandomPositionInZone(zone)
    if not zone then return Vector3.new(0, 10, 0) end

    local size = zone.Size
    local position = zone.Position

    local randomX = position.X + math.random(-size.X/2, size.X/2)
    local randomZ = position.Z + math.random(-size.Z/2, size.Z/2)
    local y = position.Y + size.Y/2 + 5

    return Vector3.new(randomX, y, randomZ)
end

-- Teleporta un giocatore in una zona
local function TeleportPlayerToZone(player, zone, isSpectator)
    if not player or not player.Character then return end

    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local position = GetRandomPositionInZone(zone)
    humanoidRootPart.CFrame = CFrame.new(position)

    if isSpectator then
        print("[RoundSystem] " .. player.Name .. " teleportato nella zona spettatori")
    else
        print("[RoundSystem] " .. player.Name .. " teleportato nella zona di gioco")
    end
end

-- Resetta il personaggio di un giocatore
local function ResetCharacter(player)
    if player and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end
end

-- ==================== GESTIONE GIOCATORI ====================

-- Inizializza stats per un nuovo giocatore
local function InitializePlayerStats(player)
    PlayerStats[player] = {
        survivalTime = 0,
        status = "waiting",
        eliminationTime = 0
    }
end

-- Gestisce nuovi giocatori che entrano
Players.PlayerAdded:Connect(function(player)
    InitializePlayerStats(player)

    player.CharacterAdded:Connect(function(character)
        if RoundInProgress and not PlayersInRound[player] then
            -- Round in corso, manda in spettatore
            wait(0.5) -- Aspetta che il personaggio sia pronto
            TeleportPlayerToZone(player, SpectatorZone, true)
            PlayerStats[player].status = "spectating"
            print("[RoundSystem] " .. player.Name .. " entra come spettatore")
        end
    end)

    print("[RoundSystem] " .. player.Name .. " è entrato nel gioco")
end)

-- Gestisce giocatori che escono
Players.PlayerRemoving:Connect(function(player)
    PlayersInRound[player] = nil
    PlayerStats[player] = nil
    print("[RoundSystem] " .. player.Name .. " ha lasciato il gioco")
end)

-- ==================== LOGICA DEL ROUND ====================

-- Conta i giocatori vivi nel round
local function CountAlivePlayers()
    local count = 0
    for player, _ in pairs(PlayersInRound) do
        if player and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                count = count + 1
            end
        end
    end
    return count
end

-- Ottiene il giocatore vincitore
local function GetWinner()
    for player, _ in pairs(PlayersInRound) do
        if player and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                return player
            end
        end
    end
    return nil
end

-- Monitora la morte dei giocatori
local function SetupDeathMonitoring(player)
    if not player.Character then return end

    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    humanoid.Died:Connect(function()
        if RoundInProgress and PlayersInRound[player] then
            local survivalTime = tick() - RoundStartTime
            PlayerStats[player].survivalTime = survivalTime
            PlayerStats[player].status = "eliminated"
            PlayerStats[player].eliminationTime = tick()

            print("[RoundSystem] " .. player.Name .. " è stato eliminato dopo " .. math.floor(survivalTime) .. " secondi")

            -- Teleporta in spettatore dopo la morte
            wait(3)
            if player and player.Parent then
                player:LoadCharacter()
                wait(0.5)
                TeleportPlayerToZone(player, SpectatorZone, true)
            end
        end
    end)
end

-- Countdown prima del round
local function StartCountdown()
    print("[RoundSystem] Countdown iniziato!")

    for i = CONFIG.COUNTDOWN_TIME, 1, -1 do
        CountdownEvent:FireAllClients(i)
        print("[RoundSystem] Countdown: " .. i)
        wait(1)
    end

    CountdownEvent:FireAllClients(0)
    print("[RoundSystem] Il round sta per iniziare!")
    wait(1)
end

-- Prepara i giocatori per il round
local function PreparePlayersForRound()
    PlayersInRound = {}

    for _, player in pairs(Players:GetPlayers()) do
        PlayerStats[player].survivalTime = 0
        PlayerStats[player].status = "alive"
        PlayerStats[player].eliminationTime = 0

        PlayersInRound[player] = true

        -- Resetta e teleporta
        player:LoadCharacter()
    end

    wait(1)

    for player, _ in pairs(PlayersInRound) do
        if player and player.Parent then
            TeleportPlayerToZone(player, SpawnZone, false)
            SetupDeathMonitoring(player)
        end
    end
end

-- Termina il round e mostra la leaderboard
local function EndRound(winner)
    RoundInProgress = false

    -- Annuncia il vincitore
    if winner then
        print("[RoundSystem] ========================================")
        print("[RoundSystem] IL VINCITORE È: " .. winner.Name .. "!")
        print("[RoundSystem] ========================================")
        RoundStatusEvent:FireAllClients("winner", winner.Name)
    else
        print("[RoundSystem] ========================================")
        print("[RoundSystem] NESSUN VINCITORE - PAREGGIO!")
        print("[RoundSystem] ========================================")
        RoundStatusEvent:FireAllClients("draw", "")
    end

    wait(3)

    -- Prepara dati leaderboard
    local leaderboardData = {}
    for player, stats in pairs(PlayerStats) do
        if stats.status == "alive" or stats.status == "eliminated" then
            table.insert(leaderboardData, {
                playerName = player.Name,
                survivalTime = stats.survivalTime,
                isWinner = (player == winner)
            })
        end
    end

    -- Ordina per tempo di sopravvivenza (decrescente)
    table.sort(leaderboardData, function(a, b)
        return a.survivalTime > b.survivalTime
    end)

    -- Invia leaderboard ai client
    LeaderboardEvent:FireAllClients(leaderboardData)
    print("[RoundSystem] Leaderboard mostrata")

    -- Mostra leaderboard per 10 secondi
    wait(10)

    -- Chiudi leaderboard
    LeaderboardEvent:FireAllClients(nil)
end

-- Loop principale del round
local function RoundLoop()
    while true do
        -- Fase di attesa
        print("[RoundSystem] In attesa di giocatori...")
        RoundStatusEvent:FireAllClients("waiting", "")

        repeat
            wait(1)
        until #Players:GetPlayers() >= CONFIG.MIN_PLAYERS

        -- Intermissione
        print("[RoundSystem] Intermissione di " .. CONFIG.INTERMISSION_TIME .. " secondi...")
        RoundStatusEvent:FireAllClients("intermission", "")
        wait(CONFIG.INTERMISSION_TIME)

        -- Countdown
        StartCountdown()

        -- Prepara giocatori
        PreparePlayersForRound()

        -- Inizia round
        RoundInProgress = true
        RoundStartTime = tick()
        print("[RoundSystem] ROUND INIZIATO!")
        RoundStatusEvent:FireAllClients("playing", "")

        -- Loop del round
        local roundTime = 0
        while RoundInProgress do
            wait(1)
            roundTime = roundTime + 1

            local alivePlayers = CountAlivePlayers()

            -- Aggiorna survival time per giocatori vivi
            for player, _ in pairs(PlayersInRound) do
                if PlayerStats[player] and PlayerStats[player].status == "alive" then
                    if player and player.Character then
                        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            PlayerStats[player].survivalTime = tick() - RoundStartTime
                        end
                    end
                end
            end

            -- Controlla condizioni di fine round
            if alivePlayers <= 1 then
                local winner = GetWinner()
                EndRound(winner)
                break
            end

            -- Timeout del round
            if CONFIG.MAX_ROUND_TIME > 0 and roundTime >= CONFIG.MAX_ROUND_TIME then
                print("[RoundSystem] Tempo massimo raggiunto!")
                local winner = GetWinner()
                EndRound(winner)
                break
            end
        end

        -- Resetta tutti i giocatori
        for _, player in pairs(Players:GetPlayers()) do
            if player then
                PlayerStats[player].status = "waiting"
            end
        end

        PlayersInRound = {}

        print("[RoundSystem] Round terminato. Nuovo round tra poco...")
    end
end

-- ==================== AVVIO DEL SISTEMA ====================

print("[RoundSystem] ========================================")
print("[RoundSystem] SISTEMA DI ROUND AVVIATO")
print("[RoundSystem] ========================================")
print("[RoundSystem] Configurazione:")
print("[RoundSystem] - Countdown: " .. CONFIG.COUNTDOWN_TIME .. "s")
print("[RoundSystem] - Intermissione: " .. CONFIG.INTERMISSION_TIME .. "s")
print("[RoundSystem] - Giocatori minimi: " .. CONFIG.MIN_PLAYERS)
print("[RoundSystem] ========================================")

CreateDefaultZones()

-- Inizializza giocatori già presenti
for _, player in pairs(Players:GetPlayers()) do
    InitializePlayerStats(player)
end

-- Avvia il loop dei round
spawn(RoundLoop)
