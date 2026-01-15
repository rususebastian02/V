# Remote Events

Questa cartella contiene i RemoteEvents e RemoteFunctions per la comunicazione client-server.

## Eventi da creare in Roblox Studio:

Crea questi RemoteEvents in `ReplicatedStorage/Events/`:

1. **DataUpdated** (RemoteEvent) - Server → Client quando i dati del player vengono aggiornati
2. **RankUp** (RemoteEvent) - Server → Client quando player ottiene nuovo rank
3. **BoostActivated** (RemoteEvent) - Server → All Clients quando boost server viene attivato
4. **BoostEnded** (RemoteEvent) - Server → All Clients quando boost termina
5. **PromptGamepass** (RemoteEvent) - Client → Server per richiedere prompt gamepass
6. **PromptDevProduct** (RemoteEvent) - Client → Server per richiedere prompt dev product
7. **TeleportToVIP** (RemoteEvent) - Client → Server per teleport a VIP area
8. **RequestData** (RemoteFunction) - Client richiede dati attuali dal server

## Come crearli in Studio:

1. Apri Roblox Studio
2. Vai a `ReplicatedStorage`
3. Crea una cartella chiamata `Events`
4. In `Events`, crea i RemoteEvents/RemoteFunctions con i nomi esatti sopra indicati
5. Usa Insert Object → RemoteEvent / RemoteFunction

**IMPORTANTE**: I nomi devono matchare esattamente con quelli negli script!
