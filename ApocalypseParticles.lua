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

-- Funzione per creare le particelle di cenere
local function createAshParticles()
	print("Creating ash particles")

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
		if descendant:IsA("ParticleEmitter") and descendant.Name == "AshParticles" then
			descendant:Destroy()
		end
	end

	if ashParticles then
		ashParticles:Destroy()
		ashParticles = nil
	end
end

-- Crea le particelle all'avvio
createAshParticles()

-- Ascolta gli eventi dal server
apocalypseEvent.OnClientEvent:Connect(function(action)
	if action == "ash" then
		print("Activating ash particles")
		ashParticles.Enabled = true
		addParticlesToAllParts(ashParticles)

	elseif action == "reset" then
		print("Resetting particles")
		removeAllParticles()
		-- Ricrea le particelle per il prossimo ciclo
		wait(0.5)
		createAshParticles()
	end
end)

-- Ricrea le particelle quando il personaggio respawna
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	removeAllParticles()
	wait(0.5)
	createAshParticles()
end)

print("Apocalypse particles loaded")
