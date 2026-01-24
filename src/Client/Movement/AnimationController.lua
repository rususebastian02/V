--[[
    AnimationController.lua
    Advanced Animation Controller

    Features:
    - Smooth animation blending
    - Directional animation support
    - Animation priorities
    - Speed-based animation adjustments
]]

local AnimationController = {}
AnimationController.__index = AnimationController

-- ═══════════════════════════════════════════════════════════════════
-- TYPE DEFINITIONS
-- ═══════════════════════════════════════════════════════════════════

export type AnimationType = "Idle" | "Walk" | "Run" | "Sprint" | "Dash" | "Jump" | "Fall" | "Land"

-- ═══════════════════════════════════════════════════════════════════
-- CONSTRUCTOR
-- ═══════════════════════════════════════════════════════════════════

function AnimationController.new(config: table, humanoid: Humanoid)
    local self = setmetatable({}, AnimationController)

    self.Config = config
    self.Humanoid = humanoid
    self.Animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

    -- Animation storage
    self.Animations = {}
    self.LoadedTracks = {}
    self.CurrentTrack = nil
    self.CurrentAnimationType = nil

    -- Blending
    self.BlendTime = config.Animations.BlendTime or 0.1
    self.FadeTime = config.Animations.FadeTime or 0.15

    -- Speed adjustment
    self.BaseSpeed = 1.0
    self.SpeedMultiplier = 1.0

    -- Initialize
    self:_loadAnimations()

    return self
end

-- ═══════════════════════════════════════════════════════════════════
-- ANIMATION LOADING
-- ═══════════════════════════════════════════════════════════════════

function AnimationController:_loadAnimations()
    local animConfig = self.Config.Animations

    -- Create animation instances for all configured animations
    local animationMap = {
        -- Idle
        {name = "Idle", id = animConfig.Idle},
        {name = "IdleCombat", id = animConfig.IdleCombat},

        -- Walk directions
        {name = "Walk", id = animConfig.Walk},
        {name = "WalkBack", id = animConfig.WalkBack},
        {name = "WalkLeft", id = animConfig.WalkLeft},
        {name = "WalkRight", id = animConfig.WalkRight},

        -- Run directions
        {name = "Run", id = animConfig.Run},
        {name = "RunBack", id = animConfig.RunBack},
        {name = "RunLeft", id = animConfig.RunLeft},
        {name = "RunRight", id = animConfig.RunRight},

        -- Sprint
        {name = "Sprint", id = animConfig.Sprint},

        -- Dash directions
        {name = "DashForward", id = animConfig.DashForward},
        {name = "DashBackward", id = animConfig.DashBackward},
        {name = "DashLeft", id = animConfig.DashLeft},
        {name = "DashRight", id = animConfig.DashRight},
        {name = "DashForwardLeft", id = animConfig.DashForwardLeft},
        {name = "DashForwardRight", id = animConfig.DashForwardRight},
        {name = "DashBackwardLeft", id = animConfig.DashBackwardLeft},
        {name = "DashBackwardRight", id = animConfig.DashBackwardRight},

        -- Jump/Fall
        {name = "Jump", id = animConfig.Jump},
        {name = "Fall", id = animConfig.Fall},
        {name = "Land", id = animConfig.Land},
        {name = "LandHard", id = animConfig.LandHard},
    }

    for _, animData in ipairs(animationMap) do
        if animData.id and animData.id ~= "rbxassetid://0" then
            local animation = Instance.new("Animation")
            animation.AnimationId = animData.id
            animation.Name = animData.name
            self.Animations[animData.name] = animation
        end
    end
end

function AnimationController:_getOrLoadTrack(animationName: string): AnimationTrack?
    if self.LoadedTracks[animationName] then
        return self.LoadedTracks[animationName]
    end

    local animation = self.Animations[animationName]
    if not animation then
        return nil
    end

    local success, track = pcall(function()
        return self.Animator:LoadAnimation(animation)
    end)

    if success and track then
        self.LoadedTracks[animationName] = track
        return track
    end

    return nil
end

-- ═══════════════════════════════════════════════════════════════════
-- ANIMATION PLAYBACK
-- ═══════════════════════════════════════════════════════════════════

function AnimationController:PlayAnimation(animationName: string, fadeTime: number?, priority: Enum.AnimationPriority?)
    local track = self:_getOrLoadTrack(animationName)
    if not track then
        -- Fallback to default animations if custom not found
        track = self:_getDefaultAnimation(animationName)
        if not track then return end
    end

    fadeTime = fadeTime or self.BlendTime

    -- Set priority if specified
    if priority then
        track.Priority = priority
    end

    -- Stop current animation with fade
    if self.CurrentTrack and self.CurrentTrack ~= track then
        self.CurrentTrack:Stop(fadeTime)
    end

    -- Play new animation
    if not track.IsPlaying then
        track:Play(fadeTime)
    end

    -- Adjust speed
    track:AdjustSpeed(self.SpeedMultiplier)

    self.CurrentTrack = track
    self.CurrentAnimationType = animationName
end

function AnimationController:StopAnimation(fadeTime: number?)
    if self.CurrentTrack then
        self.CurrentTrack:Stop(fadeTime or self.FadeTime)
        self.CurrentTrack = nil
        self.CurrentAnimationType = nil
    end
