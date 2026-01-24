--[[
    DashSystem.lua
    Advanced Multi-Directional Dash System

    Features:
    - 8-directional dashing
    - Air dashing support
    - Cooldown management
    - Dash chaining
    - Direction-based force multipliers
]]

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local DashSystem = {}
DashSystem.__index = DashSystem

-- ═══════════════════════════════════════════════════════════════════
-- TYPE DEFINITIONS
-- ═══════════════════════════════════════════════════════════════════

export type DashDirection = "Forward" | "Backward" | "Left" | "Right" |
    "ForwardLeft" | "ForwardRight" | "BackwardLeft" | "BackwardRight"

export type DashState = {
    isDashing: boolean,
    direction: Vector3,
    directionName: DashDirection,
    startTime: number,
    endTime: number,
}

-- ═══════════════════════════════════════════════════════════════════
-- CONSTRUCTOR
-- ═══════════════════════════════════════════════════════════════════

function DashSystem.new(config: table, stateManager: any, vfxManager: any)
    local self = setmetatable({}, DashSystem)

    self.Config = config
    self.StateManager = stateManager
    self.VFXManager = vfxManager

    -- Dash state
    self.IsDashing = false
    self.DashDirection = Vector3.zero
    self.DashDirectionName = "Forward" :: DashDirection
    self.DashStartTime = 0
    self.DashEndTime = 0
    self.LastDashTime = 0
    self.DashCooldownEnd = 0

    -- Air dash tracking
    self.AirDashCount = 0
    self.WasGroundedLastFrame = true

    -- Physics
    self.BodyVelocity = nil
    self.OriginalGravity = workspace.Gravity

    -- Callbacks
    self.Callbacks = {
        OnDashStart = {},
        OnDashEnd = {},
        OnDashCooldownReset = {},
    }

    -- Connections
    self.Connections = {}
    self.UpdateConnection = nil

    return self
end

-- ═══════════════════════════════════════════════════════════════════
-- DASH EXECUTION
-- ═══════════════════════════════════════════════════════════════════

function DashSystem:CanDash(isGrounded: boolean): boolean
    local dashConfig = self.Config.Dash
    local currentTime = tick()

    -- Check cooldown
    if currentTime < self.DashCooldownEnd then
        return false
    end

    -- Check if already dashing
    if self.IsDashing then
        if not dashConfig.CanCancelWithDash then
            return false
        end
    end

    -- Check ground requirement
    if dashConfig.GroundDashOnly and not isGrounded then
        return false
    end

    -- Check air dash limit
    if not isGrounded and dashConfig.AirDashEnabled then
        if self.AirDashCount >= dashConfig.MaxAirDashes then
            return false
        end
    elseif not isGrounded and not dashConfig.AirDashEnabled then
        return false
    end

    return true
end

function DashSystem:StartDash(character: Model, direction: Vector3, directionName: DashDirection, isGrounded: boolean): boolean
    if not self:CanDash(isGrounded) then
        return false
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not rootPart then
        return false
    end

    local dashConfig = self.Config.Dash
    local currentTime = tick()

    -- Cancel any existing dash
    if self.IsDashing then
        self:_endDash(character, true)
    end

    -- Set dash state
    self.IsDashing = true
    self.DashDirection = direction
    self.DashDirectionName = directionName
    self.DashStartTime = currentTime
    self.DashEndTime = currentTime + dashConfig.Duration
    self.LastDashTime = currentTime

    -- Track air dashes
    if not isGrounded then
        self.AirDashCount = self.AirDashCount + 1
    end

    -- Calculate dash force with directional multiplier
    local multiplier = self:_getDirectionMultiplier(directionName)
    local dashForce = dashConfig.Force * multiplier

    -- Create body velocity for dash
    self:_createDashVelocity(rootPart, direction, dashForce, dashConfig.Duration)

    -- Reduce gravity during dash
    if dashConfig.GravityReduction < 1 then
        self:_setGravityMultiplier(dashConfig.GravityReduction)
    end

    -- Update state manager
    if self.StateManager then
        self.StateManager:SetState("Dash", true)
        self.StateManager:LockState(dashConfig.Duration * 0.9)  -- Lock slightly less than duration
    end

    -- Trigger VFX
    if self.VFXManager then
        self.VFXManager:PlayDashEffect(rootPart, direction, directionName)
    end

    -- Start update loop
    self:_startUpdateLoop(character)

    -- Fire callbacks
    self:_fireCallbacks("OnDashStart", {
        direction = direction,
        directionName = directionName,
        isAirDash = not isGrounded,
    })

    return true
end

function DashSystem:_createDashVelocity(rootPart: BasePart, direction: Vector3, force: number, duration: number)
    -- Clean up existing
    if self.BodyVelocity then
        self.BodyVelocity:Destroy()
    end

    -- Create body velocity
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "DashVelocity"
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = direction * force
    bodyVelocity.Parent = rootPart

    self.BodyVelocity = bodyVelocity

    -- Tween velocity for smooth end
    local endTime = duration * 0.7  -- Start slowing at 70%

    task.delay(endTime, function()
        if self.BodyVelocity and self.BodyVelocity.Parent then
            local tween = TweenService:Create(
                self.BodyVelocity,
                TweenInfo.new(duration * 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Velocity = Vector3.zero}
            )
            tween:Play()
        end
    end)
end

