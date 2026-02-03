--[[
    LIFE TEXT RPG - UI Testuale
    Interfaccia utente per il gioco.

    L'UI cambia in base alla fazione:
    - Celeste: UI fredda, luce, blu
    - Cremisi: UI calda, rossa, distorta
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local TextUI = {}
TextUI.__index = TextUI

-- Colori per fazione
TextUI.Colors = {
    Celeste = {
        background = Color3.fromRGB(15, 25, 45),
        text = Color3.fromRGB(200, 220, 255),
        accent = Color3.fromRGB(100, 150, 255),
        highlight = Color3.fromRGB(150, 200, 255),
        border = Color3.fromRGB(60, 100, 180),
    },
    Cremisi = {
        background = Color3.fromRGB(45, 15, 15),
        text = Color3.fromRGB(255, 200, 180),
        accent = Color3.fromRGB(255, 80, 60),
        highlight = Color3.fromRGB(255, 120, 100),
        border = Color3.fromRGB(180, 60, 60),
    },
    Neutrale = {
        background = Color3.fromRGB(30, 30, 35),
        text = Color3.fromRGB(220, 220, 220),
        accent = Color3.fromRGB(150, 150, 160),
        highlight = Color3.fromRGB(180, 180, 190),
        border = Color3.fromRGB(80, 80, 90),
    }
}

-- Font settings
TextUI.Fonts = {
    title = Enum.Font.Antique,
    body = Enum.Font.Garamond,
    choice = Enum.Font.SourceSans,
}

-- Crea una nuova istanza UI
function TextUI.new(player)
    local self = setmetatable({}, TextUI)

    self.player = player
    self.currentFaction = "Neutrale"
    self.screenGui = nil
    self.mainFrame = nil
    self.textLabel = nil
    self.choicesFrame = nil
    self.statsFrame = nil

    self:Initialize()

    return self
end

-- Inizializza l'UI
function TextUI:Initialize()
    local playerGui = self.player:WaitForChild("PlayerGui")

    -- Screen GUI principale
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "LifeTextRPG"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.Parent = playerGui

    -- Frame principale
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.Size = UDim2.new(0.7, 0, 0.8, 0)
    self.mainFrame.Position = UDim2.new(0.15, 0, 0.1, 0)
    self.mainFrame.BackgroundTransparency = 0.1
    self.mainFrame.BorderSizePixel = 3
    self.mainFrame.Parent = self.screenGui

    -- Corner arrotondati
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = self.mainFrame

    -- Header con titolo e stats
    self:CreateHeader()

    -- Area testo principale
    self:CreateTextArea()

    -- Area scelte
    self:CreateChoicesArea()

    -- Applica tema iniziale
    self:ApplyTheme("Neutrale")
end

-- Crea l'header
function TextUI:CreateHeader()
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 60)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundTransparency = 0.5
    header.BorderSizePixel = 0
    header.Parent = self.mainFrame

    -- Titolo del gioco
    local title = Instance.new("TextLabel")
    title.Name = "GameTitle"
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "LIFE"
    title.Font = TextUI.Fonts.title
    title.TextSize = 36
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    -- Stats frame (reputazione, titolo)
    self.statsFrame = Instance.new("Frame")
    self.statsFrame.Name = "Stats"
    self.statsFrame.Size = UDim2.new(0.45, 0, 1, 0)
    self.statsFrame.Position = UDim2.new(0.55, 0, 0, 0)
    self.statsFrame.BackgroundTransparency = 1
    self.statsFrame.Parent = header

    -- Label reputazione
    self.reputationLabel = Instance.new("TextLabel")
    self.reputationLabel.Name = "Reputation"
    self.reputationLabel.Size = UDim2.new(1, 0, 0.5, 0)
    self.reputationLabel.BackgroundTransparency = 1
    self.reputationLabel.Text = "Reputazione: 0"
    self.reputationLabel.Font = TextUI.Fonts.body
    self.reputationLabel.TextSize = 18
    self.reputationLabel.TextXAlignment = Enum.TextXAlignment.Right
    self.reputationLabel.Parent = self.statsFrame

    -- Label titolo
    self.titleLabel = Instance.new("TextLabel")
    self.titleLabel.Name = "PlayerTitle"
    self.titleLabel.Size = UDim2.new(1, 0, 0.5, 0)
    self.titleLabel.Position = UDim2.new(0, 0, 0.5, 0)
    self.titleLabel.BackgroundTransparency = 1
    self.titleLabel.Text = "Sconosciuto"
    self.titleLabel.Font = TextUI.Fonts.body
    self.titleLabel.TextSize = 16
    self.titleLabel.TextXAlignment = Enum.TextXAlignment.Right
    self.titleLabel.Parent = self.statsFrame
end

-- Crea l'area testo
function TextUI:CreateTextArea()
    local textFrame = Instance.new("ScrollingFrame")
    textFrame.Name = "TextArea"
    textFrame.Size = UDim2.new(1, -40, 0.55, 0)
    textFrame.Position = UDim2.new(0, 20, 0, 80)
    textFrame.BackgroundTransparency = 1
    textFrame.BorderSizePixel = 0
    textFrame.ScrollBarThickness = 6
    textFrame.Parent = self.mainFrame

    -- Titolo evento
    self.eventTitle = Instance.new("TextLabel")
    self.eventTitle.Name = "EventTitle"
    self.eventTitle.Size = UDim2.new(1, 0, 0, 40)
    self.eventTitle.BackgroundTransparency = 1
    self.eventTitle.Text = ""
    self.eventTitle.Font = TextUI.Fonts.title
    self.eventTitle.TextSize = 28
    self.eventTitle.TextWrapped = true
    self.eventTitle.TextYAlignment = Enum.TextYAlignment.Top
    self.eventTitle.Parent = textFrame

    -- Testo principale
    self.textLabel = Instance.new("TextLabel")
    self.textLabel.Name = "MainText"
    self.textLabel.Size = UDim2.new(1, 0, 0, 0) -- Auto-size
    self.textLabel.Position = UDim2.new(0, 0, 0, 50)
    self.textLabel.BackgroundTransparency = 1
    self.textLabel.Text = ""
    self.textLabel.Font = TextUI.Fonts.body
    self.textLabel.TextSize = 20
    self.textLabel.TextWrapped = true
    self.textLabel.TextYAlignment = Enum.TextYAlignment.Top
    self.textLabel.AutomaticSize = Enum.AutomaticSize.Y
    self.textLabel.Parent = textFrame
end

-- Crea l'area scelte
function TextUI:CreateChoicesArea()
    self.choicesFrame = Instance.new("Frame")
    self.choicesFrame.Name = "ChoicesArea"
    self.choicesFrame.Size = UDim2.new(1, -40, 0.3, 0)
    self.choicesFrame.Position = UDim2.new(0, 20, 0.65, 0)
    self.choicesFrame.BackgroundTransparency = 1
    self.choicesFrame.Parent = self.mainFrame

    -- Layout per le scelte
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = self.choicesFrame
end

-- Applica tema basato sulla fazione
function TextUI:ApplyTheme(faction)
    self.currentFaction = faction
    local colors = TextUI.Colors[faction]

    -- Transizione animata
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    -- Colori main frame
    TweenService:Create(self.mainFrame, tweenInfo, {
        BackgroundColor3 = colors.background,
        BorderColor3 = colors.border
    }):Play()

    -- Colori testo
    local textElements = {
        self.eventTitle,
        self.textLabel,
        self.reputationLabel,
        self.titleLabel
    }

    for _, element in ipairs(textElements) do
        if element then
            TweenService:Create(element, tweenInfo, {
                TextColor3 = colors.text
            }):Play()
        end
    end

    -- Titolo gioco con colore accent
    local gameTitle = self.mainFrame:FindFirstChild("Header"):FindFirstChild("GameTitle")
    if gameTitle then
        TweenService:Create(gameTitle, tweenInfo, {
            TextColor3 = colors.accent
        }):Play()
    end

    -- Effetto distorsione per Cremisi
    if faction == "Cremisi" then
        self:ApplyCremisiEffect()
    else
        self:RemoveCremisiEffect()
    end
end

-- Effetto visivo Cremisi (distorsione leggera)
function TextUI:ApplyCremisiEffect()
    -- Aggiungi un leggero effetto di "calore"
    if not self.mainFrame:FindFirstChild("CremisiGlow") then
        local glow = Instance.new("ImageLabel")
        glow.Name = "CremisiGlow"
        glow.Size = UDim2.new(1.1, 0, 1.1, 0)
        glow.Position = UDim2.new(-0.05, 0, -0.05, 0)
        glow.BackgroundTransparency = 1
        glow.Image = "rbxassetid://0" -- Placeholder per effetto glow rosso
        glow.ImageColor3 = Color3.fromRGB(255, 50, 30)
        glow.ImageTransparency = 0.9
        glow.ZIndex = -1
        glow.Parent = self.mainFrame
    end
end

function TextUI:RemoveCremisiEffect()
    local glow = self.mainFrame:FindFirstChild("CremisiGlow")
    if glow then
        glow:Destroy()
    end
end

-- Mostra un evento
function TextUI:ShowEvent(event, playerData)
    -- Aggiorna titolo e testo
    self.eventTitle.Text = event.title or ""

    -- Effetto typewriter per il testo
    self:TypewriterEffect(self.textLabel, event.context)

    -- Mostra le scelte
    self:ShowChoices(event.choices, playerData)
end

-- Effetto typewriter
function TextUI:TypewriterEffect(label, text, speed)
    speed = speed or 0.02
    label.Text = ""

    coroutine.wrap(function()
        for i = 1, #text do
            label.Text = string.sub(text, 1, i)
            wait(speed)
        end
    end)()
end

-- Mostra le scelte
function TextUI:ShowChoices(choices, playerData)
    -- Pulisci scelte precedenti
    for _, child in ipairs(self.choicesFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local colors = TextUI.Colors[self.currentFaction]

    -- Crea bottoni per ogni scelta
    for i, choice in ipairs(choices) do
        local button = Instance.new("TextButton")
        button.Name = "Choice_" .. choice.id
        button.Size = UDim2.new(1, 0, 0, 45)
        button.BackgroundColor3 = colors.background
        button.BackgroundTransparency = 0.3
        button.BorderColor3 = colors.border
        button.BorderSizePixel = 2
        button.Text = i .. ". " .. choice.text
        button.Font = TextUI.Fonts.choice
        button.TextSize = 16
        button.TextColor3 = colors.text
        button.TextWrapped = true
        button.LayoutOrder = i
        button.Parent = self.choicesFrame

        -- Corner arrotondati
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = button

        -- Hover effect
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = colors.highlight,
                TextColor3 = colors.background
            }):Play()
        end)

        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = colors.background,
                TextColor3 = colors.text
            }):Play()
        end)

        -- Click handler
        button.MouseButton1Click:Connect(function()
            self:OnChoiceSelected(choice)
        end)
    end
