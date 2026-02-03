--[[
    LIFE TEXT RPG - Game Manager
    Gestisce la logica principale del gioco lato server.
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Moduli condivisi
local Shared = ReplicatedStorage:WaitForChild("Shared")
local ReputationSystem = require(Shared.ReputationSystem)
local PlayerData = require(Shared.PlayerData)
local EventSystem = require(Shared.EventSystem)

-- DataStore per salvare i dati dei giocatori
local PlayerDataStore = DataStoreService:GetDataStore("LifeTextRPG_PlayerData_v1")

local GameManager = {}
GameManager.__index = GameManager

-- Cache dei dati giocatori attivi
GameManager.ActivePlayers = {}

-- Remote Events per comunicazione client-server
local RemoteEvents = {}

function GameManager.Initialize()
    -- Crea RemoteEvents
    local eventsFolder = Instance.new("Folder")
    eventsFolder.Name = "LifeTextRPGEvents"
    eventsFolder.Parent = ReplicatedStorage

    RemoteEvents.RequestEvent = Instance.new("RemoteEvent")
    RemoteEvents.RequestEvent.Name = "RequestEvent"
    RemoteEvents.RequestEvent.Parent = eventsFolder

    RemoteEvents.SubmitChoice = Instance.new("RemoteEvent")
    RemoteEvents.SubmitChoice.Name = "SubmitChoice"
    RemoteEvents.SubmitChoice.Parent = eventsFolder

    RemoteEvents.SendEvent = Instance.new("RemoteEvent")
    RemoteEvents.SendEvent.Name = "SendEvent"
    RemoteEvents.SendEvent.Parent = eventsFolder

    RemoteEvents.SendResult = Instance.new("RemoteEvent")
    RemoteEvents.SendResult.Name = "SendResult"
    RemoteEvents.SendResult.Parent = eventsFolder

    RemoteEvents.UpdateStats = Instance.new("RemoteEvent")
    RemoteEvents.UpdateStats.Name = "UpdateStats"
    RemoteEvents.UpdateStats.Parent = eventsFolder

    RemoteEvents.SystemMessage = Instance.new("RemoteEvent")
    RemoteEvents.SystemMessage.Name = "SystemMessage"
    RemoteEvents.SystemMessage.Parent = eventsFolder

    -- Registra gli eventi narrativi
    local StoryEvents = require(ReplicatedStorage.Data.StoryEvents)
    StoryEvents.RegisterAll(EventSystem)

    -- Setup listeners
    GameManager.SetupListeners()

    print("[LifeTextRPG] GameManager inizializzato")
end

function GameManager.SetupListeners()
    -- Player join
    Players.PlayerAdded:Connect(function(player)
        GameManager.OnPlayerJoin(player)
    end)

    -- Player leave
    Players.PlayerRemoving:Connect(function(player)
        GameManager.OnPlayerLeave(player)
    end)

    -- Richiesta evento
    RemoteEvents.RequestEvent.OnServerEvent:Connect(function(player)
        GameManager.SendNextEvent(player)
    end)

    -- Scelta del giocatore
    RemoteEvents.SubmitChoice.OnServerEvent:Connect(function(player, eventId, choiceId)
        GameManager.ProcessPlayerChoice(player, eventId, choiceId)
    end)
end

-- Carica dati giocatore
function GameManager.LoadPlayerData(player)
    local success, data = pcall(function()
        return PlayerDataStore:GetAsync("Player_" .. player.UserId)
    end)

    if success and data then
        -- Deserializza i dati salvati
        local playerData = PlayerData.Deserialize(data)
        playerData.lastLogin = os.time()
        return playerData
    else
        -- Nuovo giocatore
        return PlayerData.CreateNew(player.UserId)
    end
end

-- Salva dati giocatore
function GameManager.SavePlayerData(player)
    local playerData = GameManager.ActivePlayers[player.UserId]
    if not playerData then return end

    local success, err = pcall(function()
        local serialized = PlayerData.Serialize(playerData)
        PlayerDataStore:SetAsync("Player_" .. player.UserId, serialized)
    end)

    if not success then
        warn("[LifeTextRPG] Errore salvataggio dati per " .. player.Name .. ": " .. err)
    end
end

-- Player join
function GameManager.OnPlayerJoin(player)
    print("[LifeTextRPG] " .. player.Name .. " è entrato")

    -- Carica dati
    local playerData = GameManager.LoadPlayerData(player)
    GameManager.ActivePlayers[player.UserId] = playerData

    -- Aggiorna giorni giocati
    playerData.stats.daysPlayed = playerData.stats.daysPlayed + 1

    -- Invia stats iniziali
    wait(2) -- Aspetta che l'UI sia pronta
    RemoteEvents.UpdateStats:FireClient(player, playerData)

    -- Messaggio di benvenuto
    local faction = ReputationSystem.GetFaction(playerData.reputation)
    local description = ReputationSystem.GetPlayerDescription(playerData.reputation)
    RemoteEvents.SystemMessage:FireClient(player, description, 5)

    -- Controlla eventi speciali
    GameManager.CheckSpecialEvents(player, playerData)

    -- Invia primo evento
    wait(1)
    GameManager.SendNextEvent(player)
end

-- Player leave
function GameManager.OnPlayerLeave(player)
    print("[LifeTextRPG] " .. player.Name .. " è uscito")

    -- Salva dati
    GameManager.SavePlayerData(player)

    -- Rimuovi dalla cache
    GameManager.ActivePlayers[player.UserId] = nil
end

-- Controlla eventi speciali (instabilità, soglie, ecc.)
function GameManager.CheckSpecialEvents(player, playerData)
    -- Controlla instabilità morale
    local hasInstability, instabilityEvent = EventSystem.CheckInstabilityEvent(playerData)
    if hasInstability then
        RemoteEvents.SystemMessage:FireClient(player, "Qualcosa non va... ti senti diviso.", 3)
        return instabilityEvent
    end

    -- Controlla nuove soglie raggiunte
    local stage, stageName = ReputationSystem.GetNarrativeStage(playerData.reputation)
    if playerData.lastNotifiedStage ~= stage then
        playerData.lastNotifiedStage = stage
        RemoteEvents.SystemMessage:FireClient(player, "Hai raggiunto lo status: " .. stageName, 4)
    end

    return nil
end

-- Invia prossimo evento al player
function GameManager.SendNextEvent(player)
    local playerData = GameManager.ActivePlayers[player.UserId]
    if not playerData then return end

    -- Controlla prima eventi speciali
    local specialEvent = GameManager.CheckSpecialEvents(player, playerData)
    if specialEvent then
        RemoteEvents.SendEvent:FireClient(player, specialEvent, playerData)
        playerData.currentEventId = specialEvent.id
        return
    end

    -- Controlla eventi chiave disponibili
    local hasKeyEvent, keyEvent = EventSystem.HasKeyEventAvailable(playerData)
    if hasKeyEvent then
        RemoteEvents.SendEvent:FireClient(player, keyEvent, playerData)
        playerData.currentEventId = keyEvent.id
        return
    end

    -- Altrimenti, evento quotidiano casuale
    local dailyEvents = EventSystem.GetDailyEvents(playerData, 3)
    if #dailyEvents > 0 then
        local event = dailyEvents[math.random(#dailyEvents)]
        RemoteEvents.SendEvent:FireClient(player, event, playerData)
        playerData.currentEventId = event.id
    else
        -- Nessun evento disponibile
        RemoteEvents.SystemMessage:FireClient(player, "La giornata è tranquilla... per ora.", 3)
    end
end

-- Processa la scelta del giocatore
function GameManager.ProcessPlayerChoice(player, eventId, choiceId)
    local playerData = GameManager.ActivePlayers[player.UserId]
    if not playerData then return end

    -- Verifica che l'evento sia quello corrente
    if playerData.currentEventId ~= eventId then
        warn("[LifeTextRPG] Evento non corrispondente per " .. player.Name)
        return
    end

    -- Ottieni l'evento
    local event = EventSystem.GetEvent(eventId)
    if not event then
        warn("[LifeTextRPG] Evento non trovato: " .. eventId)
        return
    end

    -- Processa la scelta
    local success, result = EventSystem.ProcessChoice(event, choiceId, playerData)
    if not success then
        warn("[LifeTextRPG] Errore nel processare scelta: " .. tostring(result))
        return
    end

    -- Invia risultato al client
    RemoteEvents.SendResult:FireClient(player, result)

    -- Aggiorna stats
    RemoteEvents.UpdateStats:FireClient(player, playerData)

    -- Processa effetti aggiuntivi
    if result.effects then
        GameManager.ProcessEffects(player, playerData, result.effects)
    end

    -- Reset evento corrente
    playerData.currentEventId = nil

    -- Auto-save periodico
    if playerData.totalEventsPlayed % 5 == 0 then
        GameManager.SavePlayerData(player)
    end

    print("[LifeTextRPG] " .. player.Name .. " ha completato evento " .. eventId ..
          " | Rep: " .. playerData.reputation ..
          " | Fazione: " .. ReputationSystem.GetFaction(playerData.reputation))
end

-- Processa effetti delle scelte
function GameManager.ProcessEffects(player, playerData, effects)
    -- Sblocca eventi
    if effects.unlockEvent then
        -- L'evento verrà automaticamente disponibile grazie al sistema dei requisiti
        print("[LifeTextRPG] Evento sbloccato: " .. effects.unlockEvent)
    end

    -- Blocca eventi
    if effects.blockEvent then
        playerData.eventsCompleted[effects.blockEvent] = true -- Marca come "completato" per bloccarlo
        print("[LifeTextRPG] Evento bloccato: " .. effects.blockEvent)
    end

    -- Imposta flag
    if effects.setFlag then
        playerData.eventMemory["FLAG_" .. effects.setFlag] = {
            set = true,
            timestamp = os.time()
        }
        print("[LifeTextRPG] Flag impostato: " .. effects.setFlag)
    end

    -- Triggera evento immediato
    if effects.triggerEvent then
        wait(2)
        local triggerEvent = EventSystem.GetEvent(effects.triggerEvent)
        if triggerEvent then
            RemoteEvents.SendEvent:FireClient(player, triggerEvent, playerData)
            playerData.currentEventId = triggerEvent.id
        end
    end
end

-- Gestione morte/fine run
function GameManager.ProcessPlayerDeath(player)
    local playerData = GameManager.ActivePlayers[player.UserId]
    if not playerData then return end

    local deathRecord = PlayerData.ProcessDeath(playerData)

    -- Notifica il player
    local faction = deathRecord.faction
    local message = faction == "Celeste"
        and "La tua luce si è spenta. Ma le tue gesta vivranno."
        or "L'ombra ti ha reclamato. Il terrore persiste."

    RemoteEvents.SystemMessage:FireClient(player, message, 5)

    -- Reset per nuova run (mantiene legacy)
    local newPlayerData = PlayerData.CreateNew(player.UserId)
    newPlayerData.legacyBonus = playerData.legacyBonus
    newPlayerData.chronicleEntries = playerData.chronicleEntries
    newPlayerData.unlockedTitles = playerData.unlockedTitles
    newPlayerData.deaths = playerData.deaths

    GameManager.ActivePlayers[player.UserId] = newPlayerData
    GameManager.SavePlayerData(player)

    -- Invia nuovi stats
    wait(3)
    RemoteEvents.UpdateStats:FireClient(player, newPlayerData)
end

-- Reset stagionale
function GameManager.SeasonReset(newSeasonNumber)
    for userId, playerData in pairs(GameManager.ActivePlayers) do
        PlayerData.SeasonReset(playerData, newSeasonNumber)

        local player = Players:GetPlayerByUserId(userId)
        if player then
            RemoteEvents.SystemMessage:FireClient(player, "Una nuova stagione inizia...", 5)
            RemoteEvents.UpdateStats:FireClient(player, playerData)
        end
    end

    print("[LifeTextRPG] Reset stagionale completato - Stagione " .. newSeasonNumber)
end

-- Shutdown sicuro
game:BindToClose(function()
    print("[LifeTextRPG] Shutdown - salvataggio dati...")
    for userId, _ in pairs(GameManager.ActivePlayers) do
        local player = Players:GetPlayerByUserId(userId)
        if player then
            GameManager.SavePlayerData(player)
        end
    end
    print("[LifeTextRPG] Tutti i dati salvati")
end)

return GameManager
