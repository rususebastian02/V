--[[
    InputHandler.lua
    Advanced Input Handling System

    Handles all player input for movement including:
    - Keyboard/Mouse input
    - Gamepad support
    - Double-tap detection
    - Input buffering
]]

local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local InputHandler = {}
InputHandler.__index = InputHandler

-- ═══════════════════════════════════════════════════════════════════
-- TYPE DEFINITIONS
-- ═══════════════════════════════════════════════════════════════════

export type InputDirection = "Forward" | "Backward" | "Left" | "Right" | "None"
export type InputAction = "Sprint" | "Dash" | "Jump" | "Crouch"

-- ═══════════════════════════════════════════════════════════════════
-- CONSTRUCTOR
-- ═══════════════════════════════════════════════════════════════════

function InputHandler.new(config: table)
    local self = setmetatable({}, InputHandler)

    self.Config = config
    self.Player = Players.LocalPlayer

    -- Input state
    self.MoveDirection = Vector3.zero
    self.RawMoveDirection = Vector3.zero
    self.LookDirection = Vector3.zero
    self.IsMoving = false
    self.IsSprinting = false
    self.WantsToDash = false
    self.WantsToJump = false
    self.WantsToCrouch = false

    -- Double tap detection
    self.LastTapDirection = "None" :: InputDirection
    self.LastTapTime = 0
    self.DoubleTapDetected = false
    self.DoubleTapDirection = "None" :: InputDirection

    -- Input buffer
    self.InputBuffer = {}
    self.BufferDuration = 0.15

    -- Key states
    self.KeyStates = {
        W = false,
        A = false,
        S = false,
        D = false,
        Sprint = false,
        Dash = false,
        Jump = false,
        Crouch = false,
    }

    -- Callbacks
    self.Callbacks = {
        OnDash = {},
        OnJump = {},
        OnSprintStart = {},
        OnSprintEnd = {},
        OnDoubleTap = {},
    }

    -- Connections
    self.Connections = {}

    self:_setupInput()

    return self
end

-- ═══════════════════════════════════════════════════════════════════
-- INPUT SETUP
-- ═══════════════════════════════════════════════════════════════════

function InputHandler:_setupInput()
    local inputConfig = self.Config.Input

    -- Keyboard input began
    table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        self:_handleInputBegan(input)
    end))

    -- Keyboard input ended
    table.insert(self.Connections, UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        self:_handleInputEnded(input)
    end))

    -- Update loop for movement direction
    table.insert(self.Connections, RunService.Heartbeat:Connect(function(dt)
        self:_updateMoveDirection()
        self:_processInputBuffer()
    end))
end

function InputHandler:_handleInputBegan(input: InputObject)
    local keyCode = input.KeyCode
    local inputConfig = self.Config.Input

    -- Movement keys
    if keyCode == Enum.KeyCode.W then
        self.KeyStates.W = true
        self:_checkDoubleTap("Forward")
    elseif keyCode == Enum.KeyCode.S then
        self.KeyStates.S = true
        self:_checkDoubleTap("Backward")
    elseif keyCode == Enum.KeyCode.A then
        self.KeyStates.A = true
        self:_checkDoubleTap("Left")
    elseif keyCode == Enum.KeyCode.D then
        self.KeyStates.D = true
        self:_checkDoubleTap("Right")
    end

    -- Sprint key
    if keyCode == inputConfig.SprintKey or keyCode == inputConfig.SprintButton then
        self.KeyStates.Sprint = true
        if inputConfig.HoldToSprint then
            self.IsSprinting = true
            self:_fireCallbacks("OnSprintStart")
        else
            self.IsSprinting = not self.IsSprinting
            if self.IsSprinting then
                self:_fireCallbacks("OnSprintStart")
            else
                self:_fireCallbacks("OnSprintEnd")
            end
        end
    end

    -- Dash key
    if keyCode == inputConfig.DashKey or keyCode == inputConfig.DashButton then
        self.KeyStates.Dash = true
        self.WantsToDash = true
        self:_bufferInput("Dash")
        self:_fireCallbacks("OnDash", self:GetDashDirection())
    end

    -- Jump key
    if keyCode == Enum.KeyCode.Space or keyCode == Enum.KeyCode.ButtonA then
        self.KeyStates.Jump = true
        self.WantsToJump = true
        self:_bufferInput("Jump")
        self:_fireCallbacks("OnJump")
    end

    -- Crouch key
    if keyCode == inputConfig.CrouchKey then
        self.KeyStates.Crouch = true
        self.WantsToCrouch = true
    end
