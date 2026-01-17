--[[
    GLOBALLEADERBOARDDISPLAY.LUA
    Crea e aggiorna il display della leaderboard globale su una Part nel workspace
    Mostra Top 100 AFK Time e Cash con avatar dei player
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Moduli
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = require(Modules.Config)
local GlobalLeaderboardManager = require(Modules.GlobalLeaderboardManager)

print("[GlobalLeaderboardDisplay] Inizializzazione...")

-- ==================== TROVA O CREA LEADERBOARD PARTS ====================

local function FindOrCreateLeaderboardPart(partName, position)
    local part = workspace:FindFirstChild(partName)

    if not part then
        warn("[GlobalLeaderboardDisplay] " .. partName .. " non trovata, creazione...")

        part = Instance.new("Part")
        part.Name = partName
        part.Size = Vector3.new(20, 30, 1)
        part.Position = position
        part.Anchored = true
        part.CanCollide = true
        part.Material = Enum.Material.SmoothPlastic
        part.BrickColor = BrickColor.new("Dark stone grey")
        part.Parent = workspace

        print("[GlobalLeaderboardDisplay] " .. partName .. " creata")
    end

    return part
end

-- Trova o crea le parti
local AFKLeaderboardPart = FindOrCreateLeaderboardPart("GlobalLeaderboard_AFK", Vector3.new(0, 20, -50))
local CashLeaderboardPart = FindOrCreateLeaderboardPart("GlobalLeaderboard_Cash", Vector3.new(25, 20, -50))
local RobuxSpentLeaderboardPart = FindOrCreateLeaderboardPart("GlobalLeaderboard_RobuxSpent", Vector3.new(50, 20, -50))

-- ==================== CREA SURFACE GUI ====================

local function CreateSurfaceGUI(part, title)
    -- Rimuovi SurfaceGUI esistente
    local existingGUI = part:FindFirstChild("LeaderboardGUI")
    if existingGUI then
        existingGUI:Destroy()
    end

    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Name = "LeaderboardGUI"
    surfaceGui.Face = Enum.NormalId.Front
    surfaceGui.AlwaysOnTop = false
    surfaceGui.CanvasSize = Vector2.new(800, 1200)
    surfaceGui.Parent = part

    -- Frame principale
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = surfaceGui

    -- Titolo
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 80)
    titleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    titleLabel.BorderSizePixel = 0
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    titleLabel.TextScaled = true
    titleLabel.Parent = mainFrame

    -- ScrollingFrame per entries
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Position = UDim2.new(0, 0, 0, 80)
    scrollFrame.Size = UDim2.new(1, 0, 1, -80)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 10
    scrollFrame.Parent = mainFrame

    -- UIListLayout
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = scrollFrame

    return surfaceGui, scrollFrame
end

local AFKGui, AFKScrollFrame = CreateSurfaceGUI(AFKLeaderboardPart, "🏆 TOP 100 AFK TIME 🏆")
local CashGui, CashScrollFrame = CreateSurfaceGUI(CashLeaderboardPart, "💰 TOP 100 CASH 💰")
local RobuxSpentGui, RobuxSpentScrollFrame = CreateSurfaceGUI(RobuxSpentLeaderboardPart, "💎 TOP 100 ROBUX SPENT 💎")

-- ==================== UPDATE LEADERBOARD DISPLAY ====================

local function CreateLeaderboardEntry(rank, username, userId, scoreText, parent)
    local frame = Instance.new("Frame")
    frame.Name = "Entry_" .. rank
    frame.Size = UDim2.new(1, -10, 0, 60)
    frame.BackgroundColor3 = rank <= 3 and Color3.fromRGB(60, 60, 0) or Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = parent

    -- Rank label
    local rankLabel = Instance.new("TextLabel")
    rankLabel.Size = UDim2.new(0, 50, 1, 0)
    rankLabel.Position = UDim2.new(0, 5, 0, 0)
    rankLabel.BackgroundTransparency = 1
    rankLabel.Font = Enum.Font.GothamBold
    rankLabel.Text = "#" .. rank
    rankLabel.TextColor3 = rank == 1 and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 255, 255)
    rankLabel.TextScaled = true
    rankLabel.Parent = frame

    -- Avatar image
    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Size = UDim2.new(0, 50, 0, 50)
    avatarImage.Position = UDim2.new(0, 60, 0, 5)
    avatarImage.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    avatarImage.BorderSizePixel = 0

    -- Fetch avatar thumbnail
    local success, thumbnailUrl = pcall(function()
        return Players:GetUserThumbnailAsync(
            userId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size150x150
        )
    end)

    if success then
        avatarImage.Image = thumbnailUrl
    end

    avatarImage.Parent = frame

    -- Username label
    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Size = UDim2.new(0, 250, 1, 0)
    usernameLabel.Position = UDim2.new(0, 120, 0, 0)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Font = Enum.Font.GothamBold
    usernameLabel.Text = username
    usernameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    usernameLabel.TextScaled = true
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.Parent = frame

    -- Score label
    local scoreLabel = Instance.new("TextLabel")
    scoreLabel.Size = UDim2.new(0, 200, 1, 0)
    scoreLabel.Position = UDim2.new(1, -210, 0, 0)
    scoreLabel.BackgroundTransparency = 1
    scoreLabel.Font = Enum.Font.GothamBold
    scoreLabel.Text = scoreText
    scoreLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    scoreLabel.TextScaled = true
    scoreLabel.TextXAlignment = Enum.TextXAlignment.Right
    scoreLabel.Parent = frame
