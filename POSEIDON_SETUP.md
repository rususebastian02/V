# 🔱 Poseidon - Istruzioni Installazione

## ✅ File Necessari

Hai questi 3 file per Poseidon:
1. **PoseidonAbilities.lua** - Sistema VFX completo
2. **POSEIDON_ANIMATION_GUIDE.md** - Guida per creare le animazioni
3. **StyleManager.lua** (già aggiornato) - Integrazione VFX

---

## 🔧 INSTALLAZIONE

### Step 1: Copia PoseidonAbilities.lua

1. Apri Roblox Studio
2. Vai in **ReplicatedStorage**
3. Clicca destro → **Insert Object** → **ModuleScript**
4. Rinomina in `PoseidonAbilities`
5. Copia **tutto il contenuto** di `PoseidonAbilities.lua` nel ModuleScript
6. Salva

### Step 2: Verifica StyleManager.lua

Il file `StyleManager.lua` è già stato aggiornato con:
- Integrazione PoseidonAbilities (linea 11)
- Funzioni helper per combat (linee 42-103)
- Gestione VFX Poseidon (linee 307-320)
- Nomi abilità autentici (linee 115-117)

**Assicurati di aver aggiornato il file in ServerScriptService!**

### Step 3: (Opzionale) Crea le Animazioni

Se vuoi animazioni custom per Poseidon:

1. Segui la guida **POSEIDON_ANIMATION_GUIDE.md**
2. Crea le 4 animazioni (Basic Attack, Amphitrite, Chione Tyro Demeter, 40 Day Flood)
3. Salva su Roblox e ottieni gli Animation ID
4. Integrali nel sistema (vedi sotto)

**Se NON vuoi creare animazioni ora:**
- Il sistema funziona comunque!
- Gli effetti VFX sono già spettacolari
- Puoi aggiungere animazioni in seguito

---

## 🎮 TESTING POSEIDON

### Test 1: Selezione Personaggio
1. Premi **Play** in Roblox Studio
2. Seleziona **Poseidon** dalla GUI (categoria Gods)
3. La GUI dovrebbe chiudersi
4. Output: `✅ [StyleManager] [TuoNome] ha scelto: Poseidon`

### Test 2: Verifica UI Abilità
Dovresti vedere in basso al centro 3 bottoni:
- **Q** - Amphitrite
- **E** - Chione Tyro Demeter
- **R** - 40 Day Flood

### Test 3: Usa le Abilità

**Amphitrite (Q)**:
- Premi **Q**
- Dovresti vedere:
  - Vortice d'acqua blu che ruota
  - Trail d'acqua sul personaggio
  - Particelle circolari (afterimages)
  - Suono d'acqua
- Cooldown: 7 secondi
- Damage: 50

**Chione Tyro Demeter (E)**:
- Premi **E**
- Dovresti vedere:
  - Il personaggio salta in aria
  - Pioggia di lance d'acqua blu cadono
  - Trail sulle lance
  - Splash all'atterraggio
  - Onde d'urto circolari
- Cooldown: 12 secondi
- Damage: 70

**40 Day Flood (R - Ultimate)**:
- Premi **R**
- Dovresti vedere:
  - Sfera d'acqua che cresce (carica)
  - Cupola massiccia blu che ruota
  - Afterimages circolari (whirlpool)
  - Implosione + esplosione finale
  - Onde d'urto multiple
  - **Knockback** sui nemici
- Cooldown: 20 secondi
- Damage: 100

### Test 4: Combat Reale

Per testare il combattimento:

**Opzione A: Con un amico**
1. Un amico entra nel gioco
2. Selezionate personaggi diversi
3. Combattete!

**Opzione B: Con un Dummy**
1. Inserisci un **Dummy** (Rig) nella Workspace
2. Aggiungi un **Humanoid** se non c'è
3. Usa le abilità vicino al Dummy
4. Gli effetti VFX funzioneranno comunque

**Opzione C: Test Server**
1. In Studio: **Test** → **Start Server and Players**
2. Avvia con 2+ giocatori
3. Controlla gli effetti da entrambe le prospettive

---

## 🐛 Troubleshooting

### ❌ Errore: "PoseidonAbilities is not a valid member of ReplicatedStorage"

**Causa**: Il ModuleScript non è stato creato correttamente

**Soluzione**:
1. Verifica che in **ReplicatedStorage** ci sia un **ModuleScript** chiamato `PoseidonAbilities`
2. Il nome deve essere **esatto** (case-sensitive)
3. Deve essere un **ModuleScript**, non uno Script o LocalScript

### ❌ Gli effetti non appaiono

**Causa**: Possibile errore nel codice VFX

**Soluzione**:
1. Apri **Output** (View → Output)
2. Cerca messaggi di errore rossi
3. Verifica di aver copiato tutto il codice di PoseidonAbilities.lua
4. Controlla che non ci siano errori di sintassi

