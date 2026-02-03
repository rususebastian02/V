--[[
    LIFE TEXT RPG - Eventi Narrativi Completi
    30 eventi totali: 15 DAILY, 10 MORAL, 5 KEY
]]

local StoryEvents = {}

-- ============================================
-- EVENTI QUOTIDIANI (DAILY) - 15 eventi
-- Piccole scelte che definiscono chi sei
-- ============================================

StoryEvents.DailyEvents = {
    -- 1. Il mendicante
    {
        id = "daily_beggar",
        type = "DAILY",
        title = "L'Incontro",
        context = "Un uomo siede contro il muro di un vicolo. I suoi vestiti sono logori, lo sguardo vuoto. Una ciotola di latta davanti a lui e' quasi vuota.\n\nTi vede e alza gli occhi. Non dice nulla. Aspetta.",
        choices = {
            { id = "help", text = "Gli dai qualche moneta", reputationChange = 15, consequence = "L'uomo annuisce. 'Grazie, straniero.'" },
            { id = "ignore", text = "Passi oltre", reputationChange = -10, consequence = "I suoi occhi ti seguono mentre ti allontani." },
            { id = "cruel", text = "Rovesci la ciotola con il piede", reputationChange = -25, consequence = "Le monete rotolano nel fango. L'uomo non reagisce." }
        },
        rememberedAs = "Il mendicante"
    },

    -- 2. Il bambino perduto
    {
        id = "daily_lost_child",
        type = "DAILY",
        title = "Pianto nel Mercato",
        context = "Un bambino piange in mezzo alla piazza. E' chiaramente perso, cerca disperatamente sua madre.\n\nLa gente passa, troppo occupata.",
        choices = {
            { id = "help", text = "Lo aiuti a cercare sua madre", reputationChange = 20, consequence = "Trovate la madre. Ti ringrazia con le lacrime agli occhi." },
            { id = "guards", text = "Chiami le guardie", reputationChange = 5, consequence = "Le guardie se ne occupano. Hai fatto il minimo." },
            { id = "ignore", text = "Non e' un tuo problema", reputationChange = -15, consequence = "Il pianto continua mentre ti allontani." }
        },
        rememberedAs = "Il bambino perduto"
    },

    -- 3. Il portafoglio
    {
        id = "daily_wallet",
        type = "DAILY",
        title = "Oggetto Smarrito",
        context = "Noti un portafoglio a terra. Dentro c'e' denaro e documenti.\n\nIl proprietario sembra essere un mercante locale.",
        choices = {
            { id = "return", text = "Restituisci tutto", reputationChange = 25, consequence = "'Pochi avrebbero fatto lo stesso.' Ti ringrazia." },
            { id = "keep_some", text = "Tieni il denaro, restituisci i documenti", reputationChange = -20, consequence = "Non sapra' mai del denaro mancante." },
            { id = "keep_all", text = "Tieni tutto", reputationChange = -30, consequence = "Il portafoglio sparisce nelle tue tasche." }
        },
        rememberedAs = "Il portafoglio"
    },

    -- 4. Il cane randagio
    {
        id = "daily_stray_dog",
        type = "DAILY",
        title = "Il Randagio",
        context = "Un cane magro e sporco ti segue. Ha fame, si vede.\n\nTi guarda con occhi speranzosi.",
        choices = {
            { id = "feed", text = "Gli dai del cibo", reputationChange = 15, consequence = "Il cane mangia voracemente. Ti seguira' per un po'." },
            { id = "ignore", text = "Lo ignori", reputationChange = -5, consequence = "Il cane resta fermo, deluso." },
            { id = "kick", text = "Lo scacci con violenza", reputationChange = -20, consequence = "Il cane fugge guaendo. Qualcuno ti ha visto." }
        },
        rememberedAs = "Il cane randagio"
    },

    -- 5. La discussione
    {
        id = "daily_argument",
        type = "DAILY",
        title = "Voci Alte",
        context = "Due mercanti litigano furiosamente per un affare andato male.\n\nLa situazione sta degenerando.",
        choices = {
            { id = "mediate", text = "Intervieni per calmare gli animi", reputationChange = 20, consequence = "Riesci a far ragionare entrambi. Ti ringraziano." },
            { id = "watch", text = "Osservi senza intervenire", reputationChange = 0, consequence = "La lite si risolve da sola, ma male." },
            { id = "escalate", text = "Aizzi uno contro l'altro", reputationChange = -25, consequence = "Scoppia una rissa. Tu ti allontani soddisfatto." }
        },
        rememberedAs = "La lite al mercato"
    },

    -- 6. L'anziana
    {
        id = "daily_elderly",
        type = "DAILY",
        title = "Il Peso degli Anni",
        context = "Un'anziana fatica a portare le borse della spesa su per una salita ripida.\n\nNessuno si ferma ad aiutarla.",
        choices = {
            { id = "help", text = "L'aiuti con le borse", reputationChange = 15, consequence = "'Che il cielo ti benedica, ragazzo.'" },
            { id = "ignore", text = "Continui per la tua strada", reputationChange = -10, consequence = "La vedi arrancare mentre ti allontani." }
        },
        rememberedAs = "L'anziana"
    },

    -- 7. Il musicista
    {
        id = "daily_musician",
        type = "DAILY",
        title = "Melodia di Strada",
        context = "Un musicista cieco suona il violino all'angolo della strada. La musica e' bellissima, ma la sua custodia e' vuota.",
        choices = {
            { id = "pay", text = "Lasci una moneta e ti fermi ad ascoltare", reputationChange = 15, consequence = "Il musicista sorride. 'Grazie per il tuo tempo.'" },
            { id = "steal", text = "Rubi le poche monete nella custodia", reputationChange = -30, consequence = "Il cieco non se ne accorge. Ma tu sai." },
            { id = "ignore", text = "Passi oltre", reputationChange = -5, consequence = "La musica continua, indifferente." }
        },
        rememberedAs = "Il musicista cieco"
    },

    -- 8. La lettera
    {
        id = "daily_letter",
        type = "DAILY",
        title = "Parole Perdute",
        context = "Trovi una lettera sigillata per terra. L'indirizzo e' leggibile.\n\nSembra importante.",
        choices = {
            { id = "deliver", text = "La consegni al destinatario", reputationChange = 20, consequence = "Il destinatario impallidisce. 'Era di mio padre... grazie.'" },
            { id = "read", text = "La apri e la leggi", reputationChange = -15, consequence = "Segreti di famiglia. Informazioni utili, forse." },
            { id = "discard", text = "La butti via", reputationChange = -10, consequence = "La lettera vola nel vento." }
        },
        rememberedAs = "La lettera perduta"
    },

    -- 9. Il furto
    {
        id = "daily_theft_witness",
        type = "DAILY",
        title = "Testimone",
        context = "Vedi un ragazzino rubare una mela dalla bancarella. Il venditore non se n'e' accorto.\n\nIl ragazzino ti guarda terrorizzato.",
        choices = {
            { id = "cover", text = "Fai finta di niente", reputationChange = 5, consequence = "Il ragazzino scappa. Aveva fame, si vedeva." },
            { id = "pay", text = "Paghi tu la mela", reputationChange = 20, consequence = "Il ragazzino ti guarda con gratitudine infinita." },
            { id = "report", text = "Lo denunci al venditore", reputationChange = -15, consequence = "Il venditore afferra il ragazzino. Le urla attirano la folla." }
        },
        rememberedAs = "Il piccolo ladro"
    },

    -- 10. La scommessa
    {
        id = "daily_gamble",
        type = "DAILY",
        title = "Tentazione",
        context = "Un gruppo gioca a dadi in un vicolo. Ti invitano a unirti.\n\n'Dai, e' solo un gioco.'",
        choices = {
            { id = "refuse", text = "Rifiuti educatamente", reputationChange = 5, consequence = "'Peccato. Forse un'altra volta.'" },
            { id = "play_fair", text = "Giochi onestamente", reputationChange = 0, consequence = "Vinci un po', perdi un po'. Esperienza." },
            { id = "cheat", text = "Giochi barando", reputationChange = -25, consequence = "Vinci. Ma qualcuno ha notato i tuoi trucchi." }
        },
        rememberedAs = "Il gioco dei dadi"
    },

    -- 11. L'incidente
    {
        id = "daily_accident",
        type = "DAILY",
        title = "Caduta",
        context = "Un uomo cade da una scala mentre lavora. Sembra essersi fatto male alla gamba.\n\nNessun altro e' nei paraggi.",
        choices = {
            { id = "help", text = "Lo aiuti a rialzarsi e chiami aiuto", reputationChange = 20, consequence = "'Non so come ringraziarti.' Ti stringe la mano." },
            { id = "ignore", text = "Non e' affar tuo", reputationChange = -15, consequence = "I suoi lamenti ti seguono mentre vai via." },
            { id = "rob", text = "Gli rubi la borsa mentre e' a terra", reputationChange = -30, consequence = "Facile. Troppo facile." }
        },
        rememberedAs = "L'uomo caduto"
    },

    -- 12. Il segreto
    {
        id = "daily_secret",
        type = "DAILY",
        title = "Sussurri",
        context = "Senti per caso una conversazione. Due persone parlano di tradire un amico comune.\n\nNon sanno che ci sei.",
        choices = {
            { id = "warn", text = "Avvisi l'amico del complotto", reputationChange = 25, consequence = "L'amico e' sconvolto ma grato. 'Ti devo molto.'" },
            { id = "ignore", text = "Non ti immischi", reputationChange = -5, consequence = "Non sono affari tuoi. Ma il senso di colpa resta." },
            { id = "blackmail", text = "Usi l'informazione per ricattarli", reputationChange = -30, consequence = "Pagano per il tuo silenzio. Per ora." }
        },
        rememberedAs = "Il segreto ascoltato"
    },

    -- 13. L'elemosina
    {
        id = "daily_charity",
        type = "DAILY",
        title = "La Questua",
        context = "Un monaco chiede offerte per il tempio. La sua ciotola e' quasi piena.\n\n'Ogni donazione e' una benedizione.'",
        choices = {
            { id = "donate", text = "Fai un'offerta generosa", reputationChange = 15, consequence = "Il monaco si inchina. 'La luce sia con te.'" },
            { id = "decline", text = "Declini gentilmente", reputationChange = 0, consequence = "'Che tu sia benedetto comunque.'" },
            { id = "mock", text = "Lo deridi pubblicamente", reputationChange = -20, consequence = "Il monaco tace. Ma la gente ti guarda male." }
        },
        rememberedAs = "Il monaco"
    },

    -- 14. Il ponte
    {
        id = "daily_bridge",
        type = "DAILY",
        title = "Sul Bordo",
        context = "Una figura solitaria sta sul bordo del ponte, guardando l'acqua sotto.\n\nSembra... indecisa.",
        choices = {
            { id = "talk", text = "Ti avvicini e parli con calma", reputationChange = 30, consequence = "Dopo un'ora, scende dal bordo. 'Grazie per essere rimasto.'" },
            { id = "ignore", text = "Non vuoi essere coinvolto", reputationChange = -20, consequence = "Ti allontani. Non vuoi sapere come finisce." },
            { id = "push", text = "La spingi", reputationChange = -50, consequence = "Il tonfo nell'acqua. Nessuno ha visto. Ma lo saprai per sempre." }
        },
        rememberedAs = "La figura sul ponte"
    },

    -- 15. Il messaggio
    {
        id = "daily_message",
        type = "DAILY",
        title = "Corriere",
        context = "Un messaggero ferito ti affida una lettera. 'Portala al capitano... e' urgente...'\n\nPoi sviene.",
        choices = {
            { id = "deliver", text = "Consegni la lettera al capitano", reputationChange = 25, consequence = "Il capitano legge e impallidisce. 'Hai salvato molte vite.'" },
            { id = "read_deliver", text = "La leggi prima di consegnarla", reputationChange = 5, consequence = "Informazioni militari. La consegni. Ma ora sai troppo." },
            { id = "sell", text = "Vendi la lettera al miglior offerente", reputationChange = -35, consequence = "Un uomo in nero paga bene. 'Saggio. Dimentica tutto.'" }
        },
        rememberedAs = "Il messaggero ferito"
    },
}

