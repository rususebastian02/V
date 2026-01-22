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

-- Crea la vignette (inizialmente disabilitata)
local vignette = Instance.new("DepthOfFieldEffect")
vignette.FarIntensity = 0
vignette.FocusDistance = 0.1
vignette.InFocusRadius = 30
vignette.NearIntensity = 0
vignette.Parent = Lighting
vignette.Enabled = false

-- Crea il suono dei respiri affannosi
local breathingSound = Instance.new("Sound")
breathingSound.SoundId = "rbxasset://sounds/uuhhh.mp3"
breathingSound.Volume = 0.3
breathingSound.Looped = true
breathingSound.Parent = player:WaitForChild("PlayerGui")

-- Crea il suono del vento
local windSound = Instance.new("Sound")
windSound.SoundId = "rbxassetid://3126502868" -- Wind ambient sound
windSound.Volume = 0
windSound.Looped = true
windSound.Parent = workspace
windSound:Play()

-- Crea il suono distante
local distantSound = Instance.new("Sound")
distantSound.SoundId = "rbxassetid://9120386436" -- Distant rumble
distantSound.Volume = 0
distantSound.Looped = true
distantSound.Parent = workspace
distantSound:Play()

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

-- PHASE 1: 20 minutes - Yellow sky, bigger sun, light wind
local function startPhase1()
	print("Phase 1: Yellow sky and light wind")

	local tweenTime = TweenInfo.new(10, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

	-- Yellow sky
	local ambientTween = TweenService:Create(Lighting, tweenTime, {Ambient = Color3.fromRGB(255, 230, 150)})
	ambientTween:Play()

	local outdoorAmbientTween = TweenService:Create(Lighting, tweenTime, {OutdoorAmbient = Color3.fromRGB(255, 240, 180)})
	outdoorAmbientTween:Play()

	-- Bigger/brighter sun
	local brightnessTween = TweenService:Create(Lighting, tweenTime, {Brightness = 2.5})
	brightnessTween:Play()

	local clockTimeTween = TweenService:Create(Lighting, tweenTime, {ClockTime = 14}) -- Afternoon sun
	clockTimeTween:Play()

	-- Light wind sound
	local windVolumeTween = TweenService:Create(windSound, tweenTime, {Volume = 0.15})
	windVolumeTween:Play()
end

-- PHASE 2: 10 minutes - Falling ash, distant sounds
local function startPhase2()
	print("Phase 2: Falling ash and distant sounds")

	local tweenTime = TweenInfo.new(8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

	-- Darker yellow/orange atmosphere
	local ambientTween = TweenService:Create(Lighting, tweenTime, {Ambient = Color3.fromRGB(255, 200, 100)})
	ambientTween:Play()

	local outdoorAmbientTween = TweenService:Create(Lighting, tweenTime, {OutdoorAmbient = Color3.fromRGB(255, 210, 120)})
	outdoorAmbientTween:Play()

	-- Add fog
	local fogColorTween = TweenService:Create(Lighting, tweenTime, {FogColor = Color3.fromRGB(200, 180, 140)})
	fogColorTween:Play()

	local fogEndTween = TweenService:Create(Lighting, tweenTime, {FogEnd = 800})
	fogEndTween:Play()

	-- Increase wind
	local windVolumeTween = TweenService:Create(windSound, tweenTime, {Volume = 0.25})
	windVolumeTween:Play()

	-- Start distant sounds
	local distantVolumeTween = TweenService:Create(distantSound, tweenTime, {Volume = 0.2})
	distantVolumeTween:Play()

	-- Create falling ash particles in the world (massive amounts)
	-- Create a large invisible part high in the sky to emit ash from
	local ashEmitterPart = Instance.new("Part")
	ashEmitterPart.Name = "AshEmitterPart"
	ashEmitterPart.Size = Vector3.new(500, 1, 500) -- Very large area
	ashEmitterPart.Position = Vector3.new(0, 200, 0) -- High in the sky
	ashEmitterPart.Anchored = true
	ashEmitterPart.CanCollide = false
	ashEmitterPart.Transparency = 1
	ashEmitterPart.Parent = workspace

	local ashEmitter = Instance.new("ParticleEmitter")
	ashEmitter.Name = "FallingAsh"
	ashEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
	ashEmitter.Color = ColorSequence.new(Color3.fromRGB(100, 100, 100), Color3.fromRGB(80, 80, 80))
	ashEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 0.4),
		NumberSequenceKeypoint.new(1, 0.3)
	})
	ashEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 0.4),
		NumberSequenceKeypoint.new(1, 1)
	})
	ashEmitter.Lifetime = NumberRange.new(15, 20) -- Longer lifetime to reach ground
	ashEmitter.Rate = 200 -- Massive amount of ash
	ashEmitter.Speed = NumberRange.new(5, 10) -- Moderate fall speed
	ashEmitter.SpreadAngle = Vector2.new(180, 180) -- Spread across the area
	ashEmitter.Rotation = NumberRange.new(0, 360)
	ashEmitter.RotSpeed = NumberRange.new(-100, 100)
	ashEmitter.Acceleration = Vector3.new(0, -10, 0) -- Gravity pull down
	ashEmitter.EmissionDirection = Enum.NormalId.Bottom -- Emit downward
	ashEmitter.Drag = 1
	ashEmitter.VelocityInheritance = 0

	-- Attach to the part in the sky
	ashEmitter.Parent = ashEmitterPart