### ❌ "attempt to index nil with 'Amphitrite'"

**Causa**: PoseidonAbilities non è stato richiesto correttamente

**Soluzione**:
1. Verifica che StyleManager.lua abbia alla linea 11:
   ```lua
   local PoseidonAbilities = require(ReplicatedStorage:WaitForChild("PoseidonAbilities"))
   ```
2. Riavvia il gioco (Stop → Play)

### ❌ L'abilità non va in cooldown

**Causa**: Client e server non sincronizzati

**Soluzione**:
1. Normale per la prima volta
2. Il cooldown viene aggiornato dopo il secondo uso
3. Se persiste, riavvia il gioco

### ❌ Il personaggio vola via con Chione Tyro Demeter

**Causa**: Il movimento verticale è troppo forte

**Soluzione**:
1. Apri PoseidonAbilities.lua
2. Alla linea ~237, riduci `jumpHeight`:
   ```lua
   local jumpHeight = 10  -- Era 15
   ```

---

## 🎨 Personalizzazione

### Modificare i Colori

Per cambiare i colori dell'acqua di Poseidon:

Apri `PoseidonAbilities.lua`, trova la funzione `createWaterParticle`:

```lua
Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 100, 200)),   -- Blu scuro
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 150, 255)), -- Blu medio
    ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 200, 255))   -- Blu chiaro
})
```

Cambia i valori RGB per colori diversi!

### Modificare Damage/Cooldown

Apri `StyleManager.lua`, linee 115-117:

```lua
{Name = "Amphitrite", Damage = 50, Cooldown = 7, Key = "Q"},
{Name = "Chione Tyro Demeter", Damage = 70, Cooldown = 12, Key = "E"},
{Name = "40 Day Flood", Damage = 100, Cooldown = 20, Key = "R"}
```

Modifica `Damage` e `Cooldown` a piacimento.

### Modificare Range Abilità

Apri `StyleManager.lua`, linee 36-40:

```lua
local ABILITY_RANGES = {
    Q = 12,  -- Range Amphitrite
    E = 15,  -- Range Chione Tyro Demeter
    R = 20   -- Range 40 Day Flood
}
```

Aumenta/diminuisci per cambiare quanto lontano colpiscono le abilità.

---

## ➕ Aggiungere Animazioni (Opzionale)

Se hai creato le animazioni seguendo la guida:

1. **Ottieni gli Animation ID** salvati
2. **Crea funzione helper** in PoseidonAbilities.lua:

```lua
-- In cima al file, dopo local PoseidonAbilities = {}
local POSEIDON_ANIMATIONS = {
    BasicAttack = "rbxassetid://XXXXXXXXX",
    Amphitrite = "rbxassetid://XXXXXXXXX",
    ChioneTyroDemeter = "rbxassetid://XXXXXXXXX",
    FortyDayFlood = "rbxassetid://XXXXXXXXX"
}

local function playAnimation(character, animId)
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    local animation = Instance.new("Animation")
    animation.AnimationId = animId

    local track = animator:LoadAnimation(animation)
    track:Play()

    return track
end
```

3. **Chiama le animazioni** all'inizio di ogni abilità:

```lua
function PoseidonAbilities.Amphitrite(attacker, targets)
    -- AGGIUNGI QUESTA LINEA:
    playAnimation(attacker.Character, POSEIDON_ANIMATIONS.Amphitrite)

    -- Resto del codice VFX...
end
```

---

## ✅ Checklist Completamento

- [ ] PoseidonAbilities.lua copiato in ReplicatedStorage come ModuleScript
- [ ] StyleManager.lua aggiornato in ServerScriptService
- [ ] Gioco avviato senza errori nell'Output
- [ ] Poseidon selezionabile dalla GUI
- [ ] Abilità Q (Amphitrite) funziona con VFX
- [ ] Abilità E (Chione Tyro Demeter) funziona con salto + pioggia
- [ ] Abilità R (40 Day Flood) funziona con cupola + esplosione
- [ ] Cooldown funziona correttamente
- [ ] Damage viene applicato ai nemici
- [ ] (Opzionale) Animazioni create e integrate

---

## 🚀 Prossimi Personaggi

Dopo aver testato Poseidon, possiamo creare:
- **Zeus** (Lightning VFX)
- **Thor** (Thunder + Hammer)
- **Shiva** (Fire + 4 arms mechanics)
- **Hades** (Dark wind blades)
- **Adam** (Copy mechanics)
- **Buddha** (Future vision + staff transforms)
- E tutti gli altri!

---

**Versione**: 1.0
**Data**: 2026-01-06
**Personaggio**: Poseidon - God of the Sea

🌊 **Buon divertimento con Poseidon!** 🔱
