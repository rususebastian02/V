-- POSIZIONA QUESTO SCRIPT IN: ServerScriptService
-- Script principale del countdown apocalittico

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local BadgeService = game:GetService("BadgeService")

-- DataStore for tracking dream phrases
local dreamPhrasesDataStore = DataStoreService:GetDataStore("DreamPhrasesSeenV1")

-- Badge IDs
local ALL_DREAMS_BADGE_ID = 0 -- CAMBIA QUESTO CON L'ID DEL TUO BADGE (Dream Collector)
local WELCOME_BADGE_ID = 515603571785681 -- Welcome badge
local DREAMER_BADGE_ID = 3190667505182002 -- First apocalypse completion badge
local ASCENSION_BADGE_ID = 2946712324529139 -- The Ascension badge

-- Configurazione
local COUNTDOWN_TIME = 30 * 60 -- 30 minuti in secondi
local DAMAGE_PER_SECOND = 5 -- Danno inflitto ai player durante l'apocalisse
local APOCALYPSE_DURATION = 15 -- Durata dell'apocalisse in secondi

-- THE ASCENSION event configuration
local roundCount = 0
local nextAscensionRound = math.random(20, 30)
local ascendedPlayer = nil

-- Eventi remoti per comunicare con i client
local apocalypseEvent = Instance.new("RemoteEvent")
apocalypseEvent.Name = "ApocalypseEvent"
apocalypseEvent.Parent = ReplicatedStorage

local countdownValue = Instance.new("IntValue")
countdownValue.Name = "CountdownValue"
countdownValue.Value = COUNTDOWN_TIME
countdownValue.Parent = ReplicatedStorage

-- Create apocalypse music
local apocalypseMusic = Instance.new("Sound")
apocalypseMusic.Name = "ApocalypseMusic"
apocalypseMusic.SoundId = "rbxassetid://9041785975"
apocalypseMusic.Volume = 0.5
apocalypseMusic.Looped = true
apocalypseMusic.Parent = workspace

-- Load ascension wings from catalog (server-side)
local ascensionWingsTemplate = nil
spawn(function()
	local InsertService = game:GetService("InsertService")
	local success, result = pcall(function()
		return InsertService:LoadAsset(13940506102)
	end)

	if success and result then
		local wings = result:FindFirstChildOfClass("Accessory")
		if wings then
			ascensionWingsTemplate = wings:Clone()
			ascensionWingsTemplate.Name = "AscensionWings"

			-- Set transparency to 0.5 for all parts
			for _, descendant in pairs(ascensionWingsTemplate:GetDescendants()) do
				if descendant:IsA("BasePart") or descendant:IsA("MeshPart") then
					descendant.Transparency = 0.5
				end
			end

			ascensionWingsTemplate.Parent = ReplicatedStorage
			print("Ascension wings loaded successfully")
		end
		result:Destroy()
	else
		warn("Failed to load ascension wings: " .. tostring(result))
	end
end)

