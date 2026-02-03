--[[
    LIFE TEXT RPG - UI Testuale Minimal
    Design pulito ed elegante che cambia con la fazione.

    Celeste: Toni freddi, blu, minimal, luce
    Cremisi: Toni caldi, rosso, distorsione sottile
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local TextUI = {}
TextUI.__index = TextUI

-- ═══════════════════════════════════════════
-- PALETTE COLORI
-- ═══════════════════════════════════════════

TextUI.Themes = {
    Neutrale = {
        bg = Color3.fromRGB(12, 12, 14),
        bgSecondary = Color3.fromRGB(18, 18, 22),
        text = Color3.fromRGB(200, 200, 205),
        textMuted = Color3.fromRGB(120, 120, 130),
        accent = Color3.fromRGB(100, 100, 110),
        border = Color3.fromRGB(40, 40, 45),
        positive = Color3.fromRGB(80, 180, 120),
        negative = Color3.fromRGB(180, 80, 80),
    },
    Celeste = {
        bg = Color3.fromRGB(8, 12, 20),
        bgSecondary = Color3.fromRGB(12, 18, 30),
        text = Color3.fromRGB(210, 225, 255),
        textMuted = Color3.fromRGB(100, 130, 180),
        accent = Color3.fromRGB(80, 140, 255),
        border = Color3.fromRGB(30, 50, 90),
        positive = Color3.fromRGB(80, 200, 255),
        negative = Color3.fromRGB(255, 100, 100),
    },
    Cremisi = {
        bg = Color3.fromRGB(18, 8, 8),
        bgSecondary = Color3.fromRGB(28, 12, 12),
        text = Color3.fromRGB(255, 220, 210),
        textMuted = Color3.fromRGB(180, 100, 90),
        accent = Color3.fromRGB(255, 60, 40),
        border = Color3.fromRGB(90, 30, 25),
        positive = Color3.fromRGB(255, 180, 80),
        negative = Color3.fromRGB(255, 50, 50),
    },
}

-- ═══════════════════════════════════════════
-- COSTRUTTORE
-- ═══════════════════════════════════════════

function TextUI.new(player)
    local self = setmetatable({}, TextUI)
    self.player = player
    self.currentTheme = "Neutrale"
    self.elements = {}
    self:Build()
    return self
end

-- ═══════════════════════════════════════════
-- COSTRUZIONE UI
-- ═══════════════════════════════════════════

function TextUI:Build()
    local playerGui = self.player:WaitForChild("PlayerGui")

    -- ScreenGui principale
    local screen = Instance.new("ScreenGui")
    screen.Name = "LIFE_RPG"
    screen.ResetOnSpawn = false
    screen.IgnoreGuiInset = true
    screen.Parent = playerGui
    self.elements.screen = screen

    -- Container principale (centrato)
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.Size = UDim2.new(0, 700, 0, 500)
    main.BackgroundTransparency = 0
    main.BorderSizePixel = 0
    main.Parent = screen
    self.elements.main = main

    -- Bordo sottile
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Thickness = 1
    mainStroke.Parent = main

    -- Angoli arrotondati
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = main

    -- Header
    self:BuildHeader(main)

    -- Area contenuto
    self:BuildContent(main)

    -- Footer con scelte
    self:BuildFooter(main)

    -- Applica tema iniziale
    self:ApplyTheme("Neutrale")
end

function TextUI:BuildHeader(parent)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundTransparency = 1
    header.Parent = parent
    self.elements.header = header

    -- Linea separatrice
    local line = Instance.new("Frame")
    line.Name = "Line"
    line.Size = UDim2.new(1, -40, 0, 1)
    line.Position = UDim2.new(0, 20, 1, -1)
    line.BorderSizePixel = 0
    line.Parent = header
    self.elements.headerLine = line

    -- Titolo gioco (sinistra)
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0.3, 0, 1, 0)
    title.Position = UDim2.new(0, 25, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "LIFE"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    self.elements.gameTitle = title

    -- Stats (destra)
    local stats = Instance.new("Frame")
    stats.Name = "Stats"
    stats.Size = UDim2.new(0.6, 0, 1, 0)
    stats.Position = UDim2.new(0.4, 0, 0, 0)
    stats.BackgroundTransparency = 1
    stats.Parent = header

    -- Reputazione
    local rep = Instance.new("TextLabel")
    rep.Name = "Reputation"
    rep.Size = UDim2.new(0.5, 0, 1, 0)
    rep.BackgroundTransparency = 1
    rep.Text = "0"
    rep.Font = Enum.Font.GothamMedium
    rep.TextSize = 18
    rep.TextXAlignment = Enum.TextXAlignment.Right
    rep.Parent = stats
    self.elements.reputation = rep

    -- Titolo player
    local playerTitle = Instance.new("TextLabel")
    playerTitle.Name = "PlayerTitle"
    playerTitle.Size = UDim2.new(0.5, -25, 1, 0)
    playerTitle.Position = UDim2.new(0.5, 0, 0, 0)
    playerTitle.BackgroundTransparency = 1
    playerTitle.Text = "Sconosciuto"
    playerTitle.Font = Enum.Font.GothamMedium
    playerTitle.TextSize = 14
    playerTitle.TextXAlignment = Enum.TextXAlignment.Right
    playerTitle.Parent = stats
    self.elements.playerTitle = playerTitle
end

function TextUI:BuildContent(parent)
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -50, 1, -170)
    content.Position = UDim2.new(0, 25, 0, 60)
    content.BackgroundTransparency = 1
    content.Parent = parent
    self.elements.content = content

    -- Titolo evento
    local eventTitle = Instance.new("TextLabel")
    eventTitle.Name = "EventTitle"
    eventTitle.Size = UDim2.new(1, 0, 0, 35)
    eventTitle.BackgroundTransparency = 1
    eventTitle.Text = ""
    eventTitle.Font = Enum.Font.GothamBold
    eventTitle.TextSize = 22
    eventTitle.TextXAlignment = Enum.TextXAlignment.Left
    eventTitle.TextYAlignment = Enum.TextYAlignment.Top
    eventTitle.Parent = content
    self.elements.eventTitle = eventTitle

    -- Testo narrativo (scrollabile)
    local textScroll = Instance.new("ScrollingFrame")
    textScroll.Name = "TextScroll"
    textScroll.Size = UDim2.new(1, 0, 1, -45)
    textScroll.Position = UDim2.new(0, 0, 0, 40)
    textScroll.BackgroundTransparency = 1
    textScroll.BorderSizePixel = 0
    textScroll.ScrollBarThickness = 3
    textScroll.ScrollBarImageTransparency = 0.5
    textScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    textScroll.Parent = content
    self.elements.textScroll = textScroll

    local storyText = Instance.new("TextLabel")
    storyText.Name = "StoryText"
    storyText.Size = UDim2.new(1, -10, 0, 0)
    storyText.BackgroundTransparency = 1
    storyText.Text = ""
    storyText.Font = Enum.Font.Gotham
    storyText.TextSize = 16
    storyText.TextXAlignment = Enum.TextXAlignment.Left
    storyText.TextYAlignment = Enum.TextYAlignment.Top
    storyText.TextWrapped = true
    storyText.AutomaticSize = Enum.AutomaticSize.Y
    storyText.LineHeight = 1.4
    storyText.Parent = textScroll
    self.elements.storyText = storyText
end

function TextUI:BuildFooter(parent)
    local footer = Instance.new("Frame")
    footer.Name = "Footer"
    footer.Size = UDim2.new(1, -50, 0, 100)
    footer.Position = UDim2.new(0, 25, 1, -110)
    footer.BackgroundTransparency = 1
    footer.Parent = parent
    self.elements.footer = footer

    -- Linea separatrice
    local line = Instance.new("Frame")
    line.Name = "Line"
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0, 0)
    line.BorderSizePixel = 0
    line.Parent = footer
    self.elements.footerLine = line

    -- Container scelte
    local choices = Instance.new("Frame")
    choices.Name = "Choices"
    choices.Size = UDim2.new(1, 0, 1, -15)
    choices.Position = UDim2.new(0, 0, 0, 15)
    choices.BackgroundTransparency = 1
    choices.Parent = footer
    self.elements.choices = choices

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = choices
end