end

-- PHASE 3: 5 minutes - Heavy breathing, blur, vignette, burning
local function startPhase3()
	print("Phase 3: Burning phase - heavy breathing and screen effects")

	local tweenTime = TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

	-- Deep orange/red atmosphere
	local ambientTween = TweenService:Create(Lighting, tweenTime, {Ambient = apocalypseAmbient})
	ambientTween:Play()

	local outdoorAmbientTween = TweenService:Create(Lighting, tweenTime, {OutdoorAmbient = apocalypseOutdoorAmbient})
	outdoorAmbientTween:Play()

	-- Heavy fog
	local fogColorTween = TweenService:Create(Lighting, tweenTime, {FogColor = apocalypseFogColor})
	fogColorTween:Play()

	local fogEndTween = TweenService:Create(Lighting, tweenTime, {FogEnd = 400})
	fogEndTween:Play()

	-- Brightness increase
	local brightnessTween = TweenService:Create(Lighting, tweenTime, {Brightness = 3})
	brightnessTween:Play()

	-- Orange sunset
	local clockTimeTween = TweenService:Create(Lighting, tweenTime, {ClockTime = 6.5})
	clockTimeTween:Play()

	-- Activate blur
	blurEffect.Enabled = true
	local blurTween = TweenService:Create(blurEffect, tweenTime, {Size = 3})
	blurTween:Play()

	-- Activate vignette
	vignette.Enabled = true
	local vignetteTween = TweenService:Create(vignette, tweenTime, {FarIntensity = 0.3, NearIntensity = 0.15})
	vignetteTween:Play()

	-- Start breathing sound
	breathingSound:Play()

	-- Increase wind to strong
	local windVolumeTween = TweenService:Create(windSound, tweenTime, {Volume = 0.4})
	windVolumeTween:Play()

	-- Increase distant sounds
	local distantVolumeTween = TweenService:Create(distantSound, tweenTime, {Volume = 0.35})
	distantVolumeTween:Play()
end

-- OLD function kept for apocalypse final phase
local function startVisualEffects()
	print("Final apocalypse phase")
	-- This is now triggered at 0:00 when apocalypse actually starts
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

	-- Disattiva vignette
	vignette.Enabled = false
	vignette.FarIntensity = 0
	vignette.NearIntensity = 0

	-- Stop all sounds
	windSound.Volume = 0
	distantSound.Volume = 0
	breathingSound:Stop()

	-- Remove falling ash particles and emitter part
	for _, child in pairs(workspace:GetChildren()) do
		if child.Name == "AshEmitterPart" then
			child:Destroy()
		end
	end

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

