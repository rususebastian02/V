--[[
	MINIMALIST GAME ROOM - Loading Screen & Main Menu

	Minimal loading screen → Main menu with locked camera and blur → Game

	Place this LocalScript in StarterGui
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- Remove default loading screen
ReplicatedFirst:RemoveDefaultLoadingScreen()

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LoadingAndMenuGui"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 100
screenGui.Parent = playerGui

-- Loading Screen Frame
local loadingFrame = Instance.new("Frame")
loadingFrame.Name = "LoadingFrame"
loadingFrame.Size = UDim2.new(1, 0, 1, 0)
loadingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
loadingFrame.BorderSizePixel = 0
loadingFrame.Parent = screenGui

-- Loading text
local loadingText = Instance.new("TextLabel")
loadingText.Name = "LoadingText"
loadingText.Size = UDim2.new(1, 0, 0, 50)
loadingText.Position = UDim2.new(0, 0, 0.5, -25)
loadingText.BackgroundTransparency = 1
loadingText.Text = "Loading"
loadingText.TextColor3 = Color3.fromRGB(200, 200, 200)
loadingText.TextSize = 24
loadingText.Font = Enum.Font.Code
loadingText.TextTransparency = 0
loadingText.TextStrokeTransparency = 0.8
loadingText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
loadingText.Parent = loadingFrame

-- Animate loading dots
task.spawn(function()
	local dots = {"", ".", "..", "..."}
	local index = 1
	while loadingFrame.Visible do
		loadingText.Text = "Loading" .. dots[index]
		index = index + 1
		if index > #dots then
			index = 1
		end
		task.wait(0.5)
	end
end)

-- Main Menu Frame (hidden initially)
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuFrame"
menuFrame.Size = UDim2.new(1, 0, 1, 0)
menuFrame.BackgroundTransparency = 1
menuFrame.BorderSizePixel = 0
menuFrame.Visible = false
menuFrame.Parent = screenGui

-- Blur effect for menu
local blurEffect = Instance.new("BlurEffect")
blurEffect.Name = "MenuBlur"
blurEffect.Size = 0
blurEffect.Parent = camera

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 80)
titleLabel.Position = UDim2.new(0, 0, 0.3, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "You're Still Here."
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
titleLabel.TextSize = 36
titleLabel.Font = Enum.Font.Code
titleLabel.TextTransparency = 1
titleLabel.TextStrokeTransparency = 1
titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
titleLabel.Parent = menuFrame

-- Subtitle
local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Name = "Subtitle"
subtitleLabel.Size = UDim2.new(1, 0, 0, 30)
subtitleLabel.Position = UDim2.new(0, 0, 0.3, 90)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "It doesn't give you objectives. It just watches you choose to stay."
subtitleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
subtitleLabel.TextSize = 14
subtitleLabel.Font = Enum.Font.Code
subtitleLabel.TextTransparency = 1
subtitleLabel.TextStrokeTransparency = 1
subtitleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
subtitleLabel.TextWrapped = true
subtitleLabel.Parent = menuFrame

-- Play Button
local playButton = Instance.new("TextButton")
playButton.Name = "PlayButton"
playButton.Size = UDim2.new(0, 200, 0, 60)
playButton.Position = UDim2.new(0.5, -100, 0.55, 0)
playButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
playButton.BorderSizePixel = 1
playButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
playButton.Text = "PLAY"
playButton.TextColor3 = Color3.fromRGB(220, 220, 220)
playButton.TextSize = 20
playButton.Font = Enum.Font.Code
playButton.BackgroundTransparency = 1
playButton.TextTransparency = 1
playButton.TextStrokeTransparency = 1
playButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
playButton.AutoButtonColor = false
playButton.Parent = menuFrame

-- Set camera to fixed position for menu
local function setupMenuCamera()
	camera.CameraType = Enum.CameraType.Scriptable

	-- Find spawn location or use default position
	local spawnLocation = workspace:FindFirstChild("SpawnLocation")
	if spawnLocation then
		-- Camera: più in alto, spostata verso destra, inquadra a sinistra di 45 gradi
		local cameraPos = spawnLocation.Position + Vector3.new(10, 15, 10)
		local lookAtPos = spawnLocation.Position + Vector3.new(-5, 0, 0)
		camera.CFrame = CFrame.new(cameraPos, lookAtPos)
	else
		-- Default: alto, destra, guarda sinistra
		local cameraPos = Vector3.new(10, 15, 10)
		local lookAtPos = Vector3.new(-5, 0, 0)
		camera.CFrame = CFrame.new(cameraPos, lookAtPos)
	end
end

-- Fade out loading, fade in menu
local function transitionToMenu()
	print("[Menu] Transitioning to main menu...")

	-- Setup camera
	setupMenuCamera()

	-- Fade out loading screen
	local loadingFadeOut = TweenService:Create(
		loadingText,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{TextTransparency = 1, TextStrokeTransparency = 1}
	)

	loadingFadeOut:Play()
	loadingFadeOut.Completed:Wait()

	loadingFrame.Visible = false
	menuFrame.Visible = true

	-- Fade in blur
	local blurTween = TweenService:Create(
		blurEffect,
		TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{Size = 24}
	)
	blurTween:Play()

	-- Fade in menu elements
	local titleFadeIn = TweenService:Create(
		titleLabel,
		TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{TextTransparency = 0, TextStrokeTransparency = 0.8}
	)

	local subtitleFadeIn = TweenService:Create(
		subtitleLabel,
		TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{TextTransparency = 0, TextStrokeTransparency = 0.8}
	)

	local buttonFadeIn = TweenService:Create(
		playButton,
		TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{BackgroundTransparency = 0, TextTransparency = 0, TextStrokeTransparency = 0.8}
	)

	titleFadeIn:Play()
	task.wait(0.2)
	subtitleFadeIn:Play()
	task.wait(0.3)
	buttonFadeIn:Play()

	print("[Menu] Main menu loaded")
end

-- Start game
local function startGame()
	print("[Menu] Starting game...")

	-- Fade out menu
	local titleFadeOut = TweenService:Create(
		titleLabel,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{TextTransparency = 1, TextStrokeTransparency = 1}
	)

	local subtitleFadeOut = TweenService:Create(
		subtitleLabel,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{TextTransparency = 1, TextStrokeTransparency = 1}
	)

	local buttonFadeOut = TweenService:Create(
		playButton,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{BackgroundTransparency = 1, TextTransparency = 1, TextStrokeTransparency = 1}
	)

	local blurFadeOut = TweenService:Create(
		blurEffect,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{Size = 0}
	)

	titleFadeOut:Play()
	subtitleFadeOut:Play()
	buttonFadeOut:Play()
	blurFadeOut:Play()

	buttonFadeOut.Completed:Wait()

	-- Remove blur and restore camera control
	blurEffect:Destroy()
	camera.CameraType = Enum.CameraType.Custom

	-- Destroy menu
	screenGui:Destroy()

	print("[Menu] Game started")
end

-- Button hover effects
playButton.MouseEnter:Connect(function()
	local hoverTween = TweenService:Create(
		playButton,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundColor3 = Color3.fromRGB(50, 50, 50), BorderColor3 = Color3.fromRGB(150, 150, 150)}
	)
	hoverTween:Play()
end)

playButton.MouseLeave:Connect(function()
	local hoverTween = TweenService:Create(
		playButton,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundColor3 = Color3.fromRGB(30, 30, 30), BorderColor3 = Color3.fromRGB(100, 100, 100)}
	)
	hoverTween:Play()
end)

-- Play button click
playButton.MouseButton1Click:Connect(function()
	playButton.Active = false
	startGame()
end)

-- Wait for game to load
task.wait(2) -- Simulate loading time

-- Transition to menu
transitionToMenu()
