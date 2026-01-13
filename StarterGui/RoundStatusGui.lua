--[[
    ROUND STATUS GUI - Script Client (OPZIONALE)
    Mostra lo stato del round in alto a destra
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Crea GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RoundStatusGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 250, 0, 40)
statusLabel.Position = UDim2.new(1, -260, 0, 10)
statusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
statusLabel.BackgroundTransparency = 0.5
statusLabel.BorderSizePixel = 0
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 18
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Text = "In attesa..."
statusLabel.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = statusLabel

-- Eventi
local RoundEvents = ReplicatedStorage:WaitForChild("RoundEvents")
local RoundStatusEvent = RoundEvents:WaitForChild("RoundStatusEvent")

RoundStatusEvent.OnClientEvent:Connect(function(status, data)
    if status == "waiting" then
        statusLabel.Text = "⏳ In attesa di giocatori..."
        statusLabel.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    elseif status == "intermission" then
        statusLabel.Text = "⏸️ Intermissione"
        statusLabel.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    elseif status == "playing" then
        statusLabel.Text = "🎮 Round in corso!"
        statusLabel.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    elseif status == "winner" then
        statusLabel.Text = "🏆 Vincitore: " .. data
        statusLabel.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    elseif status == "draw" then
        statusLabel.Text = "🤝 Pareggio!"
        statusLabel.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    end
end)

print("[RoundStatusGui] Status GUI inizializzata")
