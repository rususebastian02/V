--[[
    VISUALEFFECTSMANAGER.LUA
    Gestisce effetti visuali: aure per rank alti, effetti rank up, particles
]]

local Config = require(script.Parent.Config)

local VisualEffectsManager = {}

-- ==================== AURA SYSTEM ====================

function VisualEffectsManager.ApplyAura(player, rankName)
    local character = player.Character
    if not character then return end

    -- Rimuovi aura precedente
    VisualEffectsManager.RemoveAura(player)

    -- Check se rank ha aura
    local auraSettings = Config.Auras[rankName]
    if not auraSettings or not auraSettings.Enabled then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    -- Crea attachment per particles
    local attachment = Instance.new("Attachment")
    attachment.Name = "AuraAttachment"
    attachment.Parent = humanoidRootPart

    -- Crea particle emitter
    local particle = Instance.new("ParticleEmitter")
    particle.Name = "AuraParticle"
    particle.Color = auraSettings.ParticleColor
    particle.Size = auraSettings.Size
    particle.Transparency = auraSettings.Transparency
    particle.Lifetime = NumberRange.new(1, 2)
    particle.Rate = 20
    particle.Speed = NumberRange.new(2, 4)
    particle.SpreadAngle = Vector2.new(180, 180)
    particle.LightEmission = 1
    particle.Parent = attachment

    print("[VisualEffects] Aura applicata per " .. player.Name .. " (rank: " .. rankName .. ")")
end

function VisualEffectsManager.RemoveAura(player)
    local character = player.Character
    if not character then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local attachment = humanoidRootPart:FindFirstChild("AuraAttachment")
    if attachment then
        attachment:Destroy()
    end
end

-- ==================== RANK UP EFFECT ====================

function VisualEffectsManager.PlayRankUpEffect(player, newRank)
    local character = player.Character
    if not character then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    -- Crea effetto temporaneo
    local attachment = Instance.new("Attachment")
    attachment.Name = "RankUpAttachment"
    attachment.Parent = humanoidRootPart

    -- Particle burst
    local particle = Instance.new("ParticleEmitter")
    particle.Name = "RankUpParticle"
    particle.Color = ColorSequence.new(newRank.Color)
    particle.Size = NumberSequence.new(2)
    particle.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    particle.Lifetime = NumberRange.new(1, 1.5)
    particle.Rate = 50
    particle.Speed = NumberRange.new(5, 10)
    particle.SpreadAngle = Vector2.new(180, 180)
    particle.Enabled = true
    particle.Parent = attachment

    -- Disabilita dopo 1 secondo
    wait(1)
    particle.Enabled = false

    -- Rimuovi dopo che le particelle sono terminate
    game:GetService("Debris"):AddItem(attachment, 3)

    print("[VisualEffects] Rank up effect per " .. player.Name)
end

-- ==================== CASH PICKUP EFFECT ====================

function VisualEffectsManager.PlayCashEffect(player, amount)
    -- Effetto visivo quando il player riceve cash
    -- Può essere implementato con una GUI che appare brevemente
    -- Per ora solo log
    print("[VisualEffects] Cash effect: +" .. amount .. " per " .. player.Name)
end

-- ==================== UPDATE CHARACTER ====================

function VisualEffectsManager.OnCharacterAdded(player, rankName)
    -- Riapplica aura quando character respawna
    wait(1) -- Attendi che character sia completamente caricato

    if Config.Auras[rankName] then
        VisualEffectsManager.ApplyAura(player, rankName)
    end
end

return VisualEffectsManager
