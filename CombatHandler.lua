-- Combat Handler - Server Script
-- Da mettere in ServerScriptService

print("⚔️ [CombatHandler] Inizializzazione...")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Crea RemoteEvent per attacco base
local basicAttackEvent = ReplicatedStorage:FindFirstChild("BasicAttack")
if not basicAttackEvent then
	basicAttackEvent = Instance.new("RemoteEvent")
	basicAttackEvent.Name = "BasicAttack"
	basicAttackEvent.Parent = ReplicatedStorage
	print("✅ [CombatHandler] RemoteEvent 'BasicAttack' creato")
end

local useAbilityEvent = ReplicatedStorage:WaitForChild("UseAbility")

-- Configurazione hit detection
local HIT_RANGE = 10 -- Range attacco in studs
local HIT_ANGLE = 90 -- Angolo di attacco in gradi

-- Funzione per trovare nemici nel range
local function findEnemiesInRange(attacker, range, angle)
	local attackerChar = attacker.Character
	if not attackerChar then return {} end

	local attackerRoot = attackerChar:FindFirstChild("HumanoidRootPart")
	if not attackerRoot then return {} end

	local enemies = {}
	local attackerPos = attackerRoot.Position
	local attackerLook = attackerRoot.CFrame.LookVector

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= attacker then
			local char = player.Character
			if char then
				local humanoid = char:FindFirstChild("Humanoid")
				local root = char:FindFirstChild("HumanoidRootPart")

				if humanoid and root and humanoid.Health > 0 then
					local targetPos = root.Position
					local distance = (attackerPos - targetPos).Magnitude

					if distance <= range then
						-- Controlla angolo
						local directionToTarget = (targetPos - attackerPos).Unit
						local dotProduct = attackerLook:Dot(directionToTarget)
						local angleToTarget = math.deg(math.acos(dotProduct))

						if angleToTarget <= angle / 2 then
							table.insert(enemies, {
								Player = player,
								Character = char,
								Humanoid = humanoid,
								Distance = distance
							})
						end
					end
				end
			end
		end
	end

	return enemies
end

-- Funzione per applicare danno
local function dealDamage(victim, damage, attacker)
	if victim and victim.Health > 0 then
		victim.Health = math.max(0, victim.Health - damage)

		print("💥 [CombatHandler] " .. attacker.Name .. " ha inflitto " .. damage .. " danni a " .. victim.Parent.Name)

		-- Effetto visivo (placeholder)
		-- Qui puoi aggiungere particelle, suoni, etc.

		return true
	end
	return false
end

-- Gestione attacco base
basicAttackEvent.OnServerEvent:Connect(function(player)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	-- Ottieni configurazione stile (dallo StyleManager)
	-- Per ora usiamo valori di default
	local baseDamage = 20

	-- Trova nemici
	local enemies = findEnemiesInRange(player, HIT_RANGE, HIT_ANGLE)

	if #enemies > 0 then
		-- Colpisci il nemico più vicino
		table.sort(enemies, function(a, b)
			return a.Distance < b.Distance
		end)

		local target = enemies[1]
		dealDamage(target.Humanoid, baseDamage, player)

		print("👊 [CombatHandler] " .. player.Name .. " attacco base su " .. target.Player.Name)
	else
		print("👊 [CombatHandler] " .. player.Name .. " attacco base (nessun bersaglio)")
	end
end)

-- Gestione abilità (integrata con StyleManager)
useAbilityEvent.OnServerEvent:Connect(function(player, abilityKey)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	-- Placeholder per abilità speciali
	-- Qui verranno implementate le abilità specifiche di ogni stile

	print("⚡ [CombatHandler] " .. player.Name .. " usa abilità: " .. abilityKey)

	-- Esempio: danno area
	local enemies = findEnemiesInRange(player, 15, 360) -- Range maggiore, 360°

	for _, enemy in ipairs(enemies) do
		dealDamage(enemy.Humanoid, 30, player) -- Damage placeholder
	end
end)

-- Gestione morte
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")

		humanoid.Died:Connect(function()
			print("💀 [CombatHandler] " .. player.Name .. " è morto!")

			-- Respawn dopo 3 secondi
			wait(3)
			player:LoadCharacter()
		end)
	end)
end)

print("⚔️ [CombatHandler] Sistema attivo!")
