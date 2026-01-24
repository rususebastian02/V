--[[
    MovementInit.client.lua
    Advanced Movement System Initialization Script

    Place this script in StarterPlayerScripts to automatically
    initialize the movement system for all players.

    The system includes:
    - Walk, Run, Sprint with smooth acceleration
    - 8-directional dashing with cooldowns
    - Air dashing support
    - Comprehensive VFX (dust, trails, after-images, speed lines)
    - Directional animations
    - State management with priorities

    Configuration:
    Modify src/Shared/MovementConfig.lua to customize:
    - Movement speeds
    - Dash settings
    - VFX appearance
    - Animation IDs
    - Input keybinds
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Wait for modules to be available
local function waitForModule(parent, name, timeout)
    local startTime = tick()
    timeout = timeout or 10

    while tick() - startTime < timeout do
        local module = parent:FindFirstChild(name, true)
        if module then
            return module
        end
        task.wait(0.1)
    end

    warn("[MovementSystem] Failed to find module:", name)
    return nil
end

-- Main initialization
local function initialize()
    print("[MovementSystem] Initializing Advanced Movement System...")

    -- Get module references (adjust paths based on your project structure)
    local MovementModule = script.Parent:WaitForChild("Movement"):WaitForChild("MovementController")

    if not MovementModule then
        warn("[MovementSystem] Failed to load MovementController module!")
        return
    end

    local MovementController = require(MovementModule)

    -- Create and initialize the controller
    local controller = MovementController.new()
    controller:Initialize()

    -- Store reference globally for debugging (optional)
    if _G then
        _G.MovementController = controller
    end

    print("[MovementSystem] Advanced Movement System initialized successfully!")
    print("[MovementSystem] Controls:")
    print("  - WASD: Movement")
    print("  - Shift: Sprint (hold)")
    print("  - Q: Dash")
    print("  - Double-tap direction: Quick dash")
    print("  - Space: Jump")

    return controller
end

-- Run initialization
local controller = initialize()

-- Cleanup on player leaving (handled automatically by Roblox)
Players.LocalPlayer.AncestryChanged:Connect(function()
    if controller then
        controller:Destroy()
    end
end)
