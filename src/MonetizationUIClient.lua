--[[
	MINIMALIST GAME ROOM - Monetization UI Client

	Handles UI effects for purchases

	Place this script in StarterPlayer > StarterPlayerScripts
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for remote events
local ShowGlobalMessageEvent = ReplicatedStorage:WaitForChild("ShowGlobalMessage")
local ShowAcknowledgementEvent = ReplicatedStorage:WaitForChild("ShowAcknowledgement")
local ShowLogEvent = ReplicatedStorage:WaitForChild("ShowLog")
local GetPlayerDataFunction = ReplicatedStorage:WaitForChild("GetPlayerData")

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MonetizationUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Global message (bottom center)
local globalMessage = Instance.new("TextLabel")
globalMessage.Name = "GlobalMessage"
globalMessage.Size = UDim2.new(0, 400, 0, 30)
globalMessage.Position = UDim2.new(0.5, -200, 0.85, 0)
globalMessage.BackgroundTransparency = 1
globalMessage.Text = ""
globalMessage.TextColor3 = Color3.fromRGB(160, 160, 160)
globalMessage.TextSize = 14
globalMessage.Font = Enum.Font.Code
globalMessage.TextTransparency = 1
globalMessage.Parent = screenGui

-- Acknowledgement (center)
local acknowledgement = Instance.new("TextLabel")
acknowledgement.Name = "Acknowledgement"
acknowledgement.Size = UDim2.new(0, 400, 0, 30)
acknowledgement.Position = UDim2.new(0.5, -200, 0.5, -15)
acknowledgement.BackgroundTransparency = 1
acknowledgement.Text = ""
acknowledgement.TextColor3 = Color3.fromRGB(180, 180, 180)
acknowledgement.TextSize = 16
acknowledgement.Font = Enum.Font.Code
acknowledgement.TextTransparency = 1
acknowledgement.Parent = screenGui

-- Log window (center, hidden by default)
local logFrame = Instance.new("Frame")
logFrame.Name = "LogFrame"
logFrame.Size = UDim2.new(0, 500, 0, 400)
logFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
logFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
logFrame.BorderSizePixel = 1
logFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
logFrame.Visible = false
logFrame.Parent = screenGui

local logTitle = Instance.new("TextLabel")
logTitle.Name = "LogTitle"
logTitle.Size = UDim2.new(1, 0, 0, 40)
logTitle.Position = UDim2.new(0, 0, 0, 0)
logTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
logTitle.BorderSizePixel = 0
logTitle.Text = "Session Log"
logTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
logTitle.TextSize = 18
logTitle.Font = Enum.Font.Code
logTitle.Parent = logFrame

local logContent = Instance.new("TextLabel")
logContent.Name = "LogContent"
logContent.Size = UDim2.new(1, -40, 1, -100)
logContent.Position = UDim2.new(0, 20, 0, 60)
logContent.BackgroundTransparency = 1
logContent.Text = ""
logContent.TextColor3 = Color3.fromRGB(180, 180, 180)
logContent.TextSize = 14
logContent.Font = Enum.Font.Code
logContent.TextXAlignment = Enum.TextXAlignment.Left
logContent.TextYAlignment = Enum.TextYAlignment.Top
logContent.TextWrapped = true
logContent.Parent = logFrame

local logWarning = Instance.new("TextLabel")
logWarning.Name = "LogWarning"
logWarning.Size = UDim2.new(1, 0, 0, 30)
logWarning.Position = UDim2.new(0, 0, 1, -35)
logWarning.BackgroundTransparency = 1
logWarning.Text = "Some entries are unavailable."
logWarning.TextColor3 = Color3.fromRGB(120, 120, 120)
logWarning.TextSize = 12
logWarning.Font = Enum.Font.Code
logWarning.TextTransparency = 0.5
logWarning.Parent = logFrame

local logCloseButton = Instance.new("TextButton")
logCloseButton.Name = "CloseButton"
logCloseButton.Size = UDim2.new(0, 80, 0, 30)
logCloseButton.Position = UDim2.new(1, -90, 1, -35)
logCloseButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
logCloseButton.BorderSizePixel = 0
logCloseButton.Text = "Close"
logCloseButton.TextColor3 = Color3.fromRGB(200, 200, 200)
logCloseButton.TextSize = 14
logCloseButton.Font = Enum.Font.Code
logCloseButton.Parent = logFrame

logCloseButton.MouseButton1Click:Connect(function()
	logFrame.Visible = false
end)

-- Helper: Fade in
local function fadeIn(textLabel, duration)
	duration = duration or 1
	local tween = TweenService:Create(
		textLabel,
		TweenInfo.new(duration, Enum.EasingStyle.Linear),
		{TextTransparency = 0}
	)
	tween:Play()
	return tween
end

-- Helper: Fade out
local function fadeOut(textLabel, duration)
	duration = duration or 1
	local tween = TweenService:Create(
		textLabel,
		TweenInfo.new(duration, Enum.EasingStyle.Linear),
		{TextTransparency = 1}
	)
	tween:Play()
	return tween
end

-- Helper: Format time
local function formatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60

	if hours > 0 then
		return string.format("%dh %dm %ds", hours, minutes, secs)
	elseif minutes > 0 then
		return string.format("%dm %ds", minutes, secs)
	else
		return string.format("%ds", secs)
	end
end

-- Global message event
ShowGlobalMessageEvent.OnClientEvent:Connect(function(message)
	globalMessage.Text = message
	fadeIn(globalMessage, 0.5)

	task.wait(3)

	fadeOut(globalMessage, 1)
end)

-- Acknowledgement event
ShowAcknowledgementEvent.OnClientEvent:Connect(function()
	acknowledgement.Text = "Input acknowledged."
	fadeIn(acknowledgement, 0.3)

	task.wait(2)

	fadeOut(acknowledgement, 1)
end)

-- Show log event
ShowLogEvent.OnClientEvent:Connect(function()
	-- Fetch player data
	local data = GetPlayerDataFunction:InvokeServer()

	if data then
		local logText = string.format(
			"Sessions: %d\nTotal Time: %s\nLast Visit: %s",
			data.sessions or 0,
			formatTime(data.totalTime or 0),
			data.lastVisit and os.date("%Y-%m-%d %H:%M", data.lastVisit) or "Unknown"
		)

		logContent.Text = logText
		logFrame.Visible = true
	end
end)

print("Minimalist Game Room - Monetization UI Client Loaded")
