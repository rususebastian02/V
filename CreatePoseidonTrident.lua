-- Script per Creare il Tridente di Poseidon
-- ISTRUZIONI:
-- 1. Metti questo script in ServerScriptService
-- 2. Premi Play UNA VOLTA
-- 3. Il tridente verrà creato in ReplicatedStorage
-- 4. CANCELLA questo script dopo (serve solo una volta)

print("🔱 [TridentCreator] Creazione Tridente di Poseidon...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Controlla se esiste già
if ReplicatedStorage:FindFirstChild("PoseidonTrident") then
	warn("⚠️ [TridentCreator] PoseidonTrident esiste già! Cancello e ricreo...")
	ReplicatedStorage.PoseidonTrident:Destroy()
	wait(0.1)
end

-- Crea il Tool
local trident = Instance.new("Tool")
trident.Name = "PoseidonTrident"
trident.RequiresHandle = true
trident.CanBeDropped = false
trident.ToolTip = "Tridente di Poseidon - Dio del Mare"
trident.Parent = ReplicatedStorage

-- Crea l'Handle (asta principale)
local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Size = Vector3.new(0.3, 6, 0.3)
handle.Material = Enum.Material.Neon
handle.Color = Color3.fromRGB(30, 100, 200) -- Blu oceano scuro
handle.CanCollide = false
handle.Parent = trident

-- Mesh per l'asta (cilindro)
local handleMesh = Instance.new("SpecialMesh")
handleMesh.MeshType = Enum.MeshType.Cylinder
handleMesh.Parent = handle

-- ======================================
-- PUNTE DEL TRIDENTE
-- ======================================

-- Funzione helper per creare una punta
local function createProng(name, position, rotation)
	local prong = Instance.new("Part")
	prong.Name = name
	prong.Size = Vector3.new(0.2, 1.2, 0.2)
	prong.Material = Enum.Material.Neon
	prong.Color = Color3.fromRGB(150, 200, 255) -- Blu chiaro
	prong.CanCollide = false
	prong.Shape = Enum.PartType.Ball -- Temporaneo
	prong.Parent = trident

	-- Mesh a punta
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Wedge
	mesh.Scale = Vector3.new(1, 1.5, 1)
	mesh.Parent = prong

	-- Posiziona rispetto all'handle
	prong.CFrame = handle.CFrame * CFrame.new(position) * CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z))

	-- Weld alla handle
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = handle
	weld.Part1 = prong
	weld.Parent = prong

	return prong
end

-- Punta centrale (dritto in alto)
local centerProng = createProng(
	"CenterProng",
	Vector3.new(0, 3.5, 0),
	Vector3.new(0, 0, 0)
)

-- Punta sinistra (angolata)
local leftProng = createProng(
	"LeftProng",
	Vector3.new(-0.6, 3.2, 0),
	Vector3.new(0, 0, -25)
)

-- Punta destra (angolata)
local rightProng = createProng(
	"RightProng",
	Vector3.new(0.6, 3.2, 0),
	Vector3.new(0, 0, 25)
)

-- ======================================
-- DECORAZIONI
-- ======================================

-- Anelli decorativi sull'asta
for i = 1, 3 do
	local ring = Instance.new("Part")
	ring.Name = "Ring" .. i
	ring.Size = Vector3.new(0.45, 0.2, 0.45)
	ring.Shape = Enum.PartType.Cylinder
	ring.Material = Enum.Material.SmoothPlastic
	ring.Color = Color3.fromRGB(180, 220, 255)
	ring.CanCollide = false
	ring.Parent = trident

	-- Posiziona lungo l'asta
	local yPos = -1 - (i * 0.8)
	ring.CFrame = handle.CFrame * CFrame.new(0, yPos, 0)

	-- Weld
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = handle
	weld.Part1 = ring
	weld.Parent = ring
end

-- ======================================
-- EFFETTI PARTICELLARI
-- ======================================

-- Particelle d'acqua sulla punta
local particles = Instance.new("ParticleEmitter")
particles.Name = "WaterParticles"
particles.Texture = "rbxasset://textures/particles/smoke_main.dds"
particles.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 100, 200)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 150, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 200, 255))
})
particles.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.5),
	NumberSequenceKeypoint.new(1, 1)
})
particles.Size = NumberSequence.new(0.3)
particles.Lifetime = NumberRange.new(0.5, 1)
particles.Rate = 8
particles.Speed = NumberRange.new(2, 4)
particles.SpreadAngle = Vector2.new(20, 20)
particles.Enabled = true
particles.Parent = centerProng

-- Sparkles sulla punta centrale
local sparkles = Instance.new("Sparkles")
sparkles.SparkleColor = Color3.fromRGB(100, 180, 255)
sparkles.Enabled = true
sparkles.Parent = centerProng

-- ======================================
-- GRIP (orientamento in mano)
-- ======================================

-- Imposta come il tridente viene tenuto
trident.GripForward = Vector3.new(0, 0, -1)
trident.GripPos = Vector3.new(0, -1.5, 0)
trident.GripRight = Vector3.new(1, 0, 0)
trident.GripUp = Vector3.new(0, 1, 0)

-- ======================================
-- PUNTO LUCE
-- ======================================

local light = Instance.new("PointLight")
light.Color = Color3.fromRGB(80, 150, 255)
light.Brightness = 2
light.Range = 10
light.Shadows = true
light.Parent = centerProng

print("✅ [TridentCreator] Tridente creato con successo in ReplicatedStorage!")
print("🔱 [TridentCreator] Ora puoi CANCELLARE questo script (non serve più)")
print("🔱 [TridentCreator] Il tridente verrà equipaggiato automaticamente quando selezioni Poseidon")
