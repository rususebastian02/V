--[[
    LIFE TEXT RPG - Eventi Narrativi
    Collezione di eventi per il gioco.

    Struttura eventi:
    - DAILY: +/- 10-30 rep
    - MORAL: +/- 50-150 rep
    - KEY: +/- 300-700 rep
]]

local StoryEvents = {}

-- ============================================
-- EVENTI QUOTIDIANI (DAILY)
-- Piccole scelte che definiscono chi sei
-- ============================================

StoryEvents.DailyEvents = {
    -- Evento 1: Il mendicante
    {
        id = "daily_beggar_01",
        type = "DAILY",
        title = "L'Incontro",
        context = [[
Un uomo siede contro il muro di un vicolo. I suoi vestiti sono logori,
lo sguardo vuoto. Una ciotola di latta davanti a lui è quasi vuota.

Ti vede e alza gli occhi. Non dice nulla. Aspetta.
        ]],
        choices = {
            {
                id = "help",
                text = "Gli dai qualche moneta e un cenno del capo",
                reputationChange = 15,
                consequence = "L'uomo annuisce. 'Grazie, straniero.' Le sue parole sono sincere."
            },
            {
                id = "ignore",
                text = "Passi oltre senza guardarlo",
                reputationChange = -10,
                consequence = "I suoi occhi ti seguono mentre ti allontani. Un altro che non vede."
            },
            {
                id = "cruel",
                text = "Rovesci la ciotola con il piede",
                reputationChange = -25,
                consequence = "Le poche monete rotolano nel fango. L'uomo non reagisce. Ha smesso di sorprendersi."
            }
        },
        rememberedAs = "L'incontro con il mendicante"
    },

    -- Evento 2: Il bambino perduto
    {
        id = "daily_lost_child_01",
        type = "DAILY",
        title = "Pianto nel Mercato",
        context = [[
Un bambino piange in mezzo alla piazza del mercato.
È chiaramente perso, cerca disperatamente sua madre tra la folla.

La gente passa, troppo occupata per fermarsi.
        ]],
        choices = {
            {
                id = "help_find",
                text = "Ti fermi e lo aiuti a cercare sua madre",
                reputationChange = 20,
                consequence = "Dopo qualche minuto trovate la madre. Ti ringrazia con le lacrime agli occhi."
            },
            {
                id = "call_guards",
                text = "Chiami le guardie perché se ne occupino loro",
                reputationChange = 5,
                consequence = "Le guardie prendono il bambino. Hai fatto il minimo necessario."
            },
            {
                id = "ignore_child",
                text = "Non è un tuo problema",
                reputationChange = -15,
                consequence = "Il pianto continua mentre ti allontani. Qualcun altro ci penserà. Forse."
            }
        },
        rememberedAs = "Il bambino perduto al mercato"
    },

    -- Evento 3: Il portafoglio
    {
        id = "daily_wallet_01",
        type = "DAILY",
        title = "Oggetto Smarrito",
        context = [[
Cammini per strada quando noti un portafoglio a terra.
Dentro c'è una discreta somma di denaro e dei documenti.

Il proprietario sembra essere un mercante locale.
        ]],
        choices = {
            {
                id = "return",
                text = "Cerchi il proprietario e restituisci tutto",
                reputationChange = 25,
                consequence = "Il mercante è sorpreso e grato. 'Pochi avrebbero fatto lo stesso.'"
            },
            {
                id = "keep_some",
                text = "Tieni il denaro ma restituisci i documenti",
                reputationChange = -20,
                consequence = "Il mercante ritrova i documenti. Non saprà mai del denaro mancante."
            },
            {
                id = "keep_all",
                text = "Tieni tutto per te",
                reputationChange = -30,
                consequence = "Il portafoglio sparisce nelle tue tasche. Nessuno ha visto."
            }
        },
        rememberedAs = "Il portafoglio trovato"
    },
}

-- ============================================
-- EVENTI MORALI
-- Scelte difficili con conseguenze importanti
-- ============================================

