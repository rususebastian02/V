-- POSIZIONA QUESTO SCRIPT IN: ServerScriptService
-- Script principale del countdown apocalittico

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configurazione
local COUNTDOWN_TIME = 30 * 60 -- 30 minuti in secondi
local DAMAGE_PER_SECOND = 5 -- Danno inflitto ai player durante l'apocalisse
local APOCALYPSE_DURATION = 15 -- Durata dell'apocalisse in secondi

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

	-- Assicurati che tutti i player siano morti
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.Health = 0
		end
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

-- Funzione per il countdown
function startCountdown()
	print("Countdown started: " .. COUNTDOWN_TIME .. " seconds")

	local timeRemaining = COUNTDOWN_TIME

	while timeRemaining > 0 do
		countdownValue.Value = timeRemaining

		-- Start music at 2:40 remaining
		if timeRemaining == 160 then
			print("Starting apocalypse music")
			apocalypseMusic:Play()
			apocalypseEvent:FireAllClients("music_start")
		end

		-- Periodic announcements
		if timeRemaining == 600 then
			apocalypseEvent:FireAllClients("announcement", "10 minutes remaining")
		elseif timeRemaining == 300 then
			apocalypseEvent:FireAllClients("announcement", "5 minutes remaining")
		elseif timeRemaining == 60 then
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
