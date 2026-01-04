# Script Speed Gain per Roblox Studio

## Descrizione
Questo script aumenta automaticamente la velocità di camminata (WalkSpeed) del giocatore di +1 ogni secondo, all'infinito. Include un sistema di salvataggio che mantiene i tuoi progressi e una leaderboard visibile con Speed e Playtime in tempo reale!

## Come Installare

1. Apri il tuo progetto in **Roblox Studio**
2. Nel pannello **Explorer**, trova **ServerScriptService**
3. Fai click destro su **ServerScriptService** → **Insert Object** → **Script**
4. Rinomina il nuovo script in "SpeedGainScript" (facoltativo)
5. Copia tutto il contenuto del file `SpeedGainScript.lua` e incollalo nello script
6. Premi **Play** per testare!

## Funzionalità

- ✅ Funziona per tutti i giocatori nel server
- ✅ Incremento automatico di +1 WalkSpeed ogni secondo
- ✅ Continua all'infinito finché il giocatore è in gioco
- ✅ Si riattiva automaticamente quando il personaggio rinasce
- ✅ **Leaderboard integrata con Speed e Playtime**
- ✅ Aggiornamento in tempo reale della velocità nella leaderboard
- ✅ Contatore Playtime che mostra i secondi trascorsi in gioco
- ✅ **Salvataggio automatico dei progressi con DataStore**
- ✅ Riprendi dalla velocità esatta quando rientri nel gioco
- ✅ Backup automatico ogni 60 secondi
- ✅ Salvataggio sicuro quando esci o il server si chiude
- ✅ Include messaggi di debug nella Output Console

## 📊 Leaderboard

Lo script crea automaticamente una **leaderboard visibile** nell'angolo in alto a destra dello schermo con le seguenti statistiche:

### Speed
- Mostra la **velocità attuale** del giocatore
- Si aggiorna **in tempo reale** ogni secondo
- Parte da 16 (velocità di default) o dalla velocità salvata

### Playtime
- Mostra i **secondi totali** trascorsi in gioco nella sessione corrente
- Si aggiorna ogni secondo
- Si azzera quando esci e rientri (non viene salvato)

### Esempio Leaderboard
```
┌─────────────────────┐
│  Player Name        │
│  Speed: 142         │
│  Playtime: 3845     │  (1 ora e 4 minuti)
└─────────────────────┘
```

**Nota**: Il Playtime mostra i secondi. Puoi convertire mentalmente:
- 60 secondi = 1 minuto
- 3600 secondi = 1 ora
- Per esempio: 3845 secondi = 64 minuti ≈ 1 ora e 4 minuti

## Personalizzazione

Puoi modificare facilmente lo script:

- **Cambiare l'intervallo di tempo**: modifica `wait(1)` con il numero di secondi desiderato
  - Es: `wait(0.5)` per aumentare ogni mezzo secondo
  - Es: `wait(5)` per aumentare ogni 5 secondi

- **Cambiare l'incremento**: modifica `+ 1` con il valore desiderato
  - Es: `humanoid.WalkSpeed + 2` per +2 ogni secondo
  - Es: `humanoid.WalkSpeed + 0.5` per +0.5 ogni secondo

- **Impostare un limite massimo**: aggiungi una condizione
  ```lua
  if humanoid.WalkSpeed < 100 then
      humanoid.WalkSpeed = humanoid.WalkSpeed + 1
  end
  ```

- **Formattare il Playtime** (es: minuti invece di secondi): modifica la riga 86
  ```lua
  playtimeValue.Value = playtimeValue.Value + 1  -- Aumenta di 1 secondo
  ```
  Cambia in:
  ```lua
  -- Per mostrare minuti, aggiorna ogni 60 secondi
  wait(60)  -- invece di wait(1)
  playtimeValue.Value = playtimeValue.Value + 1  -- Sarà in minuti
  ```

## Sistema di Salvataggio

Lo script utilizza il **DataStore** di Roblox per salvare automaticamente i progressi:

### Come Funziona
- 🔄 **Salvataggio automatico**: Ogni 60 secondi viene fatto un backup della velocità
- 🚪 **Salvataggio all'uscita**: Quando esci dal gioco, la velocità viene salvata
- 🔌 **Salvataggio alla chiusura server**: Protetto anche in caso di chiusura del server
- 📥 **Caricamento all'entrata**: Quando rientri, la tua velocità viene ripristinata

### Requisiti per il DataStore
⚠️ **IMPORTANTE**: Il DataStore funziona solo in questi casi:
1. **Published game**: Il gioco deve essere pubblicato su Roblox
2. **Studio → Enable Studio Access to API Services**:
   - Vai su **Home** → **Game Settings** → **Security**
   - Attiva **Enable Studio Access to API Services**
3. **Live server**: Non funziona nel Play mode locale in Studio (ma i dati verranno salvati una volta pubblicato)

### Come Testare il Salvataggio
1. Pubblica il gioco su Roblox
2. Attiva API Services nelle impostazioni
3. Gioca per qualche secondo (guadagnerai velocità)
4. Esci dal gioco
5. Rientra → La tua velocità sarà stata mantenuta! 🎉

### Cancellare i Dati Salvati
Se vuoi ricominciare da capo, modifica il nome del DataStore nello script:
```lua
local SpeedDataStore = DataStoreService:GetDataStore("PlayerSpeedData")
```
Cambialo in:
```lua
local SpeedDataStore = DataStoreService:GetDataStore("PlayerSpeedData_v2")
```

## Note

- La velocità di default in Roblox è 16
- La velocità può diventare molto alta! Considera di aggiungere un limite se necessario
- Lo script stampa la velocità attuale nella Output Console per il debug

## Risoluzione Problemi

### Lo script non funziona:
- Verifica che sia in **ServerScriptService** e non in altro posto
- Controlla la **Output Console** per eventuali errori
- Assicurati che il gioco sia in modalità Play/Run

### Il salvataggio non funziona:
- Assicurati che **API Services** sia attivato nelle Game Settings
- Il DataStore non funziona in Play mode locale in Studio, devi pubblicare il gioco
- Controlla la Output Console per messaggi come "Dati caricati" o "Dati salvati"
- Se vedi errori DataStore, verifica che il gioco sia pubblicato e API Services attivato

### La velocità riparte da 16:
- Il salvataggio funziona solo su server pubblicati, non in locale
- Verifica che siano passati almeno 60 secondi o che tu sia uscito correttamente
- Controlla nella Output Console se vedi "Dati salvati per [nome]"

### Non vedo la leaderboard:
- La leaderboard appare automaticamente in alto a destra
- Verifica che lo script sia in **ServerScriptService**
- Riprova a premere Stop e poi Play in Studio
- Controlla la Output Console per eventuali errori
