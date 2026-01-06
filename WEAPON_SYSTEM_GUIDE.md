# 🔱 Sistema Armi - Guida Completa

## 📋 Indice
1. [Creare il Tridente di Poseidon](#creare-il-tridente)
2. [Sistema Tool Automatico](#sistema-tool-automatico)
3. [Animare con il Tridente](#animare-con-il-tridente)
4. [Multiple Animazioni Attacco Base](#multiple-animazioni-attacco-base)

---

## 🔱 PARTE 1: Creare il Tridente di Poseidon

### Metodo 1: Tool Semplice (Raccomandato per Iniziare)

#### Step 1: Creare la Struttura Tool

1. In **Roblox Studio**, vai in **ReplicatedStorage**
2. **Insert Object** → **Tool**
3. Rinomina in `PoseidonTrident`
4. Proprietà del Tool:
   - **RequiresHandle**: `true`
   - **CanBeDropped**: `false` (non può essere droppato)
   - **ManualActivationOnly**: `false`

#### Step 2: Creare il Tridente (Handle)

Dentro il Tool `PoseidonTrident`:

1. **Insert Object** → **Part**
2. Rinomina in `Handle` (DEVE chiamarsi Handle!)
3. Proprietà:
   - **Size**: `Vector3.new(0.3, 6, 0.3)` (lungo e sottile)
   - **Material**: `Neon`
   - **Color**: `RGB(30, 100, 200)` (blu oceano)
   - **CanCollide**: `false`

#### Step 3: Aggiungere le Punte (Tridenti)

1. Seleziona il `Handle`
2. **Insert Object** → **Part** (3 volte per le 3 punte)
3. Per ogni punta:
   - **Size**: `Vector3.new(0.2, 1, 0.2)`
   - **Material**: `Neon`
   - **Color**: `RGB(150, 200, 255)` (blu chiaro)
   - **Shape**: `Wedge` (a punta)

4. Posiziona le punte:
   - **Punta centrale**: `Position = (0, 3.5, 0)` rispetto all'Handle
   - **Punta sinistra**: `Position = (-0.4, 3, 0)`
   - **Punta destra**: `Position = (0.4, 3, 0)`

5. **Weld le punte all'Handle**:
   - Seleziona ogni punta
   - **Insert Object** → **WeldConstraint**
   - **Part0** = Punta
   - **Part1** = Handle

#### Step 4: Aggiungere Effetti (Opzionale)

Dentro l'`Handle`:

1. **Insert Object** → **ParticleEmitter**
2. Proprietà:
   - **Texture**: `rbxasset://textures/particles/sparkles_main.dds`
   - **Color**: ColorSequence blu acqua
   - **Rate**: `10`
   - **Lifetime**: `1`
   - **Speed**: `2`
   - **Transparency**: Fade in/out

### Metodo 2: Usare un Modello dal Marketplace

1. Vai su **Toolbox** (View → Toolbox)
2. Cerca **"trident"** o **"spear"**
3. Trova un modello gratuito che ti piace
4. Inseriscilo nella Workspace
5. Converti in Tool:
   - Rinomina la parte principale in `Handle`
   - Seleziona tutto → **Group** → **Convert to Tool**
6. Metti il Tool in **ReplicatedStorage**

---

## ⚙️ PARTE 2: Sistema Tool Automatico

Devi fare in modo che quando un giocatore seleziona Poseidon, riceva automaticamente il tridente.

### Script: Auto-Equip Weapon System

Aggiorna **StyleManager.lua** per dare il tridente automaticamente:

```lua
-- Alla fine della funzione applyStyle, PRIMA dell'ultimo 'end'
-- Aggiungi questo codice:

local function applyStyle(player, styleName)
	-- ... codice esistente ...

	-- Applica stats
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.MaxHealth = config.Health
	humanoid.Health = config.Health

	-- ⚔️ NUOVO: Equipaggia arma automaticamente
	local weaponName = config.Weapon
	if weaponName then
		-- Rimuovi armi vecchie
		for _, item in ipairs(player.Backpack:GetChildren()) do
			if item:IsA("Tool") then
				item:Destroy()
			end
		end
		for _, item in ipairs(character:GetChildren()) do
			if item:IsA("Tool") then
				item:Destroy()
			end
		end

		-- Equipaggia nuova arma
		local weaponTool = nil

		if styleName == "Poseidon" then
			weaponTool = ReplicatedStorage:FindFirstChild("PoseidonTrident")
		elseif styleName == "Zeus" then
			-- weaponTool = ReplicatedStorage:FindFirstChild("ZeusLightning")
		-- Altri personaggi...
		end

		if weaponTool then
			local newTool = weaponTool:Clone()
			newTool.Parent = character -- Equipaggia direttamente
			print("⚔️ [StyleManager] " .. player.Name .. " ha ricevuto: " .. weaponName)
		else
			warn("⚠️ [StyleManager] Arma '" .. weaponName .. "' non trovata in ReplicatedStorage")
		end
	end

	print("✅ [StyleManager] Stile applicato: " .. styleName)
end
```

**Cosa fa questo codice:**
1. Quando selezioni Poseidon
2. Rimuove eventuali armi vecchie
3. Clona il `PoseidonTrident` da ReplicatedStorage
4. Lo equipaggia direttamente sul personaggio

---

## 🎬 PARTE 3: Animare con il Tridente

### Come Creare Animazioni con l'Arma

Quando usi l'**Animation Editor**, il tridente deve essere equipaggiato:

#### Setup per Animation Editor:

1. **Inserisci un Rig** (R15 o R6) nella Workspace
2. **Equipaggia il tridente sul Rig**:
   - Trascina `PoseidonTrident` da ReplicatedStorage
   - Mettilo come child del **Rig** (non nel Backpack)
3. **Apri Animation Editor**
4. **Crea l'animazione normalmente**

#### Punti Chiave:

- Il **tridente si muoverà automaticamente** con la mano quando animi il braccio
- Il Tool segue il `RightGrip` (attachment automatico alla mano destra)
- Anima normalmente il braccio: il tridente seguirà!

#### Esempio Keyframes Attacco Base 1:

```
0.00s - Idle (tridente a lato)
0.10s - RightArm ruota indietro (carica)
       - UpperTorso ruota 20° a destra
0.30s - RightArm teso in avanti (affondo)
       - UpperTorso ruota 20° a sinistra
       - Gamba destra passo avanti
0.50s - Ritorno a idle
```

Il tridente seguirà automaticamente la mano!

---

## 🎯 PARTE 4: Multiple Animazioni Attacco Base

Per avere **varietà**, devi creare 2-3 animazioni diverse e randomizzarle.

### Creare le Animazioni

Nell'**Animation Editor**, crea 3 varianti:

#### **BasicAttack1** - Affondo dritto
- Braccio destro teso in avanti
- Passo con gamba destra

#### **BasicAttack2** - Slash orizzontale
- Braccio destro swiping da destra a sinistra
- Torso ruota 90°

#### **BasicAttack3** - Attacco dall'alto
- Braccio destro sopra la testa
- Scende in picchiata verso il basso

### Sistema di Randomizzazione

Aggiorna **PoseidonAbilities.lua** per supportare multiple animazioni:

```lua
-- In cima al file, dopo local PoseidonAbilities = {}

-- Animation IDs (sostituisci con i tuoi dopo averle create)
local POSEIDON_ANIMATIONS = {
	BasicAttacks = {
		"rbxassetid://XXXXXXXXX", -- BasicAttack1
		"rbxassetid://XXXXXXXXX", -- BasicAttack2
		"rbxassetid://XXXXXXXXX"  -- BasicAttack3
	},
	Amphitrite = "rbxassetid://XXXXXXXXX",
	ChioneTyroDemeter = "rbxassetid://XXXXXXXXX",
	FortyDayFlood = "rbxassetid://XXXXXXXXX"
}

-- Funzione per riprodurre animazione
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

-- Funzione per attacco base randomizzato
function PoseidonAbilities.BasicAttack(attacker, target)
	local character = attacker.Character
	if not character then return end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	-- ⚡ RANDOM: Scegli una delle 3 animazioni
	local randomIndex = math.random(1, #POSEIDON_ANIMATIONS.BasicAttacks)
	local selectedAnim = POSEIDON_ANIMATIONS.BasicAttacks[randomIndex]

	-- Riproduci animazione (se disponibile)
	if selectedAnim and selectedAnim ~= "rbxassetid://XXXXXXXXX" then
		playAnimation(character, selectedAnim)
	end

	-- Suono colpo
	playSound("rbxassetid://9114487369", rootPart, 0.4)

	-- Splash sulla vittima
	if target and target.Position then
		createSplashEffect(target.Position)
	end

	-- Particelle sul tridente (se esiste)
	local trident = character:FindFirstChild("PoseidonTrident")
	if trident then
		local handle = trident:FindFirstChild("Handle")
		if handle then
			local particle = createWaterParticle(handle, 1.5, 0.3)
			particle.Enabled = true
			task.delay(0.2, function()
				particle.Enabled = false
				game:GetService("Debris"):AddItem(particle, 1)
			end)
		end
	end
end
```

### Chiamare le Animazioni nelle Abilità

Per le abilità Q, E, R aggiungi all'inizio di ogni funzione:

```lua
function PoseidonAbilities.Amphitrite(attacker, targets)
	-- ⚡ Riproduci animazione
	if POSEIDON_ANIMATIONS.Amphitrite ~= "rbxassetid://XXXXXXXXX" then
		playAnimation(attacker.Character, POSEIDON_ANIMATIONS.Amphitrite)
	end

	print("🌊 [Poseidon] Amphitrite!")
	-- ... resto del codice VFX ...
end
```

---

## 🎨 PARTE 5: Modelli Alternativi

### Se Non Vuoi Creare il Tridente Manualmente

#### Opzione A: Usare un Cubo Temporaneo
1. Crea un Tool con un Handle cubico blu
2. Testa il sistema
3. Migliora il modello dopo

#### Opzione B: Asset dal Marketplace
1. Toolbox → cerca "trident", "spear", "staff"
2. Modelli gratuiti disponibili
3. Converti in Tool come spiegato sopra

#### Opzione C: Commissiona/Importa
1. Usa Blender per creare un tridente 3D
2. Esporta come .fbx/.obj
3. Importa in Roblox Studio
4. Converti in Tool

---

## ✅ Checklist Completa

### Setup Arma:
- [ ] Tool `PoseidonTrident` creato in ReplicatedStorage
- [ ] Handle con dimensioni corrette
- [ ] Punte del tridente weldate
- [ ] Material e colori impostati
- [ ] ParticleEmitter opzionale aggiunto

### Setup Animazioni:
- [ ] Animation Editor aperto con Rig + tridente
- [ ] BasicAttack1 creato e salvato (Animation ID ottenuto)
- [ ] BasicAttack2 creato e salvato
- [ ] BasicAttack3 creato e salvato (opzionale)
- [ ] Amphitrite animazione creata
- [ ] Chione Tyro Demeter animazione creata
- [ ] 40 Day Flood animazione creata

### Setup Codice:
- [ ] StyleManager.lua aggiornato con auto-equip
- [ ] PoseidonAbilities.lua aggiornato con animation system
- [ ] Animation IDs inseriti nella tabella POSEIDON_ANIMATIONS
- [ ] Testato in-game: tridente appare quando selezioni Poseidon

---

## 🐛 Troubleshooting

### ❌ Il tridente non appare

**Causa**: Tool non trovato in ReplicatedStorage

**Soluzione**:
1. Verifica che il Tool si chiami esattamente `PoseidonTrident`
2. Deve essere in **ReplicatedStorage** (non ServerStorage o Workspace)
3. Controlla l'Output per warning

### ❌ Il tridente appare ma cade a terra

**Causa**: Handle non nominato correttamente

**Soluzione**:
1. La parte principale del Tool DEVE chiamarsi `Handle`
2. Case-sensitive: `Handle`, non `handle` o `HANDLE`

### ❌ Le animazioni non funzionano con il tridente

**Causa**: Tridente non equipaggiato durante la creazione dell'animazione

**Soluzione**:
1. Ricrea le animazioni CON il tridente già equipaggiato sul Rig
2. Il tridente deve essere child del Rig durante l'animazione

### ❌ Il tridente sembra strano (orientamento sbagliato)

**Causa**: Grip della mano non corretto

**Soluzione**:
1. Nel Tool, aggiungi proprietà:
   ```
   GripForward = Vector3.new(0, 0, -1)
   GripPos = Vector3.new(0, 0, 0)
   GripRight = Vector3.new(1, 0, 0)
   GripUp = Vector3.new(0, 1, 0)
   ```
2. Regola i valori fino a quando non è orientato bene

---

## 📊 Riepilogo

### Workflow Completo:

1. **Crea il Tridente** (Tool in ReplicatedStorage)
2. **Aggiorna StyleManager** (auto-equip quando selezioni Poseidon)
3. **Crea 3 animazioni attacco base** con Animation Editor
4. **Crea 3 animazioni abilità** (Q, E, R)
5. **Salva e ottieni Animation IDs**
6. **Aggiorna PoseidonAbilities.lua** con gli ID
7. **Testa in-game**!

---

## 🚀 Prossimo Step

Dopo aver completato Poseidon con tridente e animazioni:
- **Zeus** può usare "Lightning Bolt" (stile simile)
- **Thor** può usare "Mjolnir" (martello)
- **Adam** combatte a mani nude (no tool)

Ogni personaggio avrà il suo stile unico!

---

**Versione**: 1.0
**Data**: 2026-01-06

🔱 **Buona creazione del Tridente!** 🌊
