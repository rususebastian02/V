--[[
    LIFE TEXT RPG - Server Entry Point
    Questo script inizializza il gioco lato server.

    SETUP IN ROBLOX STUDIO:
    1. Metti questo script in ServerScriptService
    2. Metti i moduli Shared in ReplicatedStorage/Shared
    3. Metti StoryEvents.lua in ReplicatedStorage/Data
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Aspetta che i moduli siano pronti
local function waitForModule(parent, name, timeout)
    timeout = timeout or 10
    local startTime = tick()
    while tick() - startTime < timeout do
        local module = parent:FindFirstChild(name)
        if module then return module end
        wait(0.1)
    end
    error("Modulo non trovato: " .. name)
end

-- Verifica struttura
print("[LifeTextRPG] Verifico struttura...")

local Shared = waitForModule(ReplicatedStorage, "Shared")
local Data = waitForModule(ReplicatedStorage, "Data")

print("[LifeTextRPG] Struttura verificata")

-- Inizializza GameManager
local GameManager = require(script.Parent.GameManager)
GameManager.Initialize()

print("============================================")
print("  LIFE TEXT RPG - Server Avviato")
print("  Il tuo destino ti attende...")
print("============================================")