-- ═══════════════════════════════════════════
-- TEMA
-- ═══════════════════════════════════════════

function TextUI:ApplyTheme(themeName)
    self.currentTheme = themeName
    local theme = TextUI.Themes[themeName]
    local t = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    -- Main background
    TweenService:Create(self.elements.main, t, { BackgroundColor3 = theme.bg }):Play()

    -- Stroke
    local stroke = self.elements.main:FindFirstChildOfClass("UIStroke")
    if stroke then
        TweenService:Create(stroke, t, { Color = theme.border }):Play()
    end

    -- Header
    TweenService:Create(self.elements.gameTitle, t, { TextColor3 = theme.accent }):Play()
    TweenService:Create(self.elements.headerLine, t, { BackgroundColor3 = theme.border }):Play()
    TweenService:Create(self.elements.reputation, t, { TextColor3 = theme.text }):Play()
    TweenService:Create(self.elements.playerTitle, t, { TextColor3 = theme.textMuted }):Play()

    -- Content
    TweenService:Create(self.elements.eventTitle, t, { TextColor3 = theme.text }):Play()
    TweenService:Create(self.elements.storyText, t, { TextColor3 = theme.text }):Play()

    -- Footer
    TweenService:Create(self.elements.footerLine, t, { BackgroundColor3 = theme.border }):Play()

    -- Scrollbar
    self.elements.textScroll.ScrollBarImageColor3 = theme.textMuted

    -- Aggiorna bottoni esistenti
    self:UpdateChoiceButtons()
