local _, QF = ...

QF.LOOKUP_TYPE = {
    SPELL = 'SPELL'
}

QF.default = {
    font = [[Interface/Addons/QuickFind/Media/Font/Poppins.ttf]],
    barBg = [[Interface/Addons/QuickFind/Media/Texture/bar]],
    barBorderGlow = [[Interface/Addons/QuickFind/Media/Texture/bar-border-glow]],
    maxSuggestions = 5,
    scale = 1.2
}

QF.BASE_LOOKUPS = {
    {
        name = "Path to Grand Magistrix",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 393766,
        icon = 1417424,
        tags = "Court of Stars, CoS, Portal"
    },
    {
        name = "Path of Arcane Secrets",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 393279,
        icon = 4578411,
        tags = "Azure Vault, Vault, Portal"
    },
    {
        name = "Path of Proven Worth",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 393764,
        icon = 1417427,
        tags = "Halls, HoV, Portal"
    },
    {
        name = "Shuriken Storm TEST",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 197835,
        icon = 1375677,
        tags = "TEST TEST"
    },
    {
        name = "Sprint TEST",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 2983,
        icon = 132307,
        tags = "Sprint"
    },
}
