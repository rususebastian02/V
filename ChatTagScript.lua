-- Script per aggiungere tag personalizzate in chat (Owner, Admin, VIP)
-- VERSIONE PER TEXTCHATSERVICE (Nuovo sistema chat di Roblox)
-- Da inserire in ServerScriptService in Roblox Studio

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TextChatService = game:GetService("TextChatService")

-- ID del Game Pass VIP
local VIP_GAMEPASS_ID = 1656463027

-- ========================================
-- SEZIONE MODIFICABILE: Inserisci qui gli ID dei giocatori
-- ========================================

-- Lista degli ID giocatori OWNER (Tag rosso scuro)
local OWNER_IDS = {
	-- Aggiungi qui gli ID dei giocatori Owner
	-- Esempio: 123456789, 987654321
}

-- Lista degli ID giocatori ADMIN (Tag rosso)
local ADMIN_IDS = {
	-- Aggiungi qui gli ID dei giocatori Admin
	-- Esempio: 111222333, 444555666
}

-- ========================================
-- FINE SEZIONE MODIFICABILE
-- ========================================

-- Funzione per verificare se un giocatore è Owner
local function isOwner(player)
	for _, id in ipairs(OWNER_IDS) do
		if player.UserId == id then
			return true
		end
	end
	return false
end

-- Funzione per verificare se un giocatore è Admin
local function isAdmin(player)
	for _, id in ipairs(ADMIN_IDS) do
		if player.UserId == id then
			return true
		end
	end
	return false
end

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

-- Modifica i messaggi in chat per aggiungere i tag
TextChatService.OnIncomingMessage = function(message: TextChatMessage)
	local properties = Instance.new("TextChatMessageProperties")

	-- Trova il giocatore che ha inviato il messaggio
	local player = Players:GetPlayerByUserId(message.TextSource.UserId)

	if player then
		-- Priorità: Owner > Admin > VIP
		if isOwner(player) then
			-- Tag OWNER (rosso scuro)
			local prefix = '<font color="#8B0000">[OWNER]</font> '
			properties.PrefixText = prefix .. message.PrefixText
			print("👑 Tag [OWNER] applicato al messaggio di " .. player.Name)

		elseif isAdmin(player) then
			-- Tag ADMIN (rosso)
			local prefix = '<font color="#FF0000">[ADMIN]</font> '
			properties.PrefixText = prefix .. message.PrefixText
			print("🛡️ Tag [ADMIN] applicato al messaggio di " .. player.Name)

		elseif hasVIPPass(player) then
			-- Tag VIP (oro) - solo se non è Owner o Admin
			local prefix = '<font color="#FFD700">[VIP]</font> '
			properties.PrefixText = prefix .. message.PrefixText
			print("⭐ Tag [VIP] applicato al messaggio di " .. player.Name)
		end
	end

	return properties
end

print("🎨 Sistema tag personalizzate in chat attivato! (Owner, Admin, VIP)")