-- THE ASCENSION event trigger
local function triggerAscension()
	print("THE ASCENSION event triggered!")

	-- Phase 1: -35s to -30s - Prepare (audio lowers, wind stops)
	apocalypseEvent:FireAllClients("ascension_prepare")

	-- Phase 2: -30s - Warning
	wait(5)
	apocalypseEvent:FireAllClients("ascension_warning")

	-- Phase 3: -28s - Silent player selection (choose random player)
	wait(2)
	local playersList = Players:GetPlayers()
	if #playersList > 0 then
		ascendedPlayer = playersList[math.random(1, #playersList)]
		print("Ascended player chosen: " .. ascendedPlayer.Name)

		-- Phase 4: -20s - Chosen player sees desaturation
		wait(8)
		apocalypseEvent:FireClient(ascendedPlayer, "ascension_chosen")

		-- Award Ascension badge
		local success, hasBadge = pcall(function()
			return BadgeService:UserHasBadgeAsync(ascendedPlayer.UserId, ASCENSION_BADGE_ID)
		end)

		if success and not hasBadge then
			pcall(function()
				BadgeService:AwardBadge(ascendedPlayer.UserId, ASCENSION_BADGE_ID)
				print("Ascension badge awarded to " .. ascendedPlayer.Name)
				apocalypseEvent:FireClient(ascendedPlayer, "badge_unlocked", "The Ascension")
			end)
		end

		-- Phase 5: -15s - Global reveal
		wait(5)
		apocalypseEvent:FireAllClients("ascension_reveal", ascendedPlayer.Name)

		-- Phase 6: Continue countdown to 0, then apocalypse with ascended surviving
		-- (handled in main countdown logic)
	end
end

-- Funzione per avviare l'apocalisse
local function startApocalypse()
	print("Apocalypse started")

	-- Notifica tutti i client di avviare gli effetti visivi
	apocalypseEvent:FireAllClients("start")

	-- Attendi 3 secondi prima di iniziare con le particelle di cenere
	wait(3)

	-- Attiva le particelle di cenere
	apocalypseEvent:FireAllClients("ash")

	-- Inizia a infliggere danno ai player
	local damageStartTime = tick()
	while tick() - damageStartTime < APOCALYPSE_DURATION do
		for _, player in pairs(Players:GetPlayers()) do
			if player.Character and player.Character:FindFirstChild("Humanoid") then
				local humanoid = player.Character.Humanoid
				if humanoid.Health > 0 then
					humanoid:TakeDamage(DAMAGE_PER_SECOND)
				end
			end
		end
		wait(1)
	end

	-- Assicurati che tutti i player siano morti e award dreamer badge
	-- If THE ASCENSION event is active, spare the ascended player
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			-- Skip the ascended player for now if THE ASCENSION is active
			if not (ascendedPlayer and player == ascendedPlayer) then
				player.Character.Humanoid.Health = 0

				-- Award Dreamer badge for completing first apocalypse
				local success, hasBadge = pcall(function()
					return BadgeService:UserHasBadgeAsync(player.UserId, DREAMER_BADGE_ID)
				end)

				if success and not hasBadge then
					pcall(function()
						BadgeService:AwardBadge(player.UserId, DREAMER_BADGE_ID)
						print("Dreamer badge awarded to " .. player.Name)
						apocalypseEvent:FireClient(player, "badge_unlocked", "Dreamer")
					end)
				end
			end
		end
	end

	-- If THE ASCENSION event is active, handle ascended player alone
	if ascendedPlayer then
		print("Ascended player " .. ascendedPlayer.Name .. " remains alone")
		wait(3)

		-- Show final message to ascended player
		apocalypseEvent:FireClient(ascendedPlayer, "ascension_alone")

		wait(2)

		-- Now kill the ascended player
		if ascendedPlayer.Character and ascendedPlayer.Character:FindFirstChild("Humanoid") then
			ascendedPlayer.Character.Humanoid.Health = 0
		end

		-- Reset ascended player variable
		ascendedPlayer = nil
	end

	print("All players eliminated. Resetting world...")
	wait(3)

	-- Reset del mondo
	resetWorld()
end

-- Funzione per resettare il mondo
function resetWorld()
	print("World reset in progress...")

	-- Stop music
	apocalypseMusic:Stop()

	-- Notifica i client di fermare gli effetti
	apocalypseEvent:FireAllClients("reset")

	-- Respawn tutti i player
	for _, player in pairs(Players:GetPlayers()) do
		player:LoadCharacter()
	end

	-- Resetta il countdown
	countdownValue.Value = COUNTDOWN_TIME

	-- Riavvia il countdown
	wait(2)
	startCountdown()
end

-- Dream phrases to show at the start of each round
local dreamPhrases = {
	"This is exactly how it happened in my dream.",
	"You didn't survive last time either.",
	"I woke up before this part.",
	"This part always repeats.",
	"I've seen this before.",
	"The dream never changes.",
	"You were here in my dream too.",
	"I know how this ends.",
	"This isn't the first time.",
	"I remember this moment."
}

-- Track which players have seen which phrases (in-memory for current session)
local playerSeenPhrases = {}

-- Function to load player's seen phrases from DataStore
local function loadPlayerPhrases(player)
	local success, data = pcall(function()
		return dreamPhrasesDataStore:GetAsync(tostring(player.UserId))
	end)

	if success and data then
		playerSeenPhrases[player.UserId] = data
		print("Loaded phrases for " .. player.Name .. ": " .. #data .. " seen")
	else
		playerSeenPhrases[player.UserId] = {}
		print("New player dream tracking for " .. player.Name)
	end
end

-- Function to save player's seen phrases to DataStore
local function savePlayerPhrases(player)
	local success, err = pcall(function()
		dreamPhrasesDataStore:SetAsync(tostring(player.UserId), playerSeenPhrases[player.UserId])
	end)

	if not success then
		warn("Failed to save phrases for " .. player.Name .. ": " .. tostring(err))
	end
end

-- Function to mark a phrase as seen and check for badge
local function markPhraseAsSeen(player, phraseIndex)
	local userId = player.UserId

	if not playerSeenPhrases[userId] then
		playerSeenPhrases[userId] = {}
	end

	-- Check if phrase was already seen
	for _, seenIndex in pairs(playerSeenPhrases[userId]) do
		if seenIndex == phraseIndex then
			return -- Already seen this phrase
		end
	end

	-- Add new phrase to seen list
	table.insert(playerSeenPhrases[userId], phraseIndex)
	print(player.Name .. " saw phrase #" .. phraseIndex .. " (" .. #playerSeenPhrases[userId] .. "/10)")

	-- Save to DataStore
	savePlayerPhrases(player)

	-- Check if player has seen all phrases
	if #playerSeenPhrases[userId] >= #dreamPhrases then
		print(player.Name .. " has seen all dream phrases! Awarding badge...")

		-- Award badge if not already owned
		if ALL_DREAMS_BADGE_ID > 0 then
			local success, hasBadge = pcall(function()
				return BadgeService:UserHasBadgeAsync(userId, ALL_DREAMS_BADGE_ID)
			end)

			if success and not hasBadge then
				local awardSuccess = pcall(function()
					BadgeService:AwardBadge(userId, ALL_DREAMS_BADGE_ID)
				end)

				if awardSuccess then
					print("Badge awarded to " .. player.Name)
					-- Notify player
					apocalypseEvent:FireClient(player, "badge_unlocked", "Dream Collector")
				end
			end
		end
	end
end

-- Load phrases when player joins
Players.PlayerAdded:Connect(function(player)
	loadPlayerPhrases(player)

	-- Award welcome badge on first join
	local success, hasBadge = pcall(function()
		return BadgeService:UserHasBadgeAsync(player.UserId, WELCOME_BADGE_ID)
	end)

	if success and not hasBadge then
		pcall(function()
			BadgeService:AwardBadge(player.UserId, WELCOME_BADGE_ID)
			print("Welcome badge awarded to " .. player.Name)
		end)
	end
end)

-- Save phrases when player leaves
Players.PlayerRemoving:Connect(function(player)
	if playerSeenPhrases[player.UserId] then
		savePlayerPhrases(player)
	end
end)

-- Funzione per il countdown
function startCountdown()
	print("Countdown started: " .. COUNTDOWN_TIME .. " seconds")

	-- Increment round count
	roundCount = roundCount + 1
	print("Round " .. roundCount .. " started")

	-- Check if THE ASCENSION should trigger this round
	local shouldTriggerAscension = false
	if roundCount >= nextAscensionRound and #Players:GetPlayers() >= 10 then
		shouldTriggerAscension = true
		print("THE ASCENSION will trigger this round!")
		-- Set next ascension for 20-30 rounds from now
		nextAscensionRound = roundCount + math.random(20, 30)
	end

	-- Send random dream phrase to all clients
	local randomIndex = math.random(1, #dreamPhrases)
	local randomPhrase = dreamPhrases[randomIndex]
	apocalypseEvent:FireAllClients("dream_phrase", randomPhrase)

	-- Mark this phrase as seen for all players in the server
	for _, player in pairs(Players:GetPlayers()) do
		markPhraseAsSeen(player, randomIndex)
	end

	local timeRemaining = COUNTDOWN_TIME

	while timeRemaining > 0 do
		countdownValue.Value = timeRemaining

		-- Phase 1: 20 minutes - Yellow sky, bigger sun, light wind
		if timeRemaining == 1200 then
			print("Phase 1: Yellow sky phase started")
			apocalypseEvent:FireAllClients("phase_1")
		end

		-- Phase 2: 10 minutes - Falling ash, distant sounds
		if timeRemaining == 600 then
			print("Phase 2: Falling ash phase started")
			apocalypseEvent:FireAllClients("phase_2")
			apocalypseEvent:FireAllClients("announcement", "10 minutes remaining")
		end

		-- Phase 3: 5 minutes - Heavy breathing, blur, vignette, burning players
		if timeRemaining == 300 then
			print("Phase 3: Burning phase started")
			apocalypseEvent:FireAllClients("phase_3")
			apocalypseEvent:FireAllClients("announcement", "5 minutes remaining")
		end

		-- THE ASCENSION event trigger at 35 seconds
		if timeRemaining == 35 and shouldTriggerAscension then
			print("Triggering THE ASCENSION event at 35 seconds")
			triggerAscension()
		end

		-- Start music at 2:40 remaining
		if timeRemaining == 160 then
			print("Starting apocalypse music")
			apocalypseMusic:Play()
			apocalypseEvent:FireAllClients("music_start")
		end

		-- Other announcements
		if timeRemaining == 60 then
			apocalypseEvent:FireAllClients("announcement", "1 minute remaining")
		elseif timeRemaining == 30 then
			apocalypseEvent:FireAllClients("announcement", "30 seconds")
		elseif timeRemaining == 10 then
			apocalypseEvent:FireAllClients("announcement", "10 seconds")
		end

		wait(1)
		timeRemaining = timeRemaining - 1
	end

	countdownValue.Value = 0
	startApocalypse()
end

-- Avvia il gioco quando il server si avvia
wait(3) -- Attendi che tutto sia caricato
startCountdown()
