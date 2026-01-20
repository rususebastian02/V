--[[
	MINIMALIST GAME ROOM - Custom Donation Handler

	Sistema per donazioni custom usando dev products multipli

	SETUP:
	1. Crea questi dev products su Roblox:
	   - Custom Donation (1R$)
	   - Custom Donation (10R$)
	   - Custom Donation (50R$)
	   - Custom Donation (100R$)
	   - Custom Donation (250R$)
	   - Custom Donation (500R$)

	2. Aggiorna gli ID qui sotto
	3. Inserisci questo script in ServerScriptService

	Place this script in ServerScriptService
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ========================================
-- CUSTOM DONATION PRODUCT IDS
-- ========================================

local CUSTOM_DONATIONS = {
	{amount = 1, productId = 0},    -- Replace with your product ID
	{amount = 10, productId = 0},   -- Replace with your product ID
	{amount = 50, productId = 0},   -- Replace with your product ID
	{amount = 100, productId = 0},  -- Replace with your product ID
	{amount = 250, productId = 0},  -- Replace with your product ID
	{amount = 500, productId = 0}   -- Replace with your product ID
}

-- ========================================
-- REMOTE FUNCTION
-- ========================================

local CustomDonateFunction = Instance.new("RemoteFunction")
CustomDonateFunction.Name = "CustomDonate"
CustomDonateFunction.Parent = ReplicatedStorage

-- Find closest donation tier
local function findClosestDonation(amount)
	local closest = nil
	local minDiff = math.huge

	for _, donation in ipairs(CUSTOM_DONATIONS) do
		if donation.productId ~= 0 then
			local diff = math.abs(donation.amount - amount)
			if diff < minDiff then
				minDiff = diff
				closest = donation
			end
		end
	end

	return closest
end

-- Handle custom donation request
CustomDonateFunction.OnServerInvoke = function(player, amount)
	if type(amount) ~= "number" or amount <= 0 then
		return {success = false, message = "Invalid amount"}
	end

	local donation = findClosestDonation(amount)

	if not donation then
		return {success = false, message = "No donation tier available"}
	end

	-- Return the product to prompt
	return {
		success = true,
		productId = donation.productId,
		actualAmount = donation.amount
	}
end

print("Custom Donation Handler Loaded")
