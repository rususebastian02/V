--[[
    VFXAssets.lua
    Visual Effects Asset Creator

    This module creates and manages all VFX particle emitters,
    trails, and other visual effect assets programmatically.
]]

local VFXAssets = {}

-- ═══════════════════════════════════════════════════════════════════
-- DUST PARTICLES
-- ═══════════════════════════════════════════════════════════════════

function VFXAssets.CreateDustEmitter(config: table): ParticleEmitter
    local vfxConfig = config.VFX.Dust

    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "DustParticles"

    -- Basic properties
    emitter.Texture = "rbxassetid://6959265430"  -- Soft circle particle
    emitter.Rate = 0  -- Controlled manually
    emitter.Lifetime = vfxConfig.ParticleLifetime
    emitter.Speed = NumberRange.new(2, 5)
    emitter.SpreadAngle = Vector2.new(180, 180)
    emitter.RotSpeed = NumberRange.new(-180, 180)
    emitter.Rotation = NumberRange.new(0, 360)

    -- Size
    emitter.Size = vfxConfig.ParticleSize

    -- Color and transparency
    emitter.Color = vfxConfig.ParticleColor
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0.6),
        NumberSequenceKeypoint.new(1, 1),
    })

    -- Physics
    emitter.Acceleration = Vector3.new(0, -5, 0)
    emitter.Drag = 3
    emitter.VelocityInheritance = 0.3
    emitter.EmissionDirection = Enum.NormalId.Bottom

    -- Rendering
    emitter.LightEmission = 0
    emitter.LightInfluence = 1
    emitter.ZOffset = 0

    return emitter
end

function VFXAssets.CreateDashDustBurst(config: table): ParticleEmitter
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "DashDustBurst"

    emitter.Texture = "rbxassetid://6959265430"
    emitter.Rate = 0
    emitter.Lifetime = NumberRange.new(0.4, 0.8)
    emitter.Speed = NumberRange.new(10, 20)
    emitter.SpreadAngle = Vector2.new(60, 60)

    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.3, 2),
        NumberSequenceKeypoint.new(1, 0),
    })

    emitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200)),
    })

    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 1),
    })

    emitter.Acceleration = Vector3.new(0, -20, 0)
    emitter.Drag = 5

    return emitter
end

-- ═══════════════════════════════════════════════════════════════════
-- SPEED LINES
-- ═══════════════════════════════════════════════════════════════════

function VFXAssets.CreateSpeedLineEmitter(config: table): ParticleEmitter
    local vfxConfig = config.VFX.SpeedLines

    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "SpeedLines"

    -- Long thin texture for speed lines
    emitter.Texture = "rbxassetid://5862309203"  -- Speed line texture
    emitter.Rate = 0
    emitter.Lifetime = NumberRange.new(vfxConfig.LineLifetime)
    emitter.Speed = NumberRange.new(0, 0)
    emitter.SpreadAngle = Vector2.new(0, 0)

    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(0.5, 0.3),
        NumberSequenceKeypoint.new(1, 0),
    })

    emitter.Color = ColorSequence.new(vfxConfig.LineColor)
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, vfxConfig.LineTransparency),
        NumberSequenceKeypoint.new(0.5, vfxConfig.LineTransparency + 0.2),
        NumberSequenceKeypoint.new(1, 1),
    })

    emitter.Orientation = Enum.ParticleOrientation.VelocityParallel
    emitter.LightEmission = 0.3
    emitter.LightInfluence = 0.5

    return emitter
end

-- ═══════════════════════════════════════════════════════════════════
-- DASH TRAIL
-- ═══════════════════════════════════════════════════════════════════

function VFXAssets.CreateDashTrail(config: table): Trail
    local vfxConfig = config.VFX.DashTrail

    local trail = Instance.new("Trail")
    trail.Name = "DashTrail"

    trail.Color = vfxConfig.Color
    trail.Transparency = vfxConfig.Transparency
    trail.Lifetime = vfxConfig.Lifetime
    trail.MinLength = vfxConfig.MinLength
    trail.WidthScale = vfxConfig.WidthScale
    trail.FaceCamera = true
    trail.LightEmission = 0.3
    trail.LightInfluence = 0.5
    trail.TextureLength = vfxConfig.TextureLength

    return trail
