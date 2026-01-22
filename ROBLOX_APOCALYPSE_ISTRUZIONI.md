# 🌋 Gioco Apocalisse Roblox - Istruzioni di Installazione

## 📋 Descrizione del Gioco

Un'esperienza apocalittica dove:
- ⏰ **Countdown di 30 minuti** prima dell'inizio dell'apocalisse
- 🌅 **Atmosfera giallo/arancio** come se il sole si stesse avvicinando
- 🔥 **Effetto blur** leggero sullo schermo
- 🌫️ **Particelle di cenere** che escono dai player
- ✨ **Disintegrazione stile "Thanos Snap"** con particelle di polverizzazione
- 💀 **I player perdono vita** progressivamente fino alla morte
- 🔄 **Reset automatico** del mondo e del countdown quando tutti sono morti

---

## 🛠️ Installazione degli Script

### ⚙️ Script 1: ApocalypseCountdownServer.lua

**📂 POSIZIONE:** `ServerScriptService`

**📝 ISTRUZIONI:**
1. Apri Roblox Studio
2. Nel pannello "Explorer", trova **ServerScriptService**
3. Fai click destro su **ServerScriptService**
4. Seleziona **Insert Object** → **Script**
5. Rinomina lo script in `ApocalypseCountdownServer`
6. Apri lo script e **incolla tutto il contenuto** del file `ApocalypseCountdownServer.lua`
7. Salva

---

### 👁️ Script 2: ApocalypseClientEffects.lua

**📂 POSIZIONE:** `StarterPlayer > StarterPlayerScripts`

**📝 ISTRUZIONI:**
1. Nel pannello "Explorer", espandi **StarterPlayer**
2. Espandi **StarterPlayerScripts**
3. Fai click destro su **StarterPlayerScripts**
4. Seleziona **Insert Object** → **LocalScript**
5. Rinomina lo script in `ApocalypseClientEffects`
6. Apri lo script e **incolla tutto il contenuto** del file `ApocalypseClientEffects.lua`
7. Salva

---

### ✨ Script 3: ApocalypseParticles.lua

**📂 POSIZIONE:** `StarterPlayer > StarterPlayerScripts`

**📝 ISTRUZIONI:**
1. Nel pannello "Explorer", vai su **StarterPlayer > StarterPlayerScripts**
2. Fai click destro su **StarterPlayerScripts**
3. Seleziona **Insert Object** → **LocalScript**
4. Rinomina lo script in `ApocalypseParticles`
5. Apri lo script e **incolla tutto il contenuto** del file `ApocalypseParticles.lua`
6. Salva

---

### 🖥️ Script 4: CountdownGUI.lua

**📂 POSIZIONE:** `StarterPlayer > StarterPlayerScripts`

**📝 ISTRUZIONI:**
1. Nel pannello "Explorer", vai su **StarterPlayer > StarterPlayerScripts**
2. Fai click destro su **StarterPlayerScripts**
3. Seleziona **Insert Object** → **LocalScript**
4. Rinomina lo script in `CountdownGUI`
5. Apri lo script e **incolla tutto il contenuto** del file `CountdownGUI.lua`
6. Salva

---

## 🎮 Struttura Finale

Quando hai finito, la tua struttura dovrebbe essere così:

```
📦 Workspace
└── (il tuo mondo di gioco)

📦 ServerScriptService
└── 📜 ApocalypseCountdownServer

📦 StarterPlayer
└── 📁 StarterPlayerScripts
    ├── 📜 ApocalypseClientEffects (LocalScript)
    ├── 📜 ApocalypseParticles (LocalScript)
    └── 📜 CountdownGUI (LocalScript)

📦 ReplicatedStorage
└── (verrà creato automaticamente dagli script)
    ├── ApocalypseEvent (RemoteEvent)
    └── CountdownValue (IntValue)
```

---

## ⚙️ Configurazione

Puoi modificare questi parametri nello script **ApocalypseCountdownServer**:

