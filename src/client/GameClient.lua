--[[
    LIFE TEXT RPG - Client Script
    Metti questo script in StarterPlayerScripts
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Attendi eventi
local Events = ReplicatedStorage:WaitForChild("LIFE_Events", 30)
if not Events then
    error("[LIFE] Eventi non trovati!")
end

local SendEvent = Events:WaitForChild("SendEvent")
local SendResult = Events:WaitForChild("SendResult")
local UpdateStats = Events:WaitForChild("UpdateStats")
local SystemMessage = Events:WaitForChild("SystemMessage")
local RequestEvent = Events:WaitForChild("RequestEvent")
local SubmitChoice = Events:WaitForChild("SubmitChoice")

-- Carica UI
local TextUI = require(script.Parent:WaitForChild("TextUI"))
local ui = TextUI.new(player)

local currentEvent = nil

-- Ricevi evento
SendEvent.OnClientEvent:Connect(function(event, playerData)
    currentEvent = event
    ui:UpdateStats(playerData)
    ui:ShowEvent(event)
end)

-- Ricevi risultato
SendResult.OnClientEvent:Connect(function(result)
    ui:ShowConsequence(result)
end)

-- Aggiorna stats
UpdateStats.OnClientEvent:Connect(function(playerData)
    ui:UpdateStats(playerData)
end)

-- Messaggio sistema
SystemMessage.OnClientEvent:Connect(function(message, duration)
    ui:ShowSystemMessage(message, duration)
end)

-- Scelta
ui.OnChoiceCallback = function(choice)
    if currentEvent then
        SubmitChoice:FireServer(currentEvent.id, choice.id)
    end
end

-- Continua
ui.OnContinueCallback = function()
    currentEvent = nil
    RequestEvent:FireServer()
end

print("[LIFE] Client avviato per " .. player.Name)
