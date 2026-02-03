--[[
    LIFE TEXT RPG - Sistema NPC Reattivo
    Gli NPC reagiscono alla tua reputazione e alle tue scelte passate.
]]

local NPCSystem = {}

-- Database NPC
NPCSystem.NPCs = {
    -- Mercanti
    merchant_old = {
        id = "merchant_old",
        name = "Vecchio Mercante",
        dialogues = {
            neutral = "Benvenuto, straniero. Cosa posso fare per te?",
            celeste_low = "Ah, ti conosco. Dicono che sei una brava persona.",
            celeste_mid = "E' un onore averti qui. I tuoi gesti parlano per te.",
            celeste_high = "Mi inchino alla tua presenza. Sei una leggenda.",
            cremisi_low = "Hmm... ho sentito cose su di te. Cosa vuoi?",
            cremisi_mid = "Fai in fretta. Non voglio problemi.",
            cremisi_high = "P-prego, non voglio guai... prendi quello che vuoi...",
        },
        remembers = { "daily_wallet", "daily_theft_witness" }
    },

    guard_captain = {
        id = "guard_captain",
        name = "Capitano delle Guardie",
        dialogues = {
            neutral = "Cittadino. Tutto in regola?",
            celeste_low = "Ho sentito parlare bene di te. Continua cosi'.",
            celeste_mid = "La citta' ha bisogno di persone come te.",
            celeste_high = "E' un onore. Se hai bisogno di qualcosa, chiedi.",
            cremisi_low = "Ti tengo d'occhio.",
            cremisi_mid = "So chi sei. Un passo falso e sei finito.",
            cremisi_high = "Fermati. Le tue mani dove posso vederle.",
        },
        remembers = { "moral_hungry_thief", "moral_witness", "daily_message" }
    },

    tavern_owner = {
        id = "tavern_owner",
        name = "Oste della Taverna",
        dialogues = {
            neutral = "Cosa ti porto? Birra, vino, idromele?",
            celeste_low = "Ehi, ti offro io il primo giro!",
            celeste_mid = "Amico mio! Siediti, sei sempre benvenuto.",
            celeste_high = "La leggenda in persona! Oggi non paghi nulla!",
            cremisi_low = "...si'. Cosa vuoi?",
            cremisi_mid = "Il tuo denaro e' buono. Ma non voglio risse.",
            cremisi_high = "Il tavolo in fondo. Lontano dagli altri.",
        },
        remembers = { "daily_argument", "daily_gamble" }
    },

    temple_priest = {
        id = "temple_priest",
        name = "Sacerdote del Tempio",
        dialogues = {
            neutral = "La luce sia con te, viaggiatore.",
            celeste_low = "Vedo la bonta' nel tuo cuore.",
            celeste_mid = "Sei un esempio per tutti noi.",
            celeste_high = "Sei benedetto dagli dei stessi.",
            cremisi_low = "Anche per te c'e' speranza di redenzione.",
            cremisi_mid = "Il tempio e' aperto a tutti... anche a te.",
            cremisi_high = "Vattene. Questo e' suolo sacro.",
        },
        remembers = { "daily_charity", "daily_bridge", "key_sacrifice" }
    },

    beggar_marco = {
        id = "beggar_marco",
        name = "Marco il Mendicante",
        dialogues = {
            neutral = "Una moneta, per pieta'?",
            celeste_low = "Ah, una faccia gentile!",
            celeste_mid = "Sei tu! Mi hai aiutato una volta.",
            celeste_high = "Il santo! Tutti parlano di te tra noi.",
            cremisi_low = "...per favore, non farmi del male.",
            cremisi_mid = "*si ritrae* Non ho nulla...",
            cremisi_high = "*fugge*",
        },
        remembers = { "daily_beggar" }
    },

    noble_lady = {
        id = "noble_lady",
        name = "Lady Elisabetta",
        dialogues = {
            neutral = "Non ci conosciamo, vero?",
            celeste_low = "Mi hanno parlato di te. Piacere di conoscerti.",
            celeste_mid = "Dovresti venire alla mia prossima festa.",
            celeste_high = "E' un onore. La tua fama ti precede.",
            cremisi_low = "Hmm. Mantieni le distanze.",
            cremisi_mid = "*alle guardie* Tenetelo d'occhio.",
            cremisi_high = "*urla* Guardie! Portatelo via!",
        },
        remembers = { "moral_deadly_secret", "moral_duel" }
    },

    blacksmith = {
        id = "blacksmith",
        name = "Fabbro",
        dialogues = {
            neutral = "Ho lame e armature. Cosa cerchi?",
            celeste_low = "Per te, un piccolo sconto.",
            celeste_mid = "Prendi, e' il mio lavoro migliore.",
            celeste_high = "Sara' mio onore forgiare per te.",
            cremisi_low = "Paga in anticipo.",
            cremisi_mid = "Solo affari. Niente domande.",
            cremisi_high = "Ho quello che cerchi... per il giusto prezzo.",
        },
        remembers = {}
    },

    mysterious_stranger = {
        id = "mysterious_stranger",
        name = "Straniero Misterioso",
        dialogues = {
            neutral = "Ti osservo da tempo...",
            celeste_low = "Interessante. Sei sulla via della luce.",
            celeste_mid = "I Celesti parlano di te.",
            celeste_high = "Sei pronto per cose piu' grandi.",
            cremisi_low = "Vedo l'ombra in te. Buono.",
            cremisi_mid = "I Cremisi hanno bisogno di gente come te.",
            cremisi_high = "Sei quasi dei nostri. Quasi.",
        },
        remembers = { "key_faction_choice" }
    },
}

