-- Style Selection GUI - Record of Ragnarok
-- Da mettere in StarterGui come LocalScript

print("⚔️ [StyleSelector] Inizializzazione...")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Aspetta RemoteEvent per selezione stile
local selectStyleEvent = ReplicatedStorage:WaitForChild("SelectStyle", 10)
if not selectStyleEvent then
	warn("❌ [StyleSelector] RemoteEvent 'SelectStyle' non trovato!")
	return
end

-- Configurazione stili
local STYLES = {
	Gods = {
		{Name = "Poseidon", Desc = "God of the Sea", Color = Color3.fromRGB(30, 100, 200), Icon = "🔱"},
		{Name = "Zeus", Desc = "King of the Gods", Color = Color3.fromRGB(255, 215, 0), Icon = "⚡"},
		{Name = "Shiva", Desc = "God of Destruction", Color = Color3.fromRGB(150, 50, 200), Icon = "🔥"},
		{Name = "Thor", Desc = "God of Thunder", Color = Color3.fromRGB(100, 150, 255), Icon = "⚒️"},
		{Name = "Hades", Desc = "God of the Underworld", Color = Color3.fromRGB(100, 0, 150), Icon = "💀"}
	},
	Humans = {
		{Name = "Adam", Desc = "Father of Humanity", Color = Color3.fromRGB(200, 150, 100), Icon = "👁️"},
		{Name = "Qin Shi Huang", Desc = "First Emperor", Color = Color3.fromRGB(255, 200, 50), Icon = "👑"},
		{Name = "Jack the Ripper", Desc = "The Ripper", Color = Color3.fromRGB(150, 0, 0), Icon = "🔪"},
		{Name = "Lü Bu", Desc = "Flying General", Color = Color3.fromRGB(200, 50, 50), Icon = "🗡️"},
		{Name = "Buddha", Desc = "The Enlightened", Color = Color3.fromRGB(255, 180, 100), Icon = "🕉️"}
	}
}

-- Crea ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StyleSelectionGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 100
screenGui.Parent = playerGui

-- Background scuro
local background = Instance.new("Frame")
background.Name = "Background"
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
background.BorderSizePixel = 0
background.Parent = screenGui

-- Titolo principale
local mainTitle = Instance.new("TextLabel")
mainTitle.Size = UDim2.new(0, 600, 0, 80)
mainTitle.Position = UDim2.new(0.5, -300, 0, 40)
mainTitle.BackgroundTransparency = 1
mainTitle.Text = "⚔️ RECORD OF RAGNAROK ⚔️"
mainTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
mainTitle.TextSize = 42
mainTitle.Font = Enum.Font.GothamBold
mainTitle.TextStrokeTransparency = 0.5
mainTitle.Parent = background

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(0, 600, 0, 40)
subtitle.Position = UDim2.new(0.5, -300, 0, 120)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Choose Your Fighter"
subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
subtitle.TextSize = 24
subtitle.Font = Enum.Font.Gotham
subtitle.Parent = background

-- Container principale per le categorie
local categoriesContainer = Instance.new("Frame")
categoriesContainer.Size = UDim2.new(0, 1400, 0, 600)
categoriesContainer.Position = UDim2.new(0.5, -700, 0, 180)
categoriesContainer.BackgroundTransparency = 1
categoriesContainer.Parent = background

