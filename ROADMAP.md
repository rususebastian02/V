# 💸 DO NOTHING TO GET RICH - ROADMAP

> "The less you play, the richer you get."

## 🧠 CORE CONCEPT

**Non fare nulla = progresso**

Regola chiave: Qualsiasi input del player NON è necessario per guadagnare.

---

## 🎯 FASI DI IMPLEMENTAZIONE

### FASE 1: CORE SYSTEMS
#### 1.1 Sistema Currency (Cash)
- [ ] Implementare sistema Cash base
- [ ] +1 Cash/secondo (base rate)
- [ ] Sistema moltiplicatori
- [ ] Scaling automatico: ogni minuto → income aumenta leggermente
- [ ] Power curve lenta ma costante
- [ ] Salvataggio Cash su DataStore

#### 1.2 Sistema AFK Time Tracking
- [ ] Tracciare tempo totale AFK
- [ ] Tracciare tempo sessione corrente
- [ ] Salvataggio AFK Time su DataStore
- [ ] Sistema di detection player inattivo

#### 1.3 Core Loop
```
1. Player spawn
2. Player sta fermo
3. Guadagna Cash ogni secondo
4. Status/Rank cresce automaticamente
5. Continua a non fare nulla
```

---

### FASE 2: SISTEMA RANK/PROGRESSIONE

#### 2.1 Rank System (Status basato su tempo AFK)

| Tempo AFK | Rank |
|-----------|------|
| 1 min | Lazy |
| 5 min | Chill |
| 15 min | Clean |
| 30 min | Rich |
| 1h | Millionaire |
| 3h | Billionaire |
| 6h | Prince of Lazyness |
| 12h | God of Nothing |
| 24h | AFK Deity |

- [ ] Sistema di calcolo rank basato su tempo totale AFK
- [ ] Aggiornamento automatico rank
- [ ] Notifiche rank up
- [ ] Salvataggio rank su DataStore

#### 2.2 Sblocchi Progressione
- [ ] **Titoli** (unlock per rank)
- [ ] **Aura** (effetti visivi per rank alti)
- [ ] **Colori nome** (personalizzazione basata su rank)

---

### FASE 3: GAMEPASS SYSTEM

#### 3.1 Implementazione Gamepass

| Gamepass | Prezzo | Effetto | ID |
|----------|--------|---------|-----|
| x2 Income | 199 R$ | Permanente x2 cash/sec | 1671785492 |
| VIP Status | 149 R$ | Rank esclusivo + VIP Area | 1671265879 |
| AFK Boost | 99 R$ | +50% income | 1671407720 |
| Offline Earnings | 129 R$ | Guadagni mentre offline | 1671275763 |

**Tasks:**
- [ ] Sistema verifica possesso gamepass
- [ ] Applicare moltiplicatori x2 Income
- [ ] Implementare VIP Status e accesso VIP Area (GUI)
- [ ] Implementare AFK Boost (+50%)
- [ ] Sistema Offline Earnings (calcolo tempo offline × rate)
- [ ] Integrare gamepass con economia

---

### FASE 4: DEV PRODUCTS SYSTEM

#### 4.1 Boost Temporanei

| Prodotto | Prezzo | Durata | ID |
|----------|--------|--------|-----|
| Boost 10 min | 29 R$ | x2 cash per tutto il server | 3513599959 |
| Boost 1h | 200 R$ | x2 cash per tutto il server | 3513600071 |

**Tasks:**
- [ ] Sistema boost temporaneo server-wide
- [ ] Timer visibile per boost attivi
- [ ] Notifica a tutti i player quando boost attivo

#### 4.2 Skip Rank
| Prodotto | Prezzo | Effetto | ID |
|----------|--------|---------|-----|
| Skip Rank | 49 R$ | Avanza al rank successivo | 3513600561 |

**Tasks:**
- [ ] Implementare skip rank (avanza al prossimo tier)
- [ ] Verifica che non superi rank massimo

