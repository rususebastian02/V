-- Infinite Loading Screen Game
-- A mind-blowing experience where you wait 20 minutes for... nothing!

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Configuration
local TOTAL_WAIT_TIME = 1200 -- 20 minutes in seconds
local MESSAGE_CHANGE_INTERVAL = 8 -- Change message every 8 seconds
local LOADING_BAR_SPEED = 0.05 -- Speed of loading bar progress (slower = more frustrating)

-- Random facts and messages
local randomMessages = {
	-- Did you know facts
	"Did you know? The black widow spider is one of the most venomous spiders in the world.",
	"Did you know? Honey never spoils. Archaeologists have found 3000-year-old honey in Egyptian tombs that's still edible.",
	"Did you know? A group of flamingos is called a 'flamboyance'.",
	"Did you know? Bananas are berries, but strawberries aren't.",
	"Did you know? Octopuses have three hearts and blue blood.",
	"Did you know? The shortest war in history lasted 38 minutes.",
	"Did you know? Cleopatra lived closer to the moon landing than to the construction of the Great Pyramid.",
	"Did you know? A day on Venus is longer than a year on Venus.",
	"Did you know? There are more stars in the universe than grains of sand on all Earth's beaches.",
	"Did you know? Sharks existed before trees.",

	-- Fun facts
	"Fun fact: Your brain uses 20% of your body's energy.",
	"Fun fact: Humans share 60% of their DNA with bananas.",
	"Fun fact: The Eiffel Tower can grow up to 6 inches during summer due to thermal expansion.",
	"Fun fact: Lightning strikes the Earth about 100 times every second.",
	"Fun fact: The human eye can distinguish about 10 million different colors.",
	"Fun fact: A sneeze travels at about 100 miles per hour.",
	"Fun fact: The average person walks the equivalent of three times around the world in a lifetime.",
	"Fun fact: Your nose can remember 50,000 different scents.",

	-- Loading messages
	"Loading awesomeness...",
	"Generating random numbers...",
	"Reticulating splines...",
	"Proving P = NP...",
	"Dividing by zero...",
	"Calculating the meaning of life...",
	"Asking the universe for permission...",
	"Waiting for something to happen...",
	"Pretending to load...",
	"Creating the illusion of progress...",
	"Compiling the code that was already compiled...",
	"Downloading more RAM...",
	"Counting backwards from infinity...",
	"Teaching robots to love...",
	"Negotiating with time itself...",

	-- Philosophical
	"What is time anyway?",
	"Patience is a virtue, they say...",
	"Good things come to those who wait.",
	"The journey is the destination.",
	"Time flies when you're having fun... or does it?",

	-- Encouraging messages
	"You're doing great! Keep waiting!",
	"Almost there! (Not really)",
	"Just a few more minutes... (Maybe)",
	"Your patience is admirable.",
	"Still loading... Still loading...",
	"This is definitely going somewhere.",
	"Trust the process.",
	"Hang in there!",
}

-- Create the main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InfiniteLoadingScreen"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 100
screenGui.IgnoreGuiInset = true -- Cover the entire screen including topbar
screenGui.Parent = playerGui

-- Disable player movement but keep chat enabled
local originalWalkSpeed = humanoid.WalkSpeed
local originalJumpPower = humanoid.JumpPower

humanoid.WalkSpeed = 0
humanoid.JumpPower = 0

-- Disable core GUI elements except chat
pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
end)

-- Function to re-enable controls (in case player dies during loading)
local function reEnableControls()
	if humanoid then
		humanoid.WalkSpeed = originalWalkSpeed
		humanoid.JumpPower = originalJumpPower
	end
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
	end)
end

-- Re-enable controls if player dies
humanoid.Died:Connect(function()
	reEnableControls()
end)

