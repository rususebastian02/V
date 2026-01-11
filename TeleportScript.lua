--[[
	SCRIPT DI TELEPORT PER ROBLOX

	ISTRUZIONI:
	1. Crea due Part nel workspace: una per il teleport di partenza e una per la destinazione
	2. Metti questo script dentro la Part di partenza (quella che vuoi toccare per teletrasportarti)
	3. Crea una Part di destinazione e chiamala come vuoi (es: "DestinazioneTeleport1")
	4. Modifica la variabile NOME_DESTINAZIONE qui sotto con il nome della tua part di destinazione
	5. Per creare più teleport, duplica questo script e cambia solo il NOME_DESTINAZIONE

	CONFIGURAZIONE ALTERNATIVA:
	- Puoi anche usare un ObjectValue chiamato "Destination" dentro la part per maggiore flessibilità
--]]

-- ============================================
-- CONFIGURAZIONE (Modifica questi valori)
-- ============================================

-- Nome della part di destinazione nel Workspace
local NOME_DESTINAZIONE = "DestinazioneTeleport1"

-- Offset verticale per evitare che il player si incastri (in stud)
local OFFSET_ALTEZZA = 3

-- Cooldown tra teleport dello stesso player (in secondi)
local COOLDOWN = 2

-- Salva il checkpoint quando ti teleporti (true/false)
local SALVA_CHECKPOINT = true

-- ============================================
-- CODICE PRINCIPALE (Non modificare se non sai cosa stai facendo)
-- ============================================

local partTeleport = script.Parent
local destinazione = nil
local playerCooldowns = {}
local spawnLocation = nil

-- Funzione per trovare la destinazione
local function trovaDestinazione()
	-- Primo metodo: cerca un ObjectValue chiamato "Destination" nella part
	local objectValue = partTeleport:FindFirstChild("Destination")
	if objectValue and objectValue:IsA("ObjectValue") and objectValue.Value then
		return objectValue.Value
	end

	-- Secondo metodo: cerca per nome nel Workspace
	local dest = workspace:FindFirstChild(NOME_DESTINAZIONE)
	if dest and dest:IsA("BasePart") then
		return dest
	end

	return nil
end

-- Funzione per creare o trovare lo SpawnLocation
local function creaSpawnLocation()
	if not SALVA_CHECKPOINT or not destinazione then
		return nil
	end

	-- Se la destinazione è già uno SpawnLocation, usala
	if destinazione:IsA("SpawnLocation") then
		return destinazione
	end

	-- Altrimenti crea uno SpawnLocation invisibile
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "TeleportCheckpoint_" .. partTeleport.Name
	spawn.Size = destinazione.Size
	spawn.CFrame = destinazione.CFrame
	spawn.Transparency = 1
	spawn.CanCollide = false
	spawn.Anchored = true
	spawn.Duration = 0
	spawn.Enabled = true
	spawn.Neutral = true
	spawn.Parent = workspace

	return spawn
end

-- Funzione per verificare il cooldown
local function checkCooldown(player)
	local currentTime = tick()
	local lastTeleport = playerCooldowns[player.UserId]

	if lastTeleport and (currentTime - lastTeleport) < COOLDOWN then
		return false
	end

	return true
end

-- Funzione per teletrasportare il player
local function teleportPlayer(character)
	if not destinazione then
		warn("Destinazione teleport non trovata! Controlla il nome: " .. NOME_DESTINAZIONE)
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

	local player = game.Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end

	-- Verifica cooldown
	if not checkCooldown(player) then
		return
	end

	-- Calcola la posizione di destinazione con offset
	local posizioneDestinazione = destinazione.Position + Vector3.new(0, OFFSET_ALTEZZA, 0)

	-- Teletrasporta il player
	humanoidRootPart.CFrame = CFrame.new(posizioneDestinazione)

	-- Salva il checkpoint se abilitato
	if SALVA_CHECKPOINT and spawnLocation then
		player.RespawnLocation = spawnLocation
	end

	-- Aggiorna il cooldown
	playerCooldowns[player.UserId] = tick()

	-- Feedback visivo (opzionale)
	print(player.Name .. " è stato teletrasportato!")
end

-- Funzione che gestisce il tocco della part
local function onTouch(otherPart)
	-- Verifica se la part che ha toccato appartiene a un personaggio
	local character = otherPart.Parent
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		teleportPlayer(character)
	end
end

-- ============================================
-- INIZIALIZZAZIONE
-- ============================================

-- Trova la destinazione all'avvio
destinazione = trovaDestinazione()

if not destinazione then
	warn("⚠️ ERRORE TELEPORT: Destinazione '" .. NOME_DESTINAZIONE .. "' non trovata!")
	warn("Assicurati che esista una part chiamata '" .. NOME_DESTINAZIONE .. "' nel Workspace")
else
	print("✓ Teleport configurato correttamente: " .. partTeleport.Name .. " → " .. destinazione.Name)

	-- Crea lo SpawnLocation se il checkpoint è abilitato
	if SALVA_CHECKPOINT then
		spawnLocation = creaSpawnLocation()
		if spawnLocation then
			print("✓ Checkpoint salvato alla destinazione")
		end
	end
end

-- Collega l'evento Touched alla funzione onTouch
partTeleport.Touched:Connect(onTouch)

-- Pulizia dei cooldown quando un player lascia il gioco
game.Players.PlayerRemoving:Connect(function(player)
	playerCooldowns[player.UserId] = nil
end)