-- ============================================
-- EVENTI MORALI - 10 eventi
-- Scelte difficili con conseguenze importanti
-- ============================================

StoryEvents.MoralEvents = {
    -- 1. Il ladro affamato
    {
        id = "moral_hungry_thief",
        type = "MORAL",
        title = "Giustizia o Pieta",
        context = "Le guardie hanno catturato un ladro. Un ragazzo giovane, magro.\n\nHa rubato del pane. La legge e' chiara: il furto si paga con una mano.\n\nLe guardie ti riconoscono. 'Cosa dovremmo fare?'",
        choices = {
            { id = "mercy", text = "Paghi il debito al venditore", reputationChange = 100, consequence = "Il ragazzo piange di gratitudine. Il venditore brontola ma accetta." },
            { id = "law", text = "La legge e' legge", reputationChange = -80, consequence = "Le urla del ragazzo echeggiano. Hai mantenuto l'ordine." },
            { id = "recruit", text = "Lo prendi sotto la tua protezione", reputationChange = -60, consequence = "Ora ti deve la vita. Un debito che potrai riscuotere." }
        },
        rememberedAs = "Il giudizio del ladro"
    },

    -- 2. Il segreto mortale
    {
        id = "moral_deadly_secret",
        type = "MORAL",
        title = "Veleno",
        context = "Una serva ti avvicina nell'ombra.\n\n'Il lord sta avvelenando sua moglie. Lentamente. Per l'eredita'.'\n\nTi porge una fiala come prova.",
        choices = {
            { id = "expose", text = "Prendi le prove e lo fermi", reputationChange = 120, consequence = "Il lord viene arrestato. La moglie e' salva." },
            { id = "blackmail", text = "Ricatti il lord", reputationChange = -100, consequence = "Il lord paga bene per il tuo silenzio." },
            { id = "warn_lord", text = "Avvisi il lord della serva", reputationChange = -150, consequence = "'Sei un vero alleato.' La serva sparisce quella notte." }
        },
        rememberedAs = "Il segreto del lord"
    },

    -- 3. Il tradimento
    {
        id = "moral_betrayal",
        type = "MORAL",
        title = "Fedelta",
        context = "Il tuo migliore amico ti chiede di mentire per lui.\n\n'Dì che ero con te quella notte. Altrimenti mi impiccano.'\n\nSai che e' colpevole.",
        choices = {
            { id = "lie", text = "Menti per salvarlo", reputationChange = -80, consequence = "L'amico e' libero. Ma un innocente pagherà al suo posto." },
            { id = "truth", text = "Dici la verita", reputationChange = 70, consequence = "L'amico viene portato via. 'Ti maledico.' Ma giustizia e' fatta." },
            { id = "silent", text = "Rifiuti di testimoniare", reputationChange = -30, consequence = "Senza la tua testimonianza, il caso si complica." }
        },
        rememberedAs = "Il tradimento dell'amico"
    },

    -- 4. Il bambino malato
    {
        id = "moral_sick_child",
        type = "MORAL",
        title = "La Cura",
        context = "Un padre disperato ti ferma. Suo figlio sta morendo.\n\n'L'unica cura e' nella farmacia. Costa troppo. Ti prego.'\n\nHai abbastanza soldi. Ma sono tutti i tuoi risparmi.",
        choices = {
            { id = "pay", text = "Paghi la cura", reputationChange = 150, consequence = "Il bambino guarira. Il padre piange. 'Non lo dimentichero mai.'" },
            { id = "half", text = "Paghi meta, lui trova il resto", reputationChange = 50, consequence = "Insieme ce la fate. Un compromesso." },
            { id = "refuse", text = "Non puoi permettertelo", reputationChange = -60, consequence = "Il padre crolla. Tu ti allontani col peso nel petto." }
        },
        rememberedAs = "Il bambino malato"
    },

    -- 5. L'assassino
    {
        id = "moral_assassin",
        type = "MORAL",
        title = "Ombra nella Notte",
        context = "Un assassino ti offre un lavoro. Il bersaglio e' un mercante corrotto.\n\n'Ha rovinato molte famiglie. Nessuno piangerà.'\n\nLa paga e' enorme.",
        choices = {
            { id = "refuse", text = "Rifiuti categoricamente", reputationChange = 80, consequence = "'Peccato. Troverò qualcun altro.' Se ne va." },
            { id = "accept", text = "Accetti il lavoro", reputationChange = -150, consequence = "Il mercante muore nel sonno. Sei piu' ricco. E piu' vuoto." },
            { id = "warn", text = "Avvisi il mercante", reputationChange = 100, consequence = "Il mercante fugge. L'assassino sapra' del tuo tradimento." }
        },
        rememberedAs = "L'offerta dell'assassino"
    },

    -- 6. I profughi
    {
        id = "moral_refugees",
        type = "MORAL",
        title = "Stranieri",
        context = "Un gruppo di profughi chiede rifugio nel tuo quartiere. Sono affamati, spaventati.\n\nI vicini mormorano. 'Non li vogliamo qui.'",
        choices = {
            { id = "welcome", text = "Li accogli e li aiuti", reputationChange = 100, consequence = "I profughi ti benedicono. I vicini ti guardano male." },
            { id = "reject", text = "Li mandi via", reputationChange = -70, consequence = "Se ne vanno nella notte. Non sai dove andranno." },
            { id = "exploit", text = "Li sfrutti come manodopera a basso costo", reputationChange = -120, consequence = "Lavorano per te quasi gratis. Sono troppo disperati per rifiutare." }
        },
        rememberedAs = "I profughi"
    },

    -- 7. Il duello
    {
        id = "moral_duel",
        type = "MORAL",
        title = "Questione d'Onore",
        context = "Un nobile ti sfida a duello. Hai insultato la sua famiglia, dice.\n\nNon e' vero. Ma rifiutare significa disonore.",
        choices = {
            { id = "accept_fair", text = "Accetti e combatti lealmente", reputationChange = 50, consequence = "Il duello e' feroce ma leale. Alla fine, rispetto reciproco." },
            { id = "refuse", text = "Rifiuti il duello", reputationChange = -40, consequence = "'Codardo!' La voce si sparge. Ma sei vivo." },
            { id = "cheat", text = "Accetti ma bari durante il duello", reputationChange = -100, consequence = "Il nobile cade. 'Hai... barato...' Nessuno può provarlo." }
        },
        rememberedAs = "Il duello"
    },

    -- 8. La schiava
    {
        id = "moral_slave",
        type = "MORAL",
        title = "Catene",
        context = "Una schiava fugge dal suo padrone e ti chiede aiuto.\n\n'Ti prego, nascondimi. Mi uccideranno se mi riprendono.'\n\nAiutarla e' illegale.",
        choices = {
            { id = "hide", text = "La nascondi", reputationChange = 120, consequence = "Rischi la tua sicurezza. Ma lei e' libera." },
            { id = "return", text = "La riporti dal padrone", reputationChange = -130, consequence = "Il padrone ti ricompensa. Le urla di lei ti seguono." },
            { id = "buy", text = "Compri la sua liberta'", reputationChange = 100, consequence = "Costa tutto cio' che hai. Ma e' libera legalmente." }
        },
        rememberedAs = "La schiava fuggitiva"
    },

    -- 9. Il testimone
    {
        id = "moral_witness",
        type = "MORAL",
        title = "Verita'",
        context = "Hai visto un omicidio. L'assassino e' il figlio del governatore.\n\nSe testimoni, la tua vita sara' in pericolo.",
        choices = {
            { id = "testify", text = "Testimoni la verita'", reputationChange = 150, consequence = "Il figlio viene arrestato. Devi lasciare la citta'. Ma giustizia e' fatta." },
            { id = "silent", text = "Taci", reputationChange = -80, consequence = "Un innocente viene accusato al suo posto." },
            { id = "blackmail", text = "Ricatti il governatore", reputationChange = -140, consequence = "Pagano per il tuo silenzio. Sei ricco. E compromesso." }
        },
        rememberedAs = "Il testimone dell'omicidio"
    },

    -- 10. La guerra
    {
        id = "moral_war",
        type = "MORAL",
        title = "Leva",
        context = "L'esercito chiede volontari per una guerra ingiusta.\n\nChi non si arruola sara' marchiato come traditore.",
        choices = {
            { id = "enlist", text = "Ti arruoli", reputationChange = -50, consequence = "Combatterai una guerra in cui non credi." },
            { id = "refuse", text = "Rifiuti pubblicamente", reputationChange = 80, consequence = "Ti marchiano. Ma la tua coscienza e' pulita." },
            { id = "flee", text = "Fuggi dalla citta'", reputationChange = -30, consequence = "Lasci tutto. Ma sei libero." }
        },
        rememberedAs = "La chiamata alle armi"
    },
}

