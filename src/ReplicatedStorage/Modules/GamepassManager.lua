--[[
    GAMEPASSMANAGER.LUA
    Gestisce i 4 gamepass del gioco:
    - x2 Income (ID: 1671785492)
    - VIP Status (ID: 1671265879)
    - AFK Boost (ID: 1671407720)
    - Offline Earnings (ID: 1671275763)
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Config = require(script.Parent.Config)

local GamepassManager = {}

-- Cache per evitare chiamate API ripetute
local GamepassCache = {}

-- ==================== CHECK OWNERSHIP ====================

function GamepassManager.PlayerOwnsGamepass(player, gamepassId)
    -- Check cache
    local cacheKey = player.UserId .. "_" .. gamepassId
    if GamepassCache[cacheKey] ~= nil then
        return GamepassCache[cacheKey]
    end

    -- Check via API
    local success, ownsGamepass = pcall(function()
        return MarketplaceService:UserOwnsGamepassAsync(player.UserId, gamepassId)
    end)

    if success then
        GamepassCache[cacheKey] = ownsGamepass
        return ownsGamepass
    else
        warn("[GamepassManager] Errore nel controllare gamepass " .. gamepassId .. " per " .. player.Name)
        return false
    end
end

-- ==================== SYNC GAMEPASSES ====================

function GamepassManager.SyncGamepasses(player, profile)
    print("[GamepassManager] Syncing gamepasses per " .. player.Name)

    local gamepasses = profile:Get("Gamepasses")
    local anyChanged = false

    -- Check x2 Income
    local ownsX2 = GamepassManager.PlayerOwnsGamepass(player, Config.Gamepasses.x2Income.ID)
    if ownsX2 and not gamepasses.x2Income then
        gamepasses.x2Income = true
        anyChanged = true
        print("[GamepassManager] " .. player.Name .. " possiede x2 Income!")
    end

    -- Check VIP Status
    local ownsVIP = GamepassManager.PlayerOwnsGamepass(player, Config.Gamepasses.VIPStatus.ID)
    if ownsVIP and not gamepasses.VIPStatus then
        gamepasses.VIPStatus = true
        anyChanged = true
        print("[GamepassManager] " .. player.Name .. " possiede VIP Status!")
    end

    -- Check AFK Boost
    local ownsAFKBoost = GamepassManager.PlayerOwnsGamepass(player, Config.Gamepasses.AFKBoost.ID)
    if ownsAFKBoost and not gamepasses.AFKBoost then
        gamepasses.AFKBoost = true
        anyChanged = true
        print("[GamepassManager] " .. player.Name .. " possiede AFK Boost!")
    end

    -- Check Offline Earnings
    local ownsOffline = GamepassManager.PlayerOwnsGamepass(player, Config.Gamepasses.OfflineEarnings.ID)
    if ownsOffline and not gamepasses.OfflineEarnings then
        gamepasses.OfflineEarnings = true
        anyChanged = true
        print("[GamepassManager] " .. player.Name .. " possiede Offline Earnings!")
    end

    if anyChanged then
        profile:Set("Gamepasses", gamepasses)
    end

    return gamepasses
end

-- ==================== PROMPT PURCHASE ====================

function GamepassManager.PromptGamepassPurchase(player, gamepassKey)
    local gamepassInfo = Config.Gamepasses[gamepassKey]
    if not gamepassInfo then
        warn("[GamepassManager] Gamepass key invalido: " .. tostring(gamepassKey))
        return false
    end

    -- Check se già possiede
    if GamepassManager.PlayerOwnsGamepass(player, gamepassInfo.ID) then
        warn("[GamepassManager] " .. player.Name .. " possiede già " .. gamepassInfo.Name)
        return false
    end

    -- Prompt purchase
    local success, errorMessage = pcall(function()
        MarketplaceService:PromptGamePassPurchase(player, gamepassInfo.ID)
    end)

    if not success then
        warn("[GamepassManager] Errore nel prompt gamepass: " .. errorMessage)
        return false
    end

    return true
end

-- ==================== GAMEPASS PURCHASED HANDLER ====================

function GamepassManager.OnGamepassPurchased(player, profile, gamepassId)
    print("[GamepassManager] Gamepass acquistato: " .. gamepassId .. " da " .. player.Name)

    -- Clear cache
    local cacheKey = player.UserId .. "_" .. gamepassId
    GamepassCache[cacheKey] = true

    -- Update profile
    local gamepasses = profile:Get("Gamepasses")

    if gamepassId == Config.Gamepasses.x2Income.ID then
        gamepasses.x2Income = true
        print("[GamepassManager] x2 Income attivato per " .. player.Name)

    elseif gamepassId == Config.Gamepasses.VIPStatus.ID then
        gamepasses.VIPStatus = true
        print("[GamepassManager] VIP Status attivato per " .. player.Name)

    elseif gamepassId == Config.Gamepasses.AFKBoost.ID then
        gamepasses.AFKBoost = true
        print("[GamepassManager] AFK Boost attivato per " .. player.Name)

    elseif gamepassId == Config.Gamepasses.OfflineEarnings.ID then
        gamepasses.OfflineEarnings = true
        print("[GamepassManager] Offline Earnings attivato per " .. player.Name)
    end

    profile:Set("Gamepasses", gamepasses)
    profile:Save()
end

-- ==================== GET INFO ====================

function GamepassManager.GetGamepassInfo(gamepassKey)
    return Config.Gamepasses[gamepassKey]
end

function GamepassManager.GetGamepassByID(gamepassId)
    for key, gamepass in pairs(Config.Gamepasses) do
        if gamepass.ID == gamepassId then
            return gamepass
        end
    end
    return nil
end

function GamepassManager.GetAllGamepasses()
    return Config.Gamepasses
end

-- ==================== CLEAR CACHE ====================

function GamepassManager.ClearCache(player)
    for cacheKey in pairs(GamepassCache) do
        if string.find(cacheKey, tostring(player.UserId)) then
            GamepassCache[cacheKey] = nil
        end
    end
end

return GamepassManager
