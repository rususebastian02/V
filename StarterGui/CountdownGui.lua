--[[
    COUNTDOWN GUI - Script Client
    Mostra il countdown prima dell'inizio del round

    INSTALLAZIONE:
    1. Crea uno ScreenGui in StarterGui chiamato "CountdownGui"
    2. Aggiungi un TextLabel chiamato "CountdownLabel" al ScreenGui
    3. Metti questo script come LocalScript dentro lo ScreenGui
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Aspetta che la GUI sia pronta
local screenGui = script.Parent
local countdownLabel = screenGui:WaitForChild("CountdownLabel")

-- Stile iniziale
countdownLabel.Size = UDim2.new(0, 400, 0, 150)
countdownLabel.Position = UDim2.new(0.5, -200, 0.3, -75)
countdownLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
countdownLabel.BackgroundTransparency = 0.5
countdownLabel.BorderSizePixel = 0
countdownLabel.Font = Enum.Font.GothamBold
countdownLabel.TextSize = 72
countdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
countdownLabel.TextStrokeTransparency = 0.5
countdownLabel.Visible = false

-- Angoli arrotondati
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 15)
uiCorner.Parent = countdownLabel

-- Aspetta il RemoteEvent
local RoundEvents = ReplicatedStorage:WaitForChild("RoundEvents", 10)
if not RoundEvents then
    warn("[CountdownGui] RoundEvents non trovato!")
    return
end

local CountdownEvent = RoundEvents:WaitForChild("CountdownEvent", 10)
if not CountdownEvent then
    warn("[CountdownGui] CountdownEvent non trovato!")
    return
end

-- Funzione per animare il countdown
local function AnimateCountdown(number)
    countdownLabel.Visible = true
    countdownLabel.Size = UDim2.new(0, 400, 0, 150)
    countdownLabel.TextTransparency = 0

    -- Animazione di ingrandimento e dissolvenza
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local goal = {
        Size = UDim2.new(0, 500, 0, 200),
        TextTransparency = 1
    }

    local tween = tweenService:Create(countdownLabel, tweenInfo, goal)
    tween:Play()

    tween.Completed:Connect(function()
        if number <= 0 then
            countdownLabel.Visible = false
        end
    end)
end

-- Ascolta gli eventi di countdown
CountdownEvent.OnClientEvent:Connect(function(timeLeft)
    if timeLeft > 0 then
        countdownLabel.Text = tostring(timeLeft)
        countdownLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        AnimateCountdown(timeLeft)

        -- Suono tick (opzionale)
        local tickSound = Instance.new("Sound")
        tickSound.SoundId = "rbxasset://sounds/switch.wav"
        tickSound.Volume = 0.5
        tickSound.Parent = screenGui
        tickSound:Play()
        game:GetService("Debris"):AddItem(tickSound, 1)

    elseif timeLeft == 0 then
        countdownLabel.Text = "INIZIA!"
        countdownLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        countdownLabel.TextSize = 96
        AnimateCountdown(0)

        -- Suono start (opzionale)
        local startSound = Instance.new("Sound")
        startSound.SoundId = "rbxasset://sounds/bell.wav"
        startSound.Volume = 0.7
        startSound.Parent = screenGui
        startSound:Play()
        game:GetService("Debris"):AddItem(startSound, 2)

        wait(1)
        countdownLabel.TextSize = 72
    end
end)

print("[CountdownGui] Countdown GUI inizializzata")
