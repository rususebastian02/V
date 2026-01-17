--[[
    MENUGUI_SCRIPT.LUA
    Gestisce il Menu con due tab:
    - Profile: Username, First Join, Total Cash, AFK Time, Rank, Robux Spent
    - Index: Mostra tutti i 9 rank con progressione

    Questo script deve essere inserito in StarterGui/MenuGUI come LocalScript
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
local RequestDataFunction = Events:WaitForChild("RequestData")

-- UI References
local MenuGUI = script.Parent
local MainFrame = MenuGUI:WaitForChild("MainFrame")
local CloseButton = MainFrame:WaitForChild("CloseButton")
local TabButtons = MainFrame:WaitForChild("TabButtons")
local ProfileTab = TabButtons:WaitForChild("ProfileTab")
local IndexTab = TabButtons:WaitForChild("IndexTab")
local ProfileFrame = MainFrame:WaitForChild("ProfileFrame")
local IndexFrame = MainFrame:WaitForChild("IndexFrame")

-- Menu toggle button (fuori dal MainFrame)
local MenuButton = MenuGUI:WaitForChild("MenuButton")

-- ==================== TOGGLE MENU ====================

local isMenuOpen = false

local function ToggleMenu()
    isMenuOpen = not isMenuOpen
    MainFrame.Visible = isMenuOpen

    if isMenuOpen then
        -- Mostra tab Profile di default e carica i dati
        ProfileFrame.Visible = true
        IndexFrame.Visible = false
        UpdateProfileData()
    end
end

MenuButton.MouseButton1Click:Connect(ToggleMenu)
CloseButton.MouseButton1Click:Connect(ToggleMenu)

-- ==================== TAB SWITCHING ====================

ProfileTab.MouseButton1Click:Connect(function()
    ProfileFrame.Visible = true
    IndexFrame.Visible = false
    UpdateProfileData()
end)

IndexTab.MouseButton1Click:Connect(function()
    ProfileFrame.Visible = false
    IndexFrame.Visible = true
end)

-- ==================== HELPER FUNCTIONS ====================

local function FormatDate(timestamp)
    local dateTable = os.date("*t", timestamp)
    return string.format("%02d/%02d/%04d", dateTable.day, dateTable.month, dateTable.year)
end

local function FormatTime(seconds)
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)

    if days > 0 then
        return string.format("%dd %dh %dmin %dsec", days, hours, minutes, secs)
    elseif hours > 0 then
        return string.format("%dh %dmin %dsec", hours, minutes, secs)
    elseif minutes > 0 then
        return string.format("%dmin %dsec", minutes, secs)
    else
        return string.format("%dsec", secs)
    end
end

local function FormatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(math.floor(num))
    end
end

-- ==================== UPDATE PROFILE DATA ====================

function UpdateProfileData()
    -- Richiedi dati dal server
    local success, data = pcall(function()
        return RequestDataFunction:InvokeServer()
    end)

    if not success or not data then
        warn("[MenuGUI] Errore nel ricevere dati dal server")
        return
    end

    -- Aggiorna UI
    local container = ProfileFrame:WaitForChild("Container")

    -- Username
    container:WaitForChild("UsernameLabel").Text = "Username: " .. player.Name

    -- First Join
    local firstJoinDate = data.FirstJoin and FormatDate(data.FirstJoin) or "N/A"
    container:WaitForChild("FirstJoinLabel").Text = "First Join: " .. firstJoinDate

    -- Total Cash
    container:WaitForChild("CashLabel").Text = "Total Cash: " .. FormatNumber(data.Cash)

    -- AFK Time
    container:WaitForChild("AFKTimeLabel").Text = "AFK Time: " .. FormatTime(data.TotalAFKTime)

    -- Rank
    container:WaitForChild("RankLabel").Text = "Rank: " .. (data.CurrentRank or "Lazy")

    -- Robux Spent
    container:WaitForChild("RobuxSpentLabel").Text = "Robux Spent: " .. (data.RobuxSpent or 0) .. " R$"

    print("[MenuGUI] Profile data aggiornati")
end

-- ==================== POPULATE INDEX ====================

local function PopulateIndex()
    local container = IndexFrame:WaitForChild("Container")

    -- Clear existing entries
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    -- Create UIListLayout if doesn't exist
    if not container:FindFirstChildOfClass("UIListLayout") then
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 10)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = container
    end

    -- Create entries for each rank
    for i, rankInfo in ipairs(Config.Ranks) do
        local frame = Instance.new("Frame")
        frame.Name = "Rank_" .. i
        frame.Size = UDim2.new(1, -20, 0, 60)
        frame.BackgroundColor3 = rankInfo.Color
        frame.BorderSizePixel = 0
        frame.LayoutOrder = i
        frame.Parent = container

        -- Rank number
        local numberLabel = Instance.new("TextLabel")
        numberLabel.Size = UDim2.new(0, 50, 1, 0)
        numberLabel.Position = UDim2.new(0, 10, 0, 0)
        numberLabel.BackgroundTransparency = 1
        numberLabel.Font = Enum.Font.GothamBold
        numberLabel.Text = "#" .. i
        numberLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
        numberLabel.TextScaled = true
        numberLabel.Parent = frame

        -- Rank name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.5, -80, 1, 0)
        nameLabel.Position = UDim2.new(0, 70, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Text = rankInfo.Name
        nameLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.TextScaled = true
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = frame

        -- Time required
        local timeLabel = Instance.new("TextLabel")
        timeLabel.Size = UDim2.new(0.5, -20, 1, 0)
        timeLabel.Position = UDim2.new(0.5, 0, 0, 0)
        timeLabel.BackgroundTransparency = 1
        timeLabel.Font = Enum.Font.GothamBold
        timeLabel.Text = FormatTime(rankInfo.TimeRequired)
        timeLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
        timeLabel.TextScaled = true
        timeLabel.TextXAlignment = Enum.TextXAlignment.Right
        timeLabel.Parent = frame
    end

    print("[MenuGUI] Index popolato con " .. #Config.Ranks .. " rank")
end

-- Popola l'index all'avvio
PopulateIndex()

print("[MenuGUI] Menu inizializzato!")