```lua
local COUNTDOWN_TIME = 30 * 60  -- Tempo del countdown (default: 30 minuti)
local DAMAGE_PER_SECOND = 5     -- Danno inflitto ai player (default: 5)
local APOCALYPSE_DURATION = 15  -- Durata dell'apocalisse in secondi (default: 15)
```

**Esempio per un countdown di 5 minuti:**
```lua
local COUNTDOWN_TIME = 5 * 60  -- 5 minuti
```

---

## 🧪 Test del Gioco

1. Clicca sul pulsante **Play** (▶️) in Roblox Studio
2. Aspetta il countdown (o modifica `COUNTDOWN_TIME` a un valore più basso per testare più velocemente)
3. Osserva gli effetti dell'apocalisse:
   - Atmosfera che diventa giallo/arancio
   - Leggero blur
   - Particelle di cenere
   - Particelle di disintegrazione
   - Perdita di vita
4. Quando tutti i player muoiono, il gioco si resetta

---

## 🐛 Risoluzione Problemi

### ❌ Gli script non funzionano
- Verifica che tutti gli script siano nella **posizione corretta**
- Assicurati che gli script nel **StarterPlayerScripts** siano **LocalScript** (non Script normali)
- Controlla la **Output Console** per eventuali errori (View → Output)

### ❌ Le particelle non appaiono
- Verifica che lo script **ApocalypseParticles** sia un **LocalScript**
- Controlla che sia in **StarterPlayerScripts**

### ❌ La GUI del countdown non appare
- Verifica che lo script **CountdownGUI** sia un **LocalScript**
- Controlla che sia in **StarterPlayerScripts**

### ❌ Il countdown non inizia
- Verifica che lo script **ApocalypseCountdownServer** sia in **ServerScriptService**
- Verifica che sia uno **Script normale** (non LocalScript)
- Controlla la Output Console per errori

---

## 🎨 Personalizzazioni Consigliate

### Cambiare i colori dell'apocalisse
Nello script **ApocalypseClientEffects**, modifica:
```lua
local apocalypseAmbient = Color3.fromRGB(255, 150, 50)  -- Colore ambientale
local apocalypseOutdoorAmbient = Color3.fromRGB(255, 180, 80)  -- Colore esterno
local apocalypseFogColor = Color3.fromRGB(255, 140, 40)  -- Colore nebbia
```

### Cambiare l'intensità del blur
Nello script **ApocalypseClientEffects**, modifica:
```lua
{Size = 3}  -- Aumenta per più blur, diminuisci per meno blur
```

### Modificare le particelle
Negli script **ApocalypseParticles**, puoi modificare:
- `Rate` - Numero di particelle al secondo
- `Speed` - Velocità delle particelle
- `Lifetime` - Durata delle particelle
- `Size` - Dimensione delle particelle

---

## ✅ Checklist Finale

- [ ] Script **ApocalypseCountdownServer** in **ServerScriptService**
- [ ] Script **ApocalypseClientEffects** in **StarterPlayerScripts** (LocalScript)
- [ ] Script **ApocalypseParticles** in **StarterPlayerScripts** (LocalScript)
- [ ] Script **CountdownGUI** in **StarterPlayerScripts** (LocalScript)
- [ ] Testato il gioco premendo Play
- [ ] Countdown funziona correttamente
- [ ] Effetti visivi attivati (blur, atmosfera giallo/arancio)
- [ ] Particelle di cenere appaiono
- [ ] Particelle di disintegrazione appaiono
- [ ] Player perdono vita e muoiono
- [ ] Gioco si resetta automaticamente

---

## 🎉 Buon Divertimento!

Il tuo gioco apocalittico è pronto! Ora puoi:
- Invitare amici a giocare
- Personalizzare ulteriormente gli effetti
- Aggiungere suoni e musica
- Creare ostacoli o safe zone
- Aggiungere power-up per sopravvivere più a lungo

**Buona apocalisse! 🌋**
