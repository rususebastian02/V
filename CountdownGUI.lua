-- POSIZIONA QUESTO SCRIPT IN: StarterPlayer > StarterPlayerScripts
-- Minimal countdown GUI script

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for countdown value
local countdownValue = ReplicatedStorage:WaitForChild("CountdownValue")

-- Create countdown GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CountdownGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Minimal container frame
local frame = Instance.new("Frame")
frame.Name = "CountdownFrame"
frame.Size = UDim2.new(0, 180, 0, 60)
frame.Position = UDim2.new(0.5, -90, 0, 30)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Subtle rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

-- Timer label (centered, no title)
local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "TimerLabel"
timerLabel.Size = UDim2.new(1, 0, 1, 0)
timerLabel.Position = UDim2.new(0, 0, 0, 0)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "30:00"
timerLabel.TextSize = 32
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.Font = Enum.Font.Gotham
timerLabel.Parent = frame

-- Format time function
local function formatTime(seconds)
	local minutes = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d", minutes, secs)
end

-- Update timer color based on time remaining
local function updateTimerColor(seconds)
	if seconds > 300 then
		timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	elseif seconds > 60 then
		timerLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
	elseif seconds > 0 then
		timerLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	else
		timerLabel.TextColor3 = Color3.fromRGB(200, 50, 50)
		timerLabel.Text = "00:00"
	end
end

-- Update timer on value change
countdownValue.Changed:Connect(function(value)
	timerLabel.Text = formatTime(value)
	updateTimerColor(value)
end)

-- Initialize timer
timerLabel.Text = formatTime(countdownValue.Value)
updateTimerColor(countdownValue.Value)

print("Countdown GUI loaded")
