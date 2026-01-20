--[[
	MINIMALIST GAME ROOM - Leaderboard Script

	"People Who Stayed"
	Shows usernames and total time wasted.
	No rewards. Just exposure.

	Place this script inside a Part in the workspace.
	The part should have a SurfaceGui.
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local PlayerDataStore = DataStoreService:GetDataStore("PlayerSessionData_v1")
local LeaderboardStore = DataStoreService:GetOrderedDataStore("GlobalLeaderboard_v1")

-- Reference to the part and SurfaceGui
local part = script.Parent
local surfaceGui = part:FindFirstChildOfClass("SurfaceGui")

if not surfaceGui then
	-- Create SurfaceGui if it doesn't exist
	surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "LeaderboardGui"
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.CanvasSize = Vector2.new(800, 1000)
	surfaceGui.Parent = part
end

-- Create UI elements
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = surfaceGui

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 80)
title.Position = UDim2.new(0, 0, 0, 20)
title.BackgroundTransparency = 1
title.Text = "People Who Stayed"
title.TextColor3 = Color3.fromRGB(200, 200, 200)
title.TextSize = 32
title.Font = Enum.Font.Code
title.Parent = mainFrame

-- Subtitle
local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.Size = UDim2.new(1, 0, 0, 30)
subtitle.Position = UDim2.new(0, 0, 0, 80)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Total Time Wasted"
subtitle.TextColor3 = Color3.fromRGB(120, 120, 120)
subtitle.TextSize = 16
subtitle.Font = Enum.Font.Code
subtitle.Parent = mainFrame

-- Scrolling frame for entries
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(0.9, 0, 0.7, 0)
scrollFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
scrollFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = mainFrame

-- Helper: Format time
local function formatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60

	if hours > 0 then
		return string.format("%dh %dm %ds", hours, minutes, secs)
	elseif minutes > 0 then
		return string.format("%dm %ds", minutes, secs)
	else
		return string.format("%ds", secs)
	end
end

-- Update leaderboard data when player leaves
Players.PlayerRemoving:Connect(function(player)
	task.wait(2) -- Wait for data to save

	pcall(function()
		local userId = "Player_" .. player.UserId
		local data = PlayerDataStore:GetAsync(userId)

		if data and data.totalTime then
			-- Update ordered data store
			LeaderboardStore:SetAsync(player.Name, data.totalTime)
		end
	end)
end)

-- Update leaderboard display
local function updateLeaderboard()
	-- Clear existing entries
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Get top entries
	local success, pages = pcall(function()
		return LeaderboardStore:GetSortedAsync(false, 50) -- Top 50
	end)

	if not success then
		warn("Failed to fetch leaderboard data")
		return
	end

	local entries = pages:GetCurrentPage()
	local yOffset = 0

	for rank, entry in ipairs(entries) do
		local entryFrame = Instance.new("Frame")
		entryFrame.Name = "Entry_" .. rank
		entryFrame.Size = UDim2.new(1, -10, 0, 40)
		entryFrame.Position = UDim2.new(0, 5, 0, yOffset)
		entryFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		entryFrame.BorderSizePixel = 0
		entryFrame.Parent = scrollFrame

		-- Rank
		local rankLabel = Instance.new("TextLabel")
		rankLabel.Name = "Rank"
		rankLabel.Size = UDim2.new(0, 60, 1, 0)
		rankLabel.Position = UDim2.new(0, 10, 0, 0)
		rankLabel.BackgroundTransparency = 1
		rankLabel.Text = "#" .. rank
		rankLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
		rankLabel.TextSize = 18
		rankLabel.Font = Enum.Font.Code
		rankLabel.TextXAlignment = Enum.TextXAlignment.Left
		rankLabel.Parent = entryFrame

		-- Username
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "Username"
		nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
		nameLabel.Position = UDim2.new(0, 80, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = entry.key
		nameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		nameLabel.TextSize = 18
		nameLabel.Font = Enum.Font.Code
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = entryFrame

		-- Time
		local timeLabel = Instance.new("TextLabel")
		timeLabel.Name = "Time"
		timeLabel.Size = UDim2.new(0.3, 0, 1, 0)
		timeLabel.Position = UDim2.new(0.7, 0, 0, 0)
		timeLabel.BackgroundTransparency = 1
		timeLabel.Text = formatTime(entry.value)
		timeLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
		timeLabel.TextSize = 16
		timeLabel.Font = Enum.Font.Code
		timeLabel.TextXAlignment = Enum.TextXAlignment.Right
		timeLabel.Parent = entryFrame

		yOffset = yOffset + 45
	end

	-- Update canvas size
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Initial update
task.wait(5)
updateLeaderboard()

-- Periodic updates (every 60 seconds)
while true do
	task.wait(60)
	updateLeaderboard()
end
