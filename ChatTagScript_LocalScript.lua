-- LocalScript per chat tag (Owner, Admin, VIP)
-- Da mettere in StarterPlayer > StarterPlayerScripts
-- IMPORTANTE: Deve essere un LocalScript, NON uno Script normale!

print("🔧 [ChatTag] Inizializzazione client...")

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TextChatService = game:GetService("TextChatService")
local player = Players.LocalPlayer

print("✅ [ChatTag] Servizi caricati (client)")

-- ID del Game Pass VIP
local VIP_GAMEPASS_ID = 1656463027

-- ========================================
-- SEZIONE MODIFICABILE: Inserisci qui gli ID dei giocatori
-- ========================================

-- Lista degli ID giocatori OWNER (Tag rosso scuro)
local OWNER_IDS = {
	144351341,  -- S3BATM (Owner - Account principale)
	757434985,  -- S3BATM (Owner - Secondo account)
}

-- Lista degli ID giocatori ADMIN (Tag rosso)
local ADMIN_IDS = {
	-- Aggiungi qui gli ID dei giocatori Admin
	-- Esempio: 111222333, 444555666
}

-- ========================================
-- FINE SEZIONE MODIFICABILE
-- ========================================

print("📋 [ChatTag] Owner: " .. #OWNER_IDS .. " | Admin: " .. #ADMIN_IDS)

-- Funzione per verificare se un giocatore è Owner
local function isOwner(userId)
	for _, id in ipairs(OWNER_IDS) do
		if userId == id then
			return true
		end
	end
	return false
end

-- Funzione per verificare se un giocatore è Admin
local function isAdmin(userId)
	for _, id in ipairs(ADMIN_IDS) do
		if userId == id then
			return true
		end
	end
	return false
end

-- Funzione per verificare se un giocatore ha il VIP
local function hasVIPPass(userId)
	local success, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(userId, VIP_GAMEPASS_ID)
	end)
	return success and result
end

print("🔧 [ChatTag] Collegamento OnIncomingMessage...")

-- Applica i tag ai messaggi in chat
TextChatService.OnIncomingMessage = function(message: TextChatMessage)
	local properties = Instance.new("TextChatMessageProperties")

	if not message.TextSource then
		return properties
	end

	local userId = message.TextSource.UserId

	-- Priorità: Owner > Admin > VIP
	if isOwner(userId) then
		-- Tag OWNER (rosso scuro)
		properties.PrefixText = '<font color="#8B0000">[OWNER]</font> ' .. message.PrefixText
		print("👑 [ChatTag] Tag OWNER applicato")

	elseif isAdmin(userId) then
		-- Tag ADMIN (rosso)
		properties.PrefixText = '<font color="#FF0000">[ADMIN]</font> ' .. message.PrefixText
		print("🛡️ [ChatTag] Tag ADMIN applicato")

	elseif hasVIPPass(userId) then
		-- Tag VIP (oro) - solo se non è Owner o Admin
		properties.PrefixText = '<font color="#FFD700">[VIP]</font> ' .. message.PrefixText
		print("⭐ [ChatTag] Tag VIP applicato")
	end

	return properties
end

print("🎨 [ChatTag] Sistema tag attivato! (Owner, Admin, VIP)")
