--[[
	MINIMALIST GAME ROOM - UI Client Script

	Handles all UI elements and message displays

	Place this script in StarterPlayer > StarterPlayerScripts
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for remote events
local UpdateTimerEvent = ReplicatedStorage:WaitForChild("UpdateTimer")
local ShowMessageEvent = ReplicatedStorage:WaitForChild("ShowMessage")
local ReturnVisitEvent = ReplicatedStorage:WaitForChild("ReturnVisit")
local FakeDisconnectEvent = ReplicatedStorage:WaitForChild("FakeDisconnect")

-- Create main UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MinimalistUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Persistent bottom text: "You're still here."
local bottomText = Instance.new("TextLabel")
bottomText.Name = "BottomText"
bottomText.Size = UDim2.new(1, 0, 0, 30)
bottomText.Position = UDim2.new(0, 0, 1, -40)
bottomText.BackgroundTransparency = 1
bottomText.Text = "You're still here."
bottomText.TextColor3 = Color3.fromRGB(150, 150, 150)
bottomText.TextSize = 14
bottomText.Font = Enum.Font.Code
bottomText.TextTransparency = 0.3
bottomText.Parent = screenGui

-- Message container (center)
local messageContainer = Instance.new("Frame")
messageContainer.Name = "MessageContainer"
messageContainer.Size = UDim2.new(0.8, 0, 0.6, 0)
messageContainer.Position = UDim2.new(0.1, 0, 0.2, 0)
messageContainer.BackgroundTransparency = 1
messageContainer.Parent = screenGui

local messageLabel = Instance.new("TextLabel")
messageLabel.Name = "MessageLabel"
messageLabel.Size = UDim2.new(1, 0, 1, 0)
messageLabel.Position = UDim2.new(0, 0, 0, 0)
messageLabel.BackgroundTransparency = 1
messageLabel.Text = ""
messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
messageLabel.TextSize = 24
messageLabel.Font = Enum.Font.Code
messageLabel.TextTransparency = 1
messageLabel.TextWrapped = true
messageLabel.TextXAlignment = Enum.TextXAlignment.Center
messageLabel.TextYAlignment = Enum.TextYAlignment.Middle
messageLabel.Parent = messageContainer

-- Leave button (hidden by default)
local leaveButton = Instance.new("TextButton")
leaveButton.Name = "LeaveButton"
leaveButton.Size = UDim2.new(0, 120, 0, 40)
leaveButton.Position = UDim2.new(0.5, -60, 0.7, 0)
leaveButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
leaveButton.BorderSizePixel = 0
leaveButton.Text = "Leave"
leaveButton.TextColor3 = Color3.fromRGB(220, 220, 220)
leaveButton.TextSize = 18
leaveButton.Font = Enum.Font.Code
leaveButton.Visible = false
leaveButton.Parent = screenGui

leaveButton.MouseButton1Click:Connect(function()
	player:Kick("You left.")
end)

-- Fake disconnect log (top-right corner)
local disconnectLog = Instance.new("TextLabel")
disconnectLog.Name = "DisconnectLog"
disconnectLog.Size = UDim2.new(0, 250, 0, 25)
disconnectLog.Position = UDim2.new(1, -260, 0, 10)
disconnectLog.BackgroundTransparency = 1
disconnectLog.Text = ""
disconnectLog.TextColor3 = Color3.fromRGB(120, 120, 120)
disconnectLog.TextSize = 12
disconnectLog.Font = Enum.Font.Code
disconnectLog.TextTransparency = 1
disconnectLog.TextXAlignment = Enum.TextXAlignment.Right
disconnectLog.Parent = screenGui

-- Return visit container (center, temporary)
local returnContainer = Instance.new("Frame")
returnContainer.Name = "ReturnContainer"
returnContainer.Size = UDim2.new(0.8, 0, 0.6, 0)
returnContainer.Position = UDim2.new(0.1, 0, 0.2, 0)
returnContainer.BackgroundTransparency = 1
returnContainer.Visible = false
returnContainer.Parent = screenGui

local returnLabel = Instance.new("TextLabel")
returnLabel.Name = "ReturnLabel"
returnLabel.Size = UDim2.new(1, 0, 1, 0)
returnLabel.Position = UDim2.new(0, 0, 0, 0)
returnLabel.BackgroundTransparency = 1
returnLabel.Text = ""
returnLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
returnLabel.TextSize = 24
returnLabel.Font = Enum.Font.Code
returnLabel.TextTransparency = 1
returnLabel.TextWrapped = true
returnLabel.TextXAlignment = Enum.TextXAlignment.Center
returnLabel.TextYAlignment = Enum.TextYAlignment.Middle
returnLabel.Parent = returnContainer

-- Helper: Fade text in
local function fadeIn(textLabel, duration)
	duration = duration or 2
	local tween = TweenService:Create(
		textLabel,
		TweenInfo.new(duration, Enum.EasingStyle.Linear),
		{TextTransparency = 0}
	)
	tween:Play()
	return tween
end

-- Helper: Fade text out
local function fadeOut(textLabel, duration)
	duration = duration or 2
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
	local minutes = math.floor(seconds / 60)
	if minutes == 0 then
		return "less than a minute"
	elseif minutes == 1 then
		return "1 minute"
	else
		return tostring(minutes) .. " minutes"
	end
end

-- Show message event
ShowMessageEvent.OnClientEvent:Connect(function(text, showLeaveBtn, isFinal)
	if isFinal then
		-- Final message: almost empty screen
		bottomText.Visible = false
		messageLabel.TextSize = 18
	end

	messageLabel.Text = text
	fadeIn(messageLabel, 3)

	if showLeaveBtn then
		task.wait(1)
		leaveButton.Visible = true
		local btnTween = TweenService:Create(
			leaveButton,
			TweenInfo.new(1, Enum.EasingStyle.Linear),
			{BackgroundColor3 = Color3.fromRGB(100, 100, 100)}
		)
		btnTween:Play()
	end

	-- Keep message visible (don't fade out)
end)

-- Return visit event
ReturnVisitEvent.OnClientEvent:Connect(function(previousTime)
	returnContainer.Visible = true

	-- "You came back."
	returnLabel.Text = "You came back."
	fadeIn(returnLabel, 2)

	task.wait(10)

	-- Fade out first message
	fadeOut(returnLabel, 1).Completed:Wait()

	-- "Last time you stayed X minutes."
	returnLabel.Text = "Last time you stayed " .. formatTime(previousTime) .. "."
	returnLabel.TextTransparency = 1
	fadeIn(returnLabel, 2)

	task.wait(10)

	-- Fade out
	fadeOut(returnLabel, 1).Completed:Wait()

	-- "You didn't have to."
	returnLabel.Text = "You didn't have to."
	returnLabel.TextTransparency = 1
	fadeIn(returnLabel, 2)

	task.wait(8)

	-- Final fade out
	fadeOut(returnLabel, 2).Completed:Wait()
	returnContainer.Visible = false
end)

-- Fake disconnect event
FakeDisconnectEvent.OnClientEvent:Connect(function(message)
	disconnectLog.Text = message
	fadeIn(disconnectLog, 0.5)

	task.wait(4)

	fadeOut(disconnectLog, 1)
end)

-- Timer update (not displayed, but can be used for custom logic)
UpdateTimerEvent.OnClientEvent:Connect(function(timeInRoom)
	-- Timer is tracked server-side, no visible display
	-- Can be used for debugging or custom client-side effects
end)

print("Minimalist Game Room - UI Client Script Loaded")
