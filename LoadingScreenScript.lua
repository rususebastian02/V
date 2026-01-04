-- Loading Screen Script
-- Da mettere in StarterGui come LocalScript

print("🎬 [LoadingScreen] Inizializzazione...")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configurazione
local LOADING_DURATION = 5 -- Durata in secondi
local BACKGROUND_IMAGE_ID = "rbxassetid://96435324041848" -- Il tuo asset ID

-- Crea lo ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LoadingScreen"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999 -- Sopra tutto
screenGui.Parent = playerGui

-- Frame principale (sfondo con immagine)
local background = Instance.new("ImageLabel")
background.Name = "Background"
background.Size = UDim2.new(1, 0, 1, 0)
background.Position = UDim2.new(0, 0, 0, 0)
background.BackgroundTransparency = 1
background.Image = BACKGROUND_IMAGE_ID
background.ScaleType = Enum.ScaleType.Stretch
background.Parent = screenGui

-- Testo "Loading"
local loadingText = Instance.new("TextLabel")
loadingText.Name = "LoadingText"
loadingText.Size = UDim2.new(0, 400, 0, 100)
loadingText.Position = UDim2.new(0.5, -200, 0.5, -50)
loadingText.BackgroundTransparency = 1
loadingText.Text = "Loading"
loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingText.TextSize = 48
loadingText.Font = Enum.Font.GothamBold
loadingText.TextXAlignment = Enum.TextXAlignment.Center
loadingText.TextYAlignment = Enum.TextYAlignment.Middle
loadingText.Parent = background

-- Aggiungi ombra al testo (opzionale ma carino)
loadingText.TextStrokeTransparency = 0.5
loadingText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

print("✅ [LoadingScreen] GUI creata")

-- Animazione dei puntini
local dots = 0
local dotAnimation = coroutine.create(function()
	while true do
		dots = (dots % 3) + 1
		local dotString = string.rep(".", dots)
		loadingText.Text = "Loading " .. dotString
		wait(0.5) -- Cambia puntino ogni 0.5 secondi
	end
end)

-- Avvia l'animazione dei puntini
coroutine.resume(dotAnimation)

print("🎬 [LoadingScreen] Animazione puntini avviata")

-- Aspetta la durata del loading
wait(LOADING_DURATION)

-- Ferma l'animazione dei puntini (non più necessario, ma per pulizia)
-- coroutine.close(dotAnimation) -- Non supportato in Lua 5.1, quindi ignoriamo

print("🎬 [LoadingScreen] Inizio animazione swipe up")

-- Animazione Swipe Up
local tweenInfo = TweenInfo.new(
	0.8, -- Durata animazione (0.8 secondi)
	Enum.EasingStyle.Quint, -- Stile easing (smooth)
	Enum.EasingDirection.In, -- Direzione (accelera verso la fine)
	0, -- Ripetizioni
	false, -- Reverse
	0 -- Delay
)

-- Tween per far scorrere tutto verso l'alto
local tween = TweenService:Create(background, tweenInfo, {
	Position = UDim2.new(0, 0, -1, 0) -- Si sposta completamente fuori schermo in alto
})

-- Avvia il tween
tween:Play()

-- Quando l'animazione finisce, distruggi la GUI
tween.Completed:Connect(function()
	print("✅ [LoadingScreen] Animazione completata, rimozione GUI")
	screenGui:Destroy()
end)

print("🎬 [LoadingScreen] Loading screen attivo!")