end

function AnimationController:StopAllAnimations(fadeTime: number?)
    for _, track in pairs(self.LoadedTracks) do
        if track.IsPlaying then
            track:Stop(fadeTime or self.FadeTime)
        end
    end
    self.CurrentTrack = nil
    self.CurrentAnimationType = nil
end

function AnimationController:_getDefaultAnimation(animationName: string): AnimationTrack?
    -- Map animation names to default Roblox animations
    -- This provides fallback when custom animations aren't set
    local defaultMap = {
        Idle = "idle",
        Walk = "walk",
        Run = "run",
        Jump = "jump",
        Fall = "fall",
    }

    local defaultName = defaultMap[animationName]
    if not defaultName then return nil end

    -- Try to find default animate script
    local character = self.Humanoid.Parent
    if not character then return nil end

    local animate = character:FindFirstChild("Animate")
    if not animate then return nil end

    local animFolder = animate:FindFirstChild(defaultName)
    if not animFolder then return nil end

    local animObj = animFolder:FindFirstChildOfClass("Animation")
    if not animObj then return nil end

    local success, track = pcall(function()
        return self.Animator:LoadAnimation(animObj)
    end)

    return success and track or nil
end

-- ═══════════════════════════════════════════════════════════════════
-- DIRECTIONAL ANIMATIONS
-- ═══════════════════════════════════════════════════════════════════

function AnimationController:PlayMovementAnimation(state: string, direction: string, speed: number?)
    local animationName = self:_getDirectionalAnimationName(state, direction)

    if speed then
        self:SetSpeedMultiplier(speed)
    end

    self:PlayAnimation(animationName, self.BlendTime, Enum.AnimationPriority.Movement)
end

function AnimationController:PlayDashAnimation(directionName: string)
    local animationName = "Dash" .. directionName
    self:PlayAnimation(animationName, 0.05, Enum.AnimationPriority.Action)
end

function AnimationController:_getDirectionalAnimationName(state: string, direction: string): string
    -- Map state and direction to animation name
    local baseAnims = {
        Walk = {
            Forward = "Walk",
            Backward = "WalkBack",
            Left = "WalkLeft",
            Right = "WalkRight",
            ForwardLeft = "Walk",
            ForwardRight = "Walk",
            BackwardLeft = "WalkBack",
            BackwardRight = "WalkBack",
        },
        Run = {
            Forward = "Run",
            Backward = "RunBack",
            Left = "RunLeft",
            Right = "RunRight",
            ForwardLeft = "Run",
            ForwardRight = "Run",
            BackwardLeft = "RunBack",
            BackwardRight = "RunBack",
        },
        Sprint = {
            Forward = "Sprint",
            Backward = "RunBack",
            Left = "RunLeft",
            Right = "RunRight",
            ForwardLeft = "Sprint",
            ForwardRight = "Sprint",
            BackwardLeft = "RunBack",
            BackwardRight = "RunBack",
        },
    }

    local stateAnims = baseAnims[state]
    if stateAnims then
        return stateAnims[direction] or stateAnims.Forward or state
    end

    return state
end

-- ═══════════════════════════════════════════════════════════════════
-- SPEED ADJUSTMENT
-- ═══════════════════════════════════════════════════════════════════

function AnimationController:SetSpeedMultiplier(multiplier: number)
    self.SpeedMultiplier = multiplier
    if self.CurrentTrack then
        self.CurrentTrack:AdjustSpeed(multiplier)
    end
end

function AnimationController:SetBaseSpeed(speed: number)
    self.BaseSpeed = speed
end

function AnimationController:AdjustSpeedForVelocity(velocity: number, targetSpeed: number)
    if targetSpeed > 0 then
        local speedRatio = velocity / targetSpeed
        self:SetSpeedMultiplier(math.clamp(speedRatio, 0.5, 1.5))
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- STATE QUERIES
-- ═══════════════════════════════════════════════════════════════════

function AnimationController:IsPlaying(animationName: string?): boolean
    if animationName then
        local track = self.LoadedTracks[animationName]
        return track and track.IsPlaying or false
    end
    return self.CurrentTrack and self.CurrentTrack.IsPlaying or false
end

function AnimationController:GetCurrentAnimation(): string?
    return self.CurrentAnimationType
end

function AnimationController:GetAnimationProgress(): number
    if self.CurrentTrack then
        return self.CurrentTrack.TimePosition / self.CurrentTrack.Length
    end
    return 0
end

-- ═══════════════════════════════════════════════════════════════════
-- ANIMATION EVENTS
-- ═══════════════════════════════════════════════════════════════════

function AnimationController:ConnectMarkerReached(animationName: string, markerName: string, callback: () -> ())
    local track = self:_getOrLoadTrack(animationName)
    if track then
        return track:GetMarkerReachedSignal(markerName):Connect(callback)
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════════════════════════════

function AnimationController:Destroy()
    self:StopAllAnimations(0)

    for _, track in pairs(self.LoadedTracks) do
        track:Destroy()
    end

    for _, animation in pairs(self.Animations) do
        animation:Destroy()
    end

    self.Animations = {}
    self.LoadedTracks = {}
end

return AnimationController
