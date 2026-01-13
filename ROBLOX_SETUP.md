# 🎮 SISTEMA DI ROUND PER ROBLOX

## 📋 FILE CREATI

1. **RoundSystem.lua** - Script principale (Server)
2. **CountdownGui.lua** - GUI Countdown (Client)
3. **LeaderboardGui.lua** - GUI Leaderboard (Client)

---

## 🚀 INSTALLAZIONE RAPIDA

### 1️⃣ SERVER SCRIPT (RoundSystem.lua)

**Dove:** `ServerScriptService`

1. Apri Roblox Studio
2. Vai su **ServerScriptService**
3. Clicca **+** → **Script**
4. Rinomina in **"RoundSystem"**
5. Copia tutto il contenuto di `ServerScriptService/RoundSystem.lua`
6. Incolla nello script

### 2️⃣ COUNTDOWN GUI (CountdownGui.lua)

**Dove:** `StarterGui`

1. Vai su **StarterGui**
2. Clicca **+** → **ScreenGui**
3. Rinomina in **"CountdownGui"**
4. Clicca sul **CountdownGui** → **+** → **TextLabel**
5. Rinomina il TextLabel in **"CountdownLabel"**
6. Clicca sul **CountdownGui** → **+** → **LocalScript**
7. Copia tutto il contenuto di `StarterGui/CountdownGui.lua`
8. Incolla nel LocalScript

### 3️⃣ LEADERBOARD GUI (LeaderboardGui.lua)

**Dove:** `StarterGui`

1. Vai su **StarterGui**
2. Clicca **+** → **LocalScript**
3. Rinomina in **"LeaderboardScript"**
4. Copia tutto il contenuto di `StarterGui/LeaderboardGui.lua`
5. Incolla nel LocalScript

---

## 🗺️ ZONE RICHIESTE (Opzionali - si creano automaticamente)

Il sistema crea automaticamente le zone se non esistono, ma puoi crearle manualmente:

### SpawnZone (Verde)
- Vai su **Workspace**
- **+** → **Part**
- Rinomina in **"SpawnZone"**
- Posiziona dove vuoi che i giocatori inizino

### SpectatorZone (Blu)
- Vai su **Workspace**
- **+** → **Part**
- Rinomina in **"SpectatorZone"**
- Posiziona dove vanno gli spettatori

---

## ⚙️ CONFIGURAZIONE

Apri `RoundSystem` e modifica la sezione `CONFIG`:

```lua
local CONFIG = {
    COUNTDOWN_TIME = 10,      -- Secondi di countdown
    INTERMISSION_TIME = 5,    -- Pausa tra round
    MAX_ROUND_TIME = 300,     -- Durata massima round (0 = infinito)
    MIN_PLAYERS = 2,          -- Giocatori minimi per iniziare
}
```

---

## ✅ COME FUNZIONA

1. **Attesa giocatori** → Aspetta MIN_PLAYERS
2. **Intermissione** → Pausa di INTERMISSION_TIME secondi
3. **Countdown** → Conto alla rovescia di COUNTDOWN_TIME secondi
4. **Round inizia** → Tutti i giocatori spawano in SpawnZone
5. **Giocatori nuovi** → Entrano come spettatori in SpectatorZone
6. **Giocatori eliminati** → Vanno in SpectatorZone dopo la morte
7. **Fine round** → Quando resta 1 o 0 giocatori
8. **Leaderboard** → Mostra classifica per tempo di sopravvivenza
9. **Ripete** → Ricomincia dal punto 1

---

## 🎯 CARATTERISTICHE

✅ Countdown animato prima del round
✅ Sistema di spettatori automatico
✅ Leaderboard con classifica finale
✅ Tempo di sopravvivenza per ogni giocatore
✅ Annuncio del vincitore
✅ Zone create automaticamente
✅ Gestione giocatori che entrano/escono
✅ Monitoraggio morti in tempo reale

---

## 🐛 TROUBLESHOOTING

**Il countdown non appare?**
- Verifica che CountdownLabel esista in CountdownGui
- Controlla che il LocalScript sia dentro CountdownGui

**La leaderboard non si vede?**
- Il LocalScript deve essere in StarterGui
- Controlla la console per errori

**I giocatori non vengono teleportati?**
- Le zone si creano automaticamente
- Puoi crearle manualmente (vedi sezione Zone)

**Il round non inizia?**
- Verifica MIN_PLAYERS in CONFIG
- Assicurati ci siano abbastanza giocatori

---

## 📝 NOTE

- **Tutto automatico**: Basta copiare i 3 file e funziona
- **Zone opzionali**: Si creano da sole se non esistono
- **Personalizzabile**: Modifica CONFIG per cambiare tempi
- **Pronto per il test**: Premi Play e testa con almeno 2 giocatori

---

**Creato per Roblox Lua | Sistema di Round Completo**
