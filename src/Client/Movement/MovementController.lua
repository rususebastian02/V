--[[
    MovementController.lua
    Advanced Movement System - Main Controller

    This is the main controller that orchestrates all movement subsystems:
    - StateManager: Handles movement state transitions
    - InputHandler: Processes player input
    - DashSystem: Manages dashing mechanics
    - AnimationController: Controls character animations
    - VFXManager: Handles visual effects

    Usage:
        local MovementController = require(path.to.MovementController)
        local controller = MovementController.new()
        controller:Initialize()
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Module dependencies (adjust paths as needed for your project structure)
local Movement = script.Parent
local Client = Movement.Parent
local Shared = Client.Parent:WaitForChild("Shared")
local VFXFolder = Client:WaitForChild("VFX")

local StateManager = require(Movement:WaitForChild("StateManager"))
local InputHandler = require(Movement:WaitForChild("InputHandler"))
local DashSystem = require(Movement:WaitForChild("DashSystem"))
local AnimationController = require(Movement:WaitForChild("AnimationController"))
local VFXManager = require(VFXFolder:WaitForChild("VFXManager"))
local MovementConfig = require(Shared:WaitForChild("MovementConfig"))

local MovementController = {}
MovementController.__index = MovementController

-- ═══════════════════════════════════════════════════════════════════
-- CONSTRUCTOR
-- ═══════════════════════════════════════════════════════════════════

function MovementController.new(customConfig: table?)
    local self = setmetatable({}, MovementController)

    -- Configuration
    self.Config = customConfig or MovementConfig
    self.Player = Players.LocalPlayer
    self.Character = nil
    self.Humanoid = nil
    self.RootPart = nil

    -- Subsystems (initialized later)
    self.StateManager = nil
    self.InputHandler = nil
    self.DashSystem = nil
    self.AnimationController = nil
    self.VFXManager = nil

    -- Movement state
    self.CurrentSpeed = 0
    self.TargetSpeed = 0
    self.IsGrounded = true
    self.LastGroundedTime = 0
    self.FallStartHeight = 0
    self.IsFalling = false

    -- Connections
    self.Connections = {}
    self.UpdateConnection = nil

    -- Initialization flag
    self.Initialized = false

    return self
end

-- ═══════════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════

function MovementController:Initialize()
    if self.Initialized then
        warn("[MovementController] Already initialized!")
        return
    end

    -- Wait for character
    self.Character = self.Player.Character or self.Player.CharacterAdded:Wait()
    self:_setupCharacter(self.Character)

    -- Handle respawns
    table.insert(self.Connections, self.Player.CharacterAdded:Connect(function(character)
        self:_onCharacterAdded(character)
    end))

    self.Initialized = true

    if self.Config.Debug and self.Config.Debug.Enabled then
        print("[MovementController] Initialized successfully!")
    end
end

function MovementController:_setupCharacter(character: Model)
    self.Character = character
    self.Humanoid = character:WaitForChild("Humanoid")
    self.RootPart = character:WaitForChild("HumanoidRootPart")

    -- Initialize subsystems
    self:_initializeSubsystems()

    -- Setup connections
    self:_setupConnections()

    -- Apply initial settings
    self:_applyInitialSettings()
end

function MovementController:_initializeSubsystems()
    -- Create State Manager
    self.StateManager = StateManager.new(self.Config)

    -- Create Input Handler
    self.InputHandler = InputHandler.new(self.Config)

    -- Create VFX Manager
    self.VFXManager = VFXManager.new(self.Config, self.Character)

    -- Create Dash System
    self.DashSystem = DashSystem.new(self.Config, self.StateManager, self.VFXManager)

    -- Create Animation Controller
    self.AnimationController = AnimationController.new(self.Config, self.Humanoid)

    -- Connect state manager to VFX and animations
    self.StateManager:OnStateChanged(function(newState, oldState)
        self:_onStateChanged(newState, oldState)
    end)
end

function MovementController:_setupConnections()
    -- Main update loop
    self.UpdateConnection = RunService.Heartbeat:Connect(function(dt)
        self:_update(dt)
    end)

    -- Humanoid state changes
    table.insert(self.Connections, self.Humanoid.StateChanged:Connect(function(oldState, newState)
        self:_onHumanoidStateChanged(oldState, newState)
    end))

    -- Input callbacks
    self.InputHandler:OnDash(function(direction)
        self:_onDashInput(direction)
    end)

    self.InputHandler:OnJump(function()
        self:_onJumpInput()
    end)
end

function MovementController:_applyInitialSettings()
    -- Set initial walk speed
    self.Humanoid.WalkSpeed = self.Config.Speeds.Walk
    self.Humanoid.JumpPower = self.Config.Physics.JumpPower

    -- Play idle animation
    self.AnimationController:PlayAnimation("Idle")
end

-- ═══════════════════════════════════════════════════════════════════
-- MAIN UPDATE LOOP
-- ═══════════════════════════════════════════════════════════════════

function MovementController:_update(dt: number)
    if not self.Character or not self.Humanoid or self.Humanoid.Health <= 0 then
        return
    end

    -- Update ground state
    self:_updateGroundState()

    -- Update movement speed
    self:_updateMovementSpeed(dt)

    -- Update movement state based on input and speed
    self:_updateMovementState()

    -- Update animations
    self:_updateAnimations()

    -- Update VFX
    self:_updateVFX()

    -- Update subsystems
    self.StateManager:Update(dt)
    self.DashSystem:UpdateGroundState(self.IsGrounded)
end

-- ═══════════════════════════════════════════════════════════════════
-- GROUND STATE DETECTION
-- ═══════════════════════════════════════════════════════════════════

function MovementController:_updateGroundState()
    local wasGrounded = self.IsGrounded

    -- Use humanoid floor material as primary check
    self.IsGrounded = self.Humanoid.FloorMaterial ~= Enum.Material.Air

    -- Alternative: Raycast check
    if not self.IsGrounded then
        local origin = self.RootPart.Position
        local direction = Vector3.new(0, -self.Config.Physics.GroundRaycastDistance, 0)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = {self.Character}

        local result = workspace:Raycast(origin, direction, raycastParams)
        self.IsGrounded = result ~= nil
    end

    -- Track fall start
    if wasGrounded and not self.IsGrounded then
        self.FallStartHeight = self.RootPart.Position.Y
        self.IsFalling = true
    elseif not wasGrounded and self.IsGrounded then
        -- Just landed
        local fallDistance = self.FallStartHeight - self.RootPart.Position.Y
        if fallDistance > 0 then
            self:_onLanded(fallDistance)
        end
        self.IsFalling = false
        self.LastGroundedTime = tick()
    end
end

function MovementController:_onLanded(fallDistance: number)
    -- Play landing VFX
    if self.VFXManager then
        self.VFXManager:PlayLandingEffect(fallDistance)
    end

    -- Play landing animation
    if fallDistance >= self.Config.VFX.Landing.HardLandDistance then
        self.AnimationController:PlayAnimation("LandHard", 0.05, Enum.AnimationPriority.Action)
    else
        self.AnimationController:PlayAnimation("Land", 0.05, Enum.AnimationPriority.Action)
    end

    -- State transition
    self.StateManager:SetState("Land", true)

    -- Brief pause after hard landing
    if fallDistance >= self.Config.VFX.Landing.HardLandDistance then
        self.StateManager:LockState(0.3)
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- MOVEMENT SPEED CONTROL
-- ═══════════════════════════════════════════════════════════════════

function MovementController:_updateMovementSpeed(dt: number)
    local speeds = self.Config.Speeds
    local isMoving = self.InputHandler.IsMoving
    local isSprinting = self.InputHandler:IsSprintHeld()

    -- Determine target speed
    if self.DashSystem.IsDashing then
        -- Speed is controlled by dash system
        return
    elseif not isMoving then
        self.TargetSpeed = speeds.Idle
    elseif isSprinting then
        self.TargetSpeed = speeds.Sprint
    elseif isSprinting == false and isMoving then
        -- Check if running (fast walk) based on input magnitude
        local inputMag = self.InputHandler:GetRawMoveDirection().Magnitude
        if inputMag > 0.8 then
            self.TargetSpeed = speeds.Run
        else
            self.TargetSpeed = speeds.Walk
        end
    else
        self.TargetSpeed = speeds.Walk
    end

    -- Apply air control reduction
    if not self.IsGrounded then
        -- Don't change speed much in air
        self.TargetSpeed = math.min(self.TargetSpeed, self.CurrentSpeed + speeds.AirControl)
    end

    -- Smooth speed interpolation
    local acceleration = isMoving and speeds.Acceleration or speeds.Deceleration
    self.CurrentSpeed = self.CurrentSpeed + (self.TargetSpeed - self.CurrentSpeed) * math.min(1, acceleration * dt)

    -- Apply to humanoid
    if not self.DashSystem.IsDashing then
        self.Humanoid.WalkSpeed = self.CurrentSpeed
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- MOVEMENT STATE MANAGEMENT
-- ═══════════════════════════════════════════════════════════════════

function MovementController:_updateMovementState()
    if self.DashSystem.IsDashing then
        return  -- Dash state is managed by dash system
    end

    if self.StateManager:IsLocked() then
        return
    end

    local speeds = self.Config.Speeds
    local currentState = self.StateManager:GetState()

    -- Determine new state
    local newState = "Idle"

    if not self.IsGrounded then
        if self.RootPart.AssemblyLinearVelocity.Y > 1 then
            newState = "Jump"
        else
            newState = "Fall"
        end
    elseif self.CurrentSpeed >= speeds.Sprint * 0.9 then
        newState = "Sprint"
    elseif self.CurrentSpeed >= speeds.Run * 0.9 then
        newState = "Run"
    elseif self.CurrentSpeed >= speeds.Walk * 0.5 then
        newState = "Walk"
    else
        newState = "Idle"
    end

    -- Transition if different
    if newState ~= currentState then
        self.StateManager:SetState(newState)
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- INPUT HANDLERS
-- ═══════════════════════════════════════════════════════════════════

function MovementController:_onDashInput(direction: Vector3)
    if self.StateManager:IsLocked() then return end

    local directionName = self.InputHandler:GetDashDirectionName()
    local dashDirection = self.InputHandler:GetDashDirection()

    local success = self.DashSystem:StartDash(
        self.Character,
        dashDirection,
        directionName,
        self.IsGrounded
    )

    if success then
        -- Play dash animation
        self.AnimationController:PlayDashAnimation(directionName)
    end
end

function MovementController:_onJumpInput()
    -- VFX is handled by humanoid jump
    if self.IsGrounded and self.VFXManager then
        self.VFXManager:PlayJumpEffect()
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- STATE CHANGE HANDLERS
-- ═══════════════════════════════════════════════════════════════════

function MovementController:_onStateChanged(newState: string, oldState: string)
    -- Notify VFX manager
    if self.VFXManager then
        self.VFXManager:OnStateChanged(newState, oldState)
    end

    -- Debug output
    if self.Config.Debug and self.Config.Debug.ShowStateChanges then
        print(string.format("[MovementController] State: %s -> %s", oldState, newState))
    end
end

function MovementController:_onHumanoidStateChanged(oldState: Enum.HumanoidStateType, newState: Enum.HumanoidStateType)
    if newState == Enum.HumanoidStateType.Jumping then
        self.StateManager:SetState("Jump")
        self.AnimationController:PlayAnimation("Jump", 0.05, Enum.AnimationPriority.Action)
    elseif newState == Enum.HumanoidStateType.Freefall then
        self.StateManager:SetState("Fall")
    elseif newState == Enum.HumanoidStateType.Landed then
        -- Handled by ground state detection
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- ANIMATION UPDATES
-- ═══════════════════════════════════════════════════════════════════

function MovementController:_updateAnimations()
    if self.DashSystem.IsDashing then
        return  -- Dash animation already playing
    end

    local currentState = self.StateManager:GetState()
    local direction = self.InputHandler:GetDashDirectionName()

    -- Get movement animation based on state
    if currentState == "Idle" then
        self.AnimationController:PlayAnimation("Idle")
    elseif currentState == "Walk" then
        self.AnimationController:PlayMovementAnimation("Walk", direction, 1)
    elseif currentState == "Run" then
        self.AnimationController:PlayMovementAnimation("Run", direction, 1)
    elseif currentState == "Sprint" then
        self.AnimationController:PlayMovementAnimation("Sprint", direction, 1)
    elseif currentState == "Jump" then
        self.AnimationController:PlayAnimation("Jump")
    elseif currentState == "Fall" then
        self.AnimationController:PlayAnimation("Fall")
    end

    -- Adjust animation speed based on velocity
    local velocity = self.RootPart.AssemblyLinearVelocity.Magnitude
    self.AnimationController:AdjustSpeedForVelocity(velocity, self.TargetSpeed)
end

-- ═══════════════════════════════════════════════════════════════════
-- VFX UPDATES
-- ═══════════════════════════════════════════════════════════════════

function MovementController:_updateVFX()
    if not self.VFXManager then return end

    local currentState = self.StateManager:GetState()
    local velocity = self.RootPart.AssemblyLinearVelocity.Magnitude

    -- Update movement VFX
    self.VFXManager:UpdateMovementVFX(velocity, currentState, self.IsGrounded)

    -- Update footstep effects
    self.VFXManager:UpdateFootsteps(velocity, currentState, self.IsGrounded)
end

-- ═══════════════════════════════════════════════════════════════════
-- CHARACTER RESPAWN
-- ═══════════════════════════════════════════════════════════════════

function MovementController:_onCharacterAdded(character: Model)
    -- Cleanup old systems
    self:_cleanup()

    -- Setup new character
    task.wait(0.1)  -- Brief delay for character to fully load
    self:_setupCharacter(character)
end

function MovementController:_cleanup()
    -- Disconnect update loop
    if self.UpdateConnection then
        self.UpdateConnection:Disconnect()
        self.UpdateConnection = nil
    end

    -- Destroy subsystems
    if self.StateManager then
        self.StateManager:Destroy()
    end
    if self.InputHandler then
        self.InputHandler:Destroy()
    end
    if self.DashSystem then
        self.DashSystem:Destroy()
    end
    if self.AnimationController then
        self.AnimationController:Destroy()
    end
    if self.VFXManager then
        self.VFXManager:Destroy()
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- PUBLIC API
-- ═══════════════════════════════════════════════════════════════════

function MovementController:GetState(): string
    return self.StateManager and self.StateManager:GetState() or "Idle"
end

function MovementController:GetSpeed(): number
    return self.CurrentSpeed
end

function MovementController:IsGrounded(): boolean
    return self.IsGrounded
end

function MovementController:IsDashing(): boolean
    return self.DashSystem and self.DashSystem.IsDashing or false
end

function MovementController:GetDashCooldown(): number
    return self.DashSystem and self.DashSystem:GetCooldownRemaining() or 0
end

function MovementController:SetSpeedMultiplier(multiplier: number)
    -- Temporary speed modifier (for buffs, debuffs, etc.)
    -- This would be implemented with a speed modifier system
end

function MovementController:LockMovement(duration: number)
    if self.StateManager then
        self.StateManager:LockState(duration)
    end
end

function MovementController:UnlockMovement()
    if self.StateManager then
        self.StateManager:UnlockState()
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════════════════════════════

function MovementController:Destroy()
    self:_cleanup()

    for _, connection in ipairs(self.Connections) do
        connection:Disconnect()
    end
    self.Connections = {}

    self.Initialized = false
end

return MovementController