StoryEvents.MoralEvents = {
    -- Evento 1: Il ladro affamato
    {
        id = "moral_hungry_thief_01",
        type = "MORAL",
        title = "Giustizia o Pietà",
        context = [[
Le guardie hanno catturato un ladro. Un ragazzo giovane, magro, lo sguardo terrorizzato.

Ha rubato del pane da una bancarella. Il venditore urla, chiede una punizione esemplare.
La legge è chiara: il furto si paga con una mano.

Le guardie ti riconoscono. "{TITLE}, cosa dovremmo fare?"
        ]],
        requirements = {
            minReputation = -2000,
            maxReputation = 2000
        },
        choices = {
            {
                id = "mercy",
                text = "Intercedi per il ragazzo. Paghi tu il debito al venditore.",
                reputationChange = 100,
                consequence = "Il ragazzo piange di gratitudine. Il venditore brontola ma accetta. Le guardie annuiscono con rispetto."
            },
            {
                id = "law",
                text = "La legge è legge. Che sia fatta giustizia.",
                reputationChange = -50,
                consequence = "Le urla del ragazzo echeggiano nella piazza. Hai mantenuto l'ordine. A che prezzo?"
            },
            {
                id = "recruit",
                text = "Prendi il ragazzo sotto la tua protezione. Diventerà utile.",
                reputationChange = -80,
                consequence = "Il ragazzo ti guarda con un misto di paura e gratitudine. Ora ti deve la vita. Un debito che potrai riscuotere."
            },
            {
                id = "public_shame",
                text = "Risparmiagli la mano, ma che sia esposto al pubblico ludibrio per tre giorni.",
                reputationChange = -30,
                consequence = "Un compromesso. Il ragazzo soffrirà, ma vivrà integro. La folla mormora, incerta su cosa pensare di te."
            }
        },
        rememberedAs = "Il giudizio del giovane ladro",
        involvedNPCs = {"hungry_thief_boy", "bread_vendor", "city_guards"}
    },

    -- Evento 2: Il segreto mortale
    {
        id = "moral_deadly_secret_01",
        type = "MORAL",
        title = "Il Peso del Silenzio",
        context = [[
Una donna ti avvicina nell'ombra. Riconosci in lei una serva della casa nobile locale.

"So qualcosa," sussurra. "Il lord sta avvelenando sua moglie. Lentamente.
Per l'eredità. Ho le prove."

Ti porge una fiala e una lettera. "Posso darle a voi. O posso venderle al lord.
Lui pagherebbe molto per il mio silenzio... e il vostro."
        ]],
        choices = {
            {
                id = "expose",
                text = "Prendi le prove. Il lord deve essere fermato.",
                reputationChange = 120,
                consequence = "La donna annuisce e sparisce nella notte. Hai le prove. Ora devi decidere cosa farne.",
                effects = {
                    unlockEvent = "moral_noble_confrontation_01"
                }
            },
            {
                id = "blackmail",
                text = "Tieni le prove per te. Il lord pagherà per il tuo silenzio.",
                reputationChange = -100,
                consequence = "Un sorriso si forma sulle tue labbra. Il potere non viene solo dalla forza.",
                effects = {
                    unlockEvent = "moral_blackmail_noble_01"
                }
            },
            {
                id = "warn_lord",
                text = "Vai dal lord e lo avvisi della serva traditrice.",
                reputationChange = -150,
                consequence = "Il lord ti guarda con nuovi occhi. 'Sei un vero alleato.' La serva non sarà più un problema. Per nessuno.",
                effects = {
                    setFlag = "betrayed_servant"
                }
            },
            {
                id = "stay_out",
                text = "Non vuoi essere coinvolto. Te ne vai senza dire nulla.",
                reputationChange = 0,
                consequence = "La donna ti guarda allontanarti. 'Codardo,' sussurra. Ma almeno sei vivo."
            }
        },
        rememberedAs = "Il segreto della casa nobile"
    },
}

-- ============================================
-- EVENTI CHIAVE (KEY)
-- Cambiano profondamente la run
-- ============================================

