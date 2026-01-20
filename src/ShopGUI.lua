--[[
	MINIMALIST GAME ROOM - Shop GUI

	Complete shop system with tabs:
	- System Re-write (Gamepass)
	- Logs (Dev Products)
	- Support Logs (Donations + Custom)

	Place this script in StarterPlayer > StarterPlayerScripts
]]

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ========================================
-- PRODUCT IDS
-- ========================================

local GAMEPASS_SILENCE = 1676198849

local PRODUCTS = {
	-- Logs
	ACKNOWLEDGED = 3518101639,
	VIEW_LOG = 3518101838,
	SYSTEM_LOAD = 3518102101,
	WHY = 3518102356,

	-- Support Logs (Donations)
	DONATION_5 = 3518100664,
	DONATION_10 = 3518100760,
	DONATION_25 = 3518100838,
	DONATION_50 = 3518100909
}

-- Custom donation product ID (you need to create this one separately)
local CUSTOM_DONATION_ID = 0 -- Replace with your custom donation product ID

-- ========================================
-- MAIN SCREEN GUI
-- ========================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShopGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- ========================================
-- SHOP BUTTON (Bottom Right)
-- ========================================

local shopButton = Instance.new("TextButton")
shopButton.Name = "ShopButton"
shopButton.Size = UDim2.new(0, 100, 0, 40)
shopButton.Position = UDim2.new(1, -110, 1, -50)
shopButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
shopButton.BorderSizePixel = 1
shopButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
shopButton.Text = "Shop"
shopButton.TextColor3 = Color3.fromRGB(200, 200, 200)
shopButton.TextSize = 16
shopButton.Font = Enum.Font.Code
shopButton.Parent = screenGui

-- ========================================
-- SHOP FRAME (Hidden by default)
-- ========================================

local shopFrame = Instance.new("Frame")
shopFrame.Name = "ShopFrame"
shopFrame.Size = UDim2.new(0, 700, 0, 500)
shopFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
shopFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
shopFrame.BorderSizePixel = 1
shopFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
shopFrame.Visible = false
shopFrame.Parent = screenGui

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
titleBar.BorderSizePixel = 0
titleBar.Parent = shopFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Shop"
titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.Code
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
closeButton.TextSize = 16
closeButton.Font = Enum.Font.Code
closeButton.Parent = titleBar

-- ========================================
-- TAB BUTTONS
-- ========================================

local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, 0, 0, 40)
tabContainer.Position = UDim2.new(0, 0, 0, 40)
tabContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
tabContainer.BorderSizePixel = 0
tabContainer.Parent = shopFrame

local function createTabButton(name, position)
	local btn = Instance.new("TextButton")
	btn.Name = name .. "Tab"
	btn.Size = UDim2.new(0.33, -4, 1, -8)
	btn.Position = UDim2.new((position - 1) * 0.33, 2 + (position - 1) * 4, 0, 4)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.BorderSizePixel = 0
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(150, 150, 150)
	btn.TextSize = 14
	btn.Font = Enum.Font.Code
	btn.Parent = tabContainer
	return btn
end

local systemTab = createTabButton("System Re-write", 1)
local logsTab = createTabButton("Logs", 2)
local supportTab = createTabButton("Support Logs", 3)

-- ========================================
-- CONTENT FRAME
-- ========================================

local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -100)
contentFrame.Position = UDim2.new(0, 10, 0, 90)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 6
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
contentFrame.Parent = shopFrame

-- ========================================
-- HELPER FUNCTIONS
-- ========================================

local function clearContent()
	for _, child in ipairs(contentFrame:GetChildren()) do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end
end

local function createUIListLayout()
	if not contentFrame:FindFirstChild("UIListLayout") then
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 10)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = contentFrame
	end
end

local function updateCanvasSize()
	local layout = contentFrame:FindFirstChild("UIListLayout")
	if layout then
		contentFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end
end

local function setActiveTab(activeButton)
	for _, btn in ipairs(tabContainer:GetChildren()) do
		if btn:IsA("TextButton") then
			if btn == activeButton then
				btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
				btn.TextColor3 = Color3.fromRGB(220, 220, 220)
			else
				btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
				btn.TextColor3 = Color3.fromRGB(150, 150, 150)
			end
		end
	end
end

-- ========================================
-- SYSTEM RE-WRITE TAB (Gamepass)
-- ========================================

