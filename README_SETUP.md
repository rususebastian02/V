# 💸 DO NOTHING TO GET RICH - Setup Guide

> "The less you play, the richer you get."

## 📋 Indice

1. [Panoramica](#panoramica)
2. [Struttura Progetto](#struttura-progetto)
3. [Setup Roblox Studio](#setup-roblox-studio)
4. [Configurazione RemoteEvents](#configurazione-remoteevents)
5. [Setup UI](#setup-ui)
6. [Setup Mappa](#setup-mappa)
7. [Testing](#testing)
8. [Deploy](#deploy)
9. [Troubleshooting](#troubleshooting)

---

## 📖 Panoramica

Questo è un gioco AFK/Idle per Roblox dove i player guadagnano Cash automaticamente semplicemente essendo nel gioco. Include:

- ✅ Sistema Cash automatico (+1/sec base)
- ✅ 9 Rank basati su tempo AFK (Lazy → AFK Deity)
- ✅ 4 Gamepass (x2 Income, VIP Status, AFK Boost, Offline Earnings)
- ✅ 9 Dev Products (boost server, skip rank, cash packs)
- ✅ Leaderboard locale e globale Top 100
- ✅ Sistema Offline Earnings
- ✅ Visual effects (aure, particles, rank up)
- ✅ DataStore con auto-save

---

## 🗂️ Struttura Progetto

```
src/
├── ServerScriptService/
│   ├── MainServer.lua                    # Script server principale
│   └── GlobalLeaderboardDisplay.lua      # Display leaderboard globale
│
├── ReplicatedStorage/
│   ├── Modules/
│   │   ├── Config.lua                    # Configurazione centrale
│   │   ├── DataManager.lua               # Gestione DataStore
│   │   ├── CashManager.lua               # Sistema Cash e AFK tracking
│   │   ├── RankManager.lua               # Sistema Rank
│   │   ├── GamepassManager.lua           # Gestione Gamepass
│   │   ├── DevProductsManager.lua        # Gestione Dev Products
│   │   ├── BoostManager.lua              # Boost temporanei
│   │   ├── OfflineEarningsManager.lua    # Offline earnings
│   │   ├── LocalLeaderboardManager.lua   # Leaderboard locale
│   │   ├── GlobalLeaderboardManager.lua  # Leaderboard globale
│   │   └── VisualEffectsManager.lua      # Effetti visivi
│   │
│   └── Events/                           # RemoteEvents (da creare in Studio)
│       └── README.md
│
├── StarterPlayer/
│   └── StarterPlayerScripts/
│       └── ClientMain.lua                # Script client principale
│
└── StarterGui/
    ├── HUD_README.md                     # Istruzioni HUD UI
    ├── ShopGUI_Script.lua                # Script Shop GUI
    ├── VIP_GUI_Script.lua                # Script VIP GUI
    └── RankUpNotification_README.md      # Istruzioni notifica rank up
```

---

## 🛠️ Setup Roblox Studio

### 1. Crea Nuovo Place

1. Apri Roblox Studio
2. Crea un nuovo place o apri il tuo progetto esistente
3. Salva il place

### 2. Importa Script

#### A. ServerScriptService

1. Vai a `ServerScriptService`
2. Crea uno **Script** chiamato `MainServer`
3. Copia il contenuto da `src/ServerScriptService/MainServer.lua`
4. Crea un altro **Script** chiamato `GlobalLeaderboardDisplay`
5. Copia il contenuto da `src/ServerScriptService/GlobalLeaderboardDisplay.lua`

#### B. ReplicatedStorage

1. In `ReplicatedStorage`, crea una **Folder** chiamata `Modules`
2. Per ogni file in `src/ReplicatedStorage/Modules/`:
   - Crea un **ModuleScript** con il nome corrispondente
   - Copia il contenuto del file

**Lista ModuleScript da creare:**
- Config
- DataManager
- CashManager
- RankManager
- GamepassManager
- DevProductsManager
- BoostManager
- OfflineEarningsManager
- LocalLeaderboardManager
- GlobalLeaderboardManager
- VisualEffectsManager

#### C. StarterPlayer/StarterPlayerScripts

1. Vai a `StarterPlayer` → `StarterPlayerScripts`
2. Crea un **LocalScript** chiamato `ClientMain`
3. Copia il contenuto da `src/StarterPlayer/StarterPlayerScripts/ClientMain.lua`

---

## 📡 Configurazione RemoteEvents

**IMPORTANTE:** Questi eventi sono necessari per la comunicazione client-server.

1. In `ReplicatedStorage`, crea una **Folder** chiamata `Events`

2. In `Events`, crea i seguenti **RemoteEvent**:
   - `DataUpdated`
   - `RankUp`
   - `BoostActivated`
   - `BoostEnded`
   - `PromptGamepass`
   - `PromptDevProduct`
   - `TeleportToVIP`

3. In `Events`, crea il seguente **RemoteFunction**:
   - `RequestData`

**⚠️ I nomi devono essere ESATTI altrimenti gli script non funzioneranno!**

---

## 🎨 Setup UI

### 1. HUD (ScreenGui)

1. In `StarterGui`, crea un **ScreenGui** chiamato `HUD`
2. Struttura:

```
HUD (ScreenGui)
├── CashFrame (Frame)
│   ├── CashLabel (TextLabel)
│   └── IncomeLabel (TextLabel)
├── RankFrame (Frame)
│   └── RankLabel (TextLabel)
├── AFKFrame (Frame)
│   └── AFKTimeLabel (TextLabel)
└── BoostFrame (Frame)
    └── BoostLabel (TextLabel)
```

**Proprietà consigliate:**

**CashFrame:**
- Position: `{0, 20}, {0, 20}`
- Size: `{0, 300}, {0, 80}`
- BackgroundColor3: `30, 30, 30`
- BackgroundTransparency: `0.3`

**CashLabel:**
- Size: `{1, -10}, {0.5, 0}`
- Text: "💰 0"
- TextScaled: true
- Font: GothamBold

**IncomeLabel:**
- Position: `{0, 5}, {0.5, 0}`
- Size: `{1, -10}, {0.5, 0}`
- Text: "+1/sec"
- TextScaled: true
- Font: Gotham

*Ripeti struttura simile per RankFrame, AFKFrame, BoostFrame (vedi HUD_README.md per dettagli)*

### 2. Shop GUI

1. In `StarterGui`, crea un **ScreenGui** chiamato `ShopGUI`
2. Struttura:

```
ShopGUI (ScreenGui)
├── ShopButton (TextButton) - Bottone per aprire shop
└── MainFrame (Frame) - Frame principale shop
    ├── CloseButton (TextButton)
    ├── TabButtons (Frame)
    │   ├── GamepassTab (TextButton)
    │   └── DevProductsTab (TextButton)
    ├── GamepassFrame (Frame)
    │   └── Container (ScrollingFrame)
    └── DevProductsFrame (Frame)
        └── Container (ScrollingFrame)
```

3. Dentro `ShopGUI`, inserisci un **LocalScript** chiamato `ShopScript`
4. Copia il contenuto da `src/StarterGui/ShopGUI_Script.lua`

**Proprietà ShopButton:**
- Position: `{1, -120}, {1, -120}`
- Size: `{0, 100}, {0, 100}`
- Text: "🛒 SHOP"
- TextScaled: true
- BackgroundColor3: `50, 150, 50`

**MainFrame:**
- AnchorPoint: `0.5, 0.5`
- Position: `{0.5, 0}, {0.5, 0}`
- Size: `{0, 600}, {0, 500}`
- Visible: false (inizialmente nascosto)

### 3. VIP GUI

1. In `StarterGui`, crea un **ScreenGui** chiamato `VIPGUI`
2. Struttura:

```
VIPGUI (ScreenGui)
└── VIPButton (TextButton)
```

3. Dentro `VIPGUI`, inserisci un **LocalScript** chiamato `VIPScript`
4. Copia il contenuto da `src/StarterGui/VIP_GUI_Script.lua`

**Proprietà VIPButton:**
- Position: `{0.5, -100}, {1, -120}`
- Size: `{0, 200}, {0, 60}`
- Text: "⭐ VIP AREA"
- TextScaled: true
- BackgroundColor3: `255, 215, 0`
- Visible: false (verrà mostrato solo a chi ha VIP Status)

### 4. Rank Up Notification

1. In `StarterGui`, crea un **ScreenGui** chiamato `RankUpNotification`
2. Struttura:

```
RankUpNotification (ScreenGui)
└── Frame
    ├── TitleLabel (TextLabel) - "RANK UP!"
    └── RankNameLabel (TextLabel)
```

**Frame:**
- AnchorPoint: `0.5, 0`
- Position: `{0.5, 0}, {-0.2, 0}`
- Size: `{0, 400}, {0, 150}`
- Visible: false

---

## 🗺️ Setup Mappa

### 1. Spawn Platform

1. Crea una **Part** nel `Workspace`:
   - Name: `SpawnPlatform`
   - Size: `20, 1, 20`
   - Position: `0, 0.5, 0`
   - Anchored: true
   - Material: SmoothPlastic

2. Aggiungi uno **SpawnLocation** sopra la platform

### 2. VIP Spawn (opzionale, per VIP Area)

1. Crea una **Part** nel `Workspace`:
   - Name: `VIPSpawn`
   - Size: `15, 1, 15`
   - Position: `0, 100, 0` (o dove preferisci)
   - Anchored: true
   - BrickColor: Bright yellow

### 3. Leaderboard Parts (create automaticamente)

Gli script creeranno automaticamente:
- `GlobalLeaderboard_AFK` - Leaderboard globale AFK Time
- `GlobalLeaderboard_Cash` - Leaderboard globale Cash

Se vuoi posizionarle manualmente, crea 2 Parts nel Workspace con questi nomi e lo script le troverà.

---

## 🧪 Testing

### 1. Test in Studio

1. **Abilita API Services:**
   - Home → Game Settings → Security
   - Abilita "Enable Studio Access to API Services"

2. **Avvia Test:**
   - Premi F5 o clicca "Play"
   - Verifica che:
     - ✅ Cash aumenta automaticamente
     - ✅ Leaderboard locale mostra Cash e AFK Time
     - ✅ Shop si apre cliccando bottone
     - ✅ Rank up funziona dopo 1 minuto (Lazy → Chill)

3. **Test Multiplayer:**
   - Usa "Test" → "Local Server" → 2+ Players
   - Verifica che boost server funzioni per tutti

### 2. Test Gamepass/Dev Products

**IMPORTANTE:** In Studio, i gamepass non funzionano completamente. Devi testare in un published game.

1. Pubblica il gioco su Roblox
2. Crea i gamepass e dev products nella dashboard
3. Aggiorna gli ID in `Config.lua`
4. Testa acquisti

---

## 🚀 Deploy

### 1. Configura ID Prodotti

In `ReplicatedStorage/Modules/Config.lua`, verifica che tutti gli ID siano corretti:

```lua
Config.Gamepasses = {
    x2Income = {
        ID = 1671785492,  -- ⚠️ Sostituisci con il TUO ID
        ...
    },
    ...
}

Config.DevProducts = {
    Boost10Min = {
        ID = 3513599959,  -- ⚠️ Sostituisci con il TUO ID
        ...
    },
    ...
}
```

### 2. Abilita DataStore

1. Game Settings → Security
2. Abilita "Enable Studio Access to API Services"

### 3. Pubblica

1. File → Publish to Roblox
2. Compila descrizione e thumbnail
3. Pubblica!

### 4. Crea Gamepass e Dev Products

**Gamepass:**
1. Vai alla dashboard del gioco su Roblox.com
2. Create → Passes
3. Crea i 4 gamepass con i prezzi nella roadmap
4. Copia gli ID e aggiornali in Config.lua

**Dev Products:**
1. Create → Developer Products
2. Crea i 9 prodotti
3. Copia gli ID e aggiornali in Config.lua

### 5. Test Live

Entra nel gioco pubblicato e testa:
- ✅ DataStore salva/carica correttamente
- ✅ Gamepass acquistabili
- ✅ Dev Products acquistabili
- ✅ Offline Earnings funziona (esci e rientra)
- ✅ Leaderboard globale si aggiorna

---

## 🐛 Troubleshooting

### Problema: "Unable to find module Config"

**Soluzione:** Verifica che tutti i ModuleScript in ReplicatedStorage/Modules abbiano i nomi ESATTI (case-sensitive).

### Problema: RemoteEvents non funzionano

**Soluzione:**
1. Verifica che la cartella Events esista in ReplicatedStorage
2. Verifica che tutti i RemoteEvent abbiano i nomi esatti
3. Controlla la console per errori

### Problema: DataStore non salva

**Soluzione:**
1. Abilita "Enable Studio Access to API Services"
2. Se in Studio, usa "Local Server" test
3. In gioco pubblicato, attendi 60 secondi per auto-save

### Problema: Gamepass non funzionano

**Soluzione:**
1. Verifica che gli ID in Config.lua siano corretti
2. I gamepass funzionano solo in giochi pubblicati, non in Studio
3. Controlla la console per errori

### Problema: Leaderboard globale vuota

**Soluzione:**
1. Attendi 5 minuti per il primo aggiornamento
2. Verifica che ci siano player con dati salvati
3. Controlla la console per errori DataStore

### Problema: UI non visibile

**Soluzione:**
1. Verifica che i ScreenGui siano in StarterGui (non PlayerGui)
2. Controlla che i LocalScript siano dentro i ScreenGui corretti
3. Verifica i nomi dei frame (case-sensitive)

---

## 📊 Monitoring

### Console Logs

Il gioco produce log dettagliati:

```
[MainServer] Player joined: Username
[DataManager] Profilo caricato per Username
[CashManager] Player inizializzato: Username
[RankManager] Username ha raggiunto il rank: Chill
[GlobalLeaderboard] Aggiornamento top 100...
```

### DataStore Usage

Monitor l'utilizzo DataStore nella dashboard:
- Auto-save ogni 60 secondi
- Save on player leave
- Global leaderboard update ogni 5 minuti

---

## 🎯 Prossimi Passi

1. **Personalizza la mappa** - Aggiungi decorazioni, sky, lighting
2. **Aggiungi SFX/Music** - Musica ambient, sound effects per rank up
3. **Crea thumbnail** - Design accattivante per attirare player
4. **Marketing** - Pubblica sui social, sponsor ads
5. **Analytics** - Monitora conversion rate gamepass/dev products

---

## 📞 Support

Se hai problemi:
1. Controlla la sezione Troubleshooting
2. Leggi i log nella console Output
3. Verifica che tutti gli script siano al posto giusto
4. Controlla che tutti gli ID siano corretti

---

## 🎮 Buon Lancio!

Il gioco è pronto! Segui questi passaggi e avrai "DO NOTHING TO GET RICH" funzionante al 100%.

**Remember:** "The less you play, the richer you get!" 💸
