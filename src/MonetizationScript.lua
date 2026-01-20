--[[
	MINIMALIST GAME ROOM - Monetization Script

	Handles all dev products and gamepass purchases.
	Ethical but disturbing.

	Place this script in ServerScriptService
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ========================================
-- PRODUCT IDS
-- ========================================

local GAMEPASS_SILENCE = 1676198849

local PRODUCTS = {
	-- Useless donations
	DONATION_5 = 3518100664,
	DONATION_10 = 3518100760,
	DONATION_25 = 3518100838,
	DONATION_50 = 3518100909,

	-- Acknowledgement
	ACKNOWLEDGED = 3518101639,

	-- View log (incomplete)
	VIEW_LOG = 3518101838,

	-- System load (collective guilt)
	SYSTEM_LOAD = 3518102101,

	-- Why (the most meta)
	WHY = 3518102356
}

-- Remote events
local ShowGlobalMessageEvent = Instance.new("RemoteEvent")
ShowGlobalMessageEvent.Name = "ShowGlobalMessage"
ShowGlobalMessageEvent.Parent = ReplicatedStorage

local ShowAcknowledgementEvent = Instance.new("RemoteEvent")
ShowAcknowledgementEvent.Name = "ShowAcknowledgement"
ShowAcknowledgementEvent.Parent = ReplicatedStorage

local ShowLogEvent = Instance.new("RemoteEvent")
ShowLogEvent.Name = "ShowLog"
ShowLogEvent.Parent = ReplicatedStorage

-- Track acknowledgements per session (can only use once)
local AcknowledgementUsed = {}

-- ========================================
-- PRODUCT HANDLERS
-- ========================================

local function handleDonation(player, amount)
	-- No visible effect for the player
	-- Send a cold, global message
	for _, p in ipairs(Players:GetPlayers()) do
		ShowGlobalMessageEvent:FireClient(p, "A contribution was recorded.")
	end

	return true
end

local function handleAcknowledgement(player)
	-- Can only be used once per session
	if AcknowledgementUsed[player.UserId] then
		return false -- Deny purchase
	end

	AcknowledgementUsed[player.UserId] = true

	-- Show cold acknowledgement
	ShowAcknowledgementEvent:FireClient(player)

	return true
end

local function handleViewLog(player)
	-- Show partial log with mysterious "unavailable" entries
	ShowLogEvent:FireClient(player)

	return true
end

local function handleSystemLoad(player)
	-- Global message: creates tension
	for _, p in ipairs(Players:GetPlayers()) do
		ShowGlobalMessageEvent:FireClient(p, "System load increased.")
	end

	return true
end

local function handleWhy(player)
	-- Literally nothing happens
	-- No effect, no log, no UI
	-- People buy it because it's cheap and provocative

	return true
end

-- ========================================
-- PURCHASE PROCESSING
-- ========================================

local function processReceipt(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)

	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local productId = receiptInfo.ProductId
	local success = false

	-- Handle donations
	if productId == PRODUCTS.DONATION_5 then
		success = handleDonation(player, 5)
	elseif productId == PRODUCTS.DONATION_10 then
		success = handleDonation(player, 10)
	elseif productId == PRODUCTS.DONATION_25 then
		success = handleDonation(player, 25)
	elseif productId == PRODUCTS.DONATION_50 then
		success = handleDonation(player, 50)

	-- Acknowledgement
	elseif productId == PRODUCTS.ACKNOWLEDGED then
		success = handleAcknowledgement(player)

	-- View log
	elseif productId == PRODUCTS.VIEW_LOG then
		success = handleViewLog(player)

	-- System load
	elseif productId == PRODUCTS.SYSTEM_LOAD then
		success = handleSystemLoad(player)

	-- Why
	elseif productId == PRODUCTS.WHY then
		success = handleWhy(player)
	end

	if success then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

-- Set callback
MarketplaceService.ProcessReceipt = processReceipt

-- ========================================
-- PLAYER CLEANUP
-- ========================================

Players.PlayerRemoving:Connect(function(player)
	AcknowledgementUsed[player.UserId] = nil
end)

print("Minimalist Game Room - Monetization Script Loaded")
