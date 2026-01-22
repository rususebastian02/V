-- POSIZIONA QUESTO SCRIPT IN: StarterPlayer > StarterPlayerScripts
-- Script client per gli effetti visivi dell'apocalisse

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Aspetta che gli eventi remoti siano disponibili
local apocalypseEvent = ReplicatedStorage:WaitForChild("ApocalypseEvent")

-- Crea il blur effect (disabilitato di default)
local blurEffect = Instance.new("BlurEffect")
blurEffect.Size = 0
blurEffect.Parent = Lighting
blurEffect.Enabled = false

-- Crea il color correction per il contrasto
local colorCorrection = Instance.new("ColorCorrectionEffect")
colorCorrection.Contrast = 0
colorCorrection.Parent = Lighting
colorCorrection.Enabled = false

-- Salva le impostazioni originali del Lighting
local originalAmbient = Lighting.Ambient
local originalOutdoorAmbient = Lighting.OutdoorAmbient
local originalBrightness = Lighting.Brightness
local originalClockTime = Lighting.ClockTime
local originalFogEnd = Lighting.FogEnd
local originalFogColor = Lighting.FogColor

-- Colori apocalittici (giallo/arancio)
local apocalypseAmbient = Color3.fromRGB(255, 150, 50)
local apocalypseOutdoorAmbient = Color3.fromRGB(255, 180, 80)
local apocalypseFogColor = Color3.fromRGB(255, 140, 40)

-- Funzione per avviare gli effetti visivi dell'apocalisse
local function startVisualEffects()
	print("Visual effects activated")

	-- Attiva il blur molto leggero
	blurEffect.Enabled = true
	local blurTween = TweenService:Create(
		blurEffect,
		TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{Size = 3} -- Blur molto leggero
	)
	blurTween:Play()

	-- Cambia l'atmosfera con tween
	local lightingTweenInfo = TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

	-- Tween per Ambient
	local ambientTween = TweenService:Create(
		Lighting,
		lightingTweenInfo,
		{Ambient = apocalypseAmbient}
	)
	ambientTween:Play()

	-- Tween per OutdoorAmbient
	local outdoorAmbientTween = TweenService:Create(
		Lighting,
		lightingTweenInfo,
		{OutdoorAmbient = apocalypseOutdoorAmbient}
	)
	outdoorAmbientTween:Play()

	-- Tween per Brightness
	local brightnessTween = TweenService:Create(
		Lighting,
		lightingTweenInfo,
		{Brightness = 3}
	)
	brightnessTween:Play()

	-- Tween per FogColor
	local fogColorTween = TweenService:Create(
		Lighting,
		lightingTweenInfo,
		{FogColor = apocalypseFogColor}
	)
	fogColorTween:Play()

	-- Tween per FogEnd
	local fogEndTween = TweenService:Create(
		Lighting,
		lightingTweenInfo,
		{FogEnd = 500}
	)
	fogEndTween:Play()

	-- Rendi il cielo più arancione/giallo
	local clockTimeTween = TweenService:Create(
		Lighting,
		lightingTweenInfo,
		{ClockTime = 6.5} -- Alba/Tramonto
	)
	clockTimeTween:Play()
end

-- Funzione per resettare gli effetti visivi
local function resetVisualEffects()
	print("Visual effects reset")

	-- Disattiva il blur
	blurEffect.Enabled = false
	blurEffect.Size = 0

	-- Disattiva il contrasto
	colorCorrection.Enabled = false
	colorCorrection.Contrast = 0

	-- Ripristina le impostazioni originali del Lighting
	Lighting.Ambient = originalAmbient
	Lighting.OutdoorAmbient = originalOutdoorAmbient
	Lighting.Brightness = originalBrightness
	Lighting.ClockTime = originalClockTime
	Lighting.FogEnd = originalFogEnd
	Lighting.FogColor = originalFogColor
end

-- Funzione per attivare blur e contrasto quando parte la musica
local function startMusicEffects()
	print("Music effects activated - increasing blur and contrast")

	-- Aumenta il blur di +1 (da 3 a 4) con fade in
	local currentBlurSize = blurEffect.Size
	local blurTween = TweenService:Create(
		blurEffect,
		TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{Size = currentBlurSize + 1}
	)
	blurTween:Play()

	-- Attiva e aumenta il contrasto di +1 con fade in
	colorCorrection.Enabled = true
	local contrastTween = TweenService:Create(
		colorCorrection,
		TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{Contrast = 1}
	)
	contrastTween:Play()
end

-- Function to show announcements (minimal style)
local function showAnnouncement(message)
	local screenGui = player.PlayerGui:FindFirstChild("AnnouncementGui")
	if not screenGui then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "AnnouncementGui"
		screenGui.Parent = player.PlayerGui
	end

	-- Remove previous announcements
	for _, child in pairs(screenGui:GetChildren()) do
		child:Destroy()
	end

	-- Create announcement text (minimal design)
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(0, 400, 0, 50)
	textLabel.Position = UDim2.new(0.5, -200, 0.3, 0)
	textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.BackgroundTransparency = 0.5
	textLabel.BorderSizePixel = 0
	textLabel.Text = message
	textLabel.TextSize = 24
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextTransparency = 0
	textLabel.Font = Enum.Font.Gotham
	textLabel.Parent = screenGui

	-- Subtle rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = textLabel

	-- Simple fade in/out
	textLabel.BackgroundTransparency = 1
	textLabel.TextTransparency = 1

	local fadeInTween = TweenService:Create(
		textLabel,
		TweenInfo.new(0.3),
		{TextTransparency = 0, BackgroundTransparency = 0.5}
	)
	fadeInTween:Play()

	wait(2.5)

	local fadeOutTween = TweenService:Create(
		textLabel,
		TweenInfo.new(0.3),
		{TextTransparency = 1, BackgroundTransparency = 1}
	)
	fadeOutTween:Play()
	fadeOutTween.Completed:Wait()
	textLabel:Destroy()
end

-- Ascolta gli eventi dal server
apocalypseEvent.OnClientEvent:Connect(function(action, data)
	if action == "start" then
		startVisualEffects()
	elseif action == "reset" then
		resetVisualEffects()
	elseif action == "announcement" then
		showAnnouncement(data)
	elseif action == "music_start" then
		startMusicEffects()
	end
end)

print("Apocalypse client effects loaded")
