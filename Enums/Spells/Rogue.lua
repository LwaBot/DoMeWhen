local Spells = DMW.Enums.Spells

Spells.ROGUE = {
    Assassination = {
        Abilities = {
            CrimsonTempest = {SpellID = 121411},
            CripplingPoison = {SpellID = 3408},
            DeadlyPoison = {SpellID = 2823},
            Envenom = {SpellID = 32645},
            Evasion = {SpellID = 5277},
            Eviscerate = {SpellID = 196819},
            Exsanguinate = {SpellID = 200806},
            FanOfKnives = {SpellID = 51723},
            Garrote = {SpellID = 703},
            KidneyShot = {SpellID = 408},
            Mutilate = {SpellID = 1329},
            PoisonedKnife = {SpellID = 185565},
            Rupture = {SpellID = 1943},
            ToxicBlade = {SpellID = 245388},
            Vendetta = {SpellID = 79140},
            WoundPoison = {SpellID = 8679}
        },
        Buffs = {
            CripplingPoison = 3408,
            DeadlyPoison = 2823,
            ElaboratePlanning = 193641,
            Envenom = 32645,
            HiddenBlades = 270070,
            MasterAssassin = 256735,
            Subterfuge = 115192,
            WoundPoison = 8679
        },
        Debuffs = {
            CrimsonTempest = {SpellID = 121411},
            CripplingPoison = {SpellID = 3409},
            DeadlyPoison = {SpellID = 2818},
            Garrote = {SpellID = 703, BaseDuration = 18},
            KidneyShot = {SpellID = 408},
            Rupture = {SpellID = 1943},
            ToxicBlade = {SpellID = 245389},
            Vendetta = {SpellID = 79140},
            WoundPoison = {SpellID = 8680}
        },
        Talents = {
            Blindside = 22339,
            CrimsonTempest = 23174,
            ElaboratePlanning = 22338,
            Elusiveness = 22123,
            Exsanguinate = 22344,
            HiddenBlades = 22133,
            InternalBleeding = 19245,
            IronWire = 23037,
            MasterAssassin = 23022,
            MasterPoisoner = 22337,
            Nightstalker = 22331,
            PoisonBomb = 21186,
            Subterfuge = 22332,
            ToxicBlade = 23015,
            VenomRush = 22343
        },
        Traits = {
            DoubleDose = 273007,
            EchoingBlades = 287649,
            ScentOfBlood = 277679,
            ShroudedSuffocation = 278666
        }
    },
    Outlaw = {
        Abilities = {
            AdrenalingRush = {SpellID = 13750},
            Ambush = {SpellID = 8676},
            BetweenTheEyes = {SpellID = 199804},
            BladeFlurry = {SpellID = 13877},
            CheapShot = {SpellID = 1833},
            CloakOfShadows = {SpellID = 31224},
            CrimsonVial = {SpellID = 185311},
            Detection = {SpellID = 56814},
            Dispatch = {SpellID = 2098},
            Distrct = {SpellID = 1725},
            Gouge = {SpellID = 1776},
            GraplingHook = {SpellID = 195457, CastType = "Ground"},
            PistolShot = {SpellID = 185763},
            Riposte = {SpellID = 199754},
            RollTheBones = {SpellID = 193316},
            ShroudOfConcealment = {SpellID = 114018},
            SinisterStrike = {SpellID = 193315},
            Sprint = {SpellID = 2983},
            TricksOfTheTrade = {SpellID = 57934},
            GhostlyStrike = {SpellID = 196937},
            MarkedForDeath = {SpellID = 137619},
            SliceAndDice = {SpellID = 5171},
            BladeRush = {SpellID = 271877},
            KillingSpree = {SpellID = 51690},

            Dismantle = {SpellID = 207777},
            PlunderArmor = {SpellID = 198529},
        },
        Buffs = {
            Opportunity  = 195627,
            Deadshot   = 272940,
            BladeFlurry = 13877,
            RuthlessPrecison = 193357, --残忍精准
            Broadside = 193356, --连击
            TrueBearing = 193359, -- 减cd
            SkullAndCrossbones = 199603, --黑帆
            GrandMelee = 193358, --大乱斗
            BuriedTreasure = 199600,-- 回能
        },
        Debuffs = {},
        Talents = {},
        Traits = {
            AceUpSleeve = 272940,
        }
    },
    Subtlety = {
        Abilities = {
            Backstab = {SpellID = 53},
            CheapShot = {SpellID = 1833},
            CloakOfShadows = {SpellID = 31224},
            CrimsonVial = {SpellID = 185311},
            Distrct = {SpellID = 1725},
            Evasion = {SpellID = 5277},
            Eviscerate = {SpellID = 196819},
            KidneyShot = {SpellID = 408},
            Nightblade = {SpellID = 195452},
            SecretTechnique = {SpellID = 280719},
            ShadowBlades = {SpellID = 121471},
            ShadowDance = {SpellID = 185313},
            Shadowstep = {SpellID = 36554},
            Shadowstrike = {SpellID = 185438},
            ShroudOfConcealment = {SpellID = 114018},
            ShurikenStorm = {SpellID = 197835},
            ShurikenToss = {SpellID = 114014},
            Sprint = {SpellID = 2983},
            SymbolsOfDeath = {SpellID = 212283},
            TricksOfTheTrade = {SpellID = 57934},
            Gloomblade = {SpellID = 200758},
            ShurikenTornado = {SpellID = 277925},
            ColdBlood = {SpellID = 213981},

            ShadowyDuel = {SpellID = 207736},
        },
        Buffs = {},
        Debuffs = {},
        Talents = {},
        Traits = {}
    },
    All = {
        Abilities = {
            Blind = {SpellID = 2094},
            CheapShot = {SpellID = 1833},
            CloakOfShadows = {SpellID = 31224},
            CrimsonVial = {SpellID = 185311},
            Feint = {SpellID = 1966},
            Kick = {SpellID = 1766},
            MarkedForDeath = {SpellID = 137619},
            Sap = {SpellID = 6770},
            Stealth = {SpellID = 115191},
            TricksOfTheTrade = {SpellID = 57934},
            Vanish = {SpellID = 1856},
            Shiv = {SpellID = 248744},
            SmokeBomb = {SpellID = 212182},
            DeathFromAbove = {SpellID = 269513},
        },
        Buffs = {
            Stealth = 115191,
            Vanish = 11327
        },
        Debuffs = {}
    }
}
