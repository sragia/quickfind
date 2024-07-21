---@class QF
local QF = select(2, ...)

QuickFind = {}
QuickFindData = {}

QF.LOOKUP_TYPE = {
    SPELL = 'SPELL',
    TOY = 'TOY',
    ITEM = 'ITEM',
    MOUNT = 'MOUNT',
    LUA = 'LUA'
}

QF.typeOptions = {
    [QF.LOOKUP_TYPE.SPELL] = 'Spell',
    [QF.LOOKUP_TYPE.TOY] = 'Toy',
    [QF.LOOKUP_TYPE.ITEM] = 'Item',
    [QF.LOOKUP_TYPE.MOUNT] = 'Mount',
    [QF.LOOKUP_TYPE.LUA] = 'Lua Script'
}

QF.presets = {}
QF.builtPresets = {}
QF.enabledPresets = {
    ['Instance Portals'] = true -- Just so you have something initially
}
QF.disabledPresets = {
}
QF.cache = {
    spells = {},
    toys = {}
}

QF.textures = {
    icon = {
        edit = [[Interface/Addons/QuickFind/Media/Texture/Frames/edit]],
        disable = [[Interface/Addons/QuickFind/Media/Texture/Frames/disableIcon]],
        interfaceSettings = [[Interface/Addons/QuickFind/Media/Texture/Frames/interfaceSettingsIcon]],
        boss = [[Interface/Addons/QuickFind/Media/Texture/Frames/bossIcon]],
        reset = [[Interface/Addons/QuickFind/Media/Texture/Frames/reset]]
    }
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
    toggle = [[Interface/Addons/QuickFind/Media/Texture/Frames/toggle]],
    maxSuggestions = 5,
    scale = 1.35,
    tagColors = {
        [QF.LOOKUP_TYPE.SPELL] = { 0.44, 0, 0.94 },
        [QF.LOOKUP_TYPE.ITEM] = { 0.04, 0.62, 0 },
        [QF.LOOKUP_TYPE.TOY] = { 0, 0.25, 0.62 },
        [QF.LOOKUP_TYPE.MOUNT] = { 1, 0.7, 0 },
        [QF.LOOKUP_TYPE.LUA] = { 0.34, 0.34, 0.34 }
    }
}

QF.createPreset = function (data)
    QF.presets[data.name] = QF.utils.shallowCloneMerge(data, {
        data = data.getData()
    })
end

QFEXPOSE = QF
