# Script Teleport per Roblox

Script Lua per creare teleport tra parti in Roblox Studio.

## 📋 Come Usare

### Setup Base

1. **Apri Roblox Studio** e il tuo progetto

2. **Crea la Part di Partenza**
   - Inserisci una `Part` nel Workspace
   - Chiamala come vuoi (es: "TeleportEntrata1")
   - Posizionala dove vuoi che i player tocchino per teletrasportarsi

3. **Crea la Part di Destinazione**
   - Inserisci un'altra `Part` nel Workspace
   - Chiamala ad esempio "DestinazioneTeleport1"
   - Posizionala dove vuoi che i player appaiano dopo il teleport

4. **Aggiungi lo Script**
   - Inserisci uno `Script` (NON LocalScript) dentro la Part di partenza
   - Copia il contenuto di `TeleportScript.lua` nello script
   - Modifica la variabile `NOME_DESTINAZIONE` con il nome della tua part di destinazione

5. **Testa il gioco!**
   - Premi Play in Roblox Studio
   - Cammina attraverso la part di partenza
   - Dovresti essere teletrasportato alla destinazione

---

## 🔧 Configurazione

Puoi modificare questi valori all'inizio dello script:

```lua
-- Nome della part di destinazione nel Workspace
local NOME_DESTINAZIONE = "DestinazioneTeleport1"

-- Offset verticale (altezza sopra la destinazione)
local OFFSET_ALTEZZA = 3

-- Tempo di attesa tra teleport (in secondi)
local COOLDOWN = 2
```

---

## 🔄 Creare Più Teleport

Per creare teleport multipli:

1. **Duplica la Part di partenza** (con lo script già dentro)
2. **Crea una nuova Part di destinazione** (con un nome diverso)
3. **Modifica lo script** nella part duplicata:
   - Cambia solo `NOME_DESTINAZIONE` con il nuovo nome
4. Ripeti per ogni teleport che vuoi creare

### Esempio con 3 Teleport

```
Workspace/
├── TeleportEntrata1 (Script con NOME_DESTINAZIONE = "Dest1")
├── Dest1
├── TeleportEntrata2 (Script con NOME_DESTINAZIONE = "Dest2")
├── Dest2
├── TeleportEntrata3 (Script con NOME_DESTINAZIONE = "Dest3")
└── Dest3
```

---

## 🎯 Metodo Alternativo (Più Flessibile)

Invece di usare il nome della destinazione, puoi usare un **ObjectValue**:

1. Inserisci un `ObjectValue` dentro la Part di partenza
2. Chiamalo esattamente "Destination"
3. Imposta la proprietà `Value` dell'ObjectValue alla Part di destinazione

**Vantaggi:**
- Non devi modificare il codice
- Puoi cambiare la destinazione facilmente da Roblox Studio
- Puoi avere lo stesso script su più part con destinazioni diverse

---

## 🎨 Personalizzazioni Suggerite

### Rendere la Part Invisibile
```lua
partTeleport.Transparency = 1
partTeleport.CanCollide = false
```

### Aggiungere un Effetto Sonoro
```lua
local suonoTeleport = Instance.new("Sound")
suonoTeleport.SoundId = "rbxassetid://12345678" -- ID del suono
suonoTeleport.Parent = partTeleport
suonoTeleport:Play()
```

### Aggiungere Particelle
```lua
local particelle = Instance.new("ParticleEmitter")
particelle.Parent = destinazione
particelle.Rate = 50
particelle.Lifetime = NumberRange.new(0.5, 1)
```

---

## ⚠️ Troubleshooting

### "Destinazione non trovata"
- Verifica che il nome in `NOME_DESTINAZIONE` sia esattamente uguale al nome della part nel Workspace
- Controlla maiuscole e minuscole
- Assicurati che la destinazione sia direttamente nel Workspace (non in una cartella)

### "Il player non si teletrasporta"
- Verifica che lo script sia un `Script` normale (non LocalScript)
- Controlla che la part abbia `CanCollide = true` o che il player possa comunque toccarla
- Guarda l'Output di Roblox Studio per eventuali errori

### "Il player si incastra nella destinazione"
- Aumenta il valore di `OFFSET_ALTEZZA`
- Assicurati che ci sia spazio sopra la part di destinazione

---

## 📝 Note

- Lo script include un sistema di **cooldown** per evitare teleport multipli rapidi
- Il cooldown è per player (ogni player ha il suo timer)
- La memoria viene pulita automaticamente quando un player lascia il gioco
- Lo script è completamente server-side per maggiore sicurezza

---

## 🚀 Buon Divertimento!

Ora puoi creare tutti i teleport che vuoi nel tuo gioco Roblox!
