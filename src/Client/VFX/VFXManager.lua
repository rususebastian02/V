--[[
    VFXManager.lua
    Advanced Visual Effects Manager

    Handles all movement-related visual effects:
    - Dust particles
    - Speed lines
    - Dash trails and energy
    - After-images
    - Landing effects
    - Screen effects
]]

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

-- Load VFX Assets module
local VFXAssets = require(script.Parent:WaitForChild("VFXAssets"))

local VFXManager = {}
VFXManager.__index = VFXManager

-- ═══════════════════════════════════════════════════════════════════
-- CONSTRUCTOR
-- ═══════════════════════════════════════════════════════════════════

function VFXManager.new(config: table, character: Model)
    local self = setmetatable({}, VFXManager)

    self.Config = config
    self.Character = character
    self.Player = Players.LocalPlayer

    -- VFX containers
    self.Emitters = {}
    self.Trails = {}
    self.ActiveEffects = {}

    -- State tracking
    self.LastFootstepTime = 0
    self.LastSpeed = 0
    self.IsDashing = false
    self.AfterImages = {}

    -- Screen effects
    self.ScreenGui = nil
    self.SpeedLinesFrame = nil

    -- Connections
    self.Connections = {}

    -- Initialize
    self:_setupVFX()
    self:_setupScreenEffects()

    return self
end

-- ═══════════════════════════════════════════════════════════════════
-- VFX SETUP
-- ═══════════════════════════════════════════════════════════════════

function VFXManager:_setupVFX()
    local rootPart = self.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local vfxConfig = self.Config.VFX

    -- Create dust emitter
    if vfxConfig.EnableDustParticles then
        local dustEmitter = VFXAssets.CreateDustEmitter(self.Config)
        dustEmitter.Parent = rootPart
        self.Emitters.Dust = dustEmitter

        local dashDust = VFXAssets.CreateDashDustBurst(self.Config)
        dashDust.Parent = rootPart
        self.Emitters.DashDust = dashDust
    end

    -- Create speed line emitter
    if vfxConfig.EnableSpeedLines then
        local speedLines = VFXAssets.CreateSpeedLineEmitter(self.Config)
        speedLines.Parent = rootPart
        self.Emitters.SpeedLines = speedLines
    end

    -- Create dash trail
    if vfxConfig.EnableDashTrails then
        local trail = VFXAssets.CreateDashTrail(self.Config)
        local att0, att1 = VFXAssets.CreateDashTrailAttachments(self.Character)

        if att0 and att1 then
            trail.Attachment0 = att0
            trail.Attachment1 = att1
            trail.Enabled = false
            trail.Parent = rootPart
            self.Trails.DashTrail = trail
            self.Trails.DashTrailAtt0 = att0
            self.Trails.DashTrailAtt1 = att1
        end
    end

    -- Create dash energy emitter
    local dashEnergy = VFXAssets.CreateDashEnergyEmitter(self.Config)
    dashEnergy.Parent = rootPart
    self.Emitters.DashEnergy = dashEnergy

    -- Create footstep emitter
    if vfxConfig.EnableFootstepEffects then
        local footstep = VFXAssets.CreateFootstepEmitter(self.Config)
        footstep.Parent = rootPart
        self.Emitters.Footstep = footstep
    end

    -- Create landing emitter
    if vfxConfig.EnableLandingEffects then
        local landing = VFXAssets.CreateLandingDustEmitter(self.Config)
        landing.Parent = rootPart
        self.Emitters.Landing = landing
    end

    -- Create wind emitter for sprint
    local wind = VFXAssets.CreateWindEmitter(self.Config)
    wind.Parent = rootPart
    self.Emitters.Wind = wind
end

function VFXManager:_setupScreenEffects()
    local playerGui = self.Player:FindFirstChild("PlayerGui")
    if not playerGui then return end

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "MovementVFX"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.IgnoreGuiInset = true
    self.ScreenGui.Parent = playerGui

    self.SpeedLinesFrame = VFXAssets.CreateSpeedLinesGui()
    self.SpeedLinesFrame.Parent = self.ScreenGui
end

-- ═══════════════════════════════════════════════════════════════════
-- MOVEMENT VFX
-- ═══════════════════════════════════════════════════════════════════

