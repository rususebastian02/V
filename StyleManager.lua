-- Style Manager - Server Script
-- Da mettere in ServerScriptService

print("⚔️ [StyleManager] Inizializzazione...")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Require VFX Modules
local PoseidonAbilities = require(ReplicatedStorage:WaitForChild("PoseidonAbilities"))

-- Crea RemoteEvent per selezione stile
local selectStyleEvent = ReplicatedStorage:FindFirstChild("SelectStyle")
if not selectStyleEvent then
	selectStyleEvent = Instance.new("RemoteEvent")
	selectStyleEvent.Name = "SelectStyle"
	selectStyleEvent.Parent = ReplicatedStorage
	print("✅ [StyleManager] RemoteEvent 'SelectStyle' creato")
end

-- Crea RemoteEvent per abilità
local useAbilityEvent = ReplicatedStorage:FindFirstChild("UseAbility")
if not useAbilityEvent then
	useAbilityEvent = Instance.new("RemoteEvent")
	useAbilityEvent.Name = "UseAbility"
	useAbilityEvent.Parent = ReplicatedStorage
	print("✅ [StyleManager] RemoteEvent 'UseAbility' creato")
end

-- Tabella per tenere traccia degli stili selezionati
local playerStyles = {}
local playerCooldowns = {}

-- Condividi playerStyles globalmente per CombatHandler
_G.PlayerStyles = playerStyles

-- Configurazione combat
local ABILITY_RANGES = {
	Q = 12,  -- Range abilità Q
	E = 15,  -- Range abilità E
	R = 20   -- Range abilità R (ultimate)
}

-- Helper: Trova nemici nel range
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
						local angleToTarget = math.deg(math.acos(math.clamp(dotProduct, -1, 1)))

						if angleToTarget <= angle / 2 then
							table.insert(enemies, {
								Player = player,
								Character = char,
								Humanoid = humanoid,
								RootPart = root,
								Position = targetPos,
								Distance = distance
							})
						end
					end
				end
			end
		end
	end

	-- Ordina per distanza
	table.sort(enemies, function(a, b)
		return a.Distance < b.Distance
	end)

	return enemies
end

-- Helper: Applica danno
local function dealDamage(victim, damage, attacker)
	if victim and victim.Health > 0 then
		victim.Health = math.max(0, victim.Health - damage)
		print("💥 [StyleManager] " .. attacker.Name .. " infligge " .. damage .. " danni a " .. victim.Parent.Name)
		return true
	end
	return false
end

