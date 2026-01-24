# V - Advanced Roblox Movement System

A comprehensive, modular movement system for Roblox games featuring smooth locomotion, 8-directional dashing, and extensive visual effects.

## Features

### Movement States
- **Idle** - Standing still with breathing animation
- **Walk** - Slow movement with directional animations
- **Run** - Normal speed movement
- **Sprint** - High-speed running with wind effects
- **Dash** - Quick burst movement in any direction
- **Jump/Fall** - Aerial states with appropriate animations
- **Land** - Landing recovery with impact effects

### Dash System
- 8-directional dashing (Forward, Back, Left, Right + diagonals)
- Air dash support with configurable limits
- Cooldown management
- Double-tap direction for quick dash
- Direction-based force multipliers
- Dash canceling options

### Visual Effects (VFX)
- **Dust Particles** - Ground dust based on movement speed
- **Speed Lines** - Screen overlay and world particles at high speeds
- **Dash Trails** - Color trails during dashes
- **After-Images** - Ghost effect during dashes
- **Footstep Effects** - Dust puffs synced with movement
- **Landing Effects** - Dust burst and shockwave on landing
- **Screen Shake** - Camera shake on hard landings

### Animations
- Full directional animation support (forward, back, strafe)
- Smooth blending between animations
- Speed-adjusted playback rates
- Priority-based animation system

## Installation

1. Copy the `src` folder contents to your Roblox project:
   - `src/Client/Movement/` -> `StarterPlayerScripts/Movement/`
   - `src/Client/VFX/` -> `StarterPlayerScripts/VFX/`
   - `src/Shared/` -> `ReplicatedStorage/Shared/`
   - `src/Client/MovementInit.client.lua` -> `StarterPlayerScripts/`

2. Update animation IDs in `MovementConfig.lua` with your custom animations

3. Run the game - the system initializes automatically

## Project Structure

```
src/
├── Client/
│   ├── Movement/
│   │   ├── MovementController.lua   # Main controller
│   │   ├── StateManager.lua         # State machine
│   │   ├── InputHandler.lua         # Input processing
│   │   ├── DashSystem.lua           # Dash mechanics
│   │   └── AnimationController.lua  # Animation management
│   ├── VFX/
│   │   ├── VFXManager.lua           # VFX orchestration
│   │   └── VFXAssets.lua            # VFX asset creation
│   └── MovementInit.client.lua      # Initialization script
├── Shared/
│   └── MovementConfig.lua           # All configuration
└── Server/
    └── (future server-side validation)
```

## Configuration

All settings are in `src/Shared/MovementConfig.lua`:

### Movement Speeds
```lua
MovementConfig.Speeds = {
    Walk = 16,
    Run = 32,
    Sprint = 48,
    Acceleration = 10,
    Deceleration = 15,
}
```

### Dash Settings
```lua
MovementConfig.Dash = {
    Force = 80,
    Duration = 0.25,
    Cooldown = 1.0,
    AirDashEnabled = true,
    MaxAirDashes = 1,
    DoubleTapEnabled = true,
}
```

### Input Keybinds
```lua
MovementConfig.Input = {
    SprintKey = Enum.KeyCode.LeftShift,
    DashKey = Enum.KeyCode.Q,
    DoubleTapDash = true,
    HoldToSprint = true,
}
```

## Controls

| Input | Action |
|-------|--------|
| WASD | Movement |
| Shift (hold) | Sprint |
| Q | Dash |
| Double-tap direction | Quick dash |
| Space | Jump |
| Ctrl | Crouch (reserved) |

## API Reference

### MovementController

```lua
local MovementController = require(path.to.MovementController)
local controller = MovementController.new()
controller:Initialize()

-- Get current state
local state = controller:GetState()  -- "Idle", "Walk", "Run", etc.

-- Check conditions
local isGrounded = controller:IsGrounded()
local isDashing = controller:IsDashing()
local cooldown = controller:GetDashCooldown()

-- Control movement
controller:LockMovement(duration)
controller:UnlockMovement()

-- Cleanup
controller:Destroy()
```

### StateManager

```lua
-- Subscribe to state changes
stateManager:OnStateChanged(function(newState, oldState)
    print("State changed:", oldState, "->", newState)
end)

-- Check states
if stateManager:IsState("Dash", "Sprint") then
    -- Player is dashing or sprinting
end
```

## Customization

### Adding Custom Animations

1. Upload your animations to Roblox
2. Update the animation IDs in `MovementConfig.lua`:

```lua
MovementConfig.Animations = {
    Idle = "rbxassetid://YOUR_IDLE_ANIM",
    Walk = "rbxassetid://YOUR_WALK_ANIM",
    Run = "rbxassetid://YOUR_RUN_ANIM",
    DashForward = "rbxassetid://YOUR_DASH_ANIM",
    -- etc.
}
```

### Customizing VFX Colors

```lua
MovementConfig.VFX.DashTrail.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 100)),  -- Red
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 50, 50)),
})

MovementConfig.VFX.AfterImage.Color = Color3.fromRGB(255, 100, 100)
```

### Disabling VFX

```lua
MovementConfig.VFX.EnableDustParticles = false
MovementConfig.VFX.EnableSpeedLines = false
MovementConfig.VFX.EnableDashTrails = false
MovementConfig.VFX.EnableAfterImages = false
```

## Performance Notes

- VFX particle counts are optimized for typical gameplay
- After-images use simplified geometry for performance
- Screen effects use lightweight UI elements
- All systems clean up properly on character respawn

## License

MIT License - Feel free to use in your Roblox games!