-- Function to show dream phrase at start (minimal, eerie style)
local function showDreamPhrase(message)
	local screenGui = player.PlayerGui:FindFirstChild("DreamPhraseGui")
	if not screenGui then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "DreamPhraseGui"
		screenGui.Parent = player.PlayerGui
	end

	-- Remove previous phrases
	for _, child in pairs(screenGui:GetChildren()) do
		child:Destroy()
	end

	-- Create dream phrase text (centered, minimal)
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(0, 600, 0, 80)
	textLabel.Position = UDim2.new(0.5, -300, 0.5, -40)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = message
	textLabel.TextSize = 28
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextTransparency = 1
	textLabel.Font = Enum.Font.Gotham
	textLabel.TextWrapped = true
	textLabel.Parent = screenGui

	-- Slow fade in
	local fadeInTween = TweenService:Create(
		textLabel,
		TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{TextTransparency = 0.2}
	)
	fadeInTween:Play()

	wait(5)

	-- Slow fade out
	local fadeOutTween = TweenService:Create(
		textLabel,
		TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{TextTransparency = 1}
	)
	fadeOutTween:Play()
	fadeOutTween.Completed:Wait()
	textLabel:Destroy()
end

-- Function to show badge unlock notification
local function showBadgeUnlock(badgeName)
	local screenGui = player.PlayerGui:FindFirstChild("BadgeUnlockGui")
	if not screenGui then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "BadgeUnlockGui"
		screenGui.Parent = player.PlayerGui
	end

	-- Remove previous notifications
	for _, child in pairs(screenGui:GetChildren()) do
		child:Destroy()
	end

	-- Create badge notification (elegant design)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 350, 0, 100)
	frame.Position = UDim2.new(0.5, -175, 0.8, 0)
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.BackgroundTransparency = 0.3
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0.4, 0)
	title.Position = UDim2.new(0, 0, 0.1, 0)
	title.BackgroundTransparency = 1
	title.Text = "Badge Unlocked!"
	title.TextSize = 20
	title.TextColor3 = Color3.fromRGB(255, 215, 0)
	title.Font = Enum.Font.GothamBold
	title.Parent = frame

	local badgeLabel = Instance.new("TextLabel")
	badgeLabel.Size = UDim2.new(1, 0, 0.4, 0)
	badgeLabel.Position = UDim2.new(0, 0, 0.5, 0)
	badgeLabel.BackgroundTransparency = 1
	badgeLabel.Text = badgeName
	badgeLabel.TextSize = 18
	badgeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	badgeLabel.Font = Enum.Font.Gotham
	badgeLabel.Parent = frame

	-- Slide up animation
	frame.Position = UDim2.new(0.5, -175, 1.2, 0)
	local slideUpTween = TweenService:Create(
		frame,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Position = UDim2.new(0.5, -175, 0.8, 0)}
	)
	slideUpTween:Play()

	wait(5)

	-- Slide down and fade out
	local slideDownTween = TweenService:Create(
		frame,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In),
		{Position = UDim2.new(0.5, -175, 1.2, 0), BackgroundTransparency = 1}
	)
	slideDownTween:Play()

	local titleFadeTween = TweenService:Create(
		title,
		TweenInfo.new(0.5),
		{TextTransparency = 1}
	)
	titleFadeTween:Play()

	local badgeFadeTween = TweenService:Create(
		badgeLabel,
		TweenInfo.new(0.5),
		{TextTransparency = 1}
	)
	badgeFadeTween:Play()

	badgeFadeTween.Completed:Wait()
	screenGui:Destroy()
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
	if action == "phase_1" then
		startPhase1()
	elseif action == "phase_2" then
		startPhase2()
	elseif action == "phase_3" then
		startPhase3()
	elseif action == "music_start" then
		startMusicEffects()
	elseif action == "start" then
		startVisualEffects()
	elseif action == "ash" then
		-- Activate player burning particles (handled by particles script)
	elseif action == "reset" then
		resetVisualEffects()
	elseif action == "announcement" then
		showAnnouncement(data)
	elseif action == "dream_phrase" then
		showDreamPhrase(data)
	elseif action == "badge_unlocked" then
		showBadgeUnlock(data)
	end
end)

print("Apocalypse client effects loaded")
