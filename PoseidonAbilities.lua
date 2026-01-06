-- Poseidon Abilities VFX System - ModuleScript
-- Da mettere in ReplicatedStorage come ModuleScript

local PoseidonAbilities = {}

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- ========================================
-- ANIMATION SYSTEM
-- ========================================

-- Animation IDs - SOSTITUISCI con i tuoi dopo averle create!
-- Per ora usa "PLACEHOLDER" - il sistema funzionerà comunque senza animazioni
local POSEIDON_ANIMATIONS = {
	BasicAttacks = {
		"PLACEHOLDER", -- BasicAttack1 - Affondo dritto
		"PLACEHOLDER", -- BasicAttack2 - Slash orizzontale
		"PLACEHOLDER"  -- BasicAttack3 - Attacco dall'alto
	},
	Amphitrite = "PLACEHOLDER",          -- Animazione Q
	ChioneTyroDemeter = "PLACEHOLDER",   -- Animazione E
	FortyDayFlood = "PLACEHOLDER"        -- Animazione R
}

-- Funzione per riprodurre animazione
local function playAnimation(character, animId)
	if not character then return end
	if animId == "PLACEHOLDER" then return end -- Salta se non configurato

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = animId

	local track = animator:LoadAnimation(animation)
	track:Play()

	return track
end

-- ========================================
-- UTILITY FUNCTIONS
-- ========================================

local function createWaterParticle(parent, size, lifetime)
	local particle = Instance.new("ParticleEmitter")
	particle.Texture = "rbxasset://textures/particles/smoke_main.dds" -- Texture acqua
	particle.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 100, 200)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 150, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 200, 255))
	})
	particle.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	particle.Size = NumberSequence.new(size)
	particle.Lifetime = NumberRange.new(lifetime)
	particle.Rate = 50
	particle.Speed = NumberRange.new(5, 10)
	particle.SpreadAngle = Vector2.new(30, 30)
	particle.Parent = parent
	return particle
end

local function createSplashEffect(position)
	local splash = Instance.new("Part")
	splash.Size = Vector3.new(1, 1, 1)
	splash.Position = position
	splash.Anchored = true
	splash.CanCollide = false
	splash.Transparency = 1
	splash.Parent = workspace

	-- Particelle splash
	local splashParticle = createWaterParticle(splash, 2, 0.8)
	splashParticle.Rate = 100
	splashParticle.Enabled = true

	-- Onda d'urto (ring)
	local ring = Instance.new("Part")
	ring.Size = Vector3.new(0.5, 0.5, 0.5)
	ring.Position = position
	ring.Anchored = true
	ring.CanCollide = false
	ring.Transparency = 0.5
	ring.Material = Enum.Material.Neon
	ring.Color = Color3.fromRGB(30, 100, 200)
	ring.Shape = Enum.PartType.Cylinder
	ring.Orientation = Vector3.new(0, 0, 90)
	ring.Parent = workspace

	-- Espansione ring
	local expandTween = TweenService:Create(ring, TweenInfo.new(0.5), {
		Size = Vector3.new(0.5, 15, 15),
		Transparency = 1
	})
	expandTween:Play()

	Debris:AddItem(splash, 1)
	Debris:AddItem(ring, 1)
end

local function createWaterTrail(character, duration)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	-- Attachment per trail
	local attach0 = Instance.new("Attachment")
	attach0.Position = Vector3.new(0, -2, 0)
	attach0.Parent = rootPart

	local attach1 = Instance.new("Attachment")
	attach1.Position = Vector3.new(0, 1, 0)
	attach1.Parent = rootPart

	-- Trail acqua
	local trail = Instance.new("Trail")
	trail.Attachment0 = attach0
	trail.Attachment1 = attach1
	trail.Color = ColorSequence.new(Color3.fromRGB(30, 100, 200))
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	trail.Lifetime = 0.5
	trail.MinLength = 0
	trail.Enabled = true
	trail.Parent = rootPart

	task.delay(duration, function()
		trail.Enabled = false
		Debris:AddItem(attach0, 1)
		Debris:AddItem(attach1, 1)
		Debris:AddItem(trail, 1)
	end)
end

local function playSound(soundId, parent, volume)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume or 0.5
	sound.Parent = parent
	sound:Play()
	Debris:AddItem(sound, 3)
end

-- ========================================
-- ABILITY 1: AMPHITRITE (Q)
-- ========================================