end

local function UpdateLeaderboardDisplay(scrollFrame, entries, formatFunction)
    -- Clear existing entries
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    -- Check if entries is nil or empty
    if not entries or #entries == 0 then
        print("[GlobalLeaderboardDisplay] Nessuna entry disponibile")
        return
    end

    -- Create new entries
    for _, entry in ipairs(entries) do
        local scoreText = formatFunction(entry.Score)
        CreateLeaderboardEntry(
            entry.Rank,
            entry.Username,
            entry.UserId,
            scoreText,
            scrollFrame
        )
    end

    -- Update canvas size
    local listLayout = scrollFrame:FindFirstChildOfClass("UIListLayout")
    if listLayout then
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end

    print("[GlobalLeaderboardDisplay] Display aggiornato con " .. #entries .. " entries")
end

-- ==================== UPDATE LOOP ====================

spawn(function()
    -- Fetch iniziale immediato
    print("[GlobalLeaderboardDisplay] Fetch iniziale in corso...")
    GlobalLeaderboardManager.FetchTop100AFK()
    GlobalLeaderboardManager.FetchTop100Cash()
    GlobalLeaderboardManager.FetchTop100RobuxSpent()

    -- Initial update dopo fetch
    task.wait(2)

    local afkTop100 = GlobalLeaderboardManager.GetCachedTop100AFK()
    local cashTop100 = GlobalLeaderboardManager.GetCachedTop100Cash()
    local robuxSpentTop100 = GlobalLeaderboardManager.GetCachedTop100RobuxSpent()

    print("[GlobalLeaderboardDisplay] AFK entries: " .. #afkTop100)
    print("[GlobalLeaderboardDisplay] Cash entries: " .. #cashTop100)
    print("[GlobalLeaderboardDisplay] RobuxSpent entries: " .. #robuxSpentTop100)

    while true do
        -- Fetch leaderboards
        afkTop100 = GlobalLeaderboardManager.GetCachedTop100AFK()
        cashTop100 = GlobalLeaderboardManager.GetCachedTop100Cash()
        robuxSpentTop100 = GlobalLeaderboardManager.GetCachedTop100RobuxSpent()

        -- Update displays (with nil check)
        if afkTop100 and #afkTop100 > 0 then
            print("[GlobalLeaderboardDisplay] Aggiornamento AFK con " .. #afkTop100 .. " entries")
            UpdateLeaderboardDisplay(
                AFKScrollFrame,
                afkTop100,
                GlobalLeaderboardManager.FormatAFKTime
            )
        else
            print("[GlobalLeaderboardDisplay] AFK leaderboard vuota")
        end

        if cashTop100 and #cashTop100 > 0 then
            print("[GlobalLeaderboardDisplay] Aggiornamento Cash con " .. #cashTop100 .. " entries")
            UpdateLeaderboardDisplay(
                CashScrollFrame,
                cashTop100,
                GlobalLeaderboardManager.FormatCash
            )
        else
            print("[GlobalLeaderboardDisplay] Cash leaderboard vuota")
        end

        if robuxSpentTop100 and #robuxSpentTop100 > 0 then
            print("[GlobalLeaderboardDisplay] Aggiornamento RobuxSpent con " .. #robuxSpentTop100 .. " entries")
            UpdateLeaderboardDisplay(
                RobuxSpentScrollFrame,
                robuxSpentTop100,
                GlobalLeaderboardManager.FormatRobux
            )
        else
            print("[GlobalLeaderboardDisplay] RobuxSpent leaderboard vuota")
        end

        -- Wait for next update
        task.wait(Config.Leaderboard.UpdateInterval)
    end
end)

print("[GlobalLeaderboardDisplay] Display pronto e update loop avviato")