-- Configurazione stili (stats e abilità)
local STYLE_CONFIGS = {
	-- GODS
	Poseidon = {
		Category = "Gods",
		Weapon = "Trident",
		BaseDamage = 25,
		AttackSpeed = 1.2,
		Health = 100,
		Abilities = {
			{Name = "Amphitrite", Damage = 50, Cooldown = 7, Key = "Q"},
			{Name = "Chione Tyro Demeter", Damage = 70, Cooldown = 12, Key = "E"},
			{Name = "40 Day Flood", Damage = 100, Cooldown = 20, Key = "R"}
		}
	},
	Zeus = {
		Category = "Gods",
		Weapon = "Lightning Bolt",
		BaseDamage = 30,
		AttackSpeed = 1.5,
		Health = 90,
		Abilities = {
			{Name = "Lightning Strike", Damage = 60, Cooldown = 7, Key = "Q"},
			{Name = "Thunder Clap", Damage = 40, Cooldown = 10, Key = "E"},
			{Name = "Divine Judgment", Damage = 100, Cooldown = 20, Key = "R"}
		}
	},
	Shiva = {
		Category = "Gods",
		Weapon = "Trishula",
		BaseDamage = 28,
		AttackSpeed = 1.8,
		Health = 95,
		Abilities = {
			{Name = "Tandava Dance", Damage = 45, Cooldown = 6, Key = "Q"},
			{Name = "Third Eye", Damage = 70, Cooldown = 12, Key = "E"},
			{Name = "Destruction Wave", Damage = 90, Cooldown = 18, Key = "R"}
		}
	},
	Thor = {
		Category = "Gods",
		Weapon = "Mjolnir",
		BaseDamage = 35,
		AttackSpeed = 1.0,
		Health = 110,
		Abilities = {
			{Name = "Hammer Throw", Damage = 55, Cooldown = 8, Key = "Q"},
			{Name = "Thunder Strike", Damage = 65, Cooldown = 11, Key = "E"},
			{Name = "Ragnarok", Damage = 120, Cooldown = 25, Key = "R"}
		}
	},
	Hades = {
		Category = "Gods",
		Weapon = "Bident",
		BaseDamage = 27,
		AttackSpeed = 1.3,
		Health = 105,
		Abilities = {
			{Name = "Soul Reaper", Damage = 50, Cooldown = 7, Key = "Q"},
			{Name = "Underworld Chains", Damage = 60, Cooldown = 13, Key = "E"},
			{Name = "Death's Embrace", Damage = 95, Cooldown = 20, Key = "R"}
		}
	},

	-- HUMANS
	Adam = {
		Category = "Humans",
		Weapon = "Knuckles",
		BaseDamage = 22,
		AttackSpeed = 2.0,
		Health = 100,
		Abilities = {
			{Name = "Eyes of the Lord", Damage = 40, Cooldown = 5, Key = "Q"}, -- Copy ability
			{Name = "Divine Reflection", Damage = 55, Cooldown = 10, Key = "E"},
			{Name = "Time Punch Rush", Damage = 75, Cooldown = 15, Key = "R"}
		}
	},
	["Qin Shi Huang"] = {
		Category = "Humans",
		Weapon = "Sword",
		BaseDamage = 26,
		AttackSpeed = 1.4,
		Health = 95,
		Abilities = {
			{Name = "Emperor's Strike", Damage = 48, Cooldown = 7, Key = "Q"},
			{Name = "Chi Redirection", Damage = 60, Cooldown = 12, Key = "E"},
			{Name = "Heavenly Hand", Damage = 85, Cooldown = 18, Key = "R"}
		}
	},
	["Jack the Ripper"] = {
		Category = "Humans",
		Weapon = "Knives",
		BaseDamage = 20,
		AttackSpeed = 2.2,
		Health = 85,
		Abilities = {
			{Name = "Knife Barrage", Damage = 35, Cooldown = 5, Key = "Q"},
			{Name = "Dear God", Damage = 65, Cooldown = 10, Key = "E"},
			{Name = "The Ripper", Damage = 90, Cooldown = 16, Key = "R"}
		}
	},
	["Lü Bu"] = {
		Category = "Humans",
		Weapon = "Halberd",
		BaseDamage = 32,
		AttackSpeed = 1.1,
		Health = 105,
		Abilities = {
			{Name = "Sky Eater", Damage = 58, Cooldown = 8, Key = "Q"},
			{Name = "Flying General", Damage = 70, Cooldown = 13, Key = "E"},
			{Name = "Heavenly Execution", Damage = 110, Cooldown = 22, Key = "R"}
		}
	},
	Buddha = {
		Category = "Humans",
		Weapon = "Staff",
		BaseDamage = 24,
		AttackSpeed = 1.6,
		Health = 100,
		Abilities = {
			{Name = "Enlightenment", Damage = 42, Cooldown = 6, Key = "Q"},
			{Name = "Shield of Ahimsa", Damage = 0, Cooldown = 14, Key = "E"}, -- Defense
			{Name = "Nirvana", Damage = 88, Cooldown = 19, Key = "R"}
		}
	}
}

-- Funzione per applicare lo stile al giocatore
local function applyStyle(player, styleName)
	if not STYLE_CONFIGS[styleName] then
		warn("⚠️ [StyleManager] Stile non valido: " .. styleName)
		return
	end

	local config = STYLE_CONFIGS[styleName]
	playerStyles[player.UserId] = {
		Name = styleName,
		Config = config
	}

	print("✅ [StyleManager] " .. player.Name .. " ha scelto: " .. styleName)

	-- Imposta health
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.MaxHealth = config.Health
	humanoid.Health = config.Health

	-- ⚔️ AUTO-EQUIP ARMA
	local weaponName = config.Weapon
	if weaponName then
		-- Rimuovi armi vecchie dal Backpack
		for _, item in ipairs(player.Backpack:GetChildren()) do
			if item:IsA("Tool") then
				item:Destroy()
			end
		end

		-- Rimuovi armi vecchie dal Character
		for _, item in ipairs(character:GetChildren()) do
			if item:IsA("Tool") then
				item:Destroy()
			end
		end

		-- Equipaggia nuova arma in base allo stile
		local weaponTool = nil

		if styleName == "Poseidon" then
			weaponTool = ReplicatedStorage:FindFirstChild("PoseidonTrident")
		elseif styleName == "Zeus" then
			weaponTool = ReplicatedStorage:FindFirstChild("ZeusBolt")
		elseif styleName == "Thor" then
			weaponTool = ReplicatedStorage:FindFirstChild("Mjolnir")
		elseif styleName == "Shiva" then
			weaponTool = ReplicatedStorage:FindFirstChild("ShivaWeapon")
		elseif styleName == "Hades" then
			weaponTool = ReplicatedStorage:FindFirstChild("Bident")
		-- Humans non hanno tool fisici (combattono a mani nude o con abilità)
		end

		if weaponTool then
			local newTool = weaponTool:Clone()
			newTool.Parent = character -- Equipaggia direttamente
			print("⚔️ [StyleManager] " .. player.Name .. " equipaggia: " .. weaponName)
		elseif styleName == "Poseidon" then
			-- Solo warning per Poseidon, altri personaggi potrebbero non avere armi
			warn("⚠️ [StyleManager] Arma '" .. weaponName .. "' non trovata in ReplicatedStorage!")
			warn("⚠️ Usa CreatePoseidonTrident.lua per creare il tridente")
		end
	end

	print("✅ [StyleManager] Stile applicato completamente: " .. styleName)
