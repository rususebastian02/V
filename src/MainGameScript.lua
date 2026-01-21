--[[
	MINIMALIST GAME ROOM - Main Game Script

	Core Concept: The game doesn't give you objectives.
	It just watches you choose to stay.

	Place this script in ServerScriptService
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- DataStore
local PlayerDataStore = DataStoreService:GetDataStore("PlayerSessionData_v1")
local LeaderboardStore = DataStoreService:GetOrderedDataStore("GlobalLeaderboard_v1")

-- Remote Events (create these in ReplicatedStorage)
local UpdateTimerEvent = Instance.new("RemoteEvent")
UpdateTimerEvent.Name = "UpdateTimer"
UpdateTimerEvent.Parent = ReplicatedStorage

local ShowMessageEvent = Instance.new("RemoteEvent")
ShowMessageEvent.Name = "ShowMessage"
ShowMessageEvent.Parent = ReplicatedStorage

local ReturnVisitEvent = Instance.new("RemoteEvent")
ReturnVisitEvent.Name = "ReturnVisit"
ReturnVisitEvent.Parent = ReplicatedStorage

local FakeDisconnectEvent = Instance.new("RemoteEvent")
FakeDisconnectEvent.Name = "FakeDisconnect"
FakeDisconnectEvent.Parent = ReplicatedStorage

-- Player session tracking
local ActiveSessions = {}

-- Save player data
local function SavePlayerData(player, timeSpent)
	local totalTime = 0
	local success, errorMessage = pcall(function()
		local userId = "Player_" .. player.UserId
		local data = PlayerDataStore:GetAsync(userId) or {
			totalTime = 0,
			sessions = 0,
			lastVisit = 0
		}

		data.totalTime = data.totalTime + timeSpent
		data.sessions = data.sessions + 1
		data.lastVisit = os.time()

		totalTime = data.totalTime

		PlayerDataStore:SetAsync(userId, data)
	end)

	if not success then
		warn("Failed to save data for " .. player.Name .. ": " .. errorMessage)
	end

	return success, totalTime
end

-- Load player data
local function LoadPlayerData(player)
	local success, data = pcall(function()
		local userId = "Player_" .. player.UserId
		return PlayerDataStore:GetAsync(userId)
	end)

	if success and data then
		return data
	else
		return {
			totalTime = 0,
			sessions = 0,
			lastVisit = 0,
			previousSessionTime = 0
		}
	end
end

-- Fake multiplayer disconnect messages
local function SendFakeDisconnects(player)
	local fakeNames = {
		"Player", "User", "Guest", "Someone", "Anonymous"
	}

	-- Random intervals between 45-180 seconds
	task.spawn(function()
		while ActiveSessions[player.UserId] do
			local waitTime = math.random(45, 180)
			task.wait(waitTime)

			if ActiveSessions[player.UserId] then
				local fakeName = fakeNames[math.random(1, #fakeNames)]
				FakeDisconnectEvent:FireClient(player, fakeName .. " left.")
			end
		end
	end)

	-- Another pattern: "Another player disconnected"
	task.spawn(function()
		while ActiveSessions[player.UserId] do
			local waitTime = math.random(60, 200)
			task.wait(waitTime)

			if ActiveSessions[player.UserId] then
				FakeDisconnectEvent:FireClient(player, "Another player disconnected.")
			end
		end
	end)
end

-- Message timeline system
local function StartMessageTimeline(player)
	local sessionData = ActiveSessions[player.UserId]
	if not sessionData then return end

	-- Check if player has "Silence" gamepass (ID: 1676198849)
	local hasSilence = false
	local success, result = pcall(function()
		return game:GetService("MarketplaceService"):UserOwnsGamePassAsync(player.UserId, 1676198849)
	end)
	if success then
		hasSilence = result
	end

	if hasSilence then
		-- Player has Silence gamepass, no messages
		return
	end

	local messages = {
		{time = 30, text = "Most people would have left by now."},
		{time = 120, text = "Nothing is happening because you're waiting."},
		{time = 300, text = "You didn't miss anything."},
		{time = 600, text = "Staying won't make this better."},
		{time = 900, text = "You can leave whenever you want.", showLeaveButton = true},
		{time = 1200, text = "Why didn't you?"},
		{time = 1800, text = "We know how long you stayed.", finalMessage = true}
	}

	task.spawn(function()
		for _, message in ipairs(messages) do
			while ActiveSessions[player.UserId] and
				  ActiveSessions[player.UserId].timeInRoom < message.time do
				task.wait(1)
			end

			if ActiveSessions[player.UserId] then
				ShowMessageEvent:FireClient(player, message.text, message.showLeaveButton, message.finalMessage)
			else
				break
			end
		end
	end)
end

-- Player joined
Players.PlayerAdded:Connect(function(player)
	-- Load previous data
	local playerData = LoadPlayerData(player)

	-- Initialize session
	ActiveSessions[player.UserId] = {
		joinTime = os.time(),
		timeInRoom = 0,
		previousData = playerData
	}

	-- If returning player, send special message
	if playerData.sessions > 0 then
		task.wait(0.5)
		ReturnVisitEvent:FireClient(player, playerData.previousSessionTime or 0)
	end

	-- Start timer update loop
	task.spawn(function()
		while ActiveSessions[player.UserId] do
			task.wait(1)
			if ActiveSessions[player.UserId] then
				ActiveSessions[player.UserId].timeInRoom = ActiveSessions[player.UserId].timeInRoom + 1
				UpdateTimerEvent:FireClient(player, ActiveSessions[player.UserId].timeInRoom)
			end
		end
	end)

	-- Start message timeline
	task.wait(1)
	StartMessageTimeline(player)

	-- Start fake disconnect messages
	task.wait(2)
	SendFakeDisconnects(player)
end)

-- Player leaving
Players.PlayerRemoving:Connect(function(player)
	if ActiveSessions[player.UserId] then
		local timeSpent = ActiveSessions[player.UserId].timeInRoom

		-- Update previous session time for next visit
		local data = LoadPlayerData(player)
		data.previousSessionTime = timeSpent

		-- Save data and get total time
		local saveSuccess, totalTime = SavePlayerData(player, timeSpent)

		-- Update leaderboard (OrderedDataStore)
		if saveSuccess and totalTime > 0 then
			task.spawn(function()
				local success, errorMsg = pcall(function()
					LeaderboardStore:SetAsync(player.Name, totalTime)
					print("[Leaderboard] Updated:", player.Name, "with", totalTime, "seconds")
				end)

				if not success then
					warn("[Leaderboard] Failed to update:", errorMsg)
				end
			end)
		else
			print("[Leaderboard] Skipped update for", player.Name, "- save failed or totalTime is 0")
		end

		-- Clean up
		ActiveSessions[player.UserId] = nil
	end
end)

-- Get player data (for leaderboard)
local GetPlayerDataFunction = Instance.new("RemoteFunction")
GetPlayerDataFunction.Name = "GetPlayerData"
GetPlayerDataFunction.Parent = ReplicatedStorage

GetPlayerDataFunction.OnServerInvoke = function(player)
	local data = LoadPlayerData(player)
	return data
end

print("Minimalist Game Room - Main Script Loaded")
