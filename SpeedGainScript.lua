-- Script per aumentare la velocità del giocatore di +1 ogni secondo
-- Include sistema di salvataggio dati con DataStore
-- Include leaderboard con Speed e Playtime in tempo reale
-- Da inserire in ServerScriptService in Roblox Studio

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

-- Crea un DataStore per salvare la velocità dei giocatori
local SpeedDataStore = DataStoreService:GetDataStore("PlayerSpeedData")

-- Tabella per tenere traccia della velocità corrente di ogni giocatore
local playerSpeeds = {}

-- Velocità di default
local DEFAULT_SPEED = 16

-- Funzione per caricare i dati del giocatore
local function loadPlayerData(player)
	local success, savedSpeed = pcall(function()
		return SpeedDataStore:GetAsync(player.UserId)
	end)

	if success and savedSpeed then
		print("Dati caricati per " .. player.Name .. ": Velocità " .. savedSpeed)
		return savedSpeed
	else
		print("Nessun dato salvato per " .. player.Name .. ", uso velocità di default")
		return DEFAULT_SPEED
	end
end

-- Funzione per salvare i dati del giocatore
local function savePlayerData(player)
	if playerSpeeds[player.UserId] then
		local success, errorMessage = pcall(function()
			SpeedDataStore:SetAsync(player.UserId, playerSpeeds[player.UserId])
		end)

		if success then
			print("Dati salvati per " .. player.Name .. ": Velocità " .. playerSpeeds[player.UserId])
		else
			warn("Errore nel salvataggio dati per " .. player.Name .. ": " .. tostring(errorMessage))
		end
	end
end

-- Funzione per creare la leaderboard
local function createLeaderboard(player)
	-- Crea la cartella leaderstats (necessaria per la leaderboard)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	-- Crea il valore Speed per la leaderboard
	local speedValue = Instance.new("IntValue")
	speedValue.Name = "Speed"
	speedValue.Value = 0
	speedValue.Parent = leaderstats

	-- Crea il valore Playtime per la leaderboard
	local playtimeValue = Instance.new("IntValue")
	playtimeValue.Name = "Playtime"
	playtimeValue.Value = 0
	playtimeValue.Parent = leaderstats

	return speedValue, playtimeValue
end

-- Funzione per gestire ogni giocatore
local function onPlayerAdded(player)
	-- Crea la leaderboard per il giocatore
	local speedValue, playtimeValue = createLeaderboard(player)

	-- Carica la velocità salvata del giocatore
	local savedSpeed = loadPlayerData(player)
	playerSpeeds[player.UserId] = savedSpeed

	-- Aggiorna la leaderboard con la velocità iniziale
	speedValue.Value = savedSpeed

	-- Timer per il Playtime (aumenta ogni secondo)
	spawn(function()
		while player and player.Parent do
			wait(1)
			if playtimeValue and playtimeValue.Parent then
				playtimeValue.Value = playtimeValue.Value + 1
			else
				break
			end
		end
	end)

	-- Aspetta che il personaggio del giocatore venga caricato
	player.CharacterAdded:Connect(function(character)
		-- Trova l'Humanoid nel personaggio
		local humanoid = character:WaitForChild("Humanoid")

		-- Imposta la velocità salvata
		humanoid.WalkSpeed = playerSpeeds[player.UserId]
		print("Velocità iniziale di " .. player.Name .. ": " .. humanoid.WalkSpeed)

		-- Loop infinito che aumenta la velocità ogni secondo
		spawn(function()
			while character and character.Parent and humanoid and humanoid.Parent do
				wait(1) -- Aspetta 1 secondo

				-- Verifica che l'Humanoid esista ancora
				if humanoid and humanoid.Parent then
					humanoid.WalkSpeed = humanoid.WalkSpeed + 1
					playerSpeeds[player.UserId] = humanoid.WalkSpeed

					-- Aggiorna la leaderboard in tempo reale
					if speedValue and speedValue.Parent then
						speedValue.Value = math.floor(humanoid.WalkSpeed)
					end

					print("Velocità di " .. player.Name .. ": " .. humanoid.WalkSpeed)
				else
					break -- Esce dal loop se l'Humanoid non esiste più
				end
			end
		end)

		-- Salva i dati ogni 60 secondi come backup
		spawn(function()
			while character and character.Parent do
				wait(60)
				savePlayerData(player)
			end
		end)
	end)
end

-- Funzione chiamata quando un giocatore esce
local function onPlayerRemoving(player)
	-- Salva i dati prima che il giocatore esca
	savePlayerData(player)

	-- Pulisci la tabella
	playerSpeeds[player.UserId] = nil
end

-- Applica la funzione a tutti i giocatori attuali
for _, player in pairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

-- Applica la funzione ai nuovi giocatori che si uniscono
Players.PlayerAdded:Connect(onPlayerAdded)

-- Salva i dati quando un giocatore esce
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Salva tutti i dati quando il server si chiude
game:BindToClose(function()
	for _, player in pairs(Players:GetPlayers()) do
		savePlayerData(player)
	end
	wait(2) -- Aspetta per assicurarsi che i dati vengano salvati
end)
