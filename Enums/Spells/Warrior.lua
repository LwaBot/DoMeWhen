local Spells = DMW.Enums.Spells

Spells.WARRIOR = {
    Arms = {
        Abilities = {
            Avatar = {SpellID = 107574},
            BerserkerRage = {SpellID = 18499},
            Bladestorm = {SpellID = 227847},
            Charge = {SpellID = 100},
            DefensiveStance = {SpellID = 197690},
            DiebytheSword = {SpellID = 118038},
            Execute = {SpellID = 163201},
            Hamstring = {SpellID = 1715},
            IntimidatingShout = {SpellID = 5246},
            MortalStrike = {SpellID = 12294},
            Overpower = {SpellID = 7384},
            Pummel = {SpellID = 6552},
            SharpenBlade = {SpellID = 198817},
            Slam = {SpellID = 1464},
            SpellReflection = {SpellID = 216890},
            SweepingStrikes = {SpellID = 260708},
            VictoryRush = {SpellID = 34428},
            Warbreaker = {SpellID = 262161},
            Whirlwind = {SpellID = 1680},
            Skullsplitter = {SpellID = 260643},
            Rend = {SpellID = 772},
            Cleave = {SpellID = 845},
            DeadlyCalm = {SpellID = 262228},
            Ravager = {SpellID = 152277},
            GiantAttack = {SpellID = 167105},
        },
        Buffs = {},
        Debuffs = {
            Hamstring = {SpellID = 1715},
        },
        Talents = {},
        Traits = {}
    },
    Fury = {
        Abilities = {
            BerserkerRage = {SpellID = 18499},
            Bladestorm = {SpellID = 46924},
            Blolldthirst = {SpellID = 23881},
            Charge = {SpellID = 100},
            Disarm = {SpellID = 236077},
            EnragedRegeneration = {SpellID = 184364},
            Execute = {SpellID = 280735},
            IntimidatingShout = {SpellID = 5246},
            PiercingHowl = {SpellID = 12323},
            RagingBlow = {SpellID = 85288},
            Rampage = {SpellID = 184367},
            Recklessness = {SpellID = 1719},
            Taunt = {SpellID = 355},
            VictoryRush = {SpellID = 34428},
            Whirlwind = {SpellID = 190411},

            FuriosSlash = {SpellID = 100130},
            DragonRoar = {SpellID = 118000},
            Bladestorm = {SpellID = 46924},
            Siegebreaker = {SpellID = 280772},
        },
        Buffs = {
            Recklessness = 1719,
        },
        Debuffs = {
            PiercingHowl = {SpellID = 12323},
        },
        Talents = {},
        Traits = {}
    },
    Protection = {
        Abilities = {
             Avatar = {SpellID = 107574},
             BerserkerRage = {SpellID = 18499},
             DemoralizingShout = {SpellID = 1160},
             Devastate = {SpellID = 20243},
             IgnorePain = {SpellID = 190456},
             Intercept = {SpellID = 198304},
             IntimidatingShout = {SpellID = 5246},
             LastStand = {SpellID = 12975},
             Revenge = {SpellID = 6572},
             ShieldBlock = {SpellID = 2565},
             ShieldSlam = {SpellID = 23922},
             ShieldWall = {SpellID = 871},
             Shockwave = {SpellID = 46968},
             SpellReflection = {SpellID = 23920},
             Taunt = {SpellID = 355},
             ThunderClap = {SpellID = 6343},
             VictoryRush = {SpellID = 34428},
             DragonRoar = {SpellID = 118000},
             Ravager = {SpellID = 228920, CastType = "Ground"},

        },
        Buffs = {
             ShieldBlock = 2565,
        },
        Debuffs = {
            DemoralizingShout = {SpellID = 1160},
            ThunderClap = {SpellID = 6343},
        },
        Talents = {},
        Traits = {}
    },
    All = {
        Abilities = {
            HeroicLeap = {SpellID = 6544, CastType = "Ground"},
            HeroicThrow = {SpellID = 57755},
            Pummel = {SpellID = 6552},
            RallyingCry = {SpellID = 97462},
            ImpendingVictory = {SpellID = 202168},
            StormBolt = {SpellID = 107570},
            BattleShout = {SpellID = 6673},
        },
        Buffs = {
             BattleShout = 6673,
             Whirlwind = 85739,
        },
        Debuffs = {

        }
    }
}