function PoseidonAbilities.Amphitrite(attacker, targets)
	print("🌊 [Poseidon] Amphitrite!")

	-- Riproduci animazione
	playAnimation(attacker.Character, POSEIDON_ANIMATIONS.Amphitrite)

	local character = attacker.Character
	if not character then return end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	-- Suono d'acqua
	playSound("rbxassetid://9125453766", rootPart, 0.7) -- Water whoosh

	-- Trail d'acqua durante rotazione
	createWaterTrail(character, 1.2)

	-- Vortice d'acqua centrale
	local vortex = Instance.new("Part")
	vortex.Size = Vector3.new(8, 0.5, 8)
	vortex.Position = rootPart.Position
	vortex.Anchored = true
	vortex.CanCollide = false
	vortex.Transparency = 0.7
	vortex.Material = Enum.Material.Neon
	vortex.Color = Color3.fromRGB(30, 100, 200)
	vortex.Parent = workspace

	-- Mesh cilindrico
	local mesh = Instance.new("CylinderMesh")
	mesh.Parent = vortex

	-- Rotazione vortice
	local rotationCFrame = vortex.CFrame
	for i = 1, 60 do
		task.wait(0.02)
		vortex.CFrame = rotationCFrame * CFrame.Angles(0, math.rad(i * 12), 0)
		vortex.Transparency = 0.7 + (i / 60) * 0.3
	end

	-- Particelle circolari (afterimages)
	for angle = 0, 360, 45 do
		local rad = math.rad(angle)
		local offset = Vector3.new(math.cos(rad) * 3, 0, math.sin(rad) * 3)
		createSplashEffect(rootPart.Position + offset)
	end

	-- Damage ai nemici
	if targets and #targets > 0 then
		for _, targetData in ipairs(targets) do
			createSplashEffect(targetData.Position)
			-- Damage applicato dal server (CombatHandler)
		end
	end

	Debris:AddItem(vortex, 1.2)
end

-- ========================================
-- ABILITY 2: CHIONE TYRO DEMETER (E)
-- ========================================

function PoseidonAbilities.ChioneTyroDemeter(attacker, targets)
	print("🌊 [Poseidon] Chione Tyro Demeter!")

	-- Riproduci animazione
	playAnimation(attacker.Character, POSEIDON_ANIMATIONS.ChioneTyroDemeter)

	local character = attacker.Character
	if not character then return end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	-- Suono salto potente
	playSound("rbxassetid://9114128563", rootPart, 0.8) -- Whoosh/jump

	-- Fase 1: Salto (movimento gestito da animazione o script)
	local originalCFrame = rootPart.CFrame
	local jumpHeight = 15

	-- Effetto carica prima del salto
	createSplashEffect(rootPart.Position)

	-- Salto (tween)
	local jumpTween = TweenService:Create(rootPart, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = originalCFrame + Vector3.new(0, jumpHeight, 0)
	})
	jumpTween:Play()
	jumpTween.Completed:Wait()

	-- Fase 2: Sospensione in aria (0.3s)
	task.wait(0.3)

	-- Fase 3: Pioggia di colpi dall'alto
	playSound("rbxassetid://9114487369", rootPart, 0.9) -- Multiple impacts

	-- Crea "lance d'acqua" che cadono
	for i = 1, 12 do
		task.wait(0.05)

		local randomOffset = Vector3.new(
			math.random(-5, 5),
			0,
			math.random(-5, 5)
		)
		local targetPos = rootPart.Position - Vector3.new(0, jumpHeight, 0) + randomOffset

		-- Lancia d'acqua
		local spear = Instance.new("Part")
		spear.Size = Vector3.new(0.3, 4, 0.3)
		spear.Position = rootPart.Position
		spear.Anchored = false
		spear.CanCollide = false
		spear.Material = Enum.Material.Neon
		spear.Color = Color3.fromRGB(80, 150, 255)
		spear.Parent = workspace

		-- Velocità verso il basso
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = (targetPos - spear.Position).Unit * 50 + Vector3.new(0, -30, 0)
		bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
		bodyVelocity.Parent = spear

		-- Trail sulla lancia
		local attach0 = Instance.new("Attachment", spear)
		local attach1 = Instance.new("Attachment", spear)
		attach1.Position = Vector3.new(0, 2, 0)

		local trail = Instance.new("Trail")
		trail.Attachment0 = attach0
		trail.Attachment1 = attach1
		trail.Color = ColorSequence.new(Color3.fromRGB(30, 100, 200))
		trail.Lifetime = 0.3
		trail.Parent = spear

		Debris:AddItem(spear, 0.8)
	end

	-- Fase 4: Discesa e atterraggio
	task.wait(0.4)
	local landTween = TweenService:Create(rootPart, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		CFrame = originalCFrame
	})
	landTween:Play()
	landTween.Completed:Wait()

	-- Impatto atterraggio
	createSplashEffect(rootPart.Position)
	playSound("rbxassetid://9125771376", rootPart, 1.0) -- Impact

	-- Onda d'urto circolare
	for angle = 0, 360, 30 do
		local rad = math.rad(angle)
		local offset = Vector3.new(math.cos(rad) * 6, 0, math.sin(rad) * 6)

		task.delay(angle / 360 * 0.2, function()
			createSplashEffect(rootPart.Position + offset)
		end)
	end

	-- Damage ai nemici
	if targets and #targets > 0 then
		for _, targetData in ipairs(targets) do
			createSplashEffect(targetData.Position)
		end
	end