-- ============================================
-- EVENTI CHIAVE (KEY) - 5 eventi
-- Cambiano profondamente la run
-- ============================================

StoryEvents.KeyEvents = {
    -- 1. La scelta della fazione
    {
        id = "key_faction_choice",
        type = "KEY",
        title = "Il Bivio",
        context = "Due messaggeri ti attendono.\n\nUno veste di blu. 'I Celesti ti osservano. Sei degno.'\n\nL'altro e' avvolto in rosso. 'I Cremisi vedono il tuo potenziale.'",
        requirements = { minReputation = -1500, maxReputation = 1500 },
        choices = {
            { id = "celeste", text = "'Sono con la Luce.'", reputationChange = 500, consequence = "'Benvenuto, fratello.' Il Cremisi scompare nell'ombra." },
            { id = "cremisi", text = "'Il potere e' tutto.'", reputationChange = -500, consequence = "Il Cremisi ride. Il Celeste si allontana con tristezza." },
            { id = "neither", text = "'Non appartengo a nessuno.'", reputationChange = 0, consequence = "Entrambi annuiscono. 'Cosi' sia.' Sei solo. Sei libero." }
        },
        rememberedAs = "La scelta della fazione"
    },

    -- 2. Il Trono Vacante
    {
        id = "key_throne",
        type = "KEY",
        title = "Il Trono Vacante",
        context = "Il vecchio re e' morto senza eredi. Il consiglio e' diviso.\n\nInaspettatamente, ti chiedono di decidere chi sara' il nuovo re.",
        requirements = { minReputation = 3000 },
        choices = {
            { id = "just", text = "Scegli il candidato piu' giusto", reputationChange = 400, consequence = "Un re saggio sale al trono. Il popolo festeggia." },
            { id = "corrupt", text = "Scegli chi ti ha pagato di piu'", reputationChange = -500, consequence = "Sei ricco. Il regno soffrira'." },
            { id = "yourself", text = "Proponi te stesso", reputationChange = -300, consequence = "Shock nel consiglio. Ma alcuni annuiscono..." }
        },
        rememberedAs = "La scelta del re"
    },

    -- 3. Il Trono Oscuro
    {
        id = "key_dark_throne",
        type = "KEY",
        title = "Il Trono Oscuro",
        context = "I signori del crimine ti riconoscono come uno di loro.\n\n'Il vecchio capo e' morto. Prendi il suo posto.'",
        requirements = { maxReputation = -3000 },
        choices = {
            { id = "accept", text = "Accetti il potere", reputationChange = -600, consequence = "Sei il nuovo signore dell'ombra. Temuto da tutti." },
            { id = "refuse", text = "Rifiuti", reputationChange = 200, consequence = "'Peccato.' Ti rispettano comunque. Per ora." },
            { id = "destroy", text = "Distruggi l'organizzazione dall'interno", reputationChange = 500, consequence = "Tradisci tutti. L'organizzazione crolla. Hai molti nemici." }
        },
        rememberedAs = "Il trono dell'ombra"
    },

    -- 4. L'Apocalisse
    {
        id = "key_apocalypse",
        type = "KEY",
        title = "La Fine dei Giorni",
        context = "Una profezia si avvera. La citta' sta per essere distrutta.\n\nHai tempo di salvare solo una cosa: le persone o i tesori.",
        requirements = {},
        choices = {
            { id = "people", text = "Salvi le persone", reputationChange = 700, consequence = "I tesori bruciano. Ma centinaia vivono grazie a te." },
            { id = "treasure", text = "Salvi i tesori", reputationChange = -600, consequence = "Sei ricco oltre misura. Le urla ti seguiranno per sempre." },
            { id = "nothing", text = "Fuggi senza salvare nulla", reputationChange = -200, consequence = "Sopravvivi. Vuoto." }
        },
        rememberedAs = "Il giorno della distruzione"
    },

    -- 5. Il Sacrificio
    {
        id = "key_sacrifice",
        type = "KEY",
        title = "Il Prezzo",
        context = "Per salvare la citta', qualcuno deve morire. Gli dei lo richiedono.\n\nTutti ti guardano. La scelta e' tua.",
        requirements = {},
        choices = {
            { id = "self", text = "Ti offri tu", reputationChange = 1000, consequence = "Miracolosamente sopravvivi. Gli dei ti hanno giudicato degno." },
            { id = "volunteer", text = "Chiedi un volontario", reputationChange = 100, consequence = "Un anziano si fa avanti. 'Ho vissuto abbastanza.'" },
            { id = "choose", text = "Scegli qualcun altro contro la sua volonta'", reputationChange = -700, consequence = "Il prescelto maledice il tuo nome. La citta' e' salva." }
        },
        rememberedAs = "Il sacrificio"
    },
}

