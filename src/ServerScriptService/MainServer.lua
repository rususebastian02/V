--[[
    MAINSERVER.LUA
    Script server principale che coordina tutti i sistemi del gioco
    "DO NOTHING TO GET RICH"
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

-- Moduli
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = require(Modules.Config)
local DataManager = require(Modules.DataManager)
local CashManager = require(Modules.CashManager)
local RankManager = require(Modules.RankManager)
local GamepassManager = require(Modules.GamepassManager)
local DevProductsManager = require(Modules.DevProductsManager)
local BoostManager = require(Modules.BoostManager)
local OfflineEarningsManager = require(Modules.OfflineEarningsManager)
local LocalLeaderboardManager = require(Modules.LocalLeaderboardManager)
local GlobalLeaderboardManager = require(Modules.GlobalLeaderboardManager)
local VisualEffectsManager = require(Modules.VisualEffectsManager)

-- Eventi
local Events = ReplicatedStorage:WaitForChild("Events")
local DataUpdatedEvent = Events:WaitForChild("DataUpdated")
local RankUpEvent = Events:WaitForChild("RankUp")
local BoostActivatedEvent = Events:WaitForChild("BoostActivated")
local BoostEndedEvent = Events:WaitForChild("BoostEnded")
local PromptGamepassEvent = Events:WaitForChild("PromptGamepass")
local PromptDevProductEvent = Events:WaitForChild("PromptDevProduct")
local TeleportToVIPEvent = Events:WaitForChild("TeleportToVIP")
local RequestDataFunction = Events:WaitForChild("RequestData")

print("==============================================")
print("DO NOTHING TO GET RICH - Server Starting...")
print("==============================================")

-- ==================== INITIALIZATION ====================

-- Init managers
RankManager.Init(RankUpEvent)
BoostManager.Init(BoostActivatedEvent, BoostEndedEvent)
DevProductsManager.Init()

-- Start global leaderboard update loop
GlobalLeaderboardManager.StartUpdateLoop()

print("[MainServer] Tutti i manager inizializzati")

-- ==================== PLAYER JOIN ====================

Players.PlayerAdded:Connect(function(player)
    print("[MainServer] Player joined: " .. player.Name)

    -- Load profile
    local profile = DataManager.LoadProfile(player)
    if not profile then
        warn("[MainServer] Impossibile caricare profilo per " .. player.Name)
        player:Kick("Errore nel caricamento dati. Riprova.")
        return
    end

    -- Sync gamepasses
    GamepassManager.SyncGamepasses(player, profile)

    -- Calculate offline earnings (se ha il gamepass)
    local offlineEarnings, offlineTime = OfflineEarningsManager.GrantOfflineEarnings(player, profile)

    -- Update last login
    profile:Set("LastLogin", os.time())

    -- Initialize managers
    CashManager.InitializePlayer(player, profile)

    -- Create local leaderboard
    LocalLeaderboardManager.CreateLeaderboard(player)
    LocalLeaderboardManager.UpdateLeaderboard(player, profile)

    -- Update rank
    RankManager.UpdatePlayerRank(player, profile)

    -- Apply visual effects when character spawns
    player.CharacterAdded:Connect(function(character)
        local rankName = profile:Get("CurrentRank")
        VisualEffectsManager.OnCharacterAdded(player, rankName)
    end)

    -- Notifica player di offline earnings
    if offlineEarnings > 0 then
        task.wait(2) -- Aspetta che client sia pronto
        -- Puoi inviare un evento al client per mostrare notifica
        print(string.format("[MainServer] %s ha guadagnato %.0f cash offline",
            player.Name, offlineEarnings))
    end

    print("[MainServer] " .. player.Name .. " completamente inizializzato")
end)

-- ==================== PLAYER LEAVE ====================

Players.PlayerRemoving:Connect(function(player)
    print("[MainServer] Player leaving: " .. player.Name)

    local profile = DataManager.GetProfile(player)
    if profile then
        -- Update global leaderboard prima di salvare
        local afkTime = profile:Get("TotalAFKTime")
        local cash = profile:Get("Cash")
        GlobalLeaderboardManager.UpdatePlayerScore(player.UserId, afkTime, cash)

        -- Save and release profile
        DataManager.ReleaseProfile(player)
    end

    -- Cleanup
    CashManager.RemovePlayer(player)
    GamepassManager.ClearCache(player)

    print("[MainServer] " .. player.Name .. " cleanup completato")
end)

-- ==================== MAIN UPDATE LOOP ====================

spawn(function()
    while true do
        task.wait(1) -- Update ogni secondo

        -- Update boost status
        BoostManager.Update()

        -- Get current server boost
        local serverBoostMultiplier = BoostManager.GetCurrentMultiplier()

        -- Update tutti i player
        for _, player in ipairs(Players:GetPlayers()) do
            local profile = DataManager.GetProfile(player)
            if profile then
                -- Update cash e AFK time
                CashManager.UpdateCash(player, profile, serverBoostMultiplier)

                -- Update rank
                local _, rankChanged = RankManager.UpdatePlayerRank(player, profile)

                -- Se rank è cambiato, applica aura
                if rankChanged then
                    local rankName = profile:Get("CurrentRank")
                    VisualEffectsManager.ApplyAura(player, rankName)
                end

                -- Update local leaderboard
                LocalLeaderboardManager.UpdateLeaderboard(player, profile)

                -- Invia update al client
                DataUpdatedEvent:FireClient(player, {
                    Cash = profile:Get("Cash"),
                    AFKTime = profile:Get("TotalAFKTime"),
                    Rank = profile:Get("CurrentRank"),
                    Income = CashManager.GetCurrentIncome(player, profile, serverBoostMultiplier),
                    ServerBoost = serverBoostMultiplier > 1
                })
            end
        end
    end
end)

-- ==================== AUTO-SAVE LOOP ====================

spawn(function()
    while true do
        task.wait(Config.DataStore.AutoSaveInterval)
        DataManager.SaveAllProfiles()
    end
end)

-- ==================== GLOBAL LEADERBOARD UPDATE ====================

spawn(function()
    while true do
        task.wait(60) -- Ogni minuto aggiorna score globale

        for _, player in ipairs(Players:GetPlayers()) do
            local profile = DataManager.GetProfile(player)
            if profile then
                local afkTime = profile:Get("TotalAFKTime")
                local cash = profile:Get("Cash")
                GlobalLeaderboardManager.UpdatePlayerScore(player.UserId, afkTime, cash)
            end
        end
    end
end)

-- ==================== REMOTE EVENTS ====================

-- Prompt Gamepass
PromptGamepassEvent.OnServerEvent:Connect(function(player, gamepassKey)
    GamepassManager.PromptGamepassPurchase(player, gamepassKey)
end)

-- Prompt Dev Product
PromptDevProductEvent.OnServerEvent:Connect(function(player, productKey)
    DevProductsManager.PromptPurchase(player, productKey)
end)

-- Teleport to VIP Area
TeleportToVIPEvent.OnServerEvent:Connect(function(player)
    local profile = DataManager.GetProfile(player)
    if not profile then return end

    -- Check se ha VIP Status
    if not profile:Get("Gamepasses").VIPStatus then
        warn("[MainServer] " .. player.Name .. " non ha VIP Status")
        return
    end

    -- Teleport (assumendo che esista un Part chiamato "VIPSpawn" nel workspace)
    local vipSpawn = workspace:FindFirstChild("VIPSpawn")
    if vipSpawn and player.Character then
        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = vipSpawn.CFrame + Vector3.new(0, 5, 0)
            print("[MainServer] " .. player.Name .. " teleportato a VIP Area")
        end
    end
end)

-- Request Data (RemoteFunction)
RequestDataFunction.OnServerInvoke = function(player)
    local profile = DataManager.GetProfile(player)
    if not profile then return nil end

    local serverBoostMultiplier = BoostManager.GetCurrentMultiplier()

    return {
        Cash = profile:Get("Cash"),
        TotalAFKTime = profile:Get("TotalAFKTime"),
        AFKTime = profile:Get("TotalAFKTime"), -- Backwards compatibility
        CurrentRank = profile:Get("CurrentRank"),
        Rank = profile:Get("CurrentRank"), -- Backwards compatibility
        FirstJoin = profile:Get("FirstJoin"),
        RobuxSpent = profile:Get("RobuxSpent"),
        Income = CashManager.GetCurrentIncome(player, profile, serverBoostMultiplier),
        Gamepasses = profile:Get("Gamepasses"),
        ServerBoost = BoostManager.GetBoostInfo()
    }
end

-- ==================== MARKETPLACE CALLBACKS ====================

-- Gamepass purchased
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamepassId, wasPurchased)
    if wasPurchased then
        local profile = DataManager.GetProfile(player)
        if profile then
            GamepassManager.OnGamepassPurchased(player, profile, gamepassId)

            -- Track RobuxSpent
            local gamepassInfo = GamepassManager.GetGamepassByID(gamepassId)
            if gamepassInfo and gamepassInfo.Price then
                profile:Increment("RobuxSpent", gamepassInfo.Price)
                GlobalLeaderboardManager.UpdatePlayerScore(player.UserId, player.Name, profile:Get("TotalAFKTime"), profile:Get("Cash"), profile:Get("RobuxSpent"))
                print(string.format("[MainServer] %s ha speso %d Robux (gamepass)", player.Name, gamepassInfo.Price))
            end
        end
    end
end)