#### 4.3 Cash Istantaneo

| Prodotto | Prezzo | Cash | ID |
|----------|--------|------|-----|
| +500 Cash | 9 R$ | +500 | 3513601163 |
| +5.000 Cash | 90 R$ | +5.000 | 3513601306 |
| +50.000 Cash | 250 R$ | +50.000 | 3513601445 |
| +500.000 Cash | 650 R$ | +500.000 | 3513601593 |
| +5.000.000 Cash | 999 R$ | +5.000.000 | 3513601782 |

**Tasks:**
- [ ] Implementare acquisto cash istantaneo
- [ ] Aggiungere cash al player
- [ ] Effetto visivo quando acquistato

#### 4.4 Receipt Processing
- [ ] Sistema ProcessReceipt per tutti i dev products
- [ ] Gestione errori e retry
- [ ] Anti-duplicazione acquisti

---

### FASE 5: LEADERBOARDS

#### 5.1 Leaderboard Locale (In-Game)
- [ ] Leaderboard con **AFK Time** (tempo totale giocato)
- [ ] Leaderboard con **Cash**
- [ ] Aggiornamento real-time
- [ ] UI elegante e minimalista

#### 5.2 Leaderboard Globale (OrderedDataStore)
**Visualizzazione su Part fisica nella mappa**

**Top 100 Players:**
- [ ] Classifica globale AFK Time (Top 100)
- [ ] Classifica globale Cash (Top 100)
- [ ] Mostra avatar del player (usando ThumbnailService)
- [ ] Aggiornamento periodico (ogni 5-10 minuti)
- [ ] SurfaceGui su Part per display

**Tasks tecnici:**
- [ ] OrderedDataStore per ranking globale
- [ ] Sistema di fetch Top 100
- [ ] Rendering avatar thumbnails
- [ ] UI responsive su Part
- [ ] Sistema di cache per performance

---

### FASE 6: UI/UX

#### 6.1 HUD principale
- [ ] Display Cash corrente
- [ ] Display Cash/sec rate
- [ ] Display Rank corrente
- [ ] Display AFK Time
- [ ] Moltiplicatori attivi
- [ ] Boost timer (se attivo)

#### 6.2 Shop GUI
- [ ] Sezione Gamepass
- [ ] Sezione Dev Products
- [ ] Preview effetti
- [ ] Prompt acquisto Roblox

#### 6.3 VIP Area GUI
- [ ] Bottone accesso VIP Area (solo per VIP Status owners)
- [ ] Teleport a VIP Area
- [ ] UI elegante

#### 6.4 Leaderboard GUI
- [ ] Toggle leaderboard locale
- [ ] Visualizzazione top players server

---

### FASE 7: DATA PERSISTENCE

#### 7.1 DataStore Structure
```lua
PlayerData = {
    Cash = 0,
    TotalAFKTime = 0,
    CurrentRank = "Lazy",
    Gamepasses = {
        x2Income = false,
        VIPStatus = false,
        AFKBoost = false,
        OfflineEarnings = false
    },
    Multipliers = {
        Total = 1.0
    },
    LastLogin = tick()
}
```

**Tasks:**
- [ ] Sistema save/load DataStore2 o ProfileService
- [ ] Auto-save ogni 60 secondi
- [ ] Save on leave
- [ ] Gestione errori DataStore
- [ ] Sistema backup/fallback

#### 7.2 Offline Earnings (Gamepass)
- [ ] Calcolare tempo offline
- [ ] Applicare income rate × tempo offline
- [ ] Cap massimo (es. 12h offline max)
- [ ] Notifica earnings al login

---

### FASE 8: POLISH & OPTIMIZATIONS

#### 8.1 Visual Effects
- [ ] Aura per rank alti
- [ ] Particle effects per rank up
- [ ] Effetti acquisto cash
- [ ] Boost activation effects

#### 8.2 Audio
- [ ] Suono rank up
- [ ] Suono cash acquisito
- [ ] Musica ambient minimalista
- [ ] Sound effects acquisti

