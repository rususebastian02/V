-- POSIZIONA QUESTO SCRIPT IN: StarterPlayer > StarterPlayerScripts
-- Script per la GUI del countdown

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Aspetta il valore del countdown
local countdownValue = ReplicatedStorage:WaitForChild("CountdownValue")

-- Crea la GUI del countdown
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CountdownGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Frame contenitore
local frame = Instance.new("Frame")
frame.Name = "CountdownFrame"
frame.Size = UDim2.new(0, 300, 0, 100)
frame.Position = UDim2.new(0.5, -150, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Corner arrotondati
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- Label del titolo
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⏰ TEMPO RIMANENTE"
titleLabel.TextSize = 18
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = frame

-- Label del timer
local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "TimerLabel"
timerLabel.Size = UDim2.new(1, 0, 0.6, 0)
timerLabel.Position = UDim2.new(0, 0, 0.4, 0)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "30:00"
timerLabel.TextSize = 32
timerLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
timerLabel.Font = Enum.Font.GothamBold
timerLabel.Parent = frame

-- Funzione per formattare il tempo in MM:SS
local function formatTime(seconds)
	local minutes = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d", minutes, secs)
end

-- Funzione per aggiornare il colore del timer in base al tempo rimanente
local function updateTimerColor(seconds)
	if seconds > 300 then
		-- Verde se più di 5 minuti
		timerLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	elseif seconds > 60 then
		-- Giallo se tra 1 e 5 minuti
		timerLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
	elseif seconds > 0 then
		-- Rosso se meno di 1 minuto
		timerLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	else
		-- Rosso lampeggiante se 0
		timerLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
		timerLabel.Text = "00:00"
		titleLabel.Text = "🌋 APOCALISSE!"
	end
end

-- Aggiorna il timer quando il valore cambia
countdownValue.Changed:Connect(function(value)
	timerLabel.Text = formatTime(value)
	updateTimerColor(value)

	-- Animazione pulsante negli ultimi 10 secondi
	if value <= 10 and value > 0 then
		timerLabel.TextSize = 40
		wait(0.3)
		timerLabel.TextSize = 32
	end
end)

-- Inizializza il timer
timerLabel.Text = formatTime(countdownValue.Value)
updateTimerColor(countdownValue.Value)

print("✅ GUI Countdown caricata")