end

-- Quando un giocatore seleziona uno stile
selectStyleEvent.OnServerEvent:Connect(function(player, styleName, category)
	print("📩 [StyleManager] " .. player.Name .. " vuole selezionare: " .. styleName .. " (" .. category .. ")")

	applyStyle(player, styleName)
end)

-- Gestione abilità
useAbilityEvent.OnServerEvent:Connect(function(player, abilityKey)
	local playerStyle = playerStyles[player.UserId]
	if not playerStyle then
		warn("⚠️ [StyleManager] " .. player.Name .. " non ha uno stile selezionato")
		return
	end

	-- Trova l'abilità corrispondente al tasto
	local ability = nil
	for _, abil in ipairs(playerStyle.Config.Abilities) do
		if abil.Key == abilityKey then
			ability = abil
			break
		end
	end

	if not ability then
		return
	end

	-- Controlla cooldown
	local cooldownKey = player.UserId .. "_" .. abilityKey
	if playerCooldowns[cooldownKey] and playerCooldowns[cooldownKey] > tick() then
		local timeLeft = math.ceil(playerCooldowns[cooldownKey] - tick())
		print("⏳ [StyleManager] " .. player.Name .. " - " .. ability.Name .. " in cooldown: " .. timeLeft .. "s")
		return
	end

	-- Usa abilità
	print("⚡ [StyleManager] " .. player.Name .. " usa: " .. ability.Name)

	-- Imposta cooldown
	playerCooldowns[cooldownKey] = tick() + ability.Cooldown

	-- Trova nemici nel range
	local range = ABILITY_RANGES[abilityKey] or 15
	local angle = 120 -- Angolo ampio per abilità
	local enemies = findEnemiesInRange(player, range, angle)

	-- Esegui abilità in base allo stile
	local styleName = playerStyle.Name

	if styleName == "Poseidon" then
		-- VFX Poseidon
		if abilityKey == "Q" then
			PoseidonAbilities.Amphitrite(player, enemies)
		elseif abilityKey == "E" then
			PoseidonAbilities.ChioneTyroDemeter(player, enemies)
		elseif abilityKey == "R" then
			PoseidonAbilities.FortyDayFlood(player, enemies)
		end

		-- Applica damage
		for _, enemy in ipairs(enemies) do
			dealDamage(enemy.Humanoid, ability.Damage, player)
		end

	else
		-- Altri stili (placeholder per ora)
		print("⚠️ [StyleManager] VFX per " .. styleName .. " non ancora implementati")

		-- Applica solo damage base
		for _, enemy in ipairs(enemies) do
			dealDamage(enemy.Humanoid, ability.Damage, player)
		end
	end
end)

-- Quando un giocatore entra
Players.PlayerAdded:Connect(function(player)
	playerCooldowns[player.UserId] = {}
	print("👤 [StyleManager] " .. player.Name .. " è entrato")
end)

-- Quando un giocatore esce
Players.PlayerRemoving:Connect(function(player)
	playerStyles[player.UserId] = nil
	playerCooldowns[player.UserId] = nil
	print("👋 [StyleManager] " .. player.Name .. " è uscito")
end)

print("⚔️ [StyleManager] Sistema attivo!")
