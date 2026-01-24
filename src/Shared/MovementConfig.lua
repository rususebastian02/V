--[[
    MovementConfig.lua
    Advanced Movement System Configuration

    This module contains all configurable values for the movement system.
    Tweak these values to adjust the feel of your game's movement.
]]

local MovementConfig = {}

-- ═══════════════════════════════════════════════════════════════════
-- MOVEMENT SPEEDS
-- ═══════════════════════════════════════════════════════════════════

MovementConfig.Speeds = {
    -- Base movement speeds
    Idle = 0,
    Walk = 16,
    Run = 32,
    Sprint = 48,

    -- Speed interpolation (how fast speed changes)
    Acceleration = 10,      -- How fast player reaches target speed
    Deceleration = 15,      -- How fast player stops
    AirControl = 0.3,       -- Movement control while airborne (0-1)
}

-- ═══════════════════════════════════════════════════════════════════
-- DASH CONFIGURATION
-- ═══════════════════════════════════════════════════════════════════

MovementConfig.Dash = {
    -- Dash properties
    Force = 80,                 -- Dash velocity
    Duration = 0.25,            -- How long dash lasts (seconds)
    Cooldown = 1.0,             -- Time between dashes (seconds)

    -- Multi-directional dash settings
    ForwardMultiplier = 1.0,    -- Forward dash strength
    BackwardMultiplier = 0.8,   -- Backward dash strength
    SideMultiplier = 0.9,       -- Side dash strength
    DiagonalMultiplier = 0.95,  -- Diagonal dash strength

    -- Dash physics
    GravityReduction = 0.3,     -- Gravity during dash (0 = no gravity)
    AirDashEnabled = true,      -- Allow dashing in air
    MaxAirDashes = 1,           -- Number of air dashes allowed
    GroundDashOnly = false,     -- If true, only allow ground dashes

    -- Dash cancel options
    CanCancelWithJump = true,
    CanCancelWithDash = false,  -- Chain dashing

    -- Double tap dash
    DoubleTapEnabled = true,
    DoubleTapWindow = 0.3,      -- Time window for double tap (seconds)
}

-- ═══════════════════════════════════════════════════════════════════
-- ANIMATION CONFIGURATION
-- ═══════════════════════════════════════════════════════════════════

MovementConfig.Animations = {
    -- Animation IDs (replace with your actual animation IDs)
    Idle = "rbxassetid://0",           -- Default idle
    IdleCombat = "rbxassetid://0",     -- Combat stance idle

    Walk = "rbxassetid://0",           -- Walking animation
    WalkBack = "rbxassetid://0",       -- Walking backwards
    WalkLeft = "rbxassetid://0",       -- Strafing left
    WalkRight = "rbxassetid://0",      -- Strafing right

    Run = "rbxassetid://0",            -- Running forward
    RunBack = "rbxassetid://0",        -- Running backwards
    RunLeft = "rbxassetid://0",        -- Running strafe left
    RunRight = "rbxassetid://0",       -- Running strafe right

    Sprint = "rbxassetid://0",         -- Full sprint

    -- Dash animations (all directions)
    DashForward = "rbxassetid://0",
    DashBackward = "rbxassetid://0",
    DashLeft = "rbxassetid://0",
    DashRight = "rbxassetid://0",
    DashForwardLeft = "rbxassetid://0",
    DashForwardRight = "rbxassetid://0",
    DashBackwardLeft = "rbxassetid://0",
    DashBackwardRight = "rbxassetid://0",

    -- Jump/Fall animations
    Jump = "rbxassetid://0",
    Fall = "rbxassetid://0",
    Land = "rbxassetid://0",
    LandHard = "rbxassetid://0",       -- Landing from high fall

    -- Transition speeds
    BlendTime = 0.1,                   -- Time to blend between animations
    FadeTime = 0.15,                   -- Fade out time for animations
}

-- ═══════════════════════════════════════════════════════════════════
-- VFX CONFIGURATION
-- ═══════════════════════════════════════════════════════════════════