function VFXManager:UpdateMovementVFX(speed: number, state: string, isGrounded: boolean)
    local vfxConfig = self.Config.VFX

    -- Update dust particles based on speed and state
    if self.Emitters.Dust and isGrounded then
        local dustRate = 0
        if state == "Walk" then
            dustRate = vfxConfig.Dust.WalkEmissionRate
        elseif state == "Run" then
            dustRate = vfxConfig.Dust.RunEmissionRate
        elseif state == "Sprint" then
            dustRate = vfxConfig.Dust.SprintEmissionRate
        end
        self.Emitters.Dust.Rate = dustRate
    elseif self.Emitters.Dust then
        self.Emitters.Dust.Rate = 0
    end

    -- Update speed lines
    if self.Emitters.SpeedLines then
        local minSpeed = vfxConfig.SpeedLines.MinSpeed
        if speed >= minSpeed then
            local lineRate = math.floor((speed - minSpeed) / 5) * 2
            lineRate = math.min(lineRate, vfxConfig.SpeedLines.MaxLines)
            self.Emitters.SpeedLines.Rate = lineRate
        else
            self.Emitters.SpeedLines.Rate = 0
        end
    end

    -- Update wind effect for sprint
    if self.Emitters.Wind then
        if state == "Sprint" and speed > 30 then
            self.Emitters.Wind.Rate = 20
        else
            self.Emitters.Wind.Rate = 0
        end
    end

    -- Update screen speed lines
    self:_updateScreenSpeedLines(speed)

    self.LastSpeed = speed
end

function VFXManager:_updateScreenSpeedLines(speed: number)
    if not self.SpeedLinesFrame then return end

    local speedLines = self.SpeedLinesFrame:FindFirstChild("SpeedLines")
    if not speedLines then return end

    local minSpeed = self.Config.VFX.SpeedLines.MinSpeed
    if speed >= minSpeed then
        local intensity = math.clamp((speed - minSpeed) / 50, 0, 1)
        speedLines.ImageTransparency = 1 - (intensity * 0.3)
    else
        speedLines.ImageTransparency = 1
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- FOOTSTEP VFX
-- ═══════════════════════════════════════════════════════════════════

function VFXManager:TriggerFootstepEffect(foot: string, material: Enum.Material?)
    if not self.Config.VFX.EnableFootstepEffects then return end

    local rootPart = self.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    if self.Emitters.Footstep then
        -- Adjust color based on material if desired
        self.Emitters.Footstep:Emit(self.Config.VFX.Footsteps.ParticleCount)
    end
end

function VFXManager:UpdateFootsteps(speed: number, state: string, isGrounded: boolean)
    if not isGrounded or speed < 1 then return end

    local footstepConfig = self.Config.VFX.Footsteps
    local interval = footstepConfig.WalkInterval

    if state == "Run" then
        interval = footstepConfig.RunInterval
    elseif state == "Sprint" then
        interval = footstepConfig.SprintInterval
    end

    local currentTime = tick()
    if currentTime - self.LastFootstepTime >= interval then
        self:TriggerFootstepEffect("left")
        self.LastFootstepTime = currentTime
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- DASH VFX
-- ═══════════════════════════════════════════════════════════════════

function VFXManager:PlayDashEffect(rootPart: BasePart, direction: Vector3, directionName: string)
    self.IsDashing = true

    -- Enable dash trail
    if self.Trails.DashTrail then
        self.Trails.DashTrail.Enabled = true
    end

    -- Burst dust particles
    if self.Emitters.DashDust then
        self.Emitters.DashDust:Emit(self.Config.VFX.Dust.DashBurstCount)
    end

    -- Enable energy particles
    if self.Emitters.DashEnergy then
        self.Emitters.DashEnergy.Rate = 50
    end

    -- Start after-images
    if self.Config.VFX.EnableAfterImages then
        self:_startAfterImages()
    end

    -- Screen effect
    self:_playDashScreenEffect()
end

function VFXManager:UpdateDashEffect(rootPart: BasePart, direction: Vector3)
    -- Update emitter direction if needed
    if self.Emitters.DashEnergy then
        self.Emitters.DashEnergy.EmissionDirection = Enum.NormalId.Back
    end
end

function VFXManager:EndDashEffect(rootPart: BasePart)
    self.IsDashing = false

    -- Disable dash trail with fade
    if self.Trails.DashTrail then
        task.delay(0.1, function()
            if self.Trails.DashTrail then
                self.Trails.DashTrail.Enabled = false
            end
        end)
    end

    -- Stop energy particles
    if self.Emitters.DashEnergy then
        self.Emitters.DashEnergy.Rate = 0
    end

    -- Stop after-images
    self:_stopAfterImages()

    -- End screen effect
    self:_endDashScreenEffect()
end

function VFXManager:_playDashScreenEffect()
    if not self.SpeedLinesFrame then return end

    local speedLines = self.SpeedLinesFrame:FindFirstChild("SpeedLines")
    if speedLines then
        TweenService:Create(
            speedLines,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {ImageTransparency = 0.3}
        ):Play()
    end
end

function VFXManager:_endDashScreenEffect()
    if not self.SpeedLinesFrame then return end

    local speedLines = self.SpeedLinesFrame:FindFirstChild("SpeedLines")
    if speedLines then
        TweenService:Create(
            speedLines,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {ImageTransparency = 1}
        ):Play()
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- AFTER-IMAGE EFFECT
-- ═══════════════════════════════════════════════════════════════════

