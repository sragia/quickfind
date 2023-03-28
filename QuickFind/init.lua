local _, QF = ...

QF.LOOKUP_TYPE = {
    SPELL = 'SPELL',
    TOY = 'TOY',
    ITEM = 'ITEM'
}

QF.default = {
    font = [[Interface/Addons/QuickFind/Media/Font/Poppins.ttf]],
    barBg = [[Interface/Addons/QuickFind/Media/Texture/bar]],
    barBorderGlow = [[Interface/Addons/QuickFind/Media/Texture/bar-border-glow]],
    logoBg = [[Interface/Addons/QuickFind/Media/Texture/Frames/logoBg]],
    windowBg = [[Interface/Addons/QuickFind/Media/Texture/Frames/windowBg]],
    closeWithSettings = [[Interface/Addons/QuickFind/Media/Texture/Frames/closeBtn]],
    closeNoSettings = [[Interface/Addons/QuickFind/Media/Texture/Frames/closeBtnNoSettings]],
    closeIcon = [[Interface/Addons/QuickFind/Media/Texture/Frames/closeIcon]],
    settingsBg = [[Interface/Addons/QuickFind/Media/Texture/Frames/settingsBg]],
    settingsIcon = [[Interface/Addons/QuickFind/Media/Texture/Frames/settingsIcon]],
    maxSuggestions = 5,
    scale = 1.35,
    tagColors = {
        [QF.LOOKUP_TYPE.SPELL] = { 0.44, 0, 0.94 },
        [QF.LOOKUP_TYPE.ITEM] = { 0.04, 0.62, 0 },
        [QF.LOOKUP_TYPE.TOY] = { 0, 0.25, 0.62 }
    }
}

QF.BASE_LOOKUPS = {
    {
        name = "Path to Grand Magistrix (CoS)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 393766,
        icon = 1417424,
        tags = "Court of Stars, CoS, Portal"
    },
    {
        name = "Path of the Clutch Defender (RLP)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 393256,
        icon = 4578416,
        tags = "RLP, Ruby, Portal"
    },
    {
        name = "Path of the Crescent Moon (SBG)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 159899,
        icon = 1002600,
        tags = "SBG, Shadowmoon, Portal"
    },
    {
        name = "Path of the Draconic Diploma (AA)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 393273,
        icon = 4578414,
        tags = "AA, Algathar, Portal"
    },
    {
        name = "Path of the Jade Serpent (TotJS)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 131204,
        icon = 603529,
        tags = "Temple, Temple of the Jade Serpent, Portal"
    },
    {
        name = "Path of the Windswept Plains (NO)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 393273,
        icon = 4578414,
        tags = "Nokhud, Nokhud Offensive, Portal"
    },
    {
        name = "Path of Arcane Secrets (AV)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 393279,
        icon = 4578411,
        tags = "Azure Vault, Vault, Portal"
    },
    {
        name = "Path of Proven Worth (HoV)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 393764,
        icon = 1417427,
        tags = "Halls, HoV, Portal"
    },
    {
        name = "Katy's Stampwhistle",
        type = QF.LOOKUP_TYPE.TOY,
        itemId = 156833,
        icon = 443375,
        tags = "Mail, Mailbox, Katy"
    },
    {
        name = "Auto-Hammer",
        type = QF.LOOKUP_TYPE.ITEM,
        itemId = 132514,
        icon = 1405803,
        tags = "Repair, Auto-Hammer"
    },
}