end

function TextUI:GetFactionFromRep(rep)
    if rep > 0 then return "Celeste"
    elseif rep < 0 then return "Cremisi"
    else return "Neutrale" end
end

-- ═══════════════════════════════════════════
-- DISPLAY
-- ═══════════════════════════════════════════

function TextUI:ShowEvent(event)
    self.currentEvent = event
    self.elements.eventTitle.Text = event.title or ""
    self:Typewriter(self.elements.storyText, event.context, 0.015)

    -- Aspetta fine typewriter poi mostra scelte
    local textLen = #event.context
    task.delay(textLen * 0.015 + 0.3, function()
        self:ShowChoices(event.choices)
    end)
end

function TextUI:ShowChoices(choices)
    -- Pulisci scelte precedenti
    for _, child in ipairs(self.elements.choices:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local theme = TextUI.Themes[self.currentTheme]

    for i, choice in ipairs(choices) do
        local btn = Instance.new("TextButton")
        btn.Name = "Choice_" .. i
        btn.Size = UDim2.new(1, 0, 0, 26)
        btn.BackgroundColor3 = theme.bgSecondary
        btn.BackgroundTransparency = 0.3
        btn.BorderSizePixel = 0
        btn.Text = "  " .. i .. ".  " .. choice.text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.TextColor3 = theme.text
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        btn.LayoutOrder = i
        btn.Parent = self.elements.choices

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = btn

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = theme.border
        stroke.Transparency = 0.5
        stroke.Parent = btn

        -- Hover
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = theme.accent,
                BackgroundTransparency = 0
            }):Play()
            TweenService:Create(btn, TweenInfo.new(0.15), {
                TextColor3 = theme.bg
            }):Play()
        end)

        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = theme.bgSecondary,
                BackgroundTransparency = 0.3
            }):Play()
            TweenService:Create(btn, TweenInfo.new(0.15), {
                TextColor3 = theme.text
            }):Play()
        end)

        -- Click
        btn.MouseButton1Click:Connect(function()
            self:OnChoiceClicked(choice)
        end)

        -- Animazione entrata
        btn.BackgroundTransparency = 1
        btn.TextTransparency = 1
        task.delay(i * 0.08, function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.3,
                TextTransparency = 0
            }):Play()
        end)
    end
end

function TextUI:OnChoiceClicked(choice)
    -- Nascondi scelte
    for _, child in ipairs(self.elements.choices:GetChildren()) do
        if child:IsA("TextButton") then
            TweenService:Create(child, TweenInfo.new(0.15), {
                BackgroundTransparency = 1,
                TextTransparency = 1
            }):Play()
        end
    end

    if self.OnChoiceCallback then
        self.OnChoiceCallback(choice)
    end
end

function TextUI:ShowConsequence(result)
    local theme = TextUI.Themes[self.currentTheme]
    local currentText = self.elements.storyText.Text

    -- Costruisci testo conseguenza
    local consequenceText = "\n\n" .. result.consequence

    -- Cambio reputazione
    local repChange = result.reputationChange
    local repColor = repChange >= 0 and "positive" or "negative"
    local repSign = repChange >= 0 and "+" or ""
    consequenceText = consequenceText .. "\n\n[" .. repSign .. repChange .. " Reputazione]"

    -- Bonus coerenza
    if result.coherenceBonus then
        consequenceText = consequenceText .. "\n(" .. result.coherenceBonus.name .. ")"
    end

    -- Nuovo titolo
    if result.newTitle then
        consequenceText = consequenceText .. "\n\n>> Nuovo Titolo: " .. result.newTitle.title .. " <<"
    end

    self:Typewriter(self.elements.storyText, currentText .. consequenceText, 0.02)

    -- Mostra pulsante continua dopo
    task.delay(#consequenceText * 0.02 + 1, function()
        self:ShowContinueButton()
    end)
