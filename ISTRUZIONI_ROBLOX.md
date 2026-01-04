# Script Speed Gain per Roblox Studio

## Descrizione
Questo script aumenta automaticamente la velocità di camminata (WalkSpeed) del giocatore di +1 ogni secondo, all'infinito.

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

## Note

- La velocità di default in Roblox è 16
- La velocità può diventare molto alta! Considera di aggiungere un limite se necessario
- Lo script stampa la velocità attuale nella Output Console per il debug

## Risoluzione Problemi

Se lo script non funziona:
- Verifica che sia in **ServerScriptService** e non in altro posto
- Controlla la **Output Console** per eventuali errori
- Assicurati che il gioco sia in modalità Play/Run
