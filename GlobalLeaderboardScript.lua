-- Script per gestire le leaderboard globali (Top 100 Speed e Playtime)
-- Da inserire in ServerScriptService in Roblox Studio

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

-- OrderedDataStores per le classifiche globali
local SpeedLeaderboard = DataStoreService:GetOrderedDataStore("GlobalSpeedLeaderboard")
local PlaytimeLeaderboard = DataStoreService:GetOrderedDataStore("GlobalPlaytimeLeaderboard")

-- DataStores normali per i dati dei giocatori
local SpeedDataStore = DataStoreService:GetDataStore("PlayerSpeedData")
local PlaytimeDataStore = DataStoreService:GetDataStore("PlayerPlaytimeData")

-- Configurazione
local UPDATE_INTERVAL = 120 -- Aggiorna le classifiche ogni 120 secondi (2 minuti)
local TOP_PLAYERS_COUNT = 100 -- Numero di giocatori da mostrare

print("🏆 [GlobalLeaderboard] Sistema leaderboard globali inizializzato")

-- Funzione per aggiornare la classifica Speed di un giocatore
local function updateSpeedLeaderboard(userId, username, speed)
	local success, errorMsg = pcall(function()
		-- Salva nella OrderedDataStore con il punteggio (speed)
		-- La chiave è "UserId_Username" per poter mostrare il nome
		SpeedLeaderboard:SetAsync(userId, speed)
	end)

	if not success then
		warn("⚠️ [GlobalLeaderboard] Errore aggiornamento Speed per " .. username .. ": " .. tostring(errorMsg))
	end
end

-- Funzione per aggiornare la classifica Playtime di un giocatore
local function updatePlaytimeLeaderboard(userId, username, playtime)
	local success, errorMsg = pcall(function()
		PlaytimeLeaderboard:SetAsync(userId, playtime)
	end)

	if not success then
		warn("⚠️ [GlobalLeaderboard] Errore aggiornamento Playtime per " .. username .. ": " .. tostring(errorMsg))
	end
end

-- Funzione per ottenere la Top 100 Speed
function getTop100Speed()
	local success, pages = pcall(function()
		return SpeedLeaderboard:GetSortedAsync(false, TOP_PLAYERS_COUNT)
	end)

	if success and pages then
		local topPlayers = {}
		local entries = pages:GetCurrentPage()

		for rank, entry in ipairs(entries) do
			local userId = entry.key
			local speed = entry.value

			-- Ottieni il nome del giocatore
			local username = "Player"
			local nameSuccess, fetchedName = pcall(function()
				return Players:GetNameFromUserIdAsync(userId)
			end)
			if nameSuccess then
				username = fetchedName
			end

			table.insert(topPlayers, {
				Rank = rank,
				UserId = userId,
				Username = username,
				Speed = speed
			})
		end

		return topPlayers
	else
		warn("⚠️ [GlobalLeaderboard] Errore nel recuperare Top 100 Speed")
		return {}
	end
end

-- Funzione per ottenere la Top 100 Playtime
function getTop100Playtime()
	local success, pages = pcall(function()
		return PlaytimeLeaderboard:GetSortedAsync(false, TOP_PLAYERS_COUNT)
	end)

	if success and pages then
		local topPlayers = {}
		local entries = pages:GetCurrentPage()

		for rank, entry in ipairs(entries) do
			local userId = entry.key
			local playtime = entry.value

			-- Ottieni il nome del giocatore
			local username = "Player"
			local nameSuccess, fetchedName = pcall(function()
				return Players:GetNameFromUserIdAsync(userId)
			end)
			if nameSuccess then
				username = fetchedName
			end

			table.insert(topPlayers, {
				Rank = rank,
				UserId = userId,
				Username = username,
				Playtime = playtime
			})
		end

		return topPlayers
	else
		warn("⚠️ [GlobalLeaderboard] Errore nel recuperare Top 100 Playtime")
		return {}
	end
end

-- Esponi le funzioni globalmente per permettere ai GUI di accedervi
_G.GetTop100Speed = getTop100Speed
_G.GetTop100Playtime = getTop100Playtime

-- Funzione per aggiornare tutte le classifiche dei giocatori online
local function updateAllLeaderboards()
	print("🔄 [GlobalLeaderboard] Aggiornamento classifiche globali...")

	for _, player in ipairs(Players:GetPlayers()) do
		local userId = player.UserId
		local username = player.Name

		-- Ottieni Speed dal leaderstats
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local speedValue = leaderstats:FindFirstChild("Speed")
			local playtimeValue = leaderstats:FindFirstChild("Playtime")

			if speedValue then
				updateSpeedLeaderboard(userId, username, speedValue.Value)
			end

			if playtimeValue then
				updatePlaytimeLeaderboard(userId, username, playtimeValue.Value)
			end
		end
	end

	print("✅ [GlobalLeaderboard] Classifiche aggiornate!")
end

-- Aggiorna le classifiche quando un giocatore esce (per salvare i suoi ultimi dati)
Players.PlayerRemoving:Connect(function(player)
	local userId = player.UserId
	local username = player.Name

	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local speedValue = leaderstats:FindFirstChild("Speed")
		local playtimeValue = leaderstats:FindFirstChild("Playtime")

		if speedValue then
			updateSpeedLeaderboard(userId, username, speedValue.Value)
		end

		if playtimeValue then
			updatePlaytimeLeaderboard(userId, username, playtimeValue.Value)
		end
	end

	print("💾 [GlobalLeaderboard] Classifica salvata per " .. username)
end)

-- Loop per aggiornare periodicamente le classifiche
spawn(function()
	wait(10) -- Aspetta 10 secondi all'avvio

	while true do
		updateAllLeaderboards()
		wait(UPDATE_INTERVAL)
	end
end)

-- Aggiorna le classifiche quando il server si chiude
game:BindToClose(function()
	print("🔄 [GlobalLeaderboard] Salvataggio finale classifiche...")
	updateAllLeaderboards()
	wait(3)
end)

print("🏆 [GlobalLeaderboard] Sistema attivo! Aggiornamento ogni " .. UPDATE_INTERVAL .. " secondi")
