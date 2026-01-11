-- Custom Walk, Sprint, and Jump Animation System
-- Da mettere in StarterPlayer > StarterCharacterScripts come LocalScript

print("🏃 [CustomWalkAndSprint] Inizializzazione...")

local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

-- Configurazione velocità
local NORMAL_SPEED = 16
local SPRINT_SPEED = 26

-- Animation IDs
local WALK_ANIMATION_ID = "rbxassetid://80499174542461"
local SPRINT_ANIMATION_ID = "rbxassetid://95750271539214"
local JUMP_ANIMATION_ID = "rbxassetid://507765000" -- Default R15 jump

-- Variabili di stato
local isSprinting = false
local isJumping = false

-- Animation tracks
local walkTrack = nil
local sprintTrack = nil
local jumpTrack = nil
local currentMovementTrack = nil

-- 🗑️ Rimuovi lo script Animate di default per avere controllo completo
local animateScript = character:FindFirstChild("Animate")
if animateScript then
	animateScript:Destroy()
	print("✅ [CustomWalkAndSprint] Script Animate rimosso")
end

-- 📦 Carica le animazioni
local function loadAnimations()
	-- Walk animation
	local walkAnim = Instance.new("Animation")
	walkAnim.AnimationId = WALK_ANIMATION_ID
	walkTrack = animator:LoadAnimation(walkAnim)
	walkTrack.Priority = Enum.AnimationPriority.Movement
	walkTrack.Looped = true

	-- Sprint animation
	local sprintAnim = Instance.new("Animation")
	sprintAnim.AnimationId = SPRINT_ANIMATION_ID
	sprintTrack = animator:LoadAnimation(sprintAnim)
	sprintTrack.Priority = Enum.AnimationPriority.Movement
	sprintTrack.Looped = true

	-- Jump animation (default R15)
	local jumpAnim = Instance.new("Animation")
	jumpAnim.AnimationId = JUMP_ANIMATION_ID
	jumpTrack = animator:LoadAnimation(jumpAnim)
	jumpTrack.Priority = Enum.AnimationPriority.Action -- Priority più alta per non essere sovrascritto
	jumpTrack.Looped = false

	print("✅ [CustomWalkAndSprint] Animazioni caricate: Walk, Sprint, Jump")
end

loadAnimations()

-- 🏃 Funzione per gestire camminata/corsa
local function updateMovementAnimation()
	-- Se sta saltando, non cambiare animazione
	if isJumping then
		return
	end

	-- Determina quale animazione di movimento usare
	local targetTrack = isSprinting and sprintTrack or walkTrack

	-- Se è già quella corretta, non fare nulla
	if currentMovementTrack == targetTrack and currentMovementTrack.IsPlaying then
		return
	end

	-- Ferma l'animazione precedente
	if currentMovementTrack and currentMovementTrack.IsPlaying then
		currentMovementTrack:Stop(0.2)
	end

	-- Riproduci la nuova animazione se il personaggio si sta muovendo
	if humanoid.MoveVector.Magnitude > 0 then
		targetTrack:Play(0.2)
		currentMovementTrack = targetTrack
	end
end

-- ⚡ Gestione SHIFT per sprint
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		isSprinting = true
		humanoid.WalkSpeed = SPRINT_SPEED
		updateMovementAnimation()
		print("🏃 [CustomWalkAndSprint] Sprint attivato")
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		isSprinting = false
		humanoid.WalkSpeed = NORMAL_SPEED
		updateMovementAnimation()
		print("🚶 [CustomWalkAndSprint] Sprint disattivato")
	end
end)

-- 🦘 Gestione Jump Animation
humanoid.StateChanged:Connect(function(oldState, newState)
	if newState == Enum.HumanoidStateType.Jumping or newState == Enum.HumanoidStateType.Freefall then
		-- Inizia salto
		if not isJumping then
			isJumping = true

			-- Ferma animazioni di movimento
			if currentMovementTrack and currentMovementTrack.IsPlaying then
				currentMovementTrack:Stop(0.1)
			end

			-- Riproduci animazione salto
			jumpTrack:Play(0.1)
			print("🦘 [CustomWalkAndSprint] Salto!")
		end

	elseif newState == Enum.HumanoidStateType.Landed then
		-- Atterraggio
		isJumping = false

		-- Ferma animazione salto
		if jumpTrack.IsPlaying then
			jumpTrack:Stop(0.1)
		end

		-- Riprendi animazione di movimento se necessario
		updateMovementAnimation()
		print("🎯 [CustomWalkAndSprint] Atterrato!")

	elseif newState == Enum.HumanoidStateType.Running then
		-- Movimento normale (non in salto)
		if not isJumping then
			updateMovementAnimation()
		end
	elseif newState == Enum.HumanoidStateType.Idle then
		-- Fermo
		if not isJumping then
			if currentMovementTrack and currentMovementTrack.IsPlaying then
				currentMovementTrack:Stop(0.2)
			end
		end
	end
end)

-- 👟 Monitora movimento per avviare/fermare animazioni
humanoid:GetPropertyChangedSignal("MoveVector"):Connect(function()
	if not isJumping then
		if humanoid.MoveVector.Magnitude > 0 then
			updateMovementAnimation()
		else
			-- Fermo
			if currentMovementTrack and currentMovementTrack.IsPlaying then
				currentMovementTrack:Stop(0.2)
			end
		end
	end
end)

print("✅ [CustomWalkAndSprint] Sistema attivo! SHIFT per sprintare")
