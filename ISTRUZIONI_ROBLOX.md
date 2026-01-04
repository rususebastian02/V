# Script Speed Gain per Roblox Studio

## Descrizione
Questo script aumenta automaticamente la velocità di camminata (WalkSpeed) del giocatore di +1 ogni secondo, all'infinito. Include un sistema di salvataggio che mantiene i tuoi progressi anche quando esci e rientri nel gioco!

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
- ✅ **Salvataggio automatico dei progressi con DataStore**
- ✅ Riprendi dalla velocità esatta quando rientri nel gioco
- ✅ Backup automatico ogni 60 secondi
- ✅ Salvataggio sicuro quando esci o il server si chiude
- ✅ Include messaggi di debug nella Output Console

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
