---@class QF
local QF = select(2, ...)

QF.createPreset({
    type = QF.LOOKUP_TYPE.LUA,
    name = 'Interface Panels',
    built = true,
    description = 'Adds quick access to different UI Panels and Settings',
    getBuiltData = function ()
        local data = {}
        -- Settings categories open
        for _, category in pairs(SettingsPanel:GetAllCategories()) do
            local lua = "Settings.OpenToCategory('" .. category:GetID() .. "')"
            if (type(category:GetID()) == 'number') then
                lua = 'Settings.OpenToCategory(' .. category:GetID() .. ')'
            end
            table.insert(data, {
                type = QF.LOOKUP_TYPE.LUA,
                name = 'Open ' .. category:GetName() .. ' settings',
                icon = QF.textures.icon.interfaceSettings,
                ID = 'category' .. category:GetID(),
                lua = lua
            })
        end

        -- Spells and Talents
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open Talents',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'talents',
            lua = 'PlayerSpellsUtil.TogglePlayerSpellsFrame(PlayerSpellsUtil.FrameTabs.ClassTalents);'
        })
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open Spell Book',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'spellbook',
            lua = 'PlayerSpellsUtil.TogglePlayerSpellsFrame(PlayerSpellsUtil.FrameTabs.SpellBook);'
        })
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open Specialization',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'specializations',
            lua = 'PlayerSpellsUtil.TogglePlayerSpellsFrame(PlayerSpellsUtil.FrameTabs.ClassSpecializations);'
        })

        -- UI Panels
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open Character',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'character',
            lua = 'ToggleCharacter("PaperDollFrame");'
        })
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open Reputations',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'reputations',
            lua = 'ToggleCharacter("ReputationFrame");'
        })
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open Currencies',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'currencies',
            lua = 'CharacterFrame:ToggleTokenFrame();'
        })
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open Professions',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'professions',
            lua = 'ShowUIPanel(ProfessionsBookFrame)'
        })
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open Addons',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'addons',
            lua = 'ShowUIPanel(AddonList)'
        })
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open Achievements',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'achievements',
            lua = 'ShowUIPanel(AchievementsFrame)'
        })
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open Achievements',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'achievements',
            lua = 'ShowUIPanel(AchievementsFrame)'
        })
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open Guild Chat',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'guildchat',
            lua = 'ShowUIPanel(CommunitiesFrame)'
        })
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open LFD',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'LFD',
            lua = [[
            if (PVEFrame and not PVEFrame:IsShown()) then
                PVEFrame_ToggleFrame();
            end
            GroupFinderFrame_ShowGroupFrame(LFDParentFrame)
            ]]
        })
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open Premade Groups (PVE)',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'LFG',
            lua = [[
            if (PVEFrame and not PVEFrame:IsShown()) then
                PVEFrame_ToggleFrame();
            end
            GroupFinderFrame_ShowGroupFrame(LFGListPVEStub)']]
        })
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open LFR',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'LFR',
            lua = [[
            if (PVEFrame and not PVEFrame:IsShown()) then
                PVEFrame_ToggleFrame();
            end
            GroupFinderFrame_ShowGroupFrame(RaidFinderFrame)']]
        })
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open Quick Match PVP',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'quickmatch',
            lua = 'PVEFrame_ShowFrame(\'PVPUIFrame\'); PVPQueueFrame_ShowFrame(HonorFrame)'
        })
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open Rated PVP',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'ratedpvp',
            lua = 'PVEFrame_ShowFrame(\'PVPUIFrame\'); PVPQueueFrame_ShowFrame(ConquestFrame)'
        })
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open Premade Groups (PVP)',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'lfgpvp',
            lua = 'PVEFrame_ShowFrame(\'PVPUIFrame\'); PVPQueueFrame_ShowFrame(LFGListPVPStub)'
        })
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open Mythic+ Dungeons',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'mythicplusdungeons',
            lua = 'PVEFrame_ShowFrame(\'ChallengesFrame\');'
        })
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open Mounts',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'mounts',
            lua = [[
            if (not CollectionsJournal or CollectionsJournal and not CollectionsJournal:IsShown()) then
                ToggleCollectionsJournal();
            end
            CollectionsJournal_SetTab(CollectionsJournal, 1)
            ]]
        })
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open Pets',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'pets',
            lua = [[
            if (not CollectionsJournal or CollectionsJournal and not CollectionsJournal:IsShown()) then
                ToggleCollectionsJournal();
            end
            CollectionsJournal_SetTab(CollectionsJournal, 2)
            ]]
        })
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open Toys',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'toys',
            lua = [[
            if (not CollectionsJournal or CollectionsJournal and not CollectionsJournal:IsShown()) then
                ToggleCollectionsJournal();
            end
            CollectionsJournal_SetTab(CollectionsJournal, 3)
            ]]
        })
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open Heirlooms',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'heirlooms',
            lua = [[
            if (not CollectionsJournal or CollectionsJournal and not CollectionsJournal:IsShown()) then
                ToggleCollectionsJournal();
            end
            CollectionsJournal_SetTab(CollectionsJournal, 4)
            ]]
        })
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open Wardrobe',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'wardrobe',
            lua = [[
            if (not CollectionsJournal or CollectionsJournal and not CollectionsJournal:IsShown()) then
                ToggleCollectionsJournal();
            end
            CollectionsJournal_SetTab(CollectionsJournal, 5)
            ]]
        })
        table.insert(data, {
            type = QF.LOOKUP_TYPE.LUA,
            name = 'Open EncounterJournal',
            icon = QF.textures.icon.interfaceSettings,
            ID = 'encounterjournal',
            lua = 'ToggleEncounterJournal()'
        })

        return data
    end,
    getData = function ()
        return {}
    end,
})
