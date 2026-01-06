# 🔱 Poseidon - Guida Creazione Animazioni

## 📋 Animazioni Necessarie

Per Poseidon servono **4 animazioni totali**:
1. **Attacco Base** - Colpo con tridente
2. **Amphitrite (Q)** - Affondi circolari rapidi
3. **Chione Tyro Demeter (E)** - Salto aereo + pioggia di colpi
4. **40 Day Flood (R)** - Rotazione devastante

---

## 🎬 Come Creare le Animazioni in Roblox Studio

### Step 1: Aprire l'Animation Editor

1. Apri **Roblox Studio**
2. Inserisci un **Rig** (personaggio dummy) nella Workspace:
   - In alto: **Avatar** → **Rig Builder** → **R15** o **R6** (scegli quello che usi)
3. Seleziona il Rig
4. Vai in **View** → **Animation Editor** (o premi Alt+Shift+A)
5. Si aprirà il pannello Animation Editor

### Step 2: Creare una Nuova Animazione

1. Clicca **Create** nel pannello Animation Editor
2. Dai un nome (es. "PoseidonBasicAttack")
3. Vedrai la timeline in basso

### Step 3: Posizionare i Keyframe

Ogni animazione è fatta di **keyframe** (fotogrammi chiave):
1. Muovi la **barra temporale** (linea rossa) al secondo desiderato
2. Seleziona una parte del corpo del Rig (es. braccio destro)
3. Ruota/muovi la parte usando i tool Move/Rotate
4. Vedrai apparire un **rombo blu** = keyframe creato
5. Ripeti per altre parti del corpo e altri momenti

---

## 🔱 Animazioni di Poseidon - Frame per Frame

### 🗡️ 1. ATTACCO BASE (0.6 secondi)

**Movimento**: Affondo in avanti con tridente

**Keyframes**:
```
0.00s - Posizione idle (braccia lungo i fianchi)
0.15s - Braccio destro indietro (carica)
       - Torso ruotato leggermente a destra
0.40s - Braccio destro teso in avanti (affondo)
       - Torso ruotato a sinistra
       - Gamba destra avanti
0.60s - Ritorno a idle
```

**Parti da animare**:
- RightUpperArm, RightLowerArm (affondo)
- UpperTorso, LowerTorso (rotazione)
- RightUpperLeg, RightLowerLeg (passo avanti)

---

### ⚡ 2. AMPHITRITE - Q (1.2 secondi)

**Movimento**: Rotazione rapida con affondi circolari multipli

**Keyframes**:
```
0.00s - Idle
0.10s - Braccia in posizione di guardia
0.20s - Affondo a sinistra + torso ruotato 45°
0.40s - Affondo avanti + torso ruotato 90°
0.60s - Affondo a destra + torso ruotato 180°
0.80s - Affondo indietro + torso ruotato 270°
1.00s - Affondo finale centrale + torso a 360°
1.20s - Posa di chiusura (braccia aperte)
```

**Parti da animare**:
- Entrambe le braccia (affondi multipli)
- UpperTorso (rotazione completa)
- LowerTorso (rotazione completa)
- Gambe (passi circolari)

**Impostazioni speciali**:
- In Animation Editor, imposta **Priority** su **Action** (sovrascrive movimento)

---

### 🌊 3. CHIONE TYRO DEMETER - E (1.5 secondi)

**Movimento**: Salto in aria → pioggia di colpi dall'alto

**Keyframes**:
```
0.00s - Idle
0.15s - Accovacciato (carica salto)
       - Gambe piegate
       - Braccia indietro
0.30s - In aria (salto)
       - Gambe tese verso il basso
       - Braccia sopra la testa
0.50s - Picco del salto (massima altezza)
0.70s - Inizia discesa - tridente sopra la testa
0.90s - Colpi rapidi durante discesa
       - Braccia alternate in movimento rapido
1.20s - Atterraggio (ginocchia piegate)
1.50s - Ritorno idle
```

