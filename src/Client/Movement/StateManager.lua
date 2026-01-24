--[[
    StateManager.lua
    Advanced Movement State Machine

    Handles all movement state transitions with priority system.
    States: Idle, Walk, Run, Sprint, Dash, Jump, Fall, Land
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local StateManager = {}
StateManager.__index = StateManager

-- ═══════════════════════════════════════════════════════════════════
-- STATE DEFINITIONS
-- ═══════════════════════════════════════════════════════════════════

export type MovementState = "Idle" | "Walk" | "Run" | "Sprint" | "Dash" | "Jump" | "Fall" | "Land" | "Stun"

export type StateData = {
    name: MovementState,
    priority: number,
    canInterrupt: {[MovementState]: boolean},
    onEnter: ((self: StateManager) -> ())?,
    onExit: ((self: StateManager) -> ())?,
    onUpdate: ((self: StateManager, dt: number) -> ())?,
}

-- ═══════════════════════════════════════════════════════════════════
-- CONSTRUCTOR
-- ═══════════════════════════════════════════════════════════════════

function StateManager.new(config: table)
    local self = setmetatable({}, StateManager)

    self.Config = config
    self.CurrentState = "Idle" :: MovementState
    self.PreviousState = "Idle" :: MovementState
    self.StateStartTime = tick()
    self.StateData = {}
    self.Callbacks = {
        OnStateChanged = {},
    }
    self.Locked = false
    self.LockEndTime = 0

    -- Initialize default states
    self:_initializeStates()

    return self
end

-- ═══════════════════════════════════════════════════════════════════
-- STATE INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════

function StateManager:_initializeStates()
    local priorities = self.Config.StatePriority

    -- Define all movement states with their properties
    self.States = {
        Idle = {
            name = "Idle",
            priority = priorities.Idle or 0,
            canInterrupt = {
                Walk = true,
                Run = true,
                Sprint = true,
                Dash = true,
                Jump = true,
                Fall = true,
            },
        },

        Walk = {
            name = "Walk",
            priority = priorities.Walk or 1,
            canInterrupt = {
                Idle = true,
                Run = true,
                Sprint = true,
                Dash = true,
                Jump = true,
                Fall = true,
            },
        },

        Run = {
            name = "Run",
            priority = priorities.Run or 2,
            canInterrupt = {
                Idle = true,
                Walk = true,
                Sprint = true,
                Dash = true,
                Jump = true,
                Fall = true,
            },
        },

        Sprint = {
            name = "Sprint",
            priority = priorities.Sprint or 3,
            canInterrupt = {
                Idle = true,
                Walk = true,
                Run = true,
                Dash = true,
                Jump = true,
                Fall = true,
            },
        },

        Dash = {
            name = "Dash",
            priority = priorities.Dash or 10,
            canInterrupt = {
                Fall = true,  -- Can transition to fall after dash
                Land = true,
                Stun = true,  -- Stun can interrupt dash
            },
        },

        Jump = {
            name = "Jump",
            priority = 5,
            canInterrupt = {
                Fall = true,
                Dash = true,
                Land = true,
            },
        },

        Fall = {
            name = "Fall",
            priority = 4,
            canInterrupt = {
                Land = true,
                Dash = true,
            },
        },

        Land = {
            name = "Land",
            priority = 3,
            canInterrupt = {
                Idle = true,
                Walk = true,
                Run = true,
                Sprint = true,
                Dash = true,
                Jump = true,
            },
        },

        Stun = {
            name = "Stun",
            priority = priorities.Stun or 100,
            canInterrupt = {
                Idle = true,
            },
        },
    }
end

-- ═══════════════════════════════════════════════════════════════════
-- STATE TRANSITIONS
-- ═══════════════════════════════════════════════════════════════════

function StateManager:CanTransitionTo(newState: MovementState): boolean
    if self.Locked and tick() < self.LockEndTime then
        return false
    end

    local currentStateData = self.States[self.CurrentState]
    local newStateData = self.States[newState]

    if not currentStateData or not newStateData then
        warn("[StateManager] Invalid state:", newState)
        return false
    end

    -- Check if current state allows transition to new state
    if currentStateData.canInterrupt[newState] then
        return true
    end

    -- Check priority override
    if newStateData.priority > currentStateData.priority then
        return true
    end

    return false
end

function StateManager:SetState(newState: MovementState, force: boolean?): boolean
    if not force and not self:CanTransitionTo(newState) then
        return false
    end

    local oldState = self.CurrentState

    -- Call exit callback for old state
    if self.StateData[oldState] and self.StateData[oldState].onExit then
        self.StateData[oldState].onExit(self)
    end

    -- Update state
    self.PreviousState = oldState
    self.CurrentState = newState
    self.StateStartTime = tick()

    -- Call enter callback for new state
    if self.StateData[newState] and self.StateData[newState].onEnter then
        self.StateData[newState].onEnter(self)
    end

    -- Notify listeners
    self:_fireCallbacks("OnStateChanged", newState, oldState)

    if self.Config.Debug and self.Config.Debug.ShowStateChanges then
        print(string.format("[StateManager] %s -> %s", oldState, newState))
    end

    return true
end

function StateManager:GetState(): MovementState
    return self.CurrentState
end

function StateManager:GetPreviousState(): MovementState
    return self.PreviousState
end

function StateManager:GetStateTime(): number
    return tick() - self.StateStartTime
end

function StateManager:IsState(...): boolean
    local states = {...}
    for _, state in ipairs(states) do
        if self.CurrentState == state then
            return true
        end
    end
    return false
end

-- ═══════════════════════════════════════════════════════════════════
-- STATE LOCKING
-- ═══════════════════════════════════════════════════════════════════

function StateManager:LockState(duration: number)
    self.Locked = true
    self.LockEndTime = tick() + duration
end

function StateManager:UnlockState()
    self.Locked = false
    self.LockEndTime = 0
end

function StateManager:IsLocked(): boolean
    if self.Locked and tick() >= self.LockEndTime then
        self.Locked = false
    end
    return self.Locked
end

-- ═══════════════════════════════════════════════════════════════════
-- CUSTOM STATE DATA
-- ═══════════════════════════════════════════════════════════════════

function StateManager:SetStateCallbacks(state: MovementState, callbacks: {
    onEnter: ((self: StateManager) -> ())?,
    onExit: ((self: StateManager) -> ())?,
    onUpdate: ((self: StateManager, dt: number) -> ())?,
})
    self.StateData[state] = callbacks
end

function StateManager:Update(dt: number)
    -- Check lock expiration
    if self.Locked and tick() >= self.LockEndTime then
        self.Locked = false
    end

    -- Call update callback for current state
    if self.StateData[self.CurrentState] and self.StateData[self.CurrentState].onUpdate then
        self.StateData[self.CurrentState].onUpdate(self, dt)
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- CALLBACKS
-- ═══════════════════════════════════════════════════════════════════

function StateManager:OnStateChanged(callback: (newState: MovementState, oldState: MovementState) -> ())
    table.insert(self.Callbacks.OnStateChanged, callback)
    return function()
        local index = table.find(self.Callbacks.OnStateChanged, callback)
        if index then
            table.remove(self.Callbacks.OnStateChanged, index)
        end
    end
end

function StateManager:_fireCallbacks(callbackType: string, ...)
    for _, callback in ipairs(self.Callbacks[callbackType] or {}) do
        task.spawn(callback, ...)
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════════════════════════════

function StateManager:Destroy()
    self.Callbacks = {}
    self.StateData = {}
end

return StateManager
