--[[
	MINIMALIST GAME ROOM - Leaderboard Script

	"People Who Stayed"
	Shows usernames and total time wasted.
	No rewards. Just exposure.

	Place this script inside a Part in the workspace.
	The part should have a SurfaceGui.
]]

local DataStoreService = game:GetService("DataStoreService")

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

-- Status message (for debugging/empty state)
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 0.5, 0)
statusLabel.Position = UDim2.new(0, 0, 0.25, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Loading..."
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statusLabel.TextSize = 18
statusLabel.Font = Enum.Font.Code
statusLabel.TextWrapped = true
statusLabel.Visible = true
statusLabel.Parent = mainFrame

-- Scrolling frame for entries
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(0.9, 0, 0.7, 0)
scrollFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
scrollFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Visible = false
scrollFrame.Parent = mainFrame

-- UIListLayout for automatic positioning
local listLayout = Instance.new("UIListLayout")
listLayout.Name = "ListLayout"
listLayout.Padding = UDim.new(0, 5)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

-- Auto-update canvas size
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

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

-- Update leaderboard display
local function updateLeaderboard()
	print("[Leaderboard] Updating display...")

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
		statusLabel.Text = "DataStore not available.\n(Works only in published games)"
		statusLabel.Visible = true
		scrollFrame.Visible = false
		warn("[Leaderboard] Failed to fetch data - DataStore not available")
		return
	end

	local entries = pages:GetCurrentPage()

	if #entries == 0 then
		statusLabel.Text = "No data yet.\nWait for players to leave the game."
		statusLabel.Visible = true
		scrollFrame.Visible = false
		print("[Leaderboard] No entries found")
		return
	end

	-- Hide status, show leaderboard
	statusLabel.Visible = false
	scrollFrame.Visible = true

	print("[Leaderboard] Found", #entries, "entries")

	-- Create entries
	for rank, entry in ipairs(entries) do
		local entryFrame = Instance.new("Frame")
		entryFrame.Name = "Entry_" .. rank
		entryFrame.Size = UDim2.new(1, 0, 0, 50)
		entryFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		entryFrame.BorderSizePixel = 0
		entryFrame.LayoutOrder = rank
		entryFrame.Parent = scrollFrame

		-- Rank
		local rankLabel = Instance.new("TextLabel")
		rankLabel.Name = "Rank"
		rankLabel.Size = UDim2.new(0, 40, 1, 0)
		rankLabel.Position = UDim2.new(0, 5, 0, 0)
		rankLabel.BackgroundTransparency = 1
		rankLabel.Text = "#" .. rank
		rankLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
		rankLabel.TextSize = 16
		rankLabel.Font = Enum.Font.Code
		rankLabel.TextXAlignment = Enum.TextXAlignment.Left
		rankLabel.Parent = entryFrame

		-- Avatar (circular)
		local avatarFrame = Instance.new("ImageLabel")
		avatarFrame.Name = "Avatar"
		avatarFrame.Size = UDim2.new(0, 35, 0, 35)
		avatarFrame.Position = UDim2.new(0, 50, 0.5, -17.5)
		avatarFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		avatarFrame.BorderSizePixel = 0
		avatarFrame.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
		avatarFrame.Parent = entryFrame

		-- Make avatar circular
		local avatarCorner = Instance.new("UICorner")
		avatarCorner.CornerRadius = UDim.new(1, 0)
		avatarCorner.Parent = avatarFrame

		-- Load avatar asynchronously
		task.spawn(function()
			local success, userId = pcall(function()
				return game:GetService("Players"):GetUserIdFromNameAsync(entry.key)
			end)

			if success and userId then
				avatarFrame.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=150&height=150&format=png"
			end
		end)

		-- Username
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "Username"
		nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
		nameLabel.Position = UDim2.new(0, 95, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = entry.key
		nameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		nameLabel.TextSize = 16
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
	end

	print("[Leaderboard] Display updated with", #entries, "entries")
end

-- Initial update
print("[Leaderboard] Script loaded, waiting 5 seconds before first update...")
task.wait(5)
updateLeaderboard()

-- Periodic updates (every 60 seconds)
while true do
	task.wait(60)
	updateLeaderboard()
end