end

function InputHandler:_handleInputEnded(input: InputObject)
    local keyCode = input.KeyCode
    local inputConfig = self.Config.Input

    -- Movement keys
    if keyCode == Enum.KeyCode.W then
        self.KeyStates.W = false
    elseif keyCode == Enum.KeyCode.S then
        self.KeyStates.S = false
    elseif keyCode == Enum.KeyCode.A then
        self.KeyStates.A = false
    elseif keyCode == Enum.KeyCode.D then
        self.KeyStates.D = false
    end

    -- Sprint key
    if keyCode == inputConfig.SprintKey or keyCode == inputConfig.SprintButton then
        self.KeyStates.Sprint = false
        if inputConfig.HoldToSprint then
            self.IsSprinting = false
            self:_fireCallbacks("OnSprintEnd")
        end
    end

    -- Dash key
    if keyCode == inputConfig.DashKey or keyCode == inputConfig.DashButton then
        self.KeyStates.Dash = false
    end

    -- Jump key
    if keyCode == Enum.KeyCode.Space or keyCode == Enum.KeyCode.ButtonA then
        self.KeyStates.Jump = false
        self.WantsToJump = false
    end

    -- Crouch key
    if keyCode == inputConfig.CrouchKey then
        self.KeyStates.Crouch = false
        self.WantsToCrouch = false
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- DOUBLE TAP DETECTION
-- ═══════════════════════════════════════════════════════════════════

function InputHandler:_checkDoubleTap(direction: InputDirection)
    if not self.Config.Input.DoubleTapDash then return end

    local currentTime = tick()
    local dashConfig = self.Config.Dash

    if self.LastTapDirection == direction then
        if currentTime - self.LastTapTime <= dashConfig.DoubleTapWindow then
            self.DoubleTapDetected = true
            self.DoubleTapDirection = direction
            self:_fireCallbacks("OnDoubleTap", direction)

            -- Trigger dash
            self.WantsToDash = true
            self:_fireCallbacks("OnDash", self:GetDashDirection())
        end
    end

    self.LastTapDirection = direction
    self.LastTapTime = currentTime
end

-- ═══════════════════════════════════════════════════════════════════
-- INPUT BUFFERING
-- ═══════════════════════════════════════════════════════════════════

function InputHandler:_bufferInput(action: InputAction)
    table.insert(self.InputBuffer, {
        action = action,
        time = tick(),
    })
end

function InputHandler:_processInputBuffer()
    local currentTime = tick()
    local i = 1
    while i <= #self.InputBuffer do
        if currentTime - self.InputBuffer[i].time > self.BufferDuration then
            table.remove(self.InputBuffer, i)
        else
            i = i + 1
        end
    end
end

function InputHandler:HasBufferedInput(action: InputAction): boolean
    for _, input in ipairs(self.InputBuffer) do
        if input.action == action then
            return true
        end
    end
    return false
end

function InputHandler:ConsumeBufferedInput(action: InputAction): boolean
    for i, input in ipairs(self.InputBuffer) do
        if input.action == action then
            table.remove(self.InputBuffer, i)
            return true
        end
    end
    return false
end

-- ═══════════════════════════════════════════════════════════════════
-- MOVEMENT DIRECTION
-- ═══════════════════════════════════════════════════════════════════