-- Main background frame (black)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.Position = UDim2.new(0, 0, 0, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Logo/Title
local logoLabel = Instance.new("TextLabel")
logoLabel.Name = "Logo"
logoLabel.Size = UDim2.new(0, 400, 0, 100)
logoLabel.Position = UDim2.new(0.5, -200, 0.25, 0)
logoLabel.BackgroundTransparency = 1
logoLabel.Font = Enum.Font.GothamBold
logoLabel.Text = "THE WAITING GAME"
logoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
logoLabel.TextSize = 48
logoLabel.TextScaled = true
logoLabel.Parent = mainFrame

-- Subtitle
local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Name = "Subtitle"
subtitleLabel.Size = UDim2.new(0, 400, 0, 30)
subtitleLabel.Position = UDim2.new(0.5, -200, 0.35, 0)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.Text = "Ultra Edition"
subtitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
subtitleLabel.TextSize = 20
subtitleLabel.Parent = mainFrame

-- Loading bar background
local loadingBarBg = Instance.new("Frame")
loadingBarBg.Name = "LoadingBarBackground"
loadingBarBg.Size = UDim2.new(0, 500, 0, 30)
loadingBarBg.Position = UDim2.new(0.5, -250, 0.55, 0)
loadingBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
loadingBarBg.BorderSizePixel = 2
loadingBarBg.BorderColor3 = Color3.fromRGB(100, 100, 100)
loadingBarBg.Parent = mainFrame

-- Loading bar fill
local loadingBarFill = Instance.new("Frame")
loadingBarFill.Name = "LoadingBarFill"
loadingBarFill.Size = UDim2.new(0, 0, 1, 0)
loadingBarFill.Position = UDim2.new(0, 0, 0, 0)
loadingBarFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
loadingBarFill.BorderSizePixel = 0
loadingBarFill.Parent = loadingBarBg

-- Gradient for loading bar
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 200))
}
gradient.Parent = loadingBarFill

-- Loading percentage text
local percentageLabel = Instance.new("TextLabel")
percentageLabel.Name = "Percentage"
percentageLabel.Size = UDim2.new(1, 0, 1, 0)
percentageLabel.Position = UDim2.new(0, 0, 0, 0)
percentageLabel.BackgroundTransparency = 1
percentageLabel.Font = Enum.Font.GothamBold
percentageLabel.Text = "0%"
percentageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
percentageLabel.TextSize = 18
percentageLabel.ZIndex = 2
percentageLabel.Parent = loadingBarBg

-- Random message label
local messageLabel = Instance.new("TextLabel")
messageLabel.Name = "MessageLabel"
messageLabel.Size = UDim2.new(0, 700, 0, 80)
messageLabel.Position = UDim2.new(0.5, -350, 0.7, 0)
messageLabel.BackgroundTransparency = 1
messageLabel.Font = Enum.Font.Gotham
messageLabel.Text = "Loading..."
messageLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
messageLabel.TextSize = 20
messageLabel.TextWrapped = true
messageLabel.Parent = mainFrame

-- Loading dots animation
local dotsLabel = Instance.new("TextLabel")
dotsLabel.Name = "DotsLabel"
dotsLabel.Size = UDim2.new(0, 100, 0, 30)
dotsLabel.Position = UDim2.new(0.5, -50, 0.8, 0)
dotsLabel.BackgroundTransparency = 1
dotsLabel.Font = Enum.Font.Gotham
dotsLabel.Text = ""
dotsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
dotsLabel.TextSize = 24
dotsLabel.Parent = mainFrame