end

function VFXAssets.CreateDashTrailAttachments(character: Model): (Attachment, Attachment)?
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")

    if not humanoidRootPart or not head then
        return nil
    end

    local attachment0 = Instance.new("Attachment")
    attachment0.Name = "DashTrailTop"
    attachment0.Position = Vector3.new(0, 1, 0)
    attachment0.Parent = humanoidRootPart

    local attachment1 = Instance.new("Attachment")
    attachment1.Name = "DashTrailBottom"
    attachment1.Position = Vector3.new(0, -2, 0)
    attachment1.Parent = humanoidRootPart

    return attachment0, attachment1
end

-- ═══════════════════════════════════════════════════════════════════
-- DASH ENERGY EFFECT
-- ═══════════════════════════════════════════════════════════════════

function VFXAssets.CreateDashEnergyEmitter(config: table): ParticleEmitter
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "DashEnergy"

    emitter.Texture = "rbxassetid://5833235272"  -- Energy/magic particle
    emitter.Rate = 0
    emitter.Lifetime = NumberRange.new(0.2, 0.4)
    emitter.Speed = NumberRange.new(5, 15)
    emitter.SpreadAngle = Vector2.new(30, 30)
    emitter.RotSpeed = NumberRange.new(-360, 360)

    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(0.5, 1),
        NumberSequenceKeypoint.new(1, 0),
    })

    emitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 220, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 150, 255)),
    })

    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.7, 0.3),
        NumberSequenceKeypoint.new(1, 1),
    })

    emitter.LightEmission = 0.8
    emitter.LightInfluence = 0.2
    emitter.Orientation = Enum.ParticleOrientation.FacingCamera

    return emitter
end

-- ═══════════════════════════════════════════════════════════════════
-- LANDING EFFECT
-- ═══════════════════════════════════════════════════════════════════

function VFXAssets.CreateLandingDustEmitter(config: table): ParticleEmitter
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "LandingDust"

    emitter.Texture = "rbxassetid://6959265430"
    emitter.Rate = 0
    emitter.Lifetime = NumberRange.new(0.5, 1.0)
    emitter.Speed = NumberRange.new(15, 30)
    emitter.SpreadAngle = Vector2.new(80, 10)

    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(0.3, 2),
        NumberSequenceKeypoint.new(1, 0),
    })

    emitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 170, 160)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 140, 130)),
    })

    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 1),
    })

    emitter.Acceleration = Vector3.new(0, -15, 0)
    emitter.Drag = 4
    emitter.EmissionDirection = Enum.NormalId.Top
    emitter.RotSpeed = NumberRange.new(-90, 90)

    return emitter
end

function VFXAssets.CreateShockwaveEffect(): Part
    local shockwave = Instance.new("Part")
    shockwave.Name = "Shockwave"
    shockwave.Shape = Enum.PartType.Cylinder
    shockwave.Anchored = true
    shockwave.CanCollide = false
    shockwave.CanQuery = false
    shockwave.CanTouch = false
    shockwave.CastShadow = false
    shockwave.Material = Enum.Material.ForceField
    shockwave.Size = Vector3.new(0.2, 1, 1)
    shockwave.Transparency = 0.5
    shockwave.Color = Color3.fromRGB(255, 255, 255)

    return shockwave
end

-- ═══════════════════════════════════════════════════════════════════
-- FOOTSTEP EFFECTS
-- ═══════════════════════════════════════════════════════════════════

function VFXAssets.CreateFootstepEmitter(config: table): ParticleEmitter
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "FootstepDust"

    emitter.Texture = "rbxassetid://6959265430"
    emitter.Rate = 0
    emitter.Lifetime = NumberRange.new(0.3, 0.5)
    emitter.Speed = NumberRange.new(1, 3)
    emitter.SpreadAngle = Vector2.new(60, 30)

    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0.6),
        NumberSequenceKeypoint.new(1, 0),
    })

    emitter.Color = ColorSequence.new(Color3.fromRGB(180, 170, 160))
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 1),
    })

    emitter.Acceleration = Vector3.new(0, -10, 0)
    emitter.Drag = 5
    emitter.EmissionDirection = Enum.NormalId.Top

    return emitter