-- ============================================
-- EVENTI DI INSTABILITA'
-- ============================================

StoryEvents.InstabilityEvents = {
    {
        id = "instability_crisis",
        type = "MORAL",
        title = "Chi Sei?",
        triggerOnInstability = true,
        context = "Ti svegli sudato. Una voce nel buio. La tua voce.\n\n'Celeste. Cremisi. Avanti e indietro. Non sai chi sei.'",
        choices = {
            { id = "light", text = "Cerchi la luce dentro di te", reputationChange = 150, consequence = "L'ombra svanisce. Per ora." },
            { id = "dark", text = "Abbracci l'oscurita'", reputationChange = -150, consequence = "La luce si dissolve. 'Finalmente.'" },
            { id = "shatter", text = "Urli contro il vuoto", reputationChange = 0, consequence = "Il silenzio e' la tua unica risposta." }
        },
        rememberedAs = "La crisi d'identita'"
    },
}

function StoryEvents.RegisterAll(EventSystem)
    for _, event in ipairs(StoryEvents.DailyEvents) do
        EventSystem.RegisterEvent(event)
    end
    for _, event in ipairs(StoryEvents.MoralEvents) do
        EventSystem.RegisterEvent(event)
    end
    for _, event in ipairs(StoryEvents.KeyEvents) do
        EventSystem.RegisterEvent(event)
    end
    for _, event in ipairs(StoryEvents.InstabilityEvents) do
        EventSystem.RegisterEvent(event)
    end
end

return StoryEvents
