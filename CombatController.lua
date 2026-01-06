-- Combat Controller - Client Side
-- Da mettere in StarterPlayerScripts come LocalScript

print("⚔️ [CombatController] Inizializzazione...")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- RemoteEvents
local useAbilityEvent = ReplicatedStorage:WaitForChild("UseAbility", 10)
local basicAttackEvent = ReplicatedStorage:WaitForChild("BasicAttack", 10)

if not useAbilityEvent or not basicAttackEvent then
	warn("❌ [CombatController] RemoteEvents non trovati!")
	return
end

-- Cooldowns locali (per UI)
local abilityCooldowns = {
	Q = 0,
	E = 0,
	R = 0
}

local isAttacking = false
local canAttack = true
local ATTACK_COOLDOWN = 0.5 -- Cooldown attacco base

-- UI Cooldown (cre

ata dinamicamente)
local function createCooldownUI()
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CombatUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- Container abilità (in basso al centro)
	local abilitiesFrame = Instance.new("Frame")
	abilitiesFrame.Size = UDim2.new(0, 400, 0, 100)
	abilitiesFrame.Position = UDim2.new(0.5, -200, 1, -120)
	abilitiesFrame.BackgroundTransparency = 1
	abilitiesFrame.Parent = screenGui

	local abilities = {"Q", "E", "R"}
	local abilityButtons = {}

	for i, key in ipairs(abilities) do
		local button = Instance.new("Frame")
		button.Name = key .. "Button"
		button.Size = UDim2.new(0, 90, 0, 90)
		button.Position = UDim2.new(0, (i - 1) * 120 + 40, 0, 0)
		button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
		button.BorderSizePixel = 0
		button.Parent = abilitiesFrame

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = button

		-- Key label
		local keyLabel = Instance.new("TextLabel")
		keyLabel.Size = UDim2.new(1, 0, 1, 0)
		keyLabel.BackgroundTransparency = 1
		keyLabel.Text = key
		keyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		keyLabel.TextSize = 36
		keyLabel.Font = Enum.Font.GothamBold
		keyLabel.Parent = button

		-- Cooldown overlay
		local cooldownOverlay = Instance.new("Frame")
		cooldownOverlay.Name = "CooldownOverlay"
		cooldownOverlay.Size = UDim2.new(1, 0, 0, 0)
		cooldownOverlay.Position = UDim2.new(0, 0, 1, 0)
		cooldownOverlay.AnchorPoint = Vector2.new(0, 1)
		cooldownOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		cooldownOverlay.BackgroundTransparency = 0.5
		cooldownOverlay.BorderSizePixel = 0
		cooldownOverlay.Parent = button

		local overlayCorner = Instance.new("UICorner")
		overlayCorner.CornerRadius = UDim.new(0, 12)
		overlayCorner.Parent = cooldownOverlay

		-- Cooldown text
		local cooldownText = Instance.new("TextLabel")
		cooldownText.Name = "CooldownText"
		cooldownText.Size = UDim2.new(1, 0, 1, 0)
		cooldownText.BackgroundTransparency = 1
		cooldownText.Text = ""
		cooldownText.TextColor3 = Color3.fromRGB(255, 100, 100)
		cooldownText.TextSize = 24
		cooldownText.Font = Enum.Font.GothamBold
		cooldownText.Visible = false
		cooldownText.Parent = button

		abilityButtons[key] = {
			Button = button,
			Overlay = cooldownOverlay,
			Text = cooldownText
		}
	end

	return abilityButtons
end

local abilityButtons = createCooldownUI()

-- Funzione per aggiornare UI cooldown
local function updateCooldownUI(key)
	local button = abilityButtons[key]
	if not button then return end

	local timeLeft = abilityCooldowns[key] - tick()

	if timeLeft > 0 then
		-- In cooldown
		button.Text.Text = string.format("%.1f", timeLeft)
		button.Text.Visible = true
		button.Overlay.Size = UDim2.new(1, 0, timeLeft / 20, 0) -- Proporzionale

		button.Button.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
	else
		-- Pronto
		button.Text.Visible = false
		button.Overlay.Size = UDim2.new(1, 0, 0, 0)
		button.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	end
end

-- Loop aggiornamento UI
spawn(function()
	while true do
		wait(0.1)
		for key, _ in pairs(abilityCooldowns) do
			updateCooldownUI(key)
		end
	end
end)

-- Attacco base (click mouse)
mouse.Button1Down:Connect(function()
	if not canAttack or isAttacking then return end

	isAttacking = true
	canAttack = false

	-- Invia al server
	basicAttackEvent:FireServer()

	-- Animazione locale (placeholder)
	print("👊 [CombatController] Attacco base!")

	-- Cooldown
	wait(ATTACK_COOLDOWN)
	canAttack = true
	isAttacking = false
end)

-- Abilità (Q, E, R)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	local key = input.KeyCode.Name

	-- Controlla se è Q, E, o R
	if key ~= "Q" and key ~= "E" and key ~= "R" then return end

	-- Controlla cooldown locale
	if abilityCooldowns[key] > tick() then
		local timeLeft = math.ceil(abilityCooldowns[key] - tick())
		print("⏳ [CombatController] " .. key .. " in cooldown: " .. timeLeft .. "s")
		return
	end

	-- Usa abilità
	print("⚡ [CombatController] Uso abilità: " .. key)
	useAbilityEvent:FireServer(key)

	-- Imposta cooldown temporaneo (verrà aggiornato dal server)
	abilityCooldowns[key] = tick() + 5 -- Placeholder
end)

print("⚔️ [CombatController] Sistema combattimento attivo!")