#### 8.3 Performance
- [ ] Ottimizzare leaderboard updates
- [ ] Cache per gamepass checks
- [ ] Throttle UI updates
- [ ] Async loading

#### 8.4 Mobile Optimization
- [ ] UI responsive per mobile
- [ ] Touch controls
- [ ] Performance mobile

---

## 🗺️ MAP DESIGN (QUASI ZERO)

> **NOTA:** La mappa verrà creata separatamente

### Specifiche Mappa:
- Piattaforma singola (20x20 studs)
- Vuoto intorno (void/cielo)
- Nessun ostacolo
- Clean, colori neutri
- Un solo punto focale
- **Part per Leaderboard Globale** (posizionamento da decidere)

---

## 📊 MONETIZZAZIONE

### Revenue Model
💡 **Dev products = core revenue**

### Gamepass Value Proposition:
- **x2 Income**: Pay-to-progress-faster (high value)
- **VIP Status**: Esclusività + area speciale
- **AFK Boost**: Extra passive income
- **Offline Earnings**: Converti downtime in progress

### Dev Products Strategy:
- **Boost server-wide**: Social incentive (aiuta tutti)
- **Skip Rank**: Instant gratification
- **Cash packs**: Multiple price points (9-999 R$)

---

## 🎮 CORE LOOP FINALE

```
Player join → Spawn su piattaforma
              ↓
        AFK tracking inizia
              ↓
    Cash accumula (+1/sec base)
              ↓
        Moltiplicatori applicati
        (Gamepass + Boost + Scaling)
              ↓
        Rank sale automaticamente
              ↓
    Sblocchi visuali/titoli/aura
              ↓
    Leaderboard aggiornate
              ↓
        Player continua AFK
              ↓
         Loop infinito
```

---

## ✅ PRIORITÀ IMPLEMENTAZIONE

### CRITICAL (MVP):
1. Sistema Cash base (+1/sec)
2. AFK Time tracking
3. Rank system
4. DataStore save/load
5. Leaderboard locale

### HIGH:
6. Gamepass implementation (tutti e 4)
7. Dev Products (cash packs + boost)
8. HUD principale
9. Shop GUI

### MEDIUM:
10. Leaderboard globale (Part + OrderedDataStore)
11. VIP Area GUI e teleport
12. Offline Earnings
13. Visual effects (aura/particles)

### LOW (Polish):
14. Audio/SFX
15. Mobile optimization
16. Advanced analytics

---

## 🔧 TECH STACK CONSIGLIATO

- **DataStore**: ProfileService (gestione sessioni robusta)
- **UI Framework**: Roact/Fusion (optional, se vuoi UI reactive)
- **Networking**: RemoteEvents per shop/teleport
- **Leaderboard**: OrderedDataStore + cache system
- **Avatar Thumbnails**: Players:GetUserThumbnailAsync()

---

## 📝 NOTE IMPLEMENTAZIONE

### Sistema di Moltiplicatori:
```lua
FinalIncome = BaseIncome × (1 + x2Income + AFKBoost + ServerBoost + ScalingBonus)
```

### Scaling Automatico:
- Ogni minuto: income +0.5%
- Oppure: income × 1.005 ogni minuto
- Cap a × 2.0 per evitare hyperinflation

### Anti-Cheat:
- Validare income server-side
- Sanity check su DataStore values
- Rate limiting su acquisti

---

## 🚀 DEPLOYMENT CHECKLIST

- [ ] Testare tutti i gamepass
- [ ] Testare tutti i dev products
- [ ] Verificare ProcessReceipt
- [ ] Testare save/load DataStore
- [ ] Testare offline earnings
- [ ] Testare leaderboard globale
- [ ] Testare su mobile
- [ ] Beta test con 5-10 players
- [ ] Monitoring errori DataStore
- [ ] Analytics tracking (visite/revenue)

---

**READY TO BUILD! 🎮**
