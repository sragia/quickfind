---@class QF
local QF = select(2, ...)

QF.createPreset({
    type = QF.LOOKUP_TYPE.LUA,
    name = 'Bosses',
    built = true,
    description = 'Adds quick access to boss encounter pages. Only for current expansion/season',
    getBuiltData = function ()
        local data = {}
        --2607 Ulgrax
        local tier = EJ_GetNumTiers()
        EJ_SelectTier(tier)
        local encounterData = {}
        for _, isRaid in ipairs({ false, true }) do
            local instanceIndex = 1
            local instanceID = EJ_GetInstanceByIndex(instanceIndex, isRaid)
            while instanceID do
                EJ_SelectInstance(instanceID)
                local bossIndex = 1
                local instanceName = EJ_GetInstanceInfo(instanceID)
                local bossName, _, ejID, _, _, _, encounterID = EJ_GetEncounterInfoByIndex(bossIndex, instanceID)
                while bossName do
                    table.insert(encounterData,
                        {
                            bossName = bossName,
                            encounterID = encounterID,
                            instanceID = instanceID,
                            instanceName = instanceName,
                            ejID = ejID
                        })
                    bossIndex = bossIndex + 1
                    bossName, _, ejID, _, _, _, encounterID = EJ_GetEncounterInfoByIndex(bossIndex, instanceID)
                end

                instanceIndex = instanceIndex + 1
                instanceID = EJ_GetInstanceByIndex(instanceIndex, isRaid)
            end
        end

        for _, bossData in ipairs(encounterData) do
            table.insert(data, {
                type = QF.LOOKUP_TYPE.LUA,
                name = bossData.bossName,
                icon = QF.textures.icon.boss,
                tags = bossData.instanceName,
                id = 'boss' .. bossData.instanceID .. bossData.encounterID,
                lua = [[
                    EncounterJournal_LoadUI();
                    EncounterJournal_OpenJournal(nil, ]] .. bossData.instanceID .. [[,]] .. bossData.ejID .. [[);
                ]]
            })
        end

        return data
    end,
    getData = function ()
        return {}
    end,
})