local function showSystemRewrite()
	clearContent()
	createUIListLayout()
	setActiveTab(systemTab)

	-- Gamepass container
	local gamepassFrame = Instance.new("Frame")
	gamepassFrame.Name = "GamepassFrame"
	gamepassFrame.Size = UDim2.new(1, -20, 0, 200)
	gamepassFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	gamepassFrame.BorderSizePixel = 1
	gamepassFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
	gamepassFrame.Parent = contentFrame

	-- Gamepass image
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Size = UDim2.new(0, 150, 0, 150)
	imageLabel.Position = UDim2.new(0, 10, 0, 25)
	imageLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	imageLabel.BorderSizePixel = 0
	imageLabel.Parent = gamepassFrame

	-- Fetch gamepass info
	pcall(function()
		local info = MarketplaceService:GetProductInfo(GAMEPASS_SILENCE, Enum.InfoType.GamePass)
		imageLabel.Image = "rbxassetid://" .. info.IconImageAssetId
	end)

	-- Gamepass info
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0, 500, 0, 30)
	nameLabel.Position = UDim2.new(0, 170, 0, 10)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = "Silence"
	nameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	nameLabel.TextSize = 20
	nameLabel.Font = Enum.Font.CodeBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = gamepassFrame

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(0, 500, 0, 60)
	descLabel.Position = UDim2.new(0, 170, 0, 45)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = "For people who don't want to be reminded.\n\nRemoves all timed messages."
	descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	descLabel.TextSize = 14
	descLabel.Font = Enum.Font.Code
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextYAlignment = Enum.TextYAlignment.Top
	descLabel.TextWrapped = true
	descLabel.Parent = gamepassFrame

	local priceLabel = Instance.new("TextLabel")
	priceLabel.Size = UDim2.new(0, 200, 0, 25)
	priceLabel.Position = UDim2.new(0, 170, 0, 115)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Text = "Price: 49 Robux"
	priceLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
	priceLabel.TextSize = 16
	priceLabel.Font = Enum.Font.Code
	priceLabel.TextXAlignment = Enum.TextXAlignment.Left
	priceLabel.Parent = gamepassFrame

	-- Purchase button
	local buyButton = Instance.new("TextButton")
	buyButton.Size = UDim2.new(0, 120, 0, 35)
	buyButton.Position = UDim2.new(0, 170, 0, 150)
	buyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	buyButton.BorderSizePixel = 0
	buyButton.Text = "Purchase"
	buyButton.TextColor3 = Color3.fromRGB(220, 220, 220)
	buyButton.TextSize = 16
	buyButton.Font = Enum.Font.Code
	buyButton.Parent = gamepassFrame

	buyButton.MouseButton1Click:Connect(function()
		MarketplaceService:PromptGamePassPurchase(player, GAMEPASS_SILENCE)
	end)

	updateCanvasSize()
end

-- ========================================
-- LOGS TAB (Dev Products)
-- ========================================

local function createProductCard(name, description, price, productId, yOffset)
	local card = Instance.new("Frame")
	card.Name = name
	card.Size = UDim2.new(1, -20, 0, 100)
	card.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	card.BorderSizePixel = 1
	card.BorderColor3 = Color3.fromRGB(60, 60, 60)
	card.Parent = contentFrame

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -140, 0, 25)
	nameLabel.Position = UDim2.new(0, 10, 0, 10)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = name
	nameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	nameLabel.TextSize = 18
	nameLabel.Font = Enum.Font.CodeBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = card

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -140, 0, 40)
	descLabel.Position = UDim2.new(0, 10, 0, 35)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = description
	descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	descLabel.TextSize = 13
	descLabel.Font = Enum.Font.Code
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextYAlignment = Enum.TextYAlignment.Top
	descLabel.TextWrapped = true
	descLabel.Parent = card

	local priceLabel = Instance.new("TextLabel")
	priceLabel.Size = UDim2.new(0, 120, 0, 20)
	priceLabel.Position = UDim2.new(1, -130, 0, 10)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Text = price .. " Robux"
	priceLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
	priceLabel.TextSize = 16
	priceLabel.Font = Enum.Font.Code
	priceLabel.TextXAlignment = Enum.TextXAlignment.Right
	priceLabel.Parent = card

	local buyButton = Instance.new("TextButton")
	buyButton.Size = UDim2.new(0, 110, 0, 30)
	buyButton.Position = UDim2.new(1, -120, 0, 60)
	buyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	buyButton.BorderSizePixel = 0
	buyButton.Text = "Purchase"
	buyButton.TextColor3 = Color3.fromRGB(220, 220, 220)
	buyButton.TextSize = 14
	buyButton.Font = Enum.Font.Code
	buyButton.Parent = card

	buyButton.MouseButton1Click:Connect(function()
		MarketplaceService:PromptProductPurchase(player, productId)
	end)

	return card
end

local function showLogs()
	clearContent()
	createUIListLayout()
	setActiveTab(logsTab)

	createProductCard(
		"Acknowledged",
		"One-time acknowledgement. No other effects.",
		29,
		PRODUCTS.ACKNOWLEDGED
	)

	createProductCard(
		"View Partial Log",
		"View your session log. Some entries unavailable.",
		59,
		PRODUCTS.VIEW_LOG
	)

	createProductCard(
		"System Load",
		"Increases system load. No visible effects.",
		25,
		PRODUCTS.SYSTEM_LOAD
	)

	createProductCard(
		"Why",
		"Why?",
		9,
		PRODUCTS.WHY
	)

	updateCanvasSize()
end

-- ========================================
-- SUPPORT LOGS TAB (Donations)
-- ========================================

