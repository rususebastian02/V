-- POSIZIONA QUESTO SCRIPT IN: StarterPlayer > StarterPlayerScripts
-- Script per le particelle di cenere e disintegrazione sui player

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Aspetta l'evento remoto
local apocalypseEvent = ReplicatedStorage:WaitForChild("ApocalypseEvent")

-- Riferimenti alle particelle
local ashParticles = nil
local disintegrateParticles = nil

-- Funzione per creare le particelle di cenere
local function createAshParticles()
	print("🌫️ Creando particelle di cenere")

	if ashParticles then
		ashParticles:Destroy()
	end

	ashParticles = Instance.new("ParticleEmitter")
	ashParticles.Name = "AshParticles"

	-- Proprietà delle particelle di cenere
	ashParticles.Texture = "rbxasset://textures/particles/smoke_main.dds"
	ashParticles.Color = ColorSequence.new(Color3.fromRGB(80, 80, 80), Color3.fromRGB(60, 60, 60))
	ashParticles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 0.8)
	})
	ashParticles.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.5, 0.7),
		NumberSequenceKeypoint.new(1, 1)
	})

	ashParticles.Lifetime = NumberRange.new(2, 4)
	ashParticles.Rate = 15
	ashParticles.Speed = NumberRange.new(2, 5)
	ashParticles.SpreadAngle = Vector2.new(30, 30)
	ashParticles.Rotation = NumberRange.new(0, 360)
	ashParticles.RotSpeed = NumberRange.new(-50, 50)
	ashParticles.VelocityInheritance = 0.3
	ashParticles.Drag = 5

	-- Gravità verso l'alto (effetto cenere che sale)
	ashParticles.Acceleration = Vector3.new(0, 3, 0)

	ashParticles.Enabled = false
	ashParticles.Parent = humanoidRootPart
end

-- Funzione per creare le particelle di disintegrazione (Thanos Snap style)
local function createDisintegrateParticles()
	print("✨ Creando particelle di disintegrazione")

	if disintegrateParticles then
		disintegrateParticles:Destroy()
	end

	disintegrateParticles = Instance.new("ParticleEmitter")
	disintegrateParticles.Name = "DisintegrateParticles"

	-- Proprietà delle particelle di disintegrazione
	disintegrateParticles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	disintegrateParticles.Color = ColorSequence.new(Color3.fromRGB(200, 150, 100), Color3.fromRGB(150, 100, 50))
	disintegrateParticles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.2),
		NumberSequenceKeypoint.new(1, 0)
	})
	disintegrateParticles.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})

	disintegrateParticles.Lifetime = NumberRange.new(1, 2)
	disintegrateParticles.Rate = 100
	disintegrateParticles.Speed = NumberRange.new(5, 15)
	disintegrateParticles.SpreadAngle = Vector2.new(180, 180)
	disintegrateParticles.Rotation = NumberRange.new(0, 360)
	disintegrateParticles.RotSpeed = NumberRange.new(-200, 200)
	disintegrateParticles.VelocityInheritance = 0

	-- Gravità verso il basso
	disintegrateParticles.Acceleration = Vector3.new(0, -20, 0)

	disintegrateParticles.Enabled = false
	disintegrateParticles.Parent = humanoidRootPart
end

-- Funzione per aggiungere particelle a tutte le parti del corpo
local function addParticlesToAllParts(particleType)
	local bodyParts = {"Head", "Torso", "UpperTorso", "LowerTorso", "LeftArm", "RightArm", "LeftLeg", "RightLeg", "LeftHand", "RightHand", "LeftFoot", "RightFoot", "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm", "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg"}

	for _, partName in pairs(bodyParts) do
		local part = character:FindFirstChild(partName)
		if part and part:IsA("BasePart") then
			local emitter = particleType:Clone()
			emitter.Parent = part
			emitter.Enabled = true
		end
	end
end

-- Funzione per rimuovere tutte le particelle
local function removeAllParticles()
	for _, descendant in pairs(character:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") and (descendant.Name == "AshParticles" or descendant.Name == "DisintegrateParticles") then
			descendant:Destroy()
		end
	end

	if ashParticles then
		ashParticles:Destroy()
		ashParticles = nil
	end

	if disintegrateParticles then
		disintegrateParticles:Destroy()
		disintegrateParticles = nil
	end
end

-- Crea le particelle all'avvio
createAshParticles()
createDisintegrateParticles()

-- Ascolta gli eventi dal server
apocalypseEvent.OnClientEvent:Connect(function(action)
	if action == "ash" then
		print("🔥 Attivando particelle di cenere")
		ashParticles.Enabled = true
		addParticlesToAllParts(ashParticles)

	elseif action == "disintegrate" then
		print("💥 Attivando particelle di disintegrazione")

		-- Disattiva le particelle di cenere
		if ashParticles then
			ashParticles.Enabled = false
			for _, descendant in pairs(character:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") and descendant.Name == "AshParticles" then
					descendant.Enabled = false
				end
			end
		end

		-- Attiva le particelle di disintegrazione
		disintegrateParticles.Enabled = true
		addParticlesToAllParts(disintegrateParticles)

	elseif action == "reset" then
		print("🔄 Resettando particelle")
		removeAllParticles()
		-- Ricrea le particelle per il prossimo ciclo
		wait(0.5)
		createAshParticles()
		createDisintegrateParticles()
	end
end)

-- Ricrea le particelle quando il personaggio respawna
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	removeAllParticles()
	wait(0.5)
	createAshParticles()
	createDisintegrateParticles()
end)

print("✅ Script particelle apocalisse caricato")
