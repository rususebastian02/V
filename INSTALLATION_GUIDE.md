# 🎮 Record of Ragnarok - Guida Installazione Completa

## 📋 Indice
1. [Prerequisiti](#prerequisiti)
2. [Struttura File](#struttura-file)
3. [Installazione Passo-Passo](#installazione-passo-passo)
4. [Configurazione RemoteEvents](#configurazione-remoteevents)
5. [Testing](#testing)
6. [Troubleshooting](#troubleshooting)

---

## ✅ Prerequisiti

- Roblox Studio installato e aggiornato
- Una lobby/arena già creata nella mappa
- Spawn point configurato nella lobby

---

## 📁 Struttura File

Il sistema è composto da **4 script principali** che devono essere posizionati nei container corretti:

```
ReplicatedStorage/
├── SelectStyle (RemoteEvent - creato automaticamente)
├── UseAbility (RemoteEvent - creato automaticamente)
└── BasicAttack (RemoteEvent - creato automaticamente)

ServerScriptService/
├── StyleManager.lua (Script)
└── CombatHandler.lua (Script)

StarterGui/
└── StyleSelectionGUI.lua (LocalScript)

StarterPlayerScripts/
└── CombatController.lua (LocalScript)
```

---

## 🔧 Installazione Passo-Passo

### **STEP 1: Server-Side Scripts**

#### 1.1 - StyleManager.lua
1. Apri Roblox Studio
2. Vai in **ServerScriptService**
3. Clicca destro → **Insert Object** → **Script**
4. Rinomina in `StyleManager`
5. Copia tutto il contenuto di `StyleManager.lua` nello script
6. Lo script creerà automaticamente i RemoteEvents necessari

#### 1.2 - CombatHandler.lua
1. Sempre in **ServerScriptService**
2. Clicca destro → **Insert Object** → **Script**
3. Rinomina in `CombatHandler`
4. Copia tutto il contenuto di `CombatHandler.lua` nello script

### **STEP 2: Client-Side Scripts**

#### 2.1 - StyleSelectionGUI.lua
1. Vai in **StarterGui**
2. Clicca destro → **Insert Object** → **LocalScript**
3. Rinomina in `StyleSelectionGUI`
4. Copia tutto il contenuto di `StyleSelectionGUI.lua` nello script
5. Questo script creerà automaticamente la GUI di selezione

#### 2.2 - CombatController.lua
1. Vai in **StarterPlayerScripts**
2. Clicca destro → **Insert Object** → **LocalScript**
3. Rinomina in `CombatController`
4. Copia tutto il contenuto di `CombatController.lua` nello script
5. Questo script creerà automaticamente l'interfaccia abilità (Q, E, R)

---

## 🌐 Configurazione RemoteEvents

I RemoteEvents vengono creati **AUTOMATICAMENTE** dagli script, ma è importante verificare che esistano:

### Verifica (dopo il primo avvio):
1. Vai in **ReplicatedStorage**
2. Dovresti vedere questi 3 RemoteEvents:
   - `SelectStyle`
   - `UseAbility`
   - `BasicAttack`

Se non li vedi, verifica l'Output per eventuali errori.

---

## 🎯 Testing

### Test 1: Selezione Stile
1. Premi **Play** in Roblox Studio
2. Dovrebbe apparire la GUI di selezione con 2 categorie:
   - **⚡ GODS** (sinistra): Poseidon, Zeus, Shiva, Thor, Hades
   - **👤 HUMANS** (destra): Adam, Qin Shi Huang, Jack the Ripper, Lü Bu, Buddha
3. Clicca su uno stile → la GUI dovrebbe chiudersi
4. Controlla l'Output per vedere: `✅ [StyleManager] [Nome] ha scelto: [Stile]`

### Test 2: Combat UI
1. Dopo aver selezionato uno stile, dovresti vedere in basso al centro:
   - 3 bottoni con le lettere **Q**, **E**, **R**
   - Questi rappresentano le abilità del tuo personaggio

### Test 3: Attacco Base
1. Avvicinati a un altro giocatore (o dummy se presente)
2. Clicca con il mouse sinistro
3. Dovresti vedere nell'Output: `👊 [CombatController] Attacco base!`
4. Se sei vicino a un nemico, verrà danneggiato

### Test 4: Abilità
1. Premi **Q**, **E**, o **R** sulla tastiera
2. L'abilità verrà usata (se non è in cooldown)
3. Il bottone corrispondente diventerà rosso e mostrerà il tempo rimanente
4. Output: `⚡ [CombatController] Uso abilità: Q/E/R`

---

## 🐛 Troubleshooting

### ❌ La GUI di selezione non appare

**Causa**: LocalScript non in esecuzione o errore di caricamento

**Soluzione**:
1. Verifica che `StyleSelectionGUI.lua` sia in **StarterGui** come **LocalScript**
2. Apri l'Output (View → Output)
3. Cerca messaggi di errore o `⚔️ [StyleSelector] Inizializzazione...`
4. Se non vedi nulla, lo script non sta partendo → controlla di averlo salvato correttamente

### ❌ RemoteEvent non trovati

**Output**: `❌ [StyleSelector] RemoteEvent 'SelectStyle' non trovato!`

**Soluzione**:
1. Assicurati che `StyleManager.lua` sia in **ServerScriptService**
2. Lo script server deve partire **PRIMA** dello script client
3. Riavvia il gioco (Stop → Play)
4. I RemoteEvents verranno creati automaticamente al primo avvio

### ❌ Le abilità non funzionano

**Causa**: Possibili problemi di sincronizzazione client-server

**Soluzione**:
1. Verifica che `UseAbility` esista in ReplicatedStorage
2. Controlla l'Output per messaggi di cooldown: `⏳ [StyleManager] ... in cooldown: Xs`
3. Se non vedi messaggi, il server non riceve la richiesta
4. Verifica che `CombatController.lua` sia in **StarterPlayerScripts**

### ❌ Gli attacchi non colpiscono

**Causa**: Range troppo piccolo o angolo troppo stretto

**Soluzione**:
1. Apri `CombatHandler.lua`
2. Trova le righe:
   ```lua
   local HIT_RANGE = 10
   local HIT_ANGLE = 90
   ```
3. Prova ad aumentare:
   ```lua
   local HIT_RANGE = 15  -- Aumenta range
   local HIT_ANGLE = 120 -- Aumenta angolo
   ```

### ❌ Il personaggio non spawna con la vita corretta

**Causa**: Humanoid.MaxHealth non aggiornato correttamente

**Soluzione**:
1. Apri `StyleManager.lua`
2. Nella funzione `applyStyle`, verifica che ci sia:
   ```lua
   local humanoid = character:WaitForChild("Humanoid")
   humanoid.MaxHealth = config.Health
   humanoid.Health = config.Health
   ```
3. Se il problema persiste, aggiungi un `wait(0.1)` prima di impostare la vita

---

## 📊 Configurazione Stili (Opzionale)

Se vuoi modificare damage, health o cooldown degli stili:

1. Apri `StyleManager.lua`
2. Trova la tabella `STYLE_CONFIGS`
3. Modifica i valori per ogni stile:

```lua
Poseidon = {
    BaseDamage = 25,      -- Damage attacco base
    AttackSpeed = 1.2,    -- Velocità attacco (non implementato ancora)
    Health = 100,         -- Vita massima
    Abilities = {
        {Name = "Tidal Wave", Damage = 50, Cooldown = 8, Key = "Q"},
        {Name = "Ocean's Wrath", Damage = 80, Cooldown = 15, Key = "E"},
        {Name = "Poseidon's Blessing", Damage = 0, Cooldown = 20, Key = "R"}
    }
}
```

---

## ✅ Checklist Finale

Prima di pubblicare il gioco, verifica:

- [ ] Tutti e 4 gli script sono nei container corretti
- [ ] I 3 RemoteEvents esistono in ReplicatedStorage
- [ ] La GUI di selezione appare correttamente
- [ ] Tutti i 10 personaggi sono selezionabili
- [ ] L'interfaccia abilità (Q, E, R) appare dopo la selezione
- [ ] Gli attacchi base funzionano con il click
- [ ] Le abilità Q, E, R funzionano e vanno in cooldown
- [ ] Il sistema di cooldown visuale funziona correttamente
- [ ] I giocatori muoiono e rispawnano correttamente

---

## 🎨 Prossimi Step (Opzionali)

Dopo aver verificato che il sistema base funziona, puoi:

1. **Aggiungere VFX/Particelle** per le abilità
2. **Creare armi/tool visuali** per ogni personaggio
3. **Implementare meccaniche speciali** (copia di Adam, future vision di Buddha, etc.)
4. **Aggiungere animazioni custom** per ogni abilità
5. **Creare suoni** per attacchi e abilità
6. **Sistema di kill/death** con leaderboard FFA
7. **Round system** con timer e vittoria

---

## 📞 Supporto

Se incontri problemi:

1. Controlla sempre l'**Output** per messaggi di errore
2. Verifica che tutti gli script siano nei container corretti
3. Riavvia il gioco (Stop → Play)
4. Confronta i tuoi script con i file originali

---

## 📖 Riferimenti

- **AUTHENTIC_MOVES_REFERENCE.md**: Mosse autentiche di ogni personaggio
- **StyleManager.lua**: Configurazione stili e abilità
- **CombatController.lua**: Input e UI client-side
- **CombatHandler.lua**: Logica combattimento server-side
- **StyleSelectionGUI.lua**: GUI selezione personaggi

---

**Versione**: 1.0
**Data**: 2026-01-06
**Autore**: Claude Code

🎮 **Buon divertimento con Record of Ragnarok!** ⚔️