function InputHandler:_updateMoveDirection()
    local camera = workspace.CurrentCamera
    if not camera then return end

    local moveVector = Vector3.zero

    -- Keyboard input
    if self.KeyStates.W then moveVector = moveVector + Vector3.new(0, 0, -1) end
    if self.KeyStates.S then moveVector = moveVector + Vector3.new(0, 0, 1) end
    if self.KeyStates.A then moveVector = moveVector + Vector3.new(-1, 0, 0) end
    if self.KeyStates.D then moveVector = moveVector + Vector3.new(1, 0, 0) end

    -- Gamepad input
    local gamepadState = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)
    if gamepadState then
        for _, input in ipairs(gamepadState) do
            if input.KeyCode == Enum.KeyCode.Thumbstick1 then
                local deadzone = self.Config.Input.MovementDeadzone
                local pos = input.Position
                if math.abs(pos.X) > deadzone or math.abs(pos.Y) > deadzone then
                    moveVector = moveVector + Vector3.new(pos.X, 0, -pos.Y)
                end
            end
        end
    end

    -- Store raw direction (local space)
    self.RawMoveDirection = moveVector.Magnitude > 0 and moveVector.Unit or Vector3.zero

    -- Convert to world space
    if moveVector.Magnitude > 0 then
        local cameraCFrame = camera.CFrame
        local cameraYaw = CFrame.new(cameraCFrame.Position) * CFrame.Angles(0, math.rad(cameraCFrame:ToEulerAnglesYXZ()), 0)
        self.MoveDirection = (cameraYaw:VectorToWorldSpace(moveVector)).Unit
        self.IsMoving = true
    else
        self.MoveDirection = Vector3.zero
        self.IsMoving = false
    end
end

function InputHandler:GetMoveDirection(): Vector3
    return self.MoveDirection
end

function InputHandler:GetRawMoveDirection(): Vector3
    return self.RawMoveDirection
end

function InputHandler:GetDashDirection(): Vector3
    -- If there's movement input, dash in that direction
    if self.RawMoveDirection.Magnitude > 0 then
        return self.MoveDirection
    end

    -- Otherwise, dash forward based on camera
    local camera = workspace.CurrentCamera
    if camera then
        local lookVector = camera.CFrame.LookVector
        return Vector3.new(lookVector.X, 0, lookVector.Z).Unit
    end

    return Vector3.new(0, 0, -1)
end

function InputHandler:GetDashDirectionName(): string
    local raw = self.RawMoveDirection

    if raw.Magnitude < 0.1 then
        return "Forward"
    end

    local forward = raw.Z < -0.5
    local backward = raw.Z > 0.5
    local left = raw.X < -0.5
    local right = raw.X > 0.5

    if forward and left then return "ForwardLeft"
    elseif forward and right then return "ForwardRight"
    elseif backward and left then return "BackwardLeft"
    elseif backward and right then return "BackwardRight"
    elseif forward then return "Forward"
    elseif backward then return "Backward"
    elseif left then return "Left"
    elseif right then return "Right"
    end

    return "Forward"
end

-- ═══════════════════════════════════════════════════════════════════
-- STATE QUERIES
-- ═══════════════════════════════════════════════════════════════════

function InputHandler:IsSprintHeld(): boolean
    return self.IsSprinting
end

function InputHandler:ConsumeDashInput(): boolean
    if self.WantsToDash then
        self.WantsToDash = false
        self.DoubleTapDetected = false
        return true
    end
    return false
end

function InputHandler:ConsumeJumpInput(): boolean
    if self.WantsToJump then
        self.WantsToJump = false
        return true
    end
    return false
end

-- ═══════════════════════════════════════════════════════════════════
-- CALLBACKS
-- ═══════════════════════════════════════════════════════════════════

function InputHandler:OnDash(callback: (direction: Vector3) -> ())
    table.insert(self.Callbacks.OnDash, callback)
    return function()
        local index = table.find(self.Callbacks.OnDash, callback)
        if index then table.remove(self.Callbacks.OnDash, index) end
    end
end

function InputHandler:OnJump(callback: () -> ())
    table.insert(self.Callbacks.OnJump, callback)
    return function()
        local index = table.find(self.Callbacks.OnJump, callback)
        if index then table.remove(self.Callbacks.OnJump, index) end
    end
end

function InputHandler:OnDoubleTap(callback: (direction: InputDirection) -> ())
    table.insert(self.Callbacks.OnDoubleTap, callback)
    return function()
        local index = table.find(self.Callbacks.OnDoubleTap, callback)
        if index then table.remove(self.Callbacks.OnDoubleTap, index) end
    end
end

function InputHandler:_fireCallbacks(callbackType: string, ...)
    for _, callback in ipairs(self.Callbacks[callbackType] or {}) do
        task.spawn(callback, ...)
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════════════════════════════

function InputHandler:Destroy()
    for _, connection in ipairs(self.Connections) do
        connection:Disconnect()
    end
    self.Connections = {}
    self.Callbacks = {}
end

return InputHandler
