--[[
    DEVPRODUCTSMANAGER.LUA
    Gestisce i 9 dev products:
    - Boost 10 min (server-wide x2 cash)
    - Boost 1h (server-wide x2 cash)
    - Skip Rank
    - 5x Cash packs istantanei
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Config = require(script.Parent.Config)

local DevProductsManager = {}

-- Callback handlers (saranno settati dal server)
local Handlers = {
    OnServerBoostActivated = nil,
    OnSkipRank = nil,
    OnInstantCash = nil,
    OnDonation = nil
}

-- ==================== PROCESS RECEIPT ====================

function DevProductsManager.ProcessReceipt(receiptInfo)
    local player = game.Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then
        -- Player ha lasciato, grant comunque
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end

    local productId = receiptInfo.ProductId
    local product = Config.GetDevProductByID(productId)

    if not product then
        warn("[DevProductsManager] Prodotto sconosciuto: " .. productId)
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    print(string.format("[DevProductsManager] Processing %s per %s", product.Name, player.Name))

    -- Gestisci per tipo
    if product.Type == "ServerBoost" then
        if Handlers.OnServerBoostActivated then
            Handlers.OnServerBoostActivated(player, product)
        end

    elseif product.Type == "SkipRank" then
        if Handlers.OnSkipRank then
            Handlers.OnSkipRank(player)
        end

    elseif product.Type == "InstantCash" then
        if Handlers.OnInstantCash then
            Handlers.OnInstantCash(player, product.Amount)
        end

    elseif product.Type == "Donation" then
        if Handlers.OnDonation then
            Handlers.OnDonation(player, product.Amount)
        end
    end

    return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- ==================== SET HANDLERS ====================

function DevProductsManager.SetServerBoostHandler(handler)
    Handlers.OnServerBoostActivated = handler
end

function DevProductsManager.SetSkipRankHandler(handler)
    Handlers.OnSkipRank = handler
end

function DevProductsManager.SetInstantCashHandler(handler)
    Handlers.OnInstantCash = handler
end

function DevProductsManager.SetDonationHandler(handler)
    Handlers.OnDonation = handler
end

-- ==================== PROMPT PURCHASE ====================

function DevProductsManager.PromptPurchase(player, productKey)
    local product = Config.DevProducts[productKey]
    if not product then
        warn("[DevProductsManager] Prodotto key invalido: " .. tostring(productKey))
        return false
    end

    local success, errorMessage = pcall(function()
        MarketplaceService:PromptProductPurchase(player, product.ID)
    end)

    if not success then
        warn("[DevProductsManager] Errore nel prompt dev product: " .. errorMessage)
        return false
    end

    return true
end

-- ==================== GET INFO ====================

function DevProductsManager.GetProductInfo(productKey)
    return Config.DevProducts[productKey]
end

function DevProductsManager.GetAllProducts()
    return Config.DevProducts
end

function DevProductsManager.GetProductsByType(productType)
    local products = {}
    for key, product in pairs(Config.DevProducts) do
        if product.Type == productType then
            table.insert(products, {Key = key, Product = product})
        end
    end
    return products
end

-- ==================== INITIALIZATION ====================

function DevProductsManager.Init()
    -- Set up ProcessReceipt callback
    MarketplaceService.ProcessReceipt = DevProductsManager.ProcessReceipt
    print("[DevProductsManager] Inizializzato con ProcessReceipt")
end

return DevProductsManager