-- Funzione per creare una categoria
local function createCategory(categoryName, stylesList, xOffset)
	local categoryFrame = Instance.new("Frame")
	categoryFrame.Name = categoryName .. "Category"
	categoryFrame.Size = UDim2.new(0, 650, 1, 0)
	categoryFrame.Position = UDim2.new(0, xOffset, 0, 0)
	categoryFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	categoryFrame.BorderSizePixel = 0
	categoryFrame.Parent = categoriesContainer

	local categoryCorner = Instance.new("UICorner")
	categoryCorner.CornerRadius = UDim.new(0, 15)
	categoryCorner.Parent = categoryFrame

	-- Header categoria
	local categoryHeader = Instance.new("Frame")
	categoryHeader.Size = UDim2.new(1, 0, 0, 80)
	categoryHeader.BackgroundColor3 = categoryName == "Gods" and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(200, 50, 50)
	categoryHeader.BorderSizePixel = 0
	categoryHeader.Parent = categoryFrame

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 15)
	headerCorner.Parent = categoryHeader

	local categoryTitle = Instance.new("TextLabel")
	categoryTitle.Size = UDim2.new(1, 0, 1, 0)
	categoryTitle.BackgroundTransparency = 1
	categoryTitle.Text = categoryName == "Gods" and "⚡ GODS ⚡" or "👤 HUMANS 👤"
	categoryTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	categoryTitle.TextSize = 36
	categoryTitle.Font = Enum.Font.GothamBold
	categoryTitle.Parent = categoryHeader

	-- Container stili
	local stylesContainer = Instance.new("ScrollingFrame")
	stylesContainer.Size = UDim2.new(1, -20, 1, -100)
	stylesContainer.Position = UDim2.new(0, 10, 0, 90)
	stylesContainer.BackgroundTransparency = 1
	stylesContainer.BorderSizePixel = 0
	stylesContainer.ScrollBarThickness = 8
	stylesContainer.CanvasSize = UDim2.new(0, 0, 0, #stylesList * 110)
	stylesContainer.Parent = categoryFrame

	-- Crea card per ogni stile
	for i, style in ipairs(stylesList) do
		local styleCard = Instance.new("TextButton")
		styleCard.Name = style.Name
		styleCard.Size = UDim2.new(1, -10, 0, 100)
		styleCard.Position = UDim2.new(0, 5, 0, (i - 1) * 110)
		styleCard.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
		styleCard.BorderSizePixel = 0
		styleCard.AutoButtonColor = false
		styleCard.Text = ""
		styleCard.Parent = stylesContainer

		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = UDim.new(0, 12)
		cardCorner.Parent = styleCard

		-- Icona stile
		local iconLabel = Instance.new("TextLabel")
		iconLabel.Size = UDim2.new(0, 80, 0, 80)
		iconLabel.Position = UDim2.new(0, 10, 0, 10)
		iconLabel.BackgroundColor3 = style.Color
		iconLabel.BorderSizePixel = 0
		iconLabel.Text = style.Icon
		iconLabel.TextSize = 48
		iconLabel.Font = Enum.Font.GothamBold
		iconLabel.Parent = styleCard

		local iconCorner = Instance.new("UICorner")
		iconCorner.CornerRadius = UDim.new(0, 10)
		iconCorner.Parent = iconLabel

		-- Nome stile
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, -110, 0, 40)
		nameLabel.Position = UDim2.new(0, 100, 0, 15)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = style.Name
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextSize = 28
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = styleCard

		-- Descrizione
		local descLabel = Instance.new("TextLabel")
		descLabel.Size = UDim2.new(1, -110, 0, 30)
		descLabel.Position = UDim2.new(0, 100, 0, 55)
		descLabel.BackgroundTransparency = 1
		descLabel.Text = style.Desc
		descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
		descLabel.TextSize = 18
		descLabel.Font = Enum.Font.Gotham
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.Parent = styleCard

		-- Effetto hover
		styleCard.MouseEnter:Connect(function()
			styleCard.BackgroundColor3 = style.Color
		end)

		styleCard.MouseLeave:Connect(function()
			styleCard.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
		end)

		-- Click per selezionare
		styleCard.MouseButton1Click:Connect(function()
			print("⚔️ [StyleSelector] Selezionato: " .. style.Name)

			-- Feedback visivo
			styleCard.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			wait(0.3)

			-- Invia al server
			selectStyleEvent:FireServer(style.Name, categoryName)

			-- Nascondi GUI
			screenGui.Enabled = false
		end)
	end
end

-- Crea entrambe le categorie
createCategory("Gods", STYLES.Gods, 0)
createCategory("Humans", STYLES.Humans, 750)

print("✅ [StyleSelector] GUI creata e pronta!")
