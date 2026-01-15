--[[
    SHOPGUI_SCRIPT.LUA
    Gestisce la Shop GUI per acquistare Gamepass e Dev Products

    Questo script deve essere inserito in StarterGui/ShopGUI come LocalScript
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Moduli
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = require(Modules.Config)

-- Eventi
local Events = ReplicatedStorage:WaitForChild("Events")
local PromptGamepassEvent = Events:WaitForChild("PromptGamepass")
local PromptDevProductEvent = Events:WaitForChild("PromptDevProduct")

-- UI References
local ShopGUI = script.Parent
local MainFrame = ShopGUI:WaitForChild("MainFrame")
local CloseButton = MainFrame:WaitForChild("CloseButton")
local GamepassFrame = MainFrame:WaitForChild("GamepassFrame")
local DevProductsFrame = MainFrame:WaitForChild("DevProductsFrame")
local TabButtons = MainFrame:WaitForChild("TabButtons")
local GamepassTab = TabButtons:WaitForChild("GamepassTab")
local DevProductsTab = TabButtons:WaitForChild("DevProductsTab")

-- Shop toggle button (fuori dal MainFrame)
local ShopButton = ShopGUI:WaitForChild("ShopButton")

print("[ShopGUI] Inizializzato")

-- ==================== TOGGLE SHOP ====================

local isShopOpen = false

local function ToggleShop()
    isShopOpen = not isShopOpen
    MainFrame.Visible = isShopOpen

    if isShopOpen then
        -- Mostra tab gamepass di default
        GamepassFrame.Visible = true
        DevProductsFrame.Visible = false
    end
end

ShopButton.MouseButton1Click:Connect(ToggleShop)
CloseButton.MouseButton1Click:Connect(ToggleShop)

-- ==================== TAB SWITCHING ====================

GamepassTab.MouseButton1Click:Connect(function()
    GamepassFrame.Visible = true
    DevProductsFrame.Visible = false
end)

DevProductsTab.MouseButton1Click:Connect(function()
    GamepassFrame.Visible = false
    DevProductsFrame.Visible = true
end)

-- ==================== POPULATE GAMEPASS ====================

local function CreateGamepassButton(gamepassKey, gamepassInfo, parent)
    local button = Instance.new("TextButton")
    button.Name = gamepassKey .. "Button"
    button.Size = UDim2.new(1, -20, 0, 80)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Text = string.format("%s\n%d R$\n%s",
        gamepassInfo.Name,
        gamepassInfo.Price,
        gamepassInfo.Description)
    button.Parent = parent

    -- Click handler
    button.MouseButton1Click:Connect(function()
        print("[ShopGUI] Richiesta acquisto gamepass: " .. gamepassKey)
        PromptGamepassEvent:FireServer(gamepassKey)
    end)

    return button
end

-- Crea bottoni gamepass
local gamepassContainer = GamepassFrame:WaitForChild("Container")
local gamepassList = Instance.new("UIListLayout")
gamepassList.Padding = UDim.new(0, 10)
gamepassList.Parent = gamepassContainer

for key, info in pairs(Config.Gamepasses) do
    CreateGamepassButton(key, info, gamepassContainer)
end

-- ==================== POPULATE DEV PRODUCTS ====================

local function CreateDevProductButton(productKey, productInfo, parent)
    local button = Instance.new("TextButton")
    button.Name = productKey .. "Button"
    button.Size = UDim2.new(1, -20, 0, 70)
    button.BackgroundColor3 = Color3.fromRGB(60, 100, 60)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true

    local buttonText = productInfo.Name .. "\n" .. productInfo.Price .. " R$"
    if productInfo.Type == "InstantCash" then
        buttonText = string.format("+%s Cash\n%d R$",
            FormatNumber(productInfo.Amount),
            productInfo.Price)
    elseif productInfo.Type == "ServerBoost" then
        buttonText = string.format("Boost %s\n%d R$ (x2 for all!)",
            productInfo.Duration >= 3600 and "1h" or "10min",
            productInfo.Price)
    end

    button.Text = buttonText
    button.Parent = parent

    -- Click handler
    button.MouseButton1Click:Connect(function()
        print("[ShopGUI] Richiesta acquisto dev product: " .. productKey)
        PromptDevProductEvent:FireServer(productKey)
    end)

    return button
end

local function FormatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
end

-- Crea bottoni dev products
local devProductsContainer = DevProductsFrame:WaitForChild("Container")
local devProductsList = Instance.new("UIListLayout")
devProductsList.Padding = UDim.new(0, 10)
devProductsList.Parent = devProductsContainer

for key, info in pairs(Config.DevProducts) do
    CreateDevProductButton(key, info, devProductsContainer)
end

print("[ShopGUI] Shop popolato con prodotti")
