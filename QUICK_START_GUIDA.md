# 🚀 QUICK START - DO NOTHING TO GET RICH

## 📁 HAI 2 FILE PRINCIPALI:

1. **COPIA_INCOLLA_COMPLETO_PARTE1-3.md** → Tutti i moduli + server + client scripts
2. **COPIA_INCOLLA_COMPLETO_PARTE4-UI.md** → UI scripts + setup UI completo

---

## ⚡ SETUP VELOCE (30 minuti)

### STEP 1: Cartelle Base (2 min)
In **ReplicatedStorage**:
- Crea Folder `Modules`
- Crea Folder `Events`

### STEP 2: RemoteEvents (3 min)
In **ReplicatedStorage/Events** crea:
- 7 **RemoteEvent**: DataUpdated, RankUp, BoostActivated, BoostEnded, PromptGamepass, PromptDevProduct, TeleportToVIP
- 1 **RemoteFunction**: RequestData

### STEP 3: Moduli (10 min)
Vai a **PARTE1-3** e copia i **11 ModuleScript** in ReplicatedStorage/Modules:
1. Config
2. DataManager
3. CashManager
4. RankManager
5. GamepassManager
6. DevProductsManager
7. BoostManager
8. OfflineEarningsManager
9. LocalLeaderboardManager
10. GlobalLeaderboardManager
11. VisualEffectsManager

### STEP 4: Server Scripts (2 min)
In **ServerScriptService** crea 2 **Script**:
1. MainServer (copia da PARTE1-3)
2. GlobalLeaderboardDisplay (copia da PARTE1-3)

### STEP 5: Client Script (1 min)
In **StarterPlayer/StarterPlayerScripts**:
- Crea **LocalScript** "ClientMain" (copia da PARTE1-3)

### STEP 6: UI (10 min)
Vai a **PARTE4** e crea tutti i 4 ScreenGui:
1. HUD (con CashFrame, RankFrame, AFKFrame, BoostFrame)
2. ShopGUI (con MainFrame, ShopButton, + script)
3. VIPGUI (con VIPButton + script)
4. RankUpNotification (con Frame + labels)

### STEP 7: Mappa Base (2 min)
Nel **Workspace**:
- Part "SpawnPlatform" (20x1x20)
- SpawnLocation sopra

### STEP 8: Settings
**Home → Game Settings → Security**:
- ✅ Enable Studio Access to API Services

---

## ✅ TEST (premi F5)

Dovresti vedere:
- Cash che aumenta automaticamente (+1/sec)
- HUD funzionante
- Leaderboard sopra testa
- Dopo 1 minuto: Rank up da Lazy → Chill

---

## 🔧 MODIFICA PARAMETRI

### Cash per secondo:
**File:** Config.lua → Riga 6
```lua
BaseCashPerSecond = 1,  -- ⚠️ CAMBIA QUESTO
```

### ID Gamepass:
**File:** Config.lua → Righe 15-42
```lua
ID = 1671785492,  -- ⚠️ SOSTITUISCI CON IL TUO
```

### ID Dev Products:
**File:** Config.lua → Righe 46-112
```lua
ID = 3513599959,  -- ⚠️ SOSTITUISCI CON IL TUO
```

---

## 🆘 PROBLEMI COMUNI

**"Unable to find module Config"**
→ Verifica che Config.lua sia in ReplicatedStorage/Modules

**"DataUpdated is not a valid member"**
→ Controlla di aver creato tutti i RemoteEvents in ReplicatedStorage/Events

**"Enable Studio Access to API Services"**
→ Game Settings → Security → Abilita questa opzione

**Cash non aumenta**
→ Premi Output (View → Output) e controlla errori

---

## 📦 ORDINE CONSIGLIATO

1. Leggi **PARTE1-3** per moduli e server
2. Leggi **PARTE4** per UI
3. Copia tutto in ordine
4. Test con F5
5. Modifica ID in Config.lua
6. Pubblica su Roblox

---

## 🎯 DOPO IL SETUP

1. Pubblica il gioco su Roblox
2. Crea i 4 gamepass su Roblox.com
3. Crea i 9 dev products
4. Copia gli ID in Config.lua
5. Ricarica il gioco
6. Test acquisti

---

## 💡 TIPS

- Salva il place regolarmente (Ctrl+S)
- Testa in "Local Server" (2+ player) per boost server
- Usa Output per debugging
- Leggi i commenti negli script

---

**TUTTO PRONTO! Buon sviluppo! 🎮💸**
