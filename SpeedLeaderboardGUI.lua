-- Script LocalScript per visualizzare la Top 100 Speed su un tabellone
-- Da inserire dentro un SurfaceGui su un Part (il tuo tabellone)

local UPDATE_INTERVAL = 30 -- Aggiorna la visualizzazione ogni 30 secondi

print("🏆 [SpeedBoard] Inizializzazione tabellone Speed...")

-- Riferimento al SurfaceGui (il parent di questo script deve essere un SurfaceGui)
local surfaceGui = script.Parent
local scrollingFrame = surfaceGui:FindFirstChild("ScrollingFrame")

if not scrollingFrame then
	warn("⚠️ [SpeedBoard] ScrollingFrame non trovato! Creane uno nel SurfaceGui")
	return
end

-- Funzione per formattare i numeri con separatori
local function formatNumber(num)
	return tostring(math.floor(num)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

-- Funzione per convertire secondi in formato tempo
local function formatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

-- Funzione per aggiornare la leaderboard
local function updateLeaderboard()
	print("🔄 [SpeedBoard] Aggiornamento tabellone Speed...")

	-- Pulisci i vecchi elementi
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if child:IsA("Frame") or child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	-- Ottieni i top 100 giocatori tramite la funzione globale
	if not _G.GetTop100Speed then
		warn("⚠️ [SpeedBoard] Funzione _G.GetTop100Speed non trovata! Assicurati che GlobalLeaderboardScript sia attivo")
		return
	end

	local topPlayers = _G.GetTop100Speed()

	if #topPlayers == 0 then
		-- Nessun dato disponibile
		local noDataLabel = Instance.new("TextLabel")
		noDataLabel.Size = UDim2.new(1, 0, 0, 50)
		noDataLabel.BackgroundTransparency = 1
		noDataLabel.Text = "No data available yet..."
		noDataLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		noDataLabel.TextSize = 24
		noDataLabel.Font = Enum.Font.GothamBold
		noDataLabel.Parent = scrollingFrame
		return
	end

	-- Crea le righe per ogni giocatore
	for i, playerData in ipairs(topPlayers) do
		local yPosition = (i - 1) * 40 -- Altezza di ogni riga

		-- Frame per la riga
		local rowFrame = Instance.new("Frame")
		rowFrame.Name = "Row" .. i
		rowFrame.Size = UDim2.new(1, -10, 0, 35)
		rowFrame.Position = UDim2.new(0, 5, 0, yPosition)
		rowFrame.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(40, 40, 45) or Color3.fromRGB(30, 30, 35)
		rowFrame.BorderSizePixel = 0
		rowFrame.Parent = scrollingFrame

		-- Arrotonda angoli
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 5)
		corner.Parent = rowFrame

		-- Rank (#1, #2, etc.)
		local rankLabel = Instance.new("TextLabel")
		rankLabel.Size = UDim2.new(0, 60, 1, 0)
		rankLabel.Position = UDim2.new(0, 5, 0, 0)
		rankLabel.BackgroundTransparency = 1
		rankLabel.Text = "#" .. playerData.Rank
		rankLabel.TextColor3 = playerData.Rank <= 3 and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(200, 200, 200)
		rankLabel.TextSize = 18
		rankLabel.Font = Enum.Font.GothamBold
		rankLabel.TextXAlignment = Enum.TextXAlignment.Left
		rankLabel.Parent = rowFrame

		-- Username
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.5, -70, 1, 0)
		nameLabel.Position = UDim2.new(0, 70, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = playerData.Username
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextSize = 16
		nameLabel.Font = Enum.Font.Gotham
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
		nameLabel.Parent = rowFrame

		-- Speed
		local speedLabel = Instance.new("TextLabel")
		speedLabel.Size = UDim2.new(0.3, 0, 1, 0)
		speedLabel.Position = UDim2.new(0.7, 0, 0, 0)
		speedLabel.BackgroundTransparency = 1
		speedLabel.Text = "⚡ " .. formatNumber(playerData.Speed)
		speedLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
		speedLabel.TextSize = 16
		speedLabel.Font = Enum.Font.GothamBold
		speedLabel.TextXAlignment = Enum.TextXAlignment.Right
		speedLabel.Parent = rowFrame

		-- Effetto speciale per i primi 3
		if playerData.Rank <= 3 then
			rowFrame.BackgroundColor3 = Color3.fromRGB(60, 50, 30) -- Sfondo dorato
		end
	end

	-- Aggiorna la dimensione del contenuto dello ScrollingFrame
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #topPlayers * 40)

	print("✅ [SpeedBoard] Tabellone aggiornato con " .. #topPlayers .. " giocatori")
end

-- Aggiorna periodicamente
spawn(function()
	while true do
		updateLeaderboard()
		wait(UPDATE_INTERVAL)
	end
end)

-- Prima visualizzazione dopo 5 secondi
wait(5)
updateLeaderboard()

print("🏆 [SpeedBoard] Tabellone Speed attivo!")
