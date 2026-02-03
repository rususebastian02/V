--[[
    LIFE TEXT RPG - Client Entry Point
    Questo script inizializza l'UI lato client.

    SETUP IN ROBLOX STUDIO:
    1. Metti questo script in StarterPlayerScripts
    2. Metti TextUI.lua nella stessa cartella
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Aspetta gli eventi remoti
local EventsFolder = ReplicatedStorage:WaitForChild("LifeTextRPGEvents", 30)
if not EventsFolder then
    error("[LifeTextRPG] Eventi non trovati - il server è attivo?")
end

local SendEvent = EventsFolder:WaitForChild("SendEvent")
local SendResult = EventsFolder:WaitForChild("SendResult")
local UpdateStats = EventsFolder:WaitForChild("UpdateStats")
local SystemMessage = EventsFolder:WaitForChild("SystemMessage")
local RequestEvent = EventsFolder:WaitForChild("RequestEvent")
local SubmitChoice = EventsFolder:WaitForChild("SubmitChoice")

-- Inizializza UI
local TextUI = require(script.Parent.TextUI)
local ui = TextUI.new(player)

-- Evento corrente
local currentEvent = nil

-- Handler: Ricevi evento
SendEvent.OnClientEvent:Connect(function(event, playerData)
    currentEvent = event
    ui:UpdateStats(playerData)
    ui:ShowEvent(event, playerData)
end)

-- Handler: Ricevi risultato scelta
SendResult.OnClientEvent:Connect(function(result)
    ui:ShowConsequence(result)
end)

-- Handler: Aggiorna stats
UpdateStats.OnClientEvent:Connect(function(playerData)
    ui:UpdateStats(playerData)
end)

-- Handler: Messaggio di sistema
SystemMessage.OnClientEvent:Connect(function(message, duration)
    ui:ShowSystemMessage(message, duration)
end)

-- Callback quando il player sceglie
ui.OnChoiceCallback = function(choice)
    if currentEvent then
        SubmitChoice:FireServer(currentEvent.id, choice.id)
    end
end

-- Callback per continuare
ui.OnContinueCallback = function()
    currentEvent = nil
    RequestEvent:FireServer()
end

print("[LifeTextRPG] Client inizializzato per " .. player.Name)