-- Ottieni il dialogo appropriato per un NPC
function NPCSystem.GetDialogue(npcId, reputation, playerMemory)
    local npc = NPCSystem.NPCs[npcId]
    if not npc then return "..." end

    -- Controlla se l'NPC ricorda qualcosa di specifico
    local specialDialogue = NPCSystem.GetSpecialDialogue(npc, playerMemory)
    if specialDialogue then
        return specialDialogue
    end

    -- Altrimenti usa il dialogo basato sulla reputazione
    local absRep = math.abs(reputation)
    local dialogueKey

    if reputation > 0 then
        if absRep >= 6000 then
            dialogueKey = "celeste_high"
        elseif absRep >= 2000 then
            dialogueKey = "celeste_mid"
        elseif absRep >= 500 then
            dialogueKey = "celeste_low"
        else
            dialogueKey = "neutral"
        end
    elseif reputation < 0 then
        if absRep >= 6000 then
            dialogueKey = "cremisi_high"
        elseif absRep >= 2000 then
            dialogueKey = "cremisi_mid"
        elseif absRep >= 500 then
            dialogueKey = "cremisi_low"
        else
            dialogueKey = "neutral"
        end
    else
        dialogueKey = "neutral"
    end

    return npc.dialogues[dialogueKey] or npc.dialogues.neutral
end

-- Controlla se l'NPC ha un dialogo speciale basato sulla memoria
function NPCSystem.GetSpecialDialogue(npc, playerMemory)
    if not npc.remembers or not playerMemory then return nil end

    -- Dialoghi speciali basati su eventi ricordati
    local specialDialogues = {
        daily_wallet = {
            merchant_old = {
                positive = "Ah, sei tu che hai restituito il portafoglio! Grazie ancora!",
                negative = "Tu... sei quello che ha rubato il mio portafoglio, vero?"
            }
        },
        daily_beggar = {
            beggar_marco = {
                positive = "Sei tu! Quella moneta mi ha salvato la vita quel giorno.",
                negative = "Tu... tu sei quello che ha rovesciato la mia ciotola..."
            }
        },
        moral_hungry_thief = {
            guard_captain = {
                positive = "Ricordo il tuo gesto con quel ragazzo. Hai mostrato pieta'.",
                negative = "Sei stato duro con quel ragazzo ladro. La legge e' legge, dici."
            }
        },
        daily_bridge = {
            temple_priest = {
                positive = "Ho saputo cosa hai fatto sul ponte. Hai salvato un'anima.",
                negative = "So cosa e' successo sul ponte. Gli dei vedono tutto."
            }
        },
    }

    for _, eventId in ipairs(npc.remembers) do
        if playerMemory[eventId] then
            local memory = playerMemory[eventId]
            local special = specialDialogues[eventId]
            if special and special[npc.id] then
                if memory.reputationChange and memory.reputationChange > 0 then
                    return special[npc.id].positive
                else
                    return special[npc.id].negative
                end
            end
        end
    end

    return nil
end

-- Ottieni la reazione dell'NPC (per animazioni/comportamenti)
function NPCSystem.GetReaction(npcId, reputation)
    local absRep = math.abs(reputation)

    if reputation > 0 then
        if absRep >= 6000 then return "WORSHIP" end
        if absRep >= 3000 then return "RESPECT" end
        if absRep >= 1000 then return "FRIENDLY" end
        return "NEUTRAL"
    elseif reputation < 0 then
        if absRep >= 6000 then return "FLEE" end
        if absRep >= 3000 then return "FEAR" end
        if absRep >= 1000 then return "HOSTILE" end
        return "NEUTRAL"
    end

    return "NEUTRAL"
end

-- Controlla se l'NPC vuole interagire
function NPCSystem.WillInteract(npcId, reputation)
    local npc = NPCSystem.NPCs[npcId]
    if not npc then return false end

    local absRep = math.abs(reputation)

    -- NPC sacri evitano i molto malvagi
    if npcId == "temple_priest" and reputation < -5000 then
        return false
    end

    -- I mendicanti fuggono dai terrificanti
    if npcId == "beggar_marco" and reputation < -3000 then
        return false
    end

    return true
end

-- Ottieni lista NPC disponibili in una zona
function NPCSystem.GetNPCsInZone(zoneType, reputation)
    local available = {}

    local zoneNPCs = {
        MARKET = { "merchant_old", "blacksmith", "beggar_marco" },
        NOBLE = { "noble_lady", "guard_captain" },
        TEMPLE = { "temple_priest" },
        TAVERN = { "tavern_owner", "mysterious_stranger" },
        STREETS = { "beggar_marco", "guard_captain" },
    }

    local npcsInZone = zoneNPCs[zoneType] or {}

    for _, npcId in ipairs(npcsInZone) do
        if NPCSystem.WillInteract(npcId, reputation) then
            table.insert(available, NPCSystem.NPCs[npcId])
        end
    end

    return available
end

return NPCSystem