-- ==================== DEV PRODUCTS HANDLERS ====================

-- Server Boost Handler
DevProductsManager.SetServerBoostHandler(function(player, product)
    BoostManager.ActivateBoost(player, product.Duration, product.Multiplier)
    print(string.format("[MainServer] %s ha attivato %s", player.Name, product.Name))
end)

-- Skip Rank Handler
DevProductsManager.SetSkipRankHandler(function(player)
    local profile = DataManager.GetProfile(player)
    if not profile then return end

    local success, newRank = RankManager.SkipToNextRank(player, profile)
    if success then
        -- Apply aura se nuovo rank ne ha una
        VisualEffectsManager.ApplyAura(player, newRank)
        print(string.format("[MainServer] %s ha skippato al rank: %s", player.Name, newRank))
    end
end)

-- Instant Cash Handler
DevProductsManager.SetInstantCashHandler(function(player, amount)
    local profile = DataManager.GetProfile(player)
    if not profile then return end

    CashManager.AddCash(player, profile, amount)
    VisualEffectsManager.PlayCashEffect(player, amount)
    print(string.format("[MainServer] %s ha ricevuto %d cash istantanei", player.Name, amount))
end)

-- Donation Handler
DevProductsManager.SetDonationHandler(function(player, amount)
    local profile = DataManager.GetProfile(player)
    if not profile then return end

    -- Track RobuxSpent
    profile:Increment("RobuxSpent", amount)
    GlobalLeaderboardManager.UpdatePlayerScore(player.UserId, player.Name, profile:Get("TotalAFKTime"), profile:Get("Cash"), profile:Get("RobuxSpent"))
    print(string.format("[MainServer] %s ha donato %d Robux! Grazie!", player.Name, amount))
end)

-- ==================== SHUTDOWN HANDLING ====================

game:BindToClose(function()
    print("[MainServer] Server shutting down, saving all profiles...")
    DataManager.SaveAllProfiles()
    task.wait(3)
end)

print("==============================================")
print("DO NOTHING TO GET RICH - Server Ready!")
print("==============================================")
