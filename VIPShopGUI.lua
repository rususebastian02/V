-- GUI Shop VIP per acquisto Game Pass in-game
-- Da inserire in StarterGui o StarterPlayer > StarterPlayerScripts come LocalScript
-- Questo script crea automaticamente la GUI quando il giocatore entra

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ID del Game Pass VIP
local VIP_GAMEPASS_ID = 1656463027

-- Crea lo ScreenGui principale
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VIPShopGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Frame principale (shop)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(1, -420, 0.5, -250) -- Centro-destra con margine 20px
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false -- Nascosto all'inizio
mainFrame.Parent = screenGui

-- Arrotonda gli angoli
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 15)
uiCorner.Parent = mainFrame

-- Header dorato
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 80)
header.BackgroundColor3 = Color3.fromRGB(255, 215, 0) -- Oro
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 15)
headerCorner.Parent = header

-- Titolo
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🌟 VIP PASS 🌟"
title.TextColor3 = Color3.fromRGB(30, 30, 35)
title.Font = Enum.Font.GothamBold
title.TextSize = 32
title.Parent = header

-- Descrizione vantaggi
local descriptionFrame = Instance.new("Frame")
descriptionFrame.Name = "Description"
descriptionFrame.Size = UDim2.new(1, -40, 0, 280)
descriptionFrame.Position = UDim2.new(0, 20, 0, 100)
descriptionFrame.BackgroundTransparency = 1
descriptionFrame.Parent = mainFrame

-- Testo vantaggi
local benefitsText = Instance.new("TextLabel")
benefitsText.Name = "Benefits"
benefitsText.Size = UDim2.new(1, 0, 0, 240)
benefitsText.BackgroundTransparency = 1
benefitsText.Text = [[Become VIP and get:

✨ +50% Speed Bonus
   (+1.5 instead of +1 per second)

💬 Golden [VIP] Chat Tag
   Stand out from other players!

⚡ Exclusive Benefits
   Faster = More fun!

🎯 Support the Developer]]
benefitsText.TextColor3 = Color3.fromRGB(255, 255, 255)
benefitsText.Font = Enum.Font.Gotham
benefitsText.TextSize = 16
benefitsText.TextXAlignment = Enum.TextXAlignment.Left
benefitsText.TextYAlignment = Enum.TextYAlignment.Top
benefitsText.Parent = descriptionFrame

-- Pulsante Acquista
local buyButton = Instance.new("TextButton")
buyButton.Name = "BuyButton"
buyButton.Size = UDim2.new(0, 300, 0, 60)
buyButton.Position = UDim2.new(0.5, -150, 0, 390)
buyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 80) -- Verde
buyButton.BorderSizePixel = 0
buyButton.Text = "💎 BUY VIP"
buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
buyButton.Font = Enum.Font.GothamBold
buyButton.TextSize = 22
buyButton.Parent = mainFrame

local buyButtonCorner = Instance.new("UICorner")
buyButtonCorner.CornerRadius = UDim.new(0, 10)
buyButtonCorner.Parent = buyButton

-- Pulsante Chiudi
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -50, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 24
closeButton.Parent = mainFrame

local closeButtonCorner = Instance.new("UICorner")
closeButtonCorner.CornerRadius = UDim.new(0, 10)
closeButtonCorner.Parent = closeButton

-- Pulsante per aprire la GUI (sempre visibile) - IMMAGINE PERSONALIZZATA
local openButton = Instance.new("ImageButton")
openButton.Name = "OpenButton"
openButton.Size = UDim2.new(0, 120, 0, 120) -- Quadrato per l'immagine
openButton.Position = UDim2.new(1, -140, 0, 20)
openButton.BackgroundTransparency = 1 -- Trasparente per mostrare solo l'immagine
openButton.BorderSizePixel = 0
openButton.Image = "rbxassetid://126083617423149" -- La tua immagine personalizzata
openButton.ScaleType = Enum.ScaleType.Fit -- Adatta l'immagine mantenendo le proporzioni
openButton.Parent = screenGui

-- Funzione per verificare se il giocatore ha già il VIP
local function checkIfPlayerHasVIP()
	local success, hasPass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, VIP_GAMEPASS_ID)
	end)

	if success and hasPass then
		-- Nascondi il pulsante di apertura se è già VIP
		openButton.Visible = false
		mainFrame.Visible = false
		return true
	end
	return false
end

-- Funzione per aprire il prompt di acquisto
local function promptPurchase()
	local success, errorMessage = pcall(function()
		MarketplaceService:PromptGamePassPurchase(player, VIP_GAMEPASS_ID)
	end)

	if not success then
		warn("Errore nell'aprire il prompt di acquisto: " .. tostring(errorMessage))
	end
end

-- Eventi per i pulsanti
buyButton.MouseButton1Click:Connect(function()
	promptPurchase()
end)

closeButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)

openButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = true
end)

-- Effetti hover sui pulsanti
local function addHoverEffect(button, normalColor, hoverColor)
	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = hoverColor
	end)

	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = normalColor
	end)
end

addHoverEffect(buyButton, Color3.fromRGB(0, 200, 80), Color3.fromRGB(0, 220, 100))
addHoverEffect(closeButton, Color3.fromRGB(200, 50, 50), Color3.fromRGB(220, 70, 70))

-- Effetto hover per ImageButton (scala l'immagine)
openButton.MouseEnter:Connect(function()
	openButton.Size = UDim2.new(0, 130, 0, 130) -- Ingrandisce leggermente
end)

openButton.MouseLeave:Connect(function()
	openButton.Size = UDim2.new(0, 120, 0, 120) -- Torna alla dimensione normale
end)

-- Gestisci l'acquisto completato
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(playerWhoJustPurchased, purchasedPassId, wasPurchaseSuccessful)
	if playerWhoJustPurchased == player and purchasedPassId == VIP_GAMEPASS_ID then
		if wasPurchaseSuccessful then
			-- Acquisto riuscito!
			mainFrame.Visible = false
			openButton.Visible = false

			-- Messaggio di conferma
			local confirmLabel = Instance.new("TextLabel")
			confirmLabel.Size = UDim2.new(0, 300, 0, 100)
			confirmLabel.Position = UDim2.new(0.5, -150, 0.5, -50)
			confirmLabel.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
			confirmLabel.BorderSizePixel = 0
			confirmLabel.Text = "✅ VIP PURCHASED!\nWelcome to VIP! 🌟"
			confirmLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			confirmLabel.Font = Enum.Font.GothamBold
			confirmLabel.TextSize = 20
			confirmLabel.Parent = screenGui

			local confirmCorner = Instance.new("UICorner")
			confirmCorner.CornerRadius = UDim.new(0, 10)
			confirmCorner.Parent = confirmLabel

			-- Rimuovi il messaggio dopo 3 secondi
			wait(3)
			confirmLabel:Destroy()
		end
	end
end)

-- Controlla all'avvio se il giocatore ha già il VIP
checkIfPlayerHasVIP()

print("✅ GUI VIP Shop caricata!")
