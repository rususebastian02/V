--[[
    CLIENTMAIN.LUA
    Script client principale che gestisce la UI e la comunicazione con il server
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Moduli
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = require(Modules.Config)

-- Eventi
local Events = ReplicatedStorage:WaitForChild("Events")
local DataUpdatedEvent = Events:WaitForChild("DataUpdated")
local RankUpEvent = Events:WaitForChild("RankUp")
local BoostActivatedEvent = Events:WaitForChild("BoostActivated")
local BoostEndedEvent = Events:WaitForChild("BoostEnded")
local RequestDataFunction = Events:WaitForChild("RequestData")

print("[ClientMain] Inizializzazione client per " .. player.Name)

-- ==================== DATA CACHE ====================

local PlayerData = {
    Cash = 0,
    AFKTime = 0,
    Rank = "Lazy",
    Income = 1,
    ServerBoost = false
}

-- ==================== REQUEST INITIAL DATA ====================

local function RequestInitialData()
    local success, data = pcall(function()
        return RequestDataFunction:InvokeServer()
    end)

    if success and data then
        PlayerData = {
            Cash = data.Cash or 0,
            AFKTime = data.AFKTime or 0,
            Rank = data.Rank or "Lazy",
            Income = data.Income or 1,
            ServerBoost = data.ServerBoost.Active or false
        }
        print("[ClientMain] Dati iniziali ricevuti")
    else
        warn("[ClientMain] Errore nel richiedere dati iniziali")
    end
end

RequestInitialData()

-- ==================== UI REFERENCES ====================

local HUD = playerGui:WaitForChild("HUD")
local CashLabel = HUD:WaitForChild("CashFrame"):WaitForChild("CashLabel")
local IncomeLabel = HUD:WaitForChild("CashFrame"):WaitForChild("IncomeLabel")
local RankLabel = HUD:WaitForChild("RankFrame"):WaitForChild("RankLabel")
local AFKTimeLabel = HUD:WaitForChild("AFKFrame"):WaitForChild("AFKTimeLabel")
local BoostFrame = HUD:WaitForChild("BoostFrame")
local BoostLabel = BoostFrame:WaitForChild("BoostLabel")

-- ==================== UPDATE UI ====================

local function FormatNumber(num)
    if num >= 1000000000 then
        return string.format("%.2fB", num / 1000000000)
    elseif num >= 1000000 then
        return string.format("%.2fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.2fK", num / 1000)
    else
        return string.format("%.0f", num)
    end
end

local function FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)

    if hours > 0 then
        return string.format("%dh %dm %ds", hours, minutes, secs)
    elseif minutes > 0 then
        return string.format("%dm %ds", minutes, secs)
    else
        return string.format("%ds", secs)
    end
end

local function UpdateUI()
    -- Cash
    CashLabel.Text = "💰 " .. FormatNumber(PlayerData.Cash)

    -- Income
    IncomeLabel.Text = "+" .. FormatNumber(PlayerData.Income) .. "/sec"

    -- Rank
    RankLabel.Text = "🏆 " .. PlayerData.Rank

    -- AFK Time
    AFKTimeLabel.Text = "⏱️ " .. FormatTime(PlayerData.AFKTime)

    -- Boost
    if PlayerData.ServerBoost then
        BoostFrame.Visible = true
        BoostLabel.Text = "🚀 SERVER BOOST ACTIVE x2"
    else
        BoostFrame.Visible = false
    end
end

-- ==================== DATA UPDATED EVENT ====================

DataUpdatedEvent.OnClientEvent:Connect(function(data)
    PlayerData.Cash = data.Cash
    PlayerData.AFKTime = data.AFKTime
    PlayerData.Rank = data.Rank
    PlayerData.Income = data.Income
    PlayerData.ServerBoost = data.ServerBoost

    UpdateUI()
end)

-- ==================== RANK UP EVENT ====================

RankUpEvent.OnClientEvent:Connect(function(rankName, rankData)
    print("[ClientMain] RANK UP! Nuovo rank: " .. rankName)

    -- Mostra notifica rank up
    local RankUpNotification = playerGui:WaitForChild("RankUpNotification")
    local NotifFrame = RankUpNotification:WaitForChild("Frame")
    local RankNameLabel = NotifFrame:WaitForChild("RankNameLabel")

    RankNameLabel.Text = rankName
    RankNameLabel.TextColor3 = rankData.Color or Color3.fromRGB(255, 255, 255)

    -- Mostra notifica
    NotifFrame.Visible = true
    NotifFrame.Position = UDim2.new(0.5, 0, -0.2, 0)

    -- Anima
    NotifFrame:TweenPosition(
        UDim2.new(0.5, 0, 0.2, 0),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Bounce,
        0.5,
        false
    )

    -- Nascondi dopo 3 secondi
    task.wait(3)
    NotifFrame:TweenPosition(
        UDim2.new(0.5, 0, -0.2, 0),
        Enum.EasingDirection.In,
        Enum.EasingStyle.Quad,
        0.3,
        false,
        function()
            NotifFrame.Visible = false
        end
    )
end)

-- ==================== BOOST EVENTS ====================

BoostActivatedEvent.OnClientEvent:Connect(function(boostInfo)
    print("[ClientMain] Server boost attivato da " .. boostInfo.ActivatedBy)
    PlayerData.ServerBoost = true
    UpdateUI()

    -- TODO: Mostra notifica boost attivato
end)

BoostEndedEvent.OnClientEvent:Connect(function()
    print("[ClientMain] Server boost terminato")
    PlayerData.ServerBoost = false
    UpdateUI()
end)

-- ==================== UPDATE LOOP ====================

spawn(function()
    while true do
        task.wait(0.1)
        UpdateUI()
    end
end)

print("[ClientMain] Client pronto!")
