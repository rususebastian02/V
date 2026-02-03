# LIFE - Text RPG Morale

> *Il player diventa ciò che sceglie, non ciò che dichiara.*

Un Text RPG morale, persistente e sociale per Roblox. Ogni scelta modifica la tua Reputazione e definisce chi sei veramente.

## Concept

- **Reputazione unica**: da –10.000 a +10.000
- **Due fazioni**: 🔵 Celeste (luce) e 🔴 Cremisi (ombra)
- **Sistema di coerenza morale**: il gioco premia la coerenza, non il bene o il male
- **Mondo reattivo**: NPC che ti riconoscono, zone di fazione, conseguenze a lungo termine

## Struttura Progetto

```
src/
├── server/
│   ├── init.server.lua      # Entry point server
│   └── GameManager.lua      # Logica principale
├── client/
│   ├── init.client.lua      # Entry point client
│   └── TextUI.lua           # Interfaccia utente
├── shared/
│   ├── ReputationSystem.lua # Sistema reputazione (CORE)
│   ├── PlayerData.lua       # Gestione dati giocatore
│   └── EventSystem.lua      # Sistema eventi narrativi
└── data/
    └── StoryEvents.lua      # Eventi narrativi
```

## Setup in Roblox Studio

### 1. Crea la struttura

In **ReplicatedStorage**, crea:
```
ReplicatedStorage/
├── Shared/           (Folder)
│   ├── ReputationSystem   (ModuleScript)
│   ├── PlayerData         (ModuleScript)
│   └── EventSystem        (ModuleScript)
└── Data/             (Folder)
    └── StoryEvents        (ModuleScript)
```

### 2. Script Server

In **ServerScriptService**, crea:
```
ServerScriptService/
└── LifeTextRPG/      (Folder)
    ├── init           (Script) ← contenuto di init.server.lua
    └── GameManager    (ModuleScript)
```

### 3. Script Client

In **StarterPlayer/StarterPlayerScripts**, crea:
```
StarterPlayerScripts/
└── LifeTextRPG/      (Folder)
    ├── init           (LocalScript) ← contenuto di init.client.lua
    └── TextUI         (ModuleScript)
```

### 4. Copia i contenuti

Copia il contenuto di ogni file `.lua` nel rispettivo ModuleScript/Script in Roblox Studio.

## Sistema Reputazione

### Soglie Narrative
| Range | Stato |
|-------|-------|
| ±250 | Primo giudizio del mondo |
| ±1.000 | Fazione riconosciuta |
| ±3.000 | Accesso gilde |
| ±6.000 | Status Elite |
| ±9.000 | Leggenda vivente |

### Titoli Celesti 🔵
- +1.000 → **Protettore**
- +2.500 → **Giudice**
- +5.000 → **Redentore**
- +7.500 → **Martire**
- +9.500 → **Araldo della Luce**

### Titoli Cremisi 🔴
- –1.000 → **Predatore**
- –2.500 → **Boia**
- –5.000 → **Tiranno**
- –7.500 → **Flagello**
- –9.500 → **Incarnazione del Terrore**

## Tipi di Eventi

| Tipo | Impatto Rep | Descrizione |
|------|-------------|-------------|
| DAILY | ±10-30 | Scelte quotidiane |
| MORAL | ±50-150 | Dilemmi morali |
| KEY | ±300-700 | Cambiano la run |
| POINT_OF_NO_RETURN | ±500-1000 | Bloccano contenuti |

## Sistema di Coerenza

Il gioco traccia le scelte consecutive:
- **3+ scelte coerenti** → +10% bonus reputazione
- **5+ scelte coerenti** → +25% bonus reputazione
- **10+ scelte coerenti** → +50% bonus reputazione

Cambi drastici di fazione causano **instabilità morale** e attivano eventi speciali.

## Roadmap Sviluppo

- [x] 1. Core reputazione
- [x] 2. Eventi base (primi 5)
- [x] 3. UI testuale
- [ ] 4. NPC reattivi
- [ ] 5. Sistema titoli completo
- [ ] 6. Gilde
- [ ] 7. Stagioni
- [ ] 8. Monetizzazione

## Aggiungere Nuovi Eventi

In `src/data/StoryEvents.lua`, aggiungi eventi seguendo questa struttura:

```lua
{
    id = "unique_event_id",
    type = "DAILY", -- o MORAL, KEY, POINT_OF_NO_RETURN
    title = "Titolo Evento",
    context = [[
        Descrizione della situazione...
    ]],
    choices = {
        {
            id = "choice_1",
            text = "Testo della scelta",
            reputationChange = 50, -- positivo = Celeste, negativo = Cremisi
            consequence = "Cosa succede dopo..."
        },
        -- altre scelte...
    },
    rememberedAs = "Come il gioco ricorda questo evento"
}
```

## Credits

Progetto sviluppato come Text RPG morale per Roblox.

---

*"Più sei estremo, più sei prigioniero della tua identità."*