end

-- ========================================
-- ABILITY 3: 40 DAY FLOOD (R/ULTIMATE)
-- ========================================

function PoseidonAbilities.FortyDayFlood(attacker, targets)
	print("🌊💥 [Poseidon] 40 DAY FLOOD!")

	-- Riproduci animazione
	playAnimation(attacker.Character, POSEIDON_ANIMATIONS.FortyDayFlood)

	local character = attacker.Character
	if not character then return end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	-- Suono epico
	playSound("rbxassetid://9125771376", rootPart, 1.0) -- Powerful impact
	playSound("rbxassetid://9114128563", rootPart, 0.8) -- Whoosh layer

	-- Trail d'acqua massiccio
	createWaterTrail(character, 2.5)

	-- Fase 1: Carica - Sfera d'acqua crescente
	local chargeSphere = Instance.new("Part")
	chargeSphere.Shape = Enum.PartType.Ball
	chargeSphere.Size = Vector3.new(2, 2, 2)
	chargeSphere.Position = rootPart.Position
	chargeSphere.Anchored = true
	chargeSphere.CanCollide = false
	chargeSphere.Transparency = 0.5
	chargeSphere.Material = Enum.Material.Neon
	chargeSphere.Color = Color3.fromRGB(30, 100, 200)
	chargeSphere.Parent = workspace

	-- Particelle sulla sfera
	local chargeParticles = createWaterParticle(chargeSphere, 3, 1)
	chargeParticles.Rate = 200

	-- Espansione sfera carica
	local chargeTween = TweenService:Create(chargeSphere, TweenInfo.new(0.5), {
		Size = Vector3.new(6, 6, 6)
	})
	chargeTween:Play()
	task.wait(0.5)

	chargeSphere:Destroy()

	-- Fase 2: CUPOLA MASSICCIA DI AFTERIMAGES
	local domeCenter = rootPart.Position
	local domeRadius = 18

	-- Crea cupola visiva
	local dome = Instance.new("Part")
	dome.Shape = Enum.PartType.Ball
	dome.Size = Vector3.new(domeRadius * 2, domeRadius * 2, domeRadius * 2)
	dome.Position = domeCenter
	dome.Anchored = true
	dome.CanCollide = false
	dome.Transparency = 0.8
	dome.Material = Enum.Material.ForceField
	dome.Color = Color3.fromRGB(30, 100, 200)
	dome.Parent = workspace

	-- Particelle massicce
	local domeParticles = createWaterParticle(dome, 5, 1.5)
	domeParticles.Rate = 300

	-- Rotazione cupola
	local rotationSpeed = 20
	task.spawn(function()
		for i = 1, 100 do
			task.wait(0.02)
			dome.CFrame = CFrame.new(domeCenter) * CFrame.Angles(0, math.rad(i * rotationSpeed), 0)
		end
	end)

	-- Fase 3: AFTERIMAGES CIRCOLARI (whirlpool effect)
	for wave = 1, 3 do
		task.wait(0.3)

		for angle = 0, 360, 20 do
			local rad = math.rad(angle + (wave * 15)) -- Offset per effetto spirale
			local distance = domeRadius * 0.7
			local height = wave * 2

			local offset = Vector3.new(
				math.cos(rad) * distance,
				height,
				math.sin(rad) * distance
			)

			-- Afterimage slash effect
			local slash = Instance.new("Part")
			slash.Size = Vector3.new(0.5, 6, 2)
			slash.Position = domeCenter + offset
			slash.Anchored = true
			slash.CanCollide = false
			slash.Transparency = 0.3
			slash.Material = Enum.Material.Neon
			slash.Color = Color3.fromRGB(80, 150, 255)
			slash.CFrame = CFrame.new(slash.Position, domeCenter) -- Guarda verso il centro
			slash.Parent = workspace

			-- Fade out slash
			TweenService:Create(slash, TweenInfo.new(0.5), {
				Transparency = 1,
				Size = Vector3.new(0.2, 8, 2.5)
			}):Play()

			Debris:AddItem(slash, 0.6)
		end

		-- Suono slash multipli
		playSound("rbxassetid://9114487369", rootPart, 0.6)
	end

	-- Fase 4: IMPLOSIONE FINALE
	task.wait(1)

	-- Contrazione cupola
	local implosionTween = TweenService:Create(dome, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = Vector3.new(2, 2, 2),
		Transparency = 0.3
	})
	implosionTween:Play()
	implosionTween.Completed:Wait()

	-- ESPLOSIONE
	playSound("rbxassetid://9125771376", rootPart, 1.2)

	local explosion = Instance.new("Explosion")
	explosion.Position = domeCenter
	explosion.BlastRadius = domeRadius
	explosion.BlastPressure = 0 -- Solo effetto visivo, damage gestito da script
	explosion.Parent = workspace

	-- Onde d'urto esplosive
	for ring = 1, 5 do
		task.wait(0.1)

		for angle = 0, 360, 30 do
			local rad = math.rad(angle)
			local offset = Vector3.new(
				math.cos(rad) * (ring * 4),
				0,
				math.sin(rad) * (ring * 4)
			)
			createSplashEffect(domeCenter + offset)
		end
	end

	-- Damage ai nemici
	if targets and #targets > 0 then
		for _, targetData in ipairs(targets) do
			-- Effetto impatto su ogni nemico
			createSplashEffect(targetData.Position)

			-- Knockback (se il character esiste)
			if targetData.Character then
				local targetRoot = targetData.Character:FindFirstChild("HumanoidRootPart")
				if targetRoot then
					local knockbackDirection = (targetRoot.Position - domeCenter).Unit
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.Velocity = knockbackDirection * 50 + Vector3.new(0, 20, 0)
					bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
					bodyVelocity.Parent = targetRoot
					Debris:AddItem(bodyVelocity, 0.3)
				end
			end
		end
	end

	Debris:AddItem(dome, 2.5)
