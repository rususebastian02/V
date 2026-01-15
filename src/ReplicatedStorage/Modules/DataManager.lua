--[[
    DATAMANAGER.LUA
    Gestisce il caricamento, salvataggio e cache dei dati dei player
    Usa DataStore2-like approach per sicurezza
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local Config = require(script.Parent.Config)

local DataManager = {}
DataManager.__index = DataManager

-- Cache dei profili attivi
local ProfileCache = {}

-- DataStore
local PlayerDataStore = DataStoreService:GetDataStore(Config.DataStore.Name)

-- ==================== FUNZIONI HELPER ====================

local function DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- ==================== PROFILE CLASS ====================

local Profile = {}
Profile.__index = Profile

function Profile.new(player, data)
    local self = setmetatable({}, Profile)
    self.Player = player
    self.Data = data
    self.IsLoaded = true
    self._saveConnection = nil
    return self
end

function Profile:Get(key)
    return self.Data[key]
end

function Profile:Set(key, value)
    self.Data[key] = value
end

function Profile:Increment(key, amount)
    if type(self.Data[key]) == "number" then
        self.Data[key] = self.Data[key] + amount
    end
end

function Profile:Save()
    if not self.IsLoaded then
        warn("[DataManager] Tentativo di salvare profilo non caricato per " .. self.Player.Name)
        return false
    end

    local userId = self.Player.UserId
    local success, errorMessage = pcall(function()
        PlayerDataStore:SetAsync("Player_" .. userId, self.Data)
    end)

    if success then
        print("[DataManager] Dati salvati per " .. self.Player.Name)
        return true
    else
        warn("[DataManager] Errore nel salvare dati per " .. self.Player.Name .. ": " .. errorMessage)
        return false
    end
end

function Profile:Release()
    self.IsLoaded = false
    if self._saveConnection then
        self._saveConnection:Disconnect()
    end
    ProfileCache[self.Player.UserId] = nil
end

-- ==================== DATA MANAGER ====================

function DataManager.LoadProfile(player)
    local userId = player.UserId

    -- Check se già caricato
    if ProfileCache[userId] then
        warn("[DataManager] Profilo già caricato per " .. player.Name)
        return ProfileCache[userId]
    end

    print("[DataManager] Caricamento dati per " .. player.Name)

    local data = nil
    local success, errorMessage = pcall(function()
        data = PlayerDataStore:GetAsync("Player_" .. userId)
    end)

    if not success then
        warn("[DataManager] Errore nel caricare dati per " .. player.Name .. ": " .. errorMessage)
        -- Usa dati default in caso di errore
        data = nil
    end

    -- Se non ci sono dati, usa default
    if not data then
        print("[DataManager] Nessun dato trovato, uso default per " .. player.Name)
        data = DeepCopy(Config.DefaultPlayerData)
    else
        -- Merge con default per nuove chiavi
        local defaultData = DeepCopy(Config.DefaultPlayerData)
        for key, value in pairs(data) do
            defaultData[key] = value
        end
        data = defaultData
    end

    -- Crea profilo
    local profile = Profile.new(player, data)
    ProfileCache[userId] = profile

    print("[DataManager] Profilo caricato per " .. player.Name)
    return profile
end

function DataManager.GetProfile(player)
    return ProfileCache[player.UserId]
end

function DataManager.SaveProfile(player)
    local profile = ProfileCache[player.UserId]
    if profile then
        return profile:Save()
    end
    return false
end

function DataManager.ReleaseProfile(player)
    local profile = ProfileCache[player.UserId]
    if profile then
        profile:Save() -- Salva prima di rilasciare
        profile:Release()
        print("[DataManager] Profilo rilasciato per " .. player.Name)
    end
end

function DataManager.SaveAllProfiles()
    print("[DataManager] Salvataggio di tutti i profili...")
    local count = 0
    for userId, profile in pairs(ProfileCache) do
        if profile:Save() then
            count = count + 1
        end
    end
    print("[DataManager] Salvati " .. count .. " profili")
end

return DataManager