**Parti da animare**:
- Entrambe le gambe (salto + atterraggio)
- RootPart (movimento Y verso l'alto - vedi nota sotto)
- Braccia (colpi dall'alto)
- Torso (inclinazione in avanti durante discesa)

**NOTA**: Per il movimento verticale, devi:
1. Selezionare **HumanoidRootPart**
2. Muoverlo in alto sull'asse Y
3. Oppure, gestire il movimento via script (meglio)

---

### 💥 4. 40 DAY FLOOD - R (2.5 secondi)

**Movimento**: Rotazione devastante a 360° + finale esplosivo

**Keyframes**:
```
0.00s - Idle
0.20s - Carica - braccia larghe
       - Gambe allargate (stance potente)
0.40s - Inizio rotazione - torso 45°
       - Braccia tese lateralmente
0.70s - Rotazione continua - torso 180°
1.00s - Rotazione continua - torso 270°
1.30s - Rotazione completa - torso 360°
1.60s - Seconda rotazione - torso 540° (1.5 giri)
1.90s - Fermata improvvisa - posa potente
       - Braccio destro teso in avanti
       - Gamba sinistra piegata
2.50s - Ritorno lento a idle
```

**Parti da animare**:
- UpperTorso, LowerTorso (rotazione multipla)
- Entrambe le braccia (tese lateralmente)
- Gambe (stance stabile → passo finale)
- Head (segue rotazione torso)

**Impostazioni speciali**:
- Priority: **Action2** (massima priorità)
- Looping: **OFF**

---

## 💾 Salvare le Animazioni

### Dopo aver creato ogni animazione:

1. Clicca il bottone **...** (tre puntini) nel pannello Animation Editor
2. **Save to Roblox** (salva sul cloud di Roblox)
3. Ti darà un **Animation ID** (es. `rbxassetid://123456789`)
4. **COPIA QUESTO ID** - ti servirà nel codice!

### Organizzazione:

Crea una tabella per conservare gli ID:
```
Poseidon Animations:
- BasicAttack: rbxassetid://XXXXXXXXX
- Amphitrite: rbxassetid://XXXXXXXXX
- ChioneTyroDemeter: rbxassetid://XXXXXXXXX
- FortyDayFlood: rbxassetid://XXXXXXXXX
```

---

## 🎯 Tips per Animazioni Migliori

### Velocità e Fluidità:
- **Amphitrite** deve essere VELOCE (usa transizioni rapide)
- **40 Day Flood** deve essere POTENTE (movimenti ampi)
- **Chione Tyro Demeter** deve avere un buon timing salto-discesa

### Easing (Interpolazione):
- Clicca destro su un keyframe → **Easing Style**
- Per movimenti rapidi: **Linear** o **Cubic**
- Per movimenti fluidi: **Sine** o **Quad**

### Preview:
- Usa il bottone **Play** nel pannello per vedere l'anteprima
- Regola i keyframe se qualcosa non sembra naturale

---

## 🔧 Alternative se Non Vuoi Crearle Tu

Se non vuoi creare le animazioni manualmente:

### Opzione 1: Usare Animazioni di Default Roblox
Roblox ha animazioni predefinite che posso referenziare nel codice:
- Slash (colpo)
- Lunge (affondo)
- Spin (rotazione)

### Opzione 2: Marketplace Roblox
Cercare "sword animations" o "combat animations" nel Marketplace:
- Molte sono gratuite
- Puoi modificarle nell'Animation Editor

### Opzione 3: Procedere Solo con VFX
Possiamo creare effetti visivi spettacolari anche senza animazioni custom:
- Il personaggio farà animazioni base
- Gli effetti VFX renderanno tutto epico comunque

---

## ✅ Prossimo Step

Dopo aver creato (o scelto) le animazioni:

1. Segna gli **Animation ID**
2. Li integrerò nel sistema VFX che sto per creare
3. Le animazioni partiranno automaticamente quando usi le abilità!

---

**Quanto tempo serve?**
- Se non hai mai usato l'Animation Editor: 30-60 min per imparare
- Creare le 4 animazioni di Poseidon: 1-2 ore
- Oppure usare animazioni esistenti: 5 minuti

**Vuoi che ti crei prima il sistema VFX e poi aggiungi le animazioni dopo?**
Funziona benissimo anche così! 🚀
