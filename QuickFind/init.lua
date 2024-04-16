local _, QF = ...

QuickFind = {};

QF.LOOKUP_TYPE = {
    SPELL = 'SPELL',
    TOY = 'TOY',
    ITEM = 'ITEM'
}

QF.default = {
    font = [[Interface/Addons/QuickFind/Media/Font/Poppins.ttf]],
    unknownIcon = [[Interface/Addons/QuickFind/Media/Texture/unknownIcon]],
    barBg = [[Interface/Addons/QuickFind/Media/Texture/bar]],
    barBorderGlow = [[Interface/Addons/QuickFind/Media/Texture/bar-border-glow]],
    logoBg = [[Interface/Addons/QuickFind/Media/Texture/Frames/logoBg]],
    windowBg = [[Interface/Addons/QuickFind/Media/Texture/Frames/windowBg]],
    closeWithSettings = [[Interface/Addons/QuickFind/Media/Texture/Frames/closeBtn]],
    expandBtn = [[Interface/Addons/QuickFind/Media/Texture/Frames/expand-btn]],
    expandBtnHighlight = [[Interface/Addons/QuickFind/Media/Texture/Frames/expand-highlight]],
    closeNoSettings = [[Interface/Addons/QuickFind/Media/Texture/Frames/closeBtnNoSettings]],
    closeIcon = [[Interface/Addons/QuickFind/Media/Texture/Frames/closeIcon]],
    settingsBg = [[Interface/Addons/QuickFind/Media/Texture/Frames/settingsBg]],
    settingsIcon = [[Interface/Addons/QuickFind/Media/Texture/Frames/settingsIcon]],
    chevronDown = [[Interface/Addons/QuickFind/Media/Texture/Frames/chevronDown]],
    optionOpenBg = [[Interface/Addons/QuickFind/Media/Texture/Frames/optionOpenBg]],
    optionClosedBg = [[Interface/Addons/QuickFind/Media/Texture/Frames/optionClosedBg]],
    optionBodyBg = [[Interface/Addons/QuickFind/Media/Texture/Frames/optionBodyBg]],
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
        id = 1,
        name = "Path to Grand Magistrix (CoS)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 393766,
        icon = 1417424,
        tags = "Court of Stars, CoS, Portal"
    },
    {
        id = 2,
        name = "Path of the Clutch Defender (RLP)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 393256,
        icon = 4578416,
        tags = "RLP, Ruby, Portal"
    },
    {
        id = 3,
        name = "Path of the Crescent Moon (SBG)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 159899,
        icon = 1002600,
        tags = "SBG, Shadowmoon, Portal"
    },
    {
        id = 4,
        name = "Path of the Draconic Diploma (AA)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 393273,
        icon = 4578414,
        tags = "AA, Algathar, Portal"
    },
    {
        id = 5,
        name = "Path of the Jade Serpent (TotJS)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 131204,
        icon = 603529,
        tags = "Temple, Temple of the Jade Serpent, Portal"
    },
    {
        id = 6,
        name = "Path of the Windswept Plains (NO)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 393273,
        icon = 4578414,
        tags = "Nokhud, Nokhud Offensive, Portal"
    },
    {
        id = 7,
        name = "Path of Arcane Secrets (AV)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 393279,
        icon = 4578411,
        tags = "Azure Vault, Vault, Portal"
    },
    {
        id = 8,
        name = "Path of the Obsidian Hoard (Nel)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 393276,
        icon = 4578417,
        tags = "Neltharus, Nel, Portal"
    },
    {
        id = 9,
        name = "Path of the Watcher's Legacy (Uldaman)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 393222,
        icon = 4578418,
        tags = "Uldaman, Portal"
    },
    {
        id = 10,
        name = "Path of Festering Rot (UR)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 410074,
        icon = 2011151,
        tags = "Underrot, UR, Portal"
    },
    {
        id = 11,
        name = "Path of the Rotting Woods (BH)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 393267,
        icon = 4578412,
        tags = "Brackenhide Hollow, BH, Portal"
    },
    {
        id = 12,
        name = "Path of the Earth-Warder (NL)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 410078,
        icon = 1417429,
        tags = "Neltharion's Lair, NL, Portal"
    },
    {
        id = 13,
        name = "Path of the Titanic Reservoir (HoL)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 393283,
        icon = 4578415,
        tags = "Halls of Infusion, HoL, Portal"
    },
    {
        id = 14,
        name = "Path of the Freebooter (FH)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 410071,
        icon = 2011112,
        tags = "Freehold, FH, Portal"
    },
    {
        id = 15,
        name = "Path of Wind's Domain (VP)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 410080,
        icon = 409599,
        tags = "Vortex Pinnacle, VP, Portal"
    },
    {
        id = 16,
        name = "Path of Proven Worth (HoV)",
        type = QF.LOOKUP_TYPE.SPELL,
        spellId = 393764,
        icon = 1417427,
        tags = "Halls, HoV, Portal"
    },
    {
        id = 17,
        name = "Katy's Stampwhistle",
        type = QF.LOOKUP_TYPE.TOY,
        itemId = 156833,
        icon = 443375,
        tags = "Mail, Mailbox, Katy"
    },
    {
        id = 18,
        name = "Auto-Hammer",
        type = QF.LOOKUP_TYPE.ITEM,
        itemId = 132514,
        icon = 1405803,
        tags = "Repair, Auto-Hammer"
    },
}
