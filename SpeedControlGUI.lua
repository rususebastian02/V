-- Speed Control GUI - LocalScript
-- Da mettere in StarterGui come LocalScript

print("⚡ [SpeedControl] Inizializzazione...")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Aspetta o crea la RemoteEvent
local setSpeedEvent = ReplicatedStorage:WaitForChild("SetPlayerSpeed", 10)
if not setSpeedEvent then
	warn("❌ [SpeedControl] RemoteEvent 'SetPlayerSpeed' non trovato!")
	return
end

-- Crea ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedControlGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Bottone per aprire il pannello (in basso a destra)
local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"
openButton.Size = UDim2.new(0, 120, 0, 50)
openButton.Position = UDim2.new(1, -140, 1, -70)
openButton.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
openButton.BorderSizePixel = 0
openButton.Text = "⚙️ Speed"
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.TextSize = 20
openButton.Font = Enum.Font.GothamBold
openButton.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 10)
openCorner.Parent = openButton

-- Pannello controllo velocità (inizialmente nascosto)
local controlPanel = Instance.new("Frame")
controlPanel.Name = "ControlPanel"
controlPanel.Size = UDim2.new(0, 350, 0, 250)
controlPanel.Position = UDim2.new(0.5, -175, 0.5, -125)
controlPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
controlPanel.BorderSizePixel = 0
controlPanel.Visible = false
controlPanel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 15)
panelCorner.Parent = controlPanel

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
header.BorderSizePixel = 0
header.Parent = controlPanel

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 15)
headerCorner.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ Speed Control"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 24
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

-- Info label (mostra speed massima)
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -40, 0, 40)
infoLabel.Position = UDim2.new(0, 20, 0, 70)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Max Speed: Loading..."
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.TextSize = 18
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Parent = controlPanel

-- TextBox per input
local speedInput = Instance.new("TextBox")
speedInput.Name = "SpeedInput"
speedInput.Size = UDim2.new(0, 310, 0, 50)
speedInput.Position = UDim2.new(0, 20, 0, 120)
speedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
speedInput.BorderSizePixel = 0
speedInput.PlaceholderText = "Enter speed value..."
speedInput.Text = ""
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.TextSize = 24
speedInput.Font = Enum.Font.GothamBold
speedInput.ClearTextOnFocus = false
speedInput.Parent = controlPanel

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 10)
inputCorner.Parent = speedInput

-- Bottone Set Speed
local setButton = Instance.new("TextButton")
setButton.Size = UDim2.new(0, 150, 0, 45)
setButton.Position = UDim2.new(0, 20, 0, 185)
setButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
setButton.BorderSizePixel = 0
setButton.Text = "✓ Set Speed"
setButton.TextColor3 = Color3.fromRGB(255, 255, 255)
setButton.TextSize = 20
setButton.Font = Enum.Font.GothamBold
setButton.Parent = controlPanel

local setCorner = Instance.new("UICorner")
setCorner.CornerRadius = UDim.new(0, 10)
setCorner.Parent = setButton

-- Bottone Close
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 140, 0, 45)
closeButton.Position = UDim2.new(0, 190, 0, 185)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.Text = "✕ Close"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 20
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = controlPanel

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = closeButton

print("✅ [SpeedControl] GUI creata")

-- Funzione per ottenere max speed
local function getMaxSpeed()
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local speedValue = leaderstats:FindFirstChild("Speed")
		if speedValue then
			return speedValue.Value
		end
	end
	return 16 -- Default
end

-- Funzione per aggiornare info
local function updateInfo()
	local maxSpeed = getMaxSpeed()
	infoLabel.Text = "Max Speed: " .. math.floor(maxSpeed)
end

-- Funzione per mostrare errore
local function showError()
	local originalText = speedInput.Text
	speedInput.Text = "ERROR"
	speedInput.TextColor3 = Color3.fromRGB(255, 50, 50)
	wait(1)
	speedInput.Text = ""
	speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
end

-- Toggle pannello
openButton.MouseButton1Click:Connect(function()
	controlPanel.Visible = not controlPanel.Visible
	if controlPanel.Visible then
		updateInfo()
		speedInput.Text = ""
	end
end)

-- Chiudi pannello
closeButton.MouseButton1Click:Connect(function()
	controlPanel.Visible = false
	speedInput.Text = ""
end)

-- Set speed
setButton.MouseButton1Click:Connect(function()
	local inputText = speedInput.Text
	local inputNumber = tonumber(inputText)

	if not inputNumber then
		-- Non è un numero
		print("⚠️ [SpeedControl] Input non valido")
		showError()
		return
	end

	local maxSpeed = getMaxSpeed()

	-- Validazione
	if inputNumber < 1 or inputNumber > maxSpeed then
		print("⚠️ [SpeedControl] Speed fuori range: " .. inputNumber .. " (max: " .. maxSpeed .. ")")
		showError()
		return
	end

	-- Invia richiesta al server
	print("✅ [SpeedControl] Impostazione speed a: " .. inputNumber)
	setSpeedEvent:FireServer(inputNumber)

	-- Feedback visivo
	speedInput.Text = "✓ Set!"
	speedInput.TextColor3 = Color3.fromRGB(0, 255, 100)
	wait(0.5)
	speedInput.Text = ""
	speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	controlPanel.Visible = false
end)

-- Effetti hover
local function addHover(button, normalColor, hoverColor)
	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = hoverColor
	end)
	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = normalColor
	end)
end

addHover(openButton, Color3.fromRGB(50, 150, 250), Color3.fromRGB(70, 170, 255))
addHover(setButton, Color3.fromRGB(0, 200, 100), Color3.fromRGB(0, 220, 120))
addHover(closeButton, Color3.fromRGB(200, 50, 50), Color3.fromRGB(220, 70, 70))

print("⚡ [SpeedControl] Sistema attivo!")
