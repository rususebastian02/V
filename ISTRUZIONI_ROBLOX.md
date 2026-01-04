# Script Speed Gain per Roblox Studio

## Descrizione
Questo script aumenta automaticamente la velocità di camminata (WalkSpeed) del giocatore di +1 ogni secondo, all'infinito. Include un sistema di salvataggio che mantiene i tuoi progressi, una leaderboard visibile con Speed e Playtime in tempo reale, e un sistema VIP con bonus +50% velocità e tag dorato in chat!

## Come Installare

### Script Principale (Velocità e Leaderboard)
1. Apri il tuo progetto in **Roblox Studio**
2. Nel pannello **Explorer**, trova **ServerScriptService**
3. Fai click destro su **ServerScriptService** → **Insert Object** → **Script**
4. Rinomina il nuovo script in "SpeedGainScript"
5. Copia tutto il contenuto del file `SpeedGainScript.lua` e incollalo nello script
6. Salva (Ctrl+S)

### Script Tag VIP in Chat (Opzionale)
7. Fai di nuovo click destro su **ServerScriptService** → **Insert Object** → **Script**
8. Rinomina questo script in "ChatTagScript"
9. Copia tutto il contenuto del file `ChatTagScript.lua` e incollalo nello script
10. Salva (Ctrl+S)
11. Premi **Play** per testare!

## Funzionalità

### Base
- ✅ Funziona per tutti i giocatori nel server
- ✅ Incremento automatico di +1 WalkSpeed ogni secondo
- ✅ Continua all'infinito finché il giocatore è in gioco
- ✅ Si riattiva automaticamente quando il personaggio rinasce

### Leaderboard
- ✅ **Leaderboard integrata con Speed e Playtime**
- ✅ Aggiornamento in tempo reale della velocità nella leaderboard
- ✅ Contatore Playtime che mostra i secondi trascorsi in gioco

### Salvataggio
- ✅ **Salvataggio automatico dei progressi con DataStore**
- ✅ Riprendi dalla velocità esatta quando rientri nel gioco
- ✅ Backup automatico ogni 60 secondi
- ✅ Salvataggio sicuro quando esci o il server si chiude

### Sistema VIP 🌟
- ✅ **Bonus +50% velocità** (+1.5 invece di +1 ogni secondo)
- ✅ **Tag [VIP] dorato in chat** davanti al nome
- ✅ Riconoscimento automatico del Game Pass VIP
- ✅ Messaggi personalizzati nella Output Console

### Extra
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

## 🌟 Sistema VIP

Il sistema VIP offre vantaggi esclusivi ai giocatori che possiedono il **Game Pass VIP**!

### ID Game Pass
Il Game Pass utilizzato è: **1656463027**

### Vantaggi VIP

#### 1. Bonus Velocità +50%
- **Giocatori normali**: +1 velocità ogni secondo
- **Giocatori VIP**: +1.5 velocità ogni secondo
- Il bonus si applica **automaticamente** quando entri nel gioco

#### 2. Tag [VIP] Dorato in Chat
- Appare davanti al tuo nome quando scrivi in chat
- Colore **dorato** (#FFD700) per distinguerti dagli altri
- Si attiva automaticamente se hai il Game Pass

### Come Funziona
1. Il giocatore entra nel gioco
2. Lo script controlla automaticamente se possiede il Game Pass VIP (ID: 1656463027)
3. Se sì:
   - Guadagna +1.5 velocità ogni secondo invece di +1
   - I suoi messaggi in chat mostrano il tag **[VIP]** dorato
4. Se no:
   - Guadagna +1 velocità ogni secondo (normale)
   - Nessun tag in chat

### Esempio Confronto

**Giocatore Normale** dopo 2 minuti:
- Velocità: 16 (base) + 120 (2 min × 60 sec × 1) = **136**

**Giocatore VIP** dopo 2 minuti:
- Velocità: 16 (base) + 180 (2 min × 60 sec × 1.5) = **196** 🌟
- **60 punti in più!**

### Chat VIP
Quando un giocatore VIP scrive in chat, il messaggio appare così:
```
[VIP] NomeGiocatore: Ciao a tutti!
```
Il tag [VIP] è di colore dorato per risaltare.

### Note Importanti
- Il bonus VIP funziona **solo se possiedi il Game Pass**
- Il controllo viene fatto ogni volta che entri nel server
- Se acquisti il Game Pass mentre sei in gioco, dovrai uscire e rientrare

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

### Il VIP non funziona (non ottengo +1.5 velocità):
- Verifica di possedere il Game Pass con ID **1656463027**
- Il controllo VIP funziona solo su server pubblicati
- Controlla la Output Console: dovresti vedere "🌟 [nome] è un giocatore VIP!"
- Se hai appena acquistato il pass, esci e rientra nel gioco
- Assicurati che entrambi gli script siano in **ServerScriptService**

### Il tag [VIP] non appare in chat:
- Assicurati di aver installato anche **ChatTagScript.lua**
- Verifica che il gioco usi **TextChatService** (nuovo sistema chat)
- Se usi il vecchio sistema chat legacy, il tag potrebbe non apparire
- Controlla la Output Console per errori relativi alla chat
