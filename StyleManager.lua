-- Style Manager - Server Script
-- Da mettere in ServerScriptService

print("⚔️ [StyleManager] Inizializzazione...")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

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
			{Name = "Tidal Wave", Damage = 50, Cooldown = 8, Key = "Q"},
			{Name = "Ocean's Wrath", Damage = 80, Cooldown = 15, Key = "E"},
			{Name = "Poseidon's Blessing", Damage = 0, Cooldown = 20, Key = "R"} -- Heal
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

	-- Qui puoi aggiungere l'arma/tool al giocatore
	-- (lo faremo nel prossimo step)
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

	-- Qui eseguirai l'abilità (damage, effects, etc.)
	-- (lo faremo nel prossimo step)
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
