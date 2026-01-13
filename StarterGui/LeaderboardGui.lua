--[[
    LEADERBOARD GUI - Script Client
    Mostra la classifica di sopravvivenza a fine round
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Crea la GUI principale
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LeaderboardGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Frame principale
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 500, 0, 600)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 15)
uiCorner.Parent = mainFrame

-- Titolo
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 60)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
titleLabel.BorderSizePixel = 0
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 32
titleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
titleLabel.Text = "CLASSIFICA FINALE"
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 15)
titleCorner.Parent = titleLabel

-- ScrollingFrame per la lista
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -80)
scrollFrame.Position = UDim2.new(0, 10, 0, 70)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 8
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

-- Funzione per formattare il tempo
local function FormatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d", mins, secs)
end

-- Funzione per creare una entry della leaderboard
local function CreateLeaderboardEntry(rank, playerName, survivalTime, isWinner)
    local entry = Instance.new("Frame")
    entry.Size = UDim2.new(1, -10, 0, 50)
    entry.BackgroundColor3 = isWinner and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(40, 40, 40)
    entry.BorderSizePixel = 0

    local entryCorner = Instance.new("UICorner")
    entryCorner.CornerRadius = UDim.new(0, 8)
    entryCorner.Parent = entry

    -- Rank
    local rankLabel = Instance.new("TextLabel")
    rankLabel.Size = UDim2.new(0, 50, 1, 0)
    rankLabel.Position = UDim2.new(0, 0, 0, 0)
    rankLabel.BackgroundTransparency = 1
    rankLabel.Font = Enum.Font.GothamBold
    rankLabel.TextSize = 24
    rankLabel.TextColor3 = isWinner and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
    rankLabel.Text = "#" .. rank
    rankLabel.Parent = entry

    -- Nome giocatore
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 250, 1, 0)
    nameLabel.Position = UDim2.new(0, 60, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextSize = 20
    nameLabel.TextColor3 = isWinner and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
    nameLabel.Text = playerName .. (isWinner and " 👑" or "")
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = entry

    -- Tempo
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(0, 120, 1, 0)
    timeLabel.Position = UDim2.new(1, -130, 0, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Font = Enum.Font.GothamBold
    timeLabel.TextSize = 20
    timeLabel.TextColor3 = isWinner and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(0, 255, 0)
    timeLabel.Text = FormatTime(survivalTime)
    timeLabel.TextXAlignment = Enum.TextXAlignment.Right
    timeLabel.Parent = entry

    return entry
end

-- Aspetta il RemoteEvent
local RoundEvents = ReplicatedStorage:WaitForChild("RoundEvents")
local LeaderboardEvent = RoundEvents:WaitForChild("LeaderboardEvent")

-- Ascolta gli eventi della leaderboard
LeaderboardEvent.OnClientEvent:Connect(function(leaderboardData)
    -- Pulisci vecchie entry
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    if not leaderboardData then
        mainFrame.Visible = false
        return
    end

    -- Mostra la leaderboard
    mainFrame.Visible = true

    -- Crea entry per ogni giocatore
    for rank, data in ipairs(leaderboardData) do
        local entry = CreateLeaderboardEntry(rank, data.playerName, data.survivalTime, data.isWinner)
        entry.LayoutOrder = rank
        entry.Parent = scrollFrame
    end

    -- Aggiorna dimensione scroll
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #leaderboardData * 55)
end)

print("[LeaderboardGui] Leaderboard GUI inizializzata")
