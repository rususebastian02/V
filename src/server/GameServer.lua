--[[
    LIFE TEXT RPG - Server Script
    Metti questo script in ServerScriptService
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Attendi che i moduli siano pronti
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Data = ReplicatedStorage:WaitForChild("Data")

local ReputationSystem = require(Shared:WaitForChild("ReputationSystem"))
local PlayerData = require(Shared:WaitForChild("PlayerData"))
local EventSystem = require(Shared:WaitForChild("EventSystem"))
local StoryEvents = require(Data:WaitForChild("StoryEvents"))

-- DataStore
local PlayerStore = DataStoreService:GetDataStore("LIFE_RPG_v1")

-- Registra eventi
StoryEvents.RegisterAll(EventSystem)

-- Cache giocatori attivi
local ActivePlayers = {}

-- Crea RemoteEvents
local Events = Instance.new("Folder")
Events.Name = "LIFE_Events"
Events.Parent = ReplicatedStorage

local SendEvent = Instance.new("RemoteEvent")
SendEvent.Name = "SendEvent"
SendEvent.Parent = Events

local SendResult = Instance.new("RemoteEvent")
SendResult.Name = "SendResult"
SendResult.Parent = Events

local UpdateStats = Instance.new("RemoteEvent")
UpdateStats.Name = "UpdateStats"
UpdateStats.Parent = Events

local SystemMessage = Instance.new("RemoteEvent")
SystemMessage.Name = "SystemMessage"
SystemMessage.Parent = Events

local RequestEvent = Instance.new("RemoteEvent")
RequestEvent.Name = "RequestEvent"
RequestEvent.Parent = Events

local SubmitChoice = Instance.new("RemoteEvent")
SubmitChoice.Name = "SubmitChoice"
SubmitChoice.Parent = Events

-- Funzioni di salvataggio
local function LoadPlayerData(player)
    local success, data = pcall(function()
        return PlayerStore:GetAsync("Player_" .. player.UserId)
    end)

    if success and data then
        local decoded = HttpService:JSONDecode(data)
        decoded.lastLogin = os.time()
        return decoded
    else
        return PlayerData.CreateNew(player.UserId)
    end
end

local function SavePlayerData(player)
    local data = ActivePlayers[player.UserId]
    if not data then return end

    pcall(function()
        local encoded = HttpService:JSONEncode(data)
        PlayerStore:SetAsync("Player_" .. player.UserId, encoded)
    end)
end

-- Invia prossimo evento
local function SendNextEvent(player)
    local data = ActivePlayers[player.UserId]
    if not data then return end

    -- Controlla instabilita'
    local hasInstability, instEvent = EventSystem.CheckInstabilityEvent(data, PlayerData)
    if hasInstability then
        SendEvent:FireClient(player, instEvent, data)
        data.currentEventId = instEvent.id
        return
    end

    -- Controlla eventi chiave
    local hasKey, keyEvent = EventSystem.HasKeyEventAvailable(data, PlayerData)
    if hasKey and not data.eventsCompleted[keyEvent.id] then
        SendEvent:FireClient(player, keyEvent, data)
        data.currentEventId = keyEvent.id
        return
    end

    -- Eventi casuali
    local daily = EventSystem.GetDailyEvents(data, 5, PlayerData)
    if #daily > 0 then
        local event = daily[math.random(#daily)]
        SendEvent:FireClient(player, event, data)
        data.currentEventId = event.id
    else
        -- Nessun evento, prova morali
        local moral = EventSystem.GetAvailableEvents(data, "MORAL", PlayerData)
        if #moral > 0 then
            local event = moral[math.random(#moral)]
            SendEvent:FireClient(player, event, data)
            data.currentEventId = event.id
        else
            SystemMessage:FireClient(player, "La giornata e' tranquilla... per ora.", 3)
        end
    end
end

-- Processa scelta
local function ProcessChoice(player, eventId, choiceId)
    local data = ActivePlayers[player.UserId]
    if not data then return end

    if data.currentEventId ~= eventId then return end

    local event = EventSystem.GetEvent(eventId)
    if not event then return end

    local success, result = EventSystem.ProcessChoice(event, choiceId, data, ReputationSystem, PlayerData)

    if success then
        SendResult:FireClient(player, result)
        UpdateStats:FireClient(player, data)
        data.currentEventId = nil

        if data.totalEventsPlayed % 5 == 0 then
            SavePlayerData(player)
        end

        print("[LIFE] " .. player.Name .. " | Rep: " .. data.reputation .. " | " .. ReputationSystem.GetFaction(data.reputation))
    end
end

-- Player Join
Players.PlayerAdded:Connect(function(player)
    local data = LoadPlayerData(player)
    ActivePlayers[player.UserId] = data
    data.stats.daysPlayed = data.stats.daysPlayed + 1

    task.wait(2)
    UpdateStats:FireClient(player, data)

    local desc = ReputationSystem.GetPlayerDescription(data.reputation)
    SystemMessage:FireClient(player, desc, 4)

    task.wait(1)
    SendNextEvent(player)
end)

-- Player Leave
Players.PlayerRemoving:Connect(function(player)
    SavePlayerData(player)
    ActivePlayers[player.UserId] = nil
end)

-- Eventi
RequestEvent.OnServerEvent:Connect(function(player)
    SendNextEvent(player)
end)

SubmitChoice.OnServerEvent:Connect(function(player, eventId, choiceId)
    ProcessChoice(player, eventId, choiceId)
end)

-- Shutdown
game:BindToClose(function()
    for userId, _ in pairs(ActivePlayers) do
        local player = Players:GetPlayerByUserId(userId)
        if player then
            SavePlayerData(player)
        end
    end
end)

print("========================================")
print("  LIFE TEXT RPG - Server Avviato")
print("========================================")