end

function TextUI:ShowContinueButton()
    local theme = TextUI.Themes[self.currentTheme]

    -- Pulisci scelte
    for _, child in ipairs(self.elements.choices:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local btn = Instance.new("TextButton")
    btn.Name = "Continue"
    btn.Size = UDim2.new(0.4, 0, 0, 32)
    btn.Position = UDim2.new(0.3, 0, 0.5, -16)
    btn.AnchorPoint = Vector2.new(0, 0)
    btn.BackgroundColor3 = theme.accent
    btn.BorderSizePixel = 0
    btn.Text = "Continua"
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.TextColor3 = theme.bg
    btn.Parent = self.elements.choices

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn

    -- Animazione entrata
    btn.BackgroundTransparency = 1
    btn.TextTransparency = 1
    TweenService:Create(btn, TweenInfo.new(0.3), {
        BackgroundTransparency = 0,
        TextTransparency = 0
    }):Play()

    btn.MouseButton1Click:Connect(function()
        btn:Destroy()
        if self.OnContinueCallback then
            self.OnContinueCallback()
        end
    end)
end

function TextUI:UpdateStats(playerData)
    local rep = playerData.reputation
    local sign = rep >= 0 and "+" or ""
    self.elements.reputation.Text = sign .. tostring(rep)

    local title = playerData.currentTitle or "Sconosciuto"
    self.elements.playerTitle.Text = title

    -- Cambia tema se necessario
    local newTheme = self:GetFactionFromRep(rep)
    if newTheme ~= self.currentTheme then
        self:ApplyTheme(newTheme)
    end

    -- Colore reputazione
    local theme = TextUI.Themes[self.currentTheme]
    local repColor = rep >= 0 and theme.positive or theme.negative
    if rep == 0 then repColor = theme.textMuted end
    self.elements.reputation.TextColor3 = repColor
end

function TextUI:ShowSystemMessage(message, duration)
    duration = duration or 3

    local theme = TextUI.Themes[self.currentTheme]

    local msg = Instance.new("TextLabel")
    msg.Name = "SystemMsg"
    msg.Size = UDim2.new(0.6, 0, 0, 40)
    msg.Position = UDim2.new(0.2, 0, 0.05, 0)
    msg.AnchorPoint = Vector2.new(0, 0)
    msg.BackgroundColor3 = theme.bgSecondary
    msg.BorderSizePixel = 0
    msg.Text = message
    msg.Font = Enum.Font.Gotham
    msg.TextSize = 14
    msg.TextColor3 = theme.text
    msg.Parent = self.elements.screen

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = msg

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = theme.border
    stroke.Parent = msg

    -- Fade in
    msg.BackgroundTransparency = 1
    msg.TextTransparency = 1
    TweenService:Create(msg, TweenInfo.new(0.3), {
        BackgroundTransparency = 0.2,
        TextTransparency = 0
    }):Play()

    -- Fade out e rimuovi
    task.delay(duration, function()
        TweenService:Create(msg, TweenInfo.new(0.5), {
            BackgroundTransparency = 1,
            TextTransparency = 1
        }):Play()
        task.delay(0.5, function()
            msg:Destroy()
        end)
    end)
end

-- ═══════════════════════════════════════════
-- EFFETTI
-- ═══════════════════════════════════════════

function TextUI:Typewriter(label, text, speed)
    speed = speed or 0.02
    label.Text = ""

    task.spawn(function()
        for i = 1, #text do
            label.Text = string.sub(text, 1, i)

            -- Aggiorna canvas size
            local scroll = label.Parent
            if scroll and scroll:IsA("ScrollingFrame") then
                scroll.CanvasSize = UDim2.new(0, 0, 0, label.AbsoluteSize.Y + 10)
            end

            task.wait(speed)
        end
    end)
end

function TextUI:UpdateChoiceButtons()
    local theme = TextUI.Themes[self.currentTheme]
    for _, child in ipairs(self.elements.choices:GetChildren()) do
        if child:IsA("TextButton") then
            child.BackgroundColor3 = theme.bgSecondary
            child.TextColor3 = theme.text
            local stroke = child:FindFirstChildOfClass("UIStroke")
            if stroke then
                stroke.Color = theme.border
            end
        end
    end
end

function TextUI:Destroy()
    if self.elements.screen then
        self.elements.screen:Destroy()
    end
end

return TextUI
