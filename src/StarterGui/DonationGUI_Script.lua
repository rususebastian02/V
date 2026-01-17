--[[
    DONATIONGUI_SCRIPT.LUA
    Gestisce la Donation GUI con 5 prodotti di donazione
    Ordinati dal più basso al più alto prezzo

    Questo script deve essere inserito in StarterGui/DonationGUI come LocalScript
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
local PromptDevProductEvent = Events:WaitForChild("PromptDevProduct")

-- UI References
local DonationGUI = script.Parent
local MainFrame = DonationGUI:WaitForChild("MainFrame")
local CloseButton = MainFrame:WaitForChild("CloseButton")
local DonationContainer = MainFrame:WaitForChild("DonationContainer")

-- Donation toggle button (fuori dal MainFrame)
local DonationButton = DonationGUI:WaitForChild("DonationButton")

-- ==================== TOGGLE DONATION ====================

local isDonationOpen = false

local function ToggleDonation()
    isDonationOpen = not isDonationOpen
    MainFrame.Visible = isDonationOpen
end

DonationButton.MouseButton1Click:Connect(ToggleDonation)
CloseButton.MouseButton1Click:Connect(ToggleDonation)

-- ==================== CREATE DONATION BUTTON ====================

local function CreateDonationButton(productKey, productInfo, layoutOrder, parent)
    local button = Instance.new("TextButton")
    button.Name = productKey .. "Button"
    button.Size = UDim2.new(1, -20, 0, 80)
    button.BackgroundColor3 = Color3.fromRGB(255, 215, 0) -- Gold color
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.TextScaled = true
    button.LayoutOrder = layoutOrder
    button.Text = string.format("💎 %d Robux 💎\nBuy", productInfo.Price)
    button.Parent = parent

    -- Hover effects
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(255, 255, 100)
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    end)

    -- Click handler
    button.MouseButton1Click:Connect(function()
        print("[DonationGUI] Donation requested: " .. productKey)
        PromptDevProductEvent:FireServer(productKey)
    end)

    return button
end

-- ==================== POPULATE DONATIONS ====================

-- Create UIListLayout if doesn't exist
if not DonationContainer:FindFirstChildOfClass("UIListLayout") then
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 10)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = DonationContainer
end

-- Ordine dei prodotti di donazione (dal più basso al più alto)
local donationOrder = {
    "Donation10",
    "Donation100",
    "Donation1K",
    "Donation10K",
    "Donation100K"
}

-- Crea i bottoni in ordine
for i, productKey in ipairs(donationOrder) do
    local productInfo = Config.DevProducts[productKey]
    if productInfo then
        CreateDonationButton(productKey, productInfo, i, DonationContainer)
    else
        warn("[DonationGUI] Prodotto non trovato: " .. productKey)
    end
end

print("[DonationGUI] Donation GUI initialized!")