local function showSupportLogs()
	clearContent()
	createUIListLayout()
	setActiveTab(supportTab)

	-- Header
	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, -20, 0, 30)
	header.BackgroundTransparency = 1
	header.Text = "This action has no effect on your session."
	header.TextColor3 = Color3.fromRGB(150, 150, 150)
	header.TextSize = 14
	header.Font = Enum.Font.Code
	header.TextWrapped = true
	header.Parent = contentFrame

	-- Fixed donations
	createProductCard(
		"Support Logging (R$5)",
		"This action has no effect on your session.",
		5,
		PRODUCTS.DONATION_5
	)

	createProductCard(
		"Support Logging (R$10)",
		"This action has no effect on your session.",
		10,
		PRODUCTS.DONATION_10
	)

	createProductCard(
		"Support Logging (R$25)",
		"This action has no effect on your session.",
		25,
		PRODUCTS.DONATION_25
	)

	createProductCard(
		"Support Logging (R$50)",
		"This action has no effect on your session.",
		50,
		PRODUCTS.DONATION_50
	)

	-- Custom donation section
	local customFrame = Instance.new("Frame")
	customFrame.Name = "CustomDonation"
	customFrame.Size = UDim2.new(1, -20, 0, 120)
	customFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	customFrame.BorderSizePixel = 1
	customFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
	customFrame.Parent = contentFrame

	local customTitle = Instance.new("TextLabel")
	customTitle.Size = UDim2.new(1, -20, 0, 25)
	customTitle.Position = UDim2.new(0, 10, 0, 10)
	customTitle.BackgroundTransparency = 1
	customTitle.Text = "Custom Donation"
	customTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
	customTitle.TextSize = 18
	customTitle.Font = Enum.Font.CodeBold
	customTitle.TextXAlignment = Enum.TextXAlignment.Left
	customTitle.Parent = customFrame

	local customDesc = Instance.new("TextLabel")
	customDesc.Size = UDim2.new(1, -20, 0, 30)
	customDesc.Position = UDim2.new(0, 10, 0, 35)
	customDesc.BackgroundTransparency = 1
	customDesc.Text = "Enter custom amount (this feature requires a developer product)"
	customDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
	customDesc.TextSize = 12
	customDesc.Font = Enum.Font.Code
	customDesc.TextXAlignment = Enum.TextXAlignment.Left
	customDesc.TextWrapped = true
	customDesc.Parent = customFrame

	local amountInput = Instance.new("TextBox")
	amountInput.Size = UDim2.new(0, 150, 0, 30)
	amountInput.Position = UDim2.new(0, 10, 0, 75)
	amountInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	amountInput.BorderSizePixel = 1
	amountInput.BorderColor3 = Color3.fromRGB(80, 80, 80)
	amountInput.PlaceholderText = "Amount (Robux)"
	amountInput.Text = ""
	amountInput.TextColor3 = Color3.fromRGB(220, 220, 220)
	amountInput.TextSize = 14
	amountInput.Font = Enum.Font.Code
	amountInput.ClearTextOnFocus = false
	amountInput.Parent = customFrame

	local donateButton = Instance.new("TextButton")
	donateButton.Size = UDim2.new(0, 110, 0, 30)
	donateButton.Position = UDim2.new(0, 170, 0, 75)
	donateButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	donateButton.BorderSizePixel = 0
	donateButton.Text = "Donate"
	donateButton.TextColor3 = Color3.fromRGB(220, 220, 220)
	donateButton.TextSize = 14
	donateButton.Font = Enum.Font.Code
	donateButton.Parent = customFrame

	donateButton.MouseButton1Click:Connect(function()
		local amount = tonumber(amountInput.Text)
		if amount and amount > 0 then
			-- Request custom donation from server
			local CustomDonateFunction = game:GetService("ReplicatedStorage"):WaitForChild("CustomDonate", 2)
			if CustomDonateFunction then
				local result = CustomDonateFunction:InvokeServer(amount)
				if result.success then
					MarketplaceService:PromptProductPurchase(player, result.productId)
					if result.actualAmount ~= amount then
						warn("Closest donation tier: " .. result.actualAmount .. " Robux")
					end
				else
					warn(result.message)
				end
			else
				warn("Custom donation system not available")
			end
		else
			warn("Please enter a valid amount")
		end
	end)

	updateCanvasSize()
end

-- ========================================
-- TAB BUTTON EVENTS
-- ========================================

systemTab.MouseButton1Click:Connect(showSystemRewrite)
logsTab.MouseButton1Click:Connect(showLogs)
supportTab.MouseButton1Click:Connect(showSupportLogs)

-- ========================================
-- SHOP TOGGLE
-- ========================================

local function toggleShop()
	shopFrame.Visible = not shopFrame.Visible
	if shopFrame.Visible then
		showSystemRewrite() -- Default tab
	end
end

shopButton.MouseButton1Click:Connect(toggleShop)
closeButton.MouseButton1Click:Connect(function()
	shopFrame.Visible = false
end)

-- ========================================
-- AUTO-UPDATE CANVAS SIZE
-- ========================================

contentFrame.ChildAdded:Connect(function()
	task.wait(0.1)
	updateCanvasSize()
end)

print("Minimalist Game Room - Shop GUI Loaded")