end

-- Handler per selezione scelta
function TextUI:OnChoiceSelected(choice)
    -- Questo evento verrà connesso al server
    if self.OnChoiceCallback then
        self.OnChoiceCallback(choice)
    end
end

-- Mostra la conseguenza di una scelta
function TextUI:ShowConsequence(result)
    -- Nascondi scelte
    for _, child in ipairs(self.choicesFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child.Visible = false
        end
    end

    -- Mostra testo conseguenza
    local consequenceText = "\n\n" .. result.consequence

    -- Aggiungi info reputazione
    local repChange = result.reputationChange
    local repSymbol = repChange >= 0 and "+" or ""
    consequenceText = consequenceText .. "\n\n[Reputazione: " .. repSymbol .. repChange .. "]"

    -- Bonus coerenza
    if result.coherenceBonus then
        consequenceText = consequenceText .. "\n(" .. result.coherenceBonus.name .. ": +" .. result.coherenceBonus.bonusAmount .. " bonus)"
    end

    -- Nuovo titolo
    if result.newTitle then
        consequenceText = consequenceText .. "\n\n*** Nuovo Titolo: " .. result.newTitle.title .. " ***"
        consequenceText = consequenceText .. "\n" .. result.newTitle.description
    end

    self:TypewriterEffect(self.textLabel, self.textLabel.Text .. consequenceText)

    -- Mostra pulsante continua
    wait(2)
    self:ShowContinueButton()
end

-- Mostra pulsante continua
function TextUI:ShowContinueButton()
    local colors = TextUI.Colors[self.currentFaction]

    local continueBtn = Instance.new("TextButton")
    continueBtn.Name = "ContinueButton"
    continueBtn.Size = UDim2.new(0.4, 0, 0, 50)
    continueBtn.Position = UDim2.new(0.3, 0, 0, 0)
    continueBtn.BackgroundColor3 = colors.accent
    continueBtn.Text = "Continua..."
    continueBtn.Font = TextUI.Fonts.choice
    continueBtn.TextSize = 20
    continueBtn.TextColor3 = colors.background
    continueBtn.Parent = self.choicesFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = continueBtn

    continueBtn.MouseButton1Click:Connect(function()
        continueBtn:Destroy()
        if self.OnContinueCallback then
            self.OnContinueCallback()
        end
    end)
end

-- Aggiorna display stats
function TextUI:UpdateStats(playerData)
    -- Reputazione con colore
    local rep = playerData.reputation
    local repText = "Reputazione: " .. (rep >= 0 and "+" or "") .. rep
    self.reputationLabel.Text = repText

    -- Titolo
    local title = playerData.currentTitle or "Sconosciuto"
    self.titleLabel.Text = title

    -- Aggiorna tema se la fazione è cambiata
    local ReputationSystem = require(game.ReplicatedStorage.Shared.ReputationSystem)
    local faction = ReputationSystem.GetFaction(rep)
    if faction ~= self.currentFaction then
        self:ApplyTheme(faction)
    end
end

-- Mostra messaggio di sistema
function TextUI:ShowSystemMessage(message, duration)
    duration = duration or 3

    local msgLabel = Instance.new("TextLabel")
    msgLabel.Name = "SystemMessage"
    msgLabel.Size = UDim2.new(0.6, 0, 0, 50)
    msgLabel.Position = UDim2.new(0.2, 0, 0.02, 0)
    msgLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    msgLabel.BackgroundTransparency = 0.3
    msgLabel.Text = message
    msgLabel.Font = TextUI.Fonts.body
    msgLabel.TextSize = 18
    msgLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    msgLabel.Parent = self.screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = msgLabel

    -- Fade out e rimuovi
    wait(duration)
    TweenService:Create(msgLabel, TweenInfo.new(0.5), {
        BackgroundTransparency = 1,
        TextTransparency = 1
    }):Play()
    wait(0.5)
    msgLabel:Destroy()
end

-- Distruggi UI
function TextUI:Destroy()
    if self.screenGui then
        self.screenGui:Destroy()
    end
end

return TextUI