end

-- ========================================
-- BASIC ATTACK
-- ========================================

function PoseidonAbilities.BasicAttack(attacker, target)
	local character = attacker.Character
	if not character then return end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	-- ⚡ RANDOM: Scegli una delle 3 animazioni
	local randomIndex = math.random(1, #POSEIDON_ANIMATIONS.BasicAttacks)
	local selectedAnim = POSEIDON_ANIMATIONS.BasicAttacks[randomIndex]
	playAnimation(character, selectedAnim)

	-- Suono colpo
	playSound("rbxassetid://9114487369", rootPart, 0.4)

	-- Splash piccolo sulla vittima
	if target and target.Position then
		createSplashEffect(target.Position)
	end

	-- Effetti sul TRIDENTE (se equipaggiato)
	local trident = character:FindFirstChild("PoseidonTrident")
	if trident then
		local handle = trident:FindFirstChild("Handle")
		if handle then
			-- Particelle d'acqua dalla punta
			local particle = createWaterParticle(handle, 1.5, 0.3)
			particle.Enabled = true
			task.delay(0.2, function()
				particle.Enabled = false
				Debris:AddItem(particle, 1)
			end)

			-- Flash blu sulla punta
			local centerProng = trident:FindFirstChild("CenterProng")
			if centerProng then
				local originalBrightness = 2
				local light = centerProng:FindFirstChild("PointLight")
				if light then
					light.Brightness = 5
					task.delay(0.1, function()
						light.Brightness = originalBrightness
					end)
				end
			end
		end
	else
		-- Fallback: Particelle sul braccio se non c'è tridente
		local rightArm = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
		if rightArm then
			local particle = createWaterParticle(rightArm, 1, 0.3)
			particle.Enabled = true
			task.delay(0.2, function()
				particle.Enabled = false
				Debris:AddItem(particle, 1)
			end)
		end
	end
end

return PoseidonAbilities
