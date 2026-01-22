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
local burningParticles = nil

-- Funzione per creare le particelle di bruciatura
local function createBurningParticles()
	print("Creating burning particles")

	if burningParticles then
		burningParticles:Destroy()
	end

	burningParticles = Instance.new("ParticleEmitter")
	burningParticles.Name = "BurningParticles"

	-- Proprietà delle particelle di fuoco/bruciatura
	burningParticles.Texture = "rbxasset://textures/particles/fire_main.dds"
	burningParticles.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 100)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 120, 50)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 50, 30))
	})
	burningParticles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.6),
		NumberSequenceKeypoint.new(1, 0.1)
	})
	burningParticles.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})

	burningParticles.Lifetime = NumberRange.new(0.5, 1.5)
	burningParticles.Rate = 20
	burningParticles.Speed = NumberRange.new(1, 3)
	burningParticles.SpreadAngle = Vector2.new(25, 25)
	burningParticles.Rotation = NumberRange.new(0, 360)
	burningParticles.RotSpeed = NumberRange.new(-100, 100)
	burningParticles.VelocityInheritance = 0.2
	burningParticles.Drag = 3

	-- Gravità verso l'alto (fiamme salgono)
	burningParticles.Acceleration = Vector3.new(0, 4, 0)

	burningParticles.LightEmission = 0.8
	burningParticles.LightInfluence = 0

	burningParticles.Enabled = false
	burningParticles.Parent = humanoidRootPart
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
		if descendant:IsA("ParticleEmitter") and descendant.Name == "BurningParticles" then
			descendant:Destroy()
		end
	end

	if burningParticles then
		burningParticles:Destroy()
		burningParticles = nil
	end
end

-- Crea le particelle all'avvio
createBurningParticles()

-- Ascolta gli eventi dal server
apocalypseEvent.OnClientEvent:Connect(function(action)
	if action == "phase_3" then
		-- Activate burning particles at 5 minutes
		print("Activating burning particles")
		burningParticles.Enabled = true
		addParticlesToAllParts(burningParticles)

	elseif action == "ash" then
		-- Intensify burning particles at apocalypse start
		print("Intensifying burning particles")
		if burningParticles then
			burningParticles.Rate = 40
		end

	elseif action == "reset" then
		print("Resetting particles")
		removeAllParticles()
		-- Ricrea le particelle per il prossimo ciclo
		wait(0.5)
		createBurningParticles()
	end
end)

-- Ricrea le particelle quando il personaggio respawna
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	removeAllParticles()
	wait(0.5)
	createBurningParticles()
end)

print("Apocalypse particles loaded")