-- Function to get random message
local function getRandomMessage()
	return randomMessages[math.random(1, #randomMessages)]
end

-- Function to animate loading dots
local dotCount = 0
task.spawn(function()
	while mainFrame.Visible do
		dotCount = (dotCount % 3) + 1
		dotsLabel.Text = string.rep(".", dotCount)
		task.wait(0.5)
	end
end)

-- Function to change random message
task.spawn(function()
	while mainFrame.Visible do
		messageLabel.Text = getRandomMessage()

		-- Fade in animation
		messageLabel.TextTransparency = 1
		local fadeIn = TweenService:Create(messageLabel, TweenInfo.new(0.5), {TextTransparency = 0})
		fadeIn:Play()

		task.wait(MESSAGE_CHANGE_INTERVAL)
	end
end)

-- Function to update loading bar
local currentProgress = 0
task.spawn(function()
	while currentProgress < 100 do
		-- Progress increases very slowly
		currentProgress = currentProgress + LOADING_BAR_SPEED

		-- But never quite reaches 100% until the timer is done
		if currentProgress >= 99.5 and os.clock() < TOTAL_WAIT_TIME then
			currentProgress = 99.5
		end

		-- Update the bar
		local targetSize = UDim2.new(currentProgress / 100, 0, 1, 0)
		local tween = TweenService:Create(loadingBarFill, TweenInfo.new(0.1), {Size = targetSize})
		tween:Play()

		-- Update percentage text
		percentageLabel.Text = string.format("%.1f%%", currentProgress)

		task.wait(0.1)
	end
end)

-- Main timer: Wait for 20 minutes
task.spawn(function()
	local startTime = os.clock()

	-- Wait for exactly 20 minutes
	while os.clock() - startTime < TOTAL_WAIT_TIME do
		task.wait(1)
	end

	-- Complete the loading bar
	currentProgress = 100
	loadingBarFill.Size = UDim2.new(1, 0, 1, 0)
	percentageLabel.Text = "100%"

	task.wait(1)

	-- Fade out the loading screen
	local fadeOut = TweenService:Create(mainFrame, TweenInfo.new(1), {BackgroundTransparency = 1})
	fadeOut:Play()

	for _, child in ipairs(mainFrame:GetChildren()) do
		if child:IsA("TextLabel") or child:IsA("Frame") then
			if child:IsA("TextLabel") then
				TweenService:Create(child, TweenInfo.new(1), {TextTransparency = 1}):Play()
			end
			if child.Name == "LoadingBarBackground" then
				TweenService:Create(child, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
				for _, barChild in ipairs(child:GetChildren()) do
					if barChild:IsA("TextLabel") then
						TweenService:Create(barChild, TweenInfo.new(1), {TextTransparency = 1}):Play()
					elseif barChild:IsA("Frame") then
						TweenService:Create(barChild, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
					end
				end
			end
		end
	end

	task.wait(1.5)
	mainFrame.Visible = false

	-- Re-enable player controls
	reEnableControls()

	-- Show the congratulations screen
	showCongratulationsScreen()
end)

-- Function to show congratulations screen
function showCongratulationsScreen()
	-- Create congratulations frame
	local congratsFrame = Instance.new("Frame")
	congratsFrame.Name = "CongratulationsFrame"
	congratsFrame.Size = UDim2.new(1, 0, 1, 0)
	congratsFrame.Position = UDim2.new(0, 0, 0, 0)
	congratsFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	congratsFrame.BorderSizePixel = 0
	congratsFrame.BackgroundTransparency = 1
	congratsFrame.Parent = screenGui

	-- Fade in background
	local fadeInBg = TweenService:Create(congratsFrame, TweenInfo.new(1), {BackgroundTransparency = 0})
	fadeInBg:Play()

	task.wait(1)

	-- Congratulations text
	local congratsText = Instance.new("TextLabel")
	congratsText.Name = "CongratsText"
	congratsText.Size = UDim2.new(0, 800, 0, 150)
	congratsText.Position = UDim2.new(0.5, -400, 0.4, 0)
	congratsText.BackgroundTransparency = 1
	congratsText.Font = Enum.Font.GothamBold
	congratsText.Text = "CONGRATULATIONS!"
	congratsText.TextColor3 = Color3.fromRGB(255, 215, 0)
	congratsText.TextSize = 64
	congratsText.TextScaled = true
	congratsText.TextTransparency = 1
	congratsText.Parent = congratsFrame

	-- Message text
	local messageText = Instance.new("TextLabel")
	messageText.Name = "MessageText"
	messageText.Size = UDim2.new(0, 700, 0, 100)
	messageText.Position = UDim2.new(0.5, -350, 0.55, 0)
	messageText.BackgroundTransparency = 1
	messageText.Font = Enum.Font.Gotham
	messageText.Text = "You just wasted 20 minutes of your life!"
	messageText.TextColor3 = Color3.fromRGB(255, 255, 255)
	messageText.TextSize = 32
	messageText.TextWrapped = true
	messageText.TextTransparency = 1
	messageText.Parent = congratsFrame

	-- Subtext
	local subText = Instance.new("TextLabel")
	subText.Name = "SubText"
	subText.Size = UDim2.new(0, 600, 0, 50)
	subText.Position = UDim2.new(0.5, -300, 0.68, 0)
	subText.BackgroundTransparency = 1
	subText.Font = Enum.Font.GothamItalic
	subText.Text = "Hope it was worth it!"
	subText.TextColor3 = Color3.fromRGB(180, 180, 180)
	subText.TextSize = 24
	subText.TextTransparency = 1
	subText.Parent = congratsFrame

	-- Fade in texts with delays
	task.wait(0.5)
	TweenService:Create(congratsText, TweenInfo.new(1), {TextTransparency = 0}):Play()

	task.wait(1)
	TweenService:Create(messageText, TweenInfo.new(1), {TextTransparency = 0}):Play()

	task.wait(1)
	TweenService:Create(subText, TweenInfo.new(1), {TextTransparency = 0}):Play()

	-- Add sparkle effect
	for i = 1, 20 do
		task.spawn(function()
			local sparkle = Instance.new("Frame")
			sparkle.Size = UDim2.new(0, 4, 0, 4)
			sparkle.Position = UDim2.new(math.random(), 0, math.random(), 0)
			sparkle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			sparkle.BorderSizePixel = 0
			sparkle.Parent = congratsFrame

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(1, 0)
			corner.Parent = sparkle

			task.wait(math.random() * 2)

			while true do
				sparkle.BackgroundTransparency = 0
				TweenService:Create(sparkle, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
				task.wait(2 + math.random() * 2)
			end
		end)
	end
end
