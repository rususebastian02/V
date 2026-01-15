--[[
    VIP_GUI_SCRIPT.LUA
    Gestisce il bottone VIP Area per player con VIP Status gamepass

    Questo script deve essere inserito in StarterGui/VIPGUI come LocalScript
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- Eventi
local Events = ReplicatedStorage:WaitForChild("Events")
local TeleportToVIPEvent = Events:WaitForChild("TeleportToVIP")
local RequestDataFunction = Events:WaitForChild("RequestData")

-- UI
local VIPGUI = script.Parent
local VIPButton = VIPGUI:WaitForChild("VIPButton")

print("[VIPGUI] Inizializzato")

-- ==================== CHECK VIP STATUS ====================

local function CheckVIPStatus()
    local success, data = pcall(function()
        return RequestDataFunction:InvokeServer()
    end)

    if success and data then
        local hasVIP = data.Gamepasses and data.Gamepasses.VIPStatus
        VIPButton.Visible = hasVIP

        if hasVIP then
            print("[VIPGUI] Player ha VIP Status, bottone visibile")
        else
            print("[VIPGUI] Player non ha VIP Status")
        end
    else
        VIPButton.Visible = false
        warn("[VIPGUI] Errore nel check VIP status")
    end
end

-- Check iniziale dopo un delay
task.wait(2)
CheckVIPStatus()

-- ==================== TELEPORT TO VIP ====================

VIPButton.MouseButton1Click:Connect(function()
    print("[VIPGUI] Richiesta teleport a VIP Area")
    TeleportToVIPEvent:FireServer()
end)

-- ==================== HOVER EFFECTS ====================

VIPButton.MouseEnter:Connect(function()
    VIPButton.BackgroundColor3 = Color3.fromRGB(255, 235, 0)
end)

VIPButton.MouseLeave:Connect(function()
    VIPButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
end)

print("[VIPGUI] Pronto!")