end

-- ═══════════════════════════════════════════════════════════════════
-- AFTER-IMAGE EFFECT
-- ═══════════════════════════════════════════════════════════════════

function VFXAssets.CreateAfterImage(character: Model, config: table): Model?
    local vfxConfig = config.VFX.AfterImage
    if not vfxConfig.Enabled then return nil end

    local afterImage = Instance.new("Model")
    afterImage.Name = "AfterImage"

    -- Clone visible parts
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 1 then
            local clone = Instance.new("Part")
            clone.Name = part.Name
            clone.Size = part.Size
            clone.CFrame = part.CFrame
            clone.Anchored = true
            clone.CanCollide = false
            clone.CanQuery = false
            clone.CanTouch = false
            clone.CastShadow = false
            clone.Material = Enum.Material.ForceField
            clone.Color = vfxConfig.Color
            clone.Transparency = vfxConfig.Transparency
            clone.Parent = afterImage

            -- Copy mesh if exists
            local mesh = part:FindFirstChildOfClass("SpecialMesh")
            if mesh then
                local meshClone = mesh:Clone()
                meshClone.Parent = clone
            end
        end
    end

    return afterImage
end

-- ═══════════════════════════════════════════════════════════════════
-- WIND EFFECT (for sprinting)
-- ═══════════════════════════════════════════════════════════════════

function VFXAssets.CreateWindEmitter(config: table): ParticleEmitter
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "WindParticles"

    emitter.Texture = "rbxassetid://5862309203"  -- Streak texture
    emitter.Rate = 0
    emitter.Lifetime = NumberRange.new(0.1, 0.2)
    emitter.Speed = NumberRange.new(0, 0)
    emitter.SpreadAngle = Vector2.new(0, 0)

    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.2, 0.1),
        NumberSequenceKeypoint.new(1, 0),
    })

    emitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.7),
        NumberSequenceKeypoint.new(1, 1),
    })

    emitter.Orientation = Enum.ParticleOrientation.VelocityParallel
    emitter.LightEmission = 0.1
    emitter.ZOffset = -1

    return emitter
end

-- ═══════════════════════════════════════════════════════════════════
-- SCREEN EFFECTS
-- ═══════════════════════════════════════════════════════════════════

function VFXAssets.CreateScreenShakeEffect(intensity: number, duration: number)
    local camera = workspace.CurrentCamera
    if not camera then return end

    local startTime = tick()
    local originalCFrame = camera.CFrame

    local connection
    connection = game:GetService("RunService").RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        if elapsed >= duration then
            connection:Disconnect()
            return
        end

        local progress = elapsed / duration
        local currentIntensity = intensity * (1 - progress)

        local offsetX = (math.random() - 0.5) * 2 * currentIntensity
        local offsetY = (math.random() - 0.5) * 2 * currentIntensity

        camera.CFrame = camera.CFrame * CFrame.new(offsetX, offsetY, 0)
    end)
end

function VFXAssets.CreateSpeedLinesGui(): Frame
    local frame = Instance.new("Frame")
    frame.Name = "SpeedLinesOverlay"
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0

    -- Create radial speed lines using image labels
    local lineImage = Instance.new("ImageLabel")
    lineImage.Name = "SpeedLines"
    lineImage.Size = UDim2.new(2, 0, 2, 0)
    lineImage.Position = UDim2.new(-0.5, 0, -0.5, 0)
    lineImage.BackgroundTransparency = 1
    lineImage.Image = "rbxassetid://5862309203"  -- Radial lines
    lineImage.ImageTransparency = 1
    lineImage.ScaleType = Enum.ScaleType.Stretch
    lineImage.Parent = frame

    return frame
end

return VFXAssets
