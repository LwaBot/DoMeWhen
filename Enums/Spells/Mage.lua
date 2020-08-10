local Spells = DMW.Enums.Spells

Spells.MAGE = {
    Arcane = {
        Abilities = {
             ArcaneBarrage = {SpellID = 44425},
             ArcaneBlast = {SpellID = 30451},
             ArcaneExplosion = {SpellID = 1449},
             ArcaneMissiles = {SpellID = 5143},
             ArcanePower = {SpellID = 12042},
             ChargedUp = {SpellID = 205032},
             Displacement = {SpellID = 212801},
             Evocation = {SpellID = 12051},
             GreaterInvisibility = {SpellID = 110959},
             PresenceofMind = {SpellID = 205025},
             PrismaticBarrier = {SpellID = 235450},
             Shimmer = {SpellID = 212653},
             Slow = {SpellID = 31589},
             SuperNova  = {SpellID = 157980},
             ArcaneFamiliar = {SpellID = 205022},
             NetherTempest = {SpellID = 114923},
             ArcaneOrb  = {SpellID = 153626},
        },
        Buffs = {
            EnergySave = 79684,
            ArcaneFamiliar = 205022,
        },
        Debuffs = {
             NetherTempest = {SpellID = 114923},
        },
        Talents = {},
        Traits = {}
    },
    Fire = {
        Abilities = {
            BlastWave = {SpellID = 157981},
            BlazingBarrier = {SpellID = 235313},
            Combustion = {SpellID = 190319},
            DragonBreath = {SpellID = 31661},
            FireBlast = {SpellID = 108853},
            Fireball = {SpellID = 133},
            Flamestrike = {SpellID = 2120, CastType = "Ground"},
            GreaterPyroblast = {SpellID = 203286},
            LivingBomb = {SpellID = 44457},
            Meteor = {SpellID = 153561, CastType = "Ground"},
            PhonenixFlames = {SpellID = 257541},
            Pyroblast = {SpellID = 11366},
            Scorch = {SpellID = 2948},


        },
        Buffs = {
            FireCombo = 48108,
            Combustion = 190319,
            --48108
        },
        Debuffs = {
            --12654
            Light = {SpellID = 12654},
        },
        Talents = {},
        Traits = {}
    },
    Frost = {
        Abilities = {
            Blizzard = {SpellID = 190356, CastType = "Ground"},
            ColdBlood = {SpellID = 12472},
            ColdSnap = {SpellID = 235219},
            CometStorm = {SpellID = 153595},
            ConeofCold = {SpellID = 120},
            Ebonbolt = {SpellID = 257537},
            Flurry = {SpellID = 44614},
            Frostbolt = {SpellID = 116},
            FrozenOrb = {SpellID = 84714, CastType = "Ground"},
            GlacialSpike = {SpellID = 199786},
            IceBarrier = {SpellID = 11426},
            IceForm = {SpellID = 198144},
            IceLance = {SpellID = 30455},
            RayOfFros = {SpellID = 205021},
            SummonWater = {SpellID = 31687},
            FrostSp = {SpellID = 33395, CastType = "Ground"},
        },
        Buffs = {
            TorrentSpell = 116267,
            IceGland = 205473,
            GlacialSpike = 199844,
            IceIntel = 190446,
            IceFinger = 44544,
        },
        Debuffs = {
             GlacialSpike = {SpellID = 228600},
             WinterCold = {SpellID = 228358},
              FrostSp = {SpellID = 33395},
        },
        Talents = {
            SummonWater = 31687,
        },
        Traits = {}
    },
    All = {
        Abilities = {
            ArcaneIntellect = {SpellID = 1459},
            Counterspell = {SpellID = 2139},
            FrostNova = {SpellID = 122},
            MirrorImage = {SpellID = 55342},
            RuneofPower = {SpellID = 116011},
            IceBlock = {SpellID = 45438},
            Invisibility = {SpellID = 66},
            Polymorph = {SpellID = 118},

            RemoveCurse = {SpellID = 475},
            RingofFrost = {SpellID = 113724, CastType = "Ground"},
            Shimmer = {SpellID = 212653},
            Spellsteal = {SpellID = 30449},
            TemporalShield = {SpellID = 198111},
            TimeWrap = {SpellID = 80353},
        },
        Buffs = {
            IceBlock = 45438,
            RuneofPower = 116014,
            ArcaneIntellect = 1459,
            TemporalShield = 198111,

        },
        Debuffs = {
            FrostNova = {SpellID = 122},
            TimeWrap = {SpellID = 80354},
        }
    }
}