function DashSystem:_getDirectionMultiplier(directionName: DashDirection): number
    local dashConfig = self.Config.Dash

    local multipliers = {
        Forward = dashConfig.ForwardMultiplier,
        Backward = dashConfig.BackwardMultiplier,
        Left = dashConfig.SideMultiplier,
        Right = dashConfig.SideMultiplier,
        ForwardLeft = dashConfig.DiagonalMultiplier,
        ForwardRight = dashConfig.DiagonalMultiplier,
        BackwardLeft = dashConfig.DiagonalMultiplier * dashConfig.BackwardMultiplier,
        BackwardRight = dashConfig.DiagonalMultiplier * dashConfig.BackwardMultiplier,
    }

    return multipliers[directionName] or 1.0
end

function DashSystem:_setGravityMultiplier(multiplier: number)
    -- Note: This affects all physics. For per-character gravity,
    -- you'd need to use BodyForce to counteract gravity
    -- This is a simplified implementation
    self.OriginalGravity = workspace.Gravity
    -- We don't actually modify workspace.Gravity as it affects all players
    -- Instead, we could add an upward force, but for simplicity we skip this
end

-- ═══════════════════════════════════════════════════════════════════
-- DASH UPDATE LOOP
-- ═══════════════════════════════════════════════════════════════════

function DashSystem:_startUpdateLoop(character: Model)
    if self.UpdateConnection then
        self.UpdateConnection:Disconnect()
    end

    self.UpdateConnection = RunService.Heartbeat:Connect(function(dt)
        self:_updateDash(character, dt)
    end)
end

function DashSystem:_updateDash(character: Model, dt: number)
    if not self.IsDashing then
        if self.UpdateConnection then
            self.UpdateConnection:Disconnect()
            self.UpdateConnection = nil
        end
        return
    end

    local currentTime = tick()

    -- Check if dash should end
    if currentTime >= self.DashEndTime then
        self:_endDash(character, false)
        return
    end

    -- Update VFX during dash
    if self.VFXManager then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            self.VFXManager:UpdateDashEffect(rootPart, self.DashDirection)
        end
    end
end

function DashSystem:_endDash(character: Model, cancelled: boolean)
    if not self.IsDashing then return end

    self.IsDashing = false

    -- Clean up body velocity
    if self.BodyVelocity then
        self.BodyVelocity:Destroy()
        self.BodyVelocity = nil
    end

    -- Set cooldown
    self.DashCooldownEnd = tick() + self.Config.Dash.Cooldown

    -- Restore gravity
    -- (skipped as we didn't actually modify it)

    -- Update state manager
    if self.StateManager then
        self.StateManager:UnlockState()
        -- State will be updated by movement controller
    end

    -- End VFX
    if self.VFXManager then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            self.VFXManager:EndDashEffect(rootPart)
        end
    end

    -- Disconnect update loop
    if self.UpdateConnection then
        self.UpdateConnection:Disconnect()
        self.UpdateConnection = nil
    end

    -- Fire callbacks
    self:_fireCallbacks("OnDashEnd", {
        cancelled = cancelled,
        direction = self.DashDirection,
        directionName = self.DashDirectionName,
    })
end

-- ═══════════════════════════════════════════════════════════════════
-- GROUND STATE TRACKING
-- ═══════════════════════════════════════════════════════════════════

function DashSystem:UpdateGroundState(isGrounded: boolean)
    -- Reset air dash count when landing
    if isGrounded and not self.WasGroundedLastFrame then
        self.AirDashCount = 0
        self:_fireCallbacks("OnDashCooldownReset")
    end

    self.WasGroundedLastFrame = isGrounded
end

-- ═══════════════════════════════════════════════════════════════════
-- STATE QUERIES
-- ═══════════════════════════════════════════════════════════════════

function DashSystem:GetDashState(): DashState
    return {
        isDashing = self.IsDashing,
        direction = self.DashDirection,
        directionName = self.DashDirectionName,
        startTime = self.DashStartTime,
        endTime = self.DashEndTime,
    }
end

function DashSystem:GetCooldownRemaining(): number
    local remaining = self.DashCooldownEnd - tick()
    return math.max(0, remaining)
end

function DashSystem:GetCooldownPercent(): number
    local remaining = self:GetCooldownRemaining()
    return 1 - (remaining / self.Config.Dash.Cooldown)
end

function DashSystem:GetAirDashesRemaining(): number
    return self.Config.Dash.MaxAirDashes - self.AirDashCount
end

-- ═══════════════════════════════════════════════════════════════════
-- CALLBACKS
-- ═══════════════════════════════════════════════════════════════════

function DashSystem:OnDashStart(callback: (data: table) -> ())
    table.insert(self.Callbacks.OnDashStart, callback)
    return function()
        local index = table.find(self.Callbacks.OnDashStart, callback)
        if index then table.remove(self.Callbacks.OnDashStart, index) end
    end
end

function DashSystem:OnDashEnd(callback: (data: table) -> ())
    table.insert(self.Callbacks.OnDashEnd, callback)
    return function()
        local index = table.find(self.Callbacks.OnDashEnd, callback)
        if index then table.remove(self.Callbacks.OnDashEnd, index) end
    end
end

function DashSystem:_fireCallbacks(callbackType: string, ...)
    for _, callback in ipairs(self.Callbacks[callbackType] or {}) do
        task.spawn(callback, ...)
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════════════════════════════

function DashSystem:Destroy()
    if self.UpdateConnection then
        self.UpdateConnection:Disconnect()
    end

    if self.BodyVelocity then
        self.BodyVelocity:Destroy()
    end

    for _, connection in ipairs(self.Connections) do
        connection:Disconnect()
    end

    self.Callbacks = {}
end

return DashSystem
