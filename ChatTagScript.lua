-- Script per aggiungere il tag [VIP] in chat ai giocatori con il game pass
-- VERSIONE PER TEXTCHATSERVICE (Nuovo sistema chat di Roblox)
-- Da inserire in ServerScriptService in Roblox Studio

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TextChatService = game:GetService("TextChatService")

-- ID del Game Pass VIP
local VIP_GAMEPASS_ID = 1656463027

-- Funzione per verificare se un giocatore ha il VIP
local function hasVIPPass(player)
	local success, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, VIP_GAMEPASS_ID)
	end)

	if success then
		return result
	end
	return false
end

-- Modifica i messaggi in chat per aggiungere il tag [VIP]
TextChatService.OnIncomingMessage = function(message: TextChatMessage)
	local properties = Instance.new("TextChatMessageProperties")

	-- Trova il giocatore che ha inviato il messaggio
	local player = Players:GetPlayerByUserId(message.TextSource.UserId)

	if player and hasVIPPass(player) then
		-- Personalizza il messaggio per i VIP
		local prefix = '<font color="#FFD700">[VIP]</font> '
		properties.PrefixText = prefix .. message.PrefixText

		print("✅ Tag [VIP] applicato al messaggio di " .. player.Name)
	end

	return properties
end

print("🌟 Sistema tag VIP in chat attivato!")