function VFXManager:_startAfterImages()
    local afterImageConfig = self.Config.VFX.AfterImage
    if not afterImageConfig.Enabled then return end

    -- Clear existing
    self:_stopAfterImages()

    -- Start spawning after-images
    self.AfterImageConnection = RunService.Heartbeat:Connect(function()
        if not self.IsDashing then
            self:_stopAfterImages()
            return
        end

        self:_spawnAfterImage()
    end)

    -- Spawn initial after-images
    for i = 1, afterImageConfig.Count do
        task.delay(i * afterImageConfig.Interval, function()
            if self.IsDashing then
                self:_spawnAfterImage()
            end
        end)
    end
end

function VFXManager:_spawnAfterImage()
    local afterImage = VFXAssets.CreateAfterImage(self.Character, self.Config)
    if not afterImage then return end

    afterImage.Parent = workspace
    table.insert(self.AfterImages, afterImage)

    -- Fade out and destroy
    local fadeTime = self.Config.VFX.AfterImage.FadeTime

    task.delay(0.01, function()
        for _, part in ipairs(afterImage:GetDescendants()) do
            if part:IsA("BasePart") then
                TweenService:Create(
                    part,
                    TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Transparency = 1}
                ):Play()
            end
        end
    end)

    Debris:AddItem(afterImage, fadeTime + 0.1)

    -- Remove from tracking
    task.delay(fadeTime + 0.1, function()
        local index = table.find(self.AfterImages, afterImage)
        if index then
            table.remove(self.AfterImages, index)
        end
    end)
end

function VFXManager:_stopAfterImages()
    if self.AfterImageConnection then
        self.AfterImageConnection:Disconnect()
        self.AfterImageConnection = nil
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- LANDING VFX
-- ═══════════════════════════════════════════════════════════════════

function VFXManager:PlayLandingEffect(fallDistance: number)
    if not self.Config.VFX.EnableLandingEffects then return end

    local landingConfig = self.Config.VFX.Landing
    local rootPart = self.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    -- Check if fall was significant
    if fallDistance < landingConfig.MinFallDistance then return end

    local isHardLand = fallDistance >= landingConfig.HardLandDistance

    -- Emit landing dust
    if self.Emitters.Landing then
        local particleCount = isHardLand and landingConfig.DustBurstCount * 2 or landingConfig.DustBurstCount
        self.Emitters.Landing:Emit(particleCount)
    end

    -- Play shockwave effect
    if landingConfig.ShockwaveEnabled and isHardLand then
        self:_playShockwaveEffect(rootPart.Position)
    end

    -- Screen shake
    if landingConfig.ScreenShakeEnabled then
        local intensity = isHardLand and landingConfig.ScreenShakeIntensity * 2 or landingConfig.ScreenShakeIntensity
        VFXAssets.CreateScreenShakeEffect(intensity, 0.2)
    end
end

function VFXManager:_playShockwaveEffect(position: Vector3)
    local shockwave = VFXAssets.CreateShockwaveEffect()
    shockwave.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
    shockwave.Parent = workspace

    -- Expand and fade shockwave
    local expandTween = TweenService:Create(
        shockwave,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            Size = Vector3.new(0.2, 15, 15),
            Transparency = 1
        }
    )

    expandTween:Play()
    expandTween.Completed:Connect(function()
        shockwave:Destroy()
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- JUMP VFX
-- ═══════════════════════════════════════════════════════════════════

function VFXManager:PlayJumpEffect()
    if self.Emitters.Dust then
        self.Emitters.Dust:Emit(10)
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- STATE UPDATES
-- ═══════════════════════════════════════════════════════════════════

function VFXManager:OnStateChanged(newState: string, oldState: string)
    -- Handle state-specific VFX transitions
    if newState == "Dash" then
        -- Dash VFX handled by PlayDashEffect
    elseif oldState == "Dash" then
        -- End dash VFX handled by EndDashEffect
    end

    if newState == "Jump" then
        self:PlayJumpEffect()
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════════════════════════════

function VFXManager:SetCharacter(character: Model)
    self:Destroy()
    self.Character = character
    self:_setupVFX()
end

function VFXManager:Destroy()
    -- Stop all emitters
    for _, emitter in pairs(self.Emitters) do
        if emitter and emitter.Parent then
            emitter:Destroy()
        end
    end
    self.Emitters = {}

    -- Destroy trails and attachments
    for _, trail in pairs(self.Trails) do
        if trail and trail.Parent then
            trail:Destroy()
        end
    end
    self.Trails = {}

    -- Stop after-images
    self:_stopAfterImages()
    for _, afterImage in ipairs(self.AfterImages) do
        if afterImage and afterImage.Parent then
            afterImage:Destroy()
        end
    end
    self.AfterImages = {}

    -- Destroy screen GUI
    if self.ScreenGui then
        self.ScreenGui:Destroy()
        self.ScreenGui = nil
    end

    -- Disconnect all connections
    for _, connection in ipairs(self.Connections) do
        connection:Disconnect()
    end
    self.Connections = {}
end

return VFXManager