MovementConfig.VFX = {
    -- Enable/Disable VFX categories
    EnableDustParticles = true,
    EnableSpeedLines = true,
    EnableDashTrails = true,
    EnableAfterImages = true,
    EnableFootstepEffects = true,
    EnableLandingEffects = true,

    -- Dust/Particle settings
    Dust = {
        WalkEmissionRate = 5,
        RunEmissionRate = 15,
        SprintEmissionRate = 25,
        DashBurstCount = 30,
        ParticleLifetime = NumberRange.new(0.3, 0.6),
        ParticleSize = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5),
            NumberSequenceKeypoint.new(0.5, 1),
            NumberSequenceKeypoint.new(1, 0),
        }),
        ParticleColor = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 180, 160)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 140, 130)),
        }),
    },

    -- Speed lines settings
    SpeedLines = {
        MinSpeed = 30,                  -- Speed to start showing lines
        MaxLines = 20,                  -- Maximum speed lines
        LineLength = NumberRange.new(2, 5),
        LineLifetime = 0.15,
        LineColor = Color3.fromRGB(255, 255, 255),
        LineTransparency = 0.5,
    },

    -- Dash trail settings
    DashTrail = {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 100, 200)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Lifetime = 0.3,
        MinLength = 0.1,
        WidthScale = NumberSequence.new(1),
        TextureLength = 1,
    },

    -- After-image/ghost effect settings
    AfterImage = {
        Enabled = true,
        Count = 5,                      -- Number of after-images
        Interval = 0.03,                -- Time between images
        FadeTime = 0.2,                 -- Time for image to fade
        Transparency = 0.7,             -- Starting transparency
        Color = Color3.fromRGB(100, 150, 255),
    },

    -- Footstep effect settings
    Footsteps = {
        WalkInterval = 0.5,             -- Time between footstep effects
        RunInterval = 0.3,
        SprintInterval = 0.2,
        ParticleCount = 5,
    },

    -- Landing effect settings
    Landing = {
        MinFallDistance = 5,            -- Minimum fall for effect
        HardLandDistance = 15,          -- Distance for hard land effect
        DustBurstCount = 20,
        ShockwaveEnabled = true,
        ScreenShakeEnabled = true,
        ScreenShakeIntensity = 0.5,
    },
}

-- ═══════════════════════════════════════════════════════════════════
-- INPUT CONFIGURATION
-- ═══════════════════════════════════════════════════════════════════

MovementConfig.Input = {
    -- Keybinds (Enum.KeyCode)
    SprintKey = Enum.KeyCode.LeftShift,
    DashKey = Enum.KeyCode.Q,
    CrouchKey = Enum.KeyCode.LeftControl,

    -- Gamepad support
    SprintButton = Enum.KeyCode.ButtonL3,
    DashButton = Enum.KeyCode.ButtonB,

    -- Input settings
    DoubleTapDash = true,               -- Enable double-tap direction to dash
    HoldToSprint = true,                -- Hold vs toggle sprint
    MovementDeadzone = 0.15,            -- Analog stick deadzone
}

-- ═══════════════════════════════════════════════════════════════════
-- PHYSICS CONFIGURATION
-- ═══════════════════════════════════════════════════════════════════

MovementConfig.Physics = {
    -- Jump settings
    JumpPower = 50,
    JumpCooldown = 0.1,

    -- Air movement
    AirAcceleration = 5,
    MaxAirSpeed = 20,
    FallSpeedCap = 100,

    -- Ground detection
    GroundRaycastDistance = 3,
    GroundCheckInterval = 0.05,

    -- Slopes
    MaxWalkableSlope = 45,              -- Degrees
    SlopeSpeedReduction = 0.5,          -- Speed reduction on slopes
}

-- ═══════════════════════════════════════════════════════════════════
-- STATE PRIORITIES (higher = takes precedence)
-- ═══════════════════════════════════════════════════════════════════

MovementConfig.StatePriority = {
    Idle = 0,
    Walk = 1,
    Run = 2,
    Sprint = 3,
    Dash = 10,
    Stun = 100,
}

-- ═══════════════════════════════════════════════════════════════════
-- DEBUG SETTINGS
-- ═══════════════════════════════════════════════════════════════════

MovementConfig.Debug = {
    Enabled = false,
    ShowStateChanges = true,
    ShowSpeedValues = true,
    ShowDashInfo = true,
    ShowVFXInfo = false,
    VisualizeGroundCheck = false,
}

return MovementConfig