StoryEvents.KeyEvents = {
    -- Evento 1: La scelta della fazione
    {
        id = "key_faction_choice_01",
        type = "KEY",
        title = "Il Bivio",
        context = [[
Sei stato convocato. Due messaggeri ti attendono.

Uno veste di blu, l'emblema della Luce cucito sul mantello.
"I Celesti ti hanno osservato. Sei degno di unirti a noi."

L'altro è avvolto in rosso scuro, gli occhi come braci.
"I Cremisi vedono il tuo potenziale. Il vero potere non ha catene morali."

Entrambi attendono la tua risposta.
        ]],
        requirements = {
            minReputation = -1500,
            maxReputation = 1500
        },
        choices = {
            {
                id = "join_celeste",
                text = "Ti inchini al messaggero Celeste. 'Sono con la Luce.'",
                reputationChange = 500,
                consequence = "Il messaggero Celeste sorride. 'Benvenuto, fratello.' Il Cremisi scompare nell'ombra, ma i suoi occhi promettono che vi rincontrerete.",
                effects = {
                    setFlag = "faction_celeste_joined",
                    unlockEvent = "celeste_initiation_01"
                }
            },
            {
                id = "join_cremisi",
                text = "Sorridi al messaggero Cremisi. 'Il potere è tutto.'",
                reputationChange = -500,
                consequence = "Il Cremisi ride. 'Saggio.' Il Celeste scuote la testa con tristezza e si allontana. Hai fatto la tua scelta.",
                effects = {
                    setFlag = "faction_cremisi_joined",
                    unlockEvent = "cremisi_initiation_01"
                }
            },
            {
                id = "reject_both",
                text = "Rifiuti entrambi. 'Non appartengo a nessuno.'",
                reputationChange = 0,
                consequence = "Entrambi i messaggeri ti guardano con un misto di sorpresa e rispetto. 'Così sia,' dicono all'unisono, e se ne vanno. Sei solo. Sei libero.",
                effects = {
                    setFlag = "faction_independent",
                    unlockEvent = "independent_path_01"
                }
            }
        },
        rememberedAs = "La scelta della fazione"
    },
}

-- ============================================
-- EVENTI DI INSTABILITÀ
-- Per player che cambiano spesso fazione
-- ============================================

StoryEvents.InstabilityEvents = {
    {
        id = "instability_identity_crisis_01",
        type = "MORAL",
        title = "Chi Sei Veramente?",
        triggerOnInstability = true,
        context = [[
Ti svegli nel cuore della notte. Sudore freddo.

Nel buio, una voce. La tua voce. Ma non sei tu a parlare.

"Celeste. Cremisi. Celeste. Cremisi. Avanti e indietro, come una foglia nel vento.
Non sai chi sei, vero? Non lo sai nemmeno tu."

Lo specchio di fronte a te mostra due riflessi sovrapposti.
Uno di luce. Uno di ombra. Entrambi sei tu.
        ]],
        choices = {
            {
                id = "embrace_light",
                text = "Chiudi gli occhi e cerchi la luce dentro di te",
                reputationChange = 150,
                consequence = "Il riflesso oscuro svanisce. Per ora. Ma sai che tornerà."
            },
            {
                id = "embrace_dark",
                text = "Sorridi all'ombra. È sempre stata più onesta.",
                reputationChange = -150,
                consequence = "Il riflesso luminoso si dissolve. L'ombra ti sorride. 'Finalmente.'"
            },
            {
                id = "shatter_mirror",
                text = "Spacchi lo specchio. Non vuoi più vedere.",
                reputationChange = 0,
                consequence = "I frammenti cadono. Ma nei mille pezzi, mille riflessi ti fissano ancora. Non puoi sfuggire a te stesso."
            }
        },
        rememberedAs = "La crisi d'identità"
    },
}

-- Funzione per registrare tutti gli eventi
function StoryEvents.RegisterAll(EventSystem)
    -- Registra eventi quotidiani
    for _, event in ipairs(StoryEvents.DailyEvents) do
        EventSystem.RegisterEvent(event)
    end

    -- Registra eventi morali
    for _, event in ipairs(StoryEvents.MoralEvents) do
        EventSystem.RegisterEvent(event)
    end

    -- Registra eventi chiave
    for _, event in ipairs(StoryEvents.KeyEvents) do
        EventSystem.RegisterEvent(event)
    end

    -- Registra eventi di instabilità
    for _, event in ipairs(StoryEvents.InstabilityEvents) do
        EventSystem.RegisterEvent(event)
    end
end

return StoryEvents
