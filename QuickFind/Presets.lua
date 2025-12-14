---@class QF
local QF = select(2, ...)
local moduleName = 'presets'

---@class SpellDataItem : {spellID: number, name: string, iconID: string, description: string}

---@class Presets
local presets = QF:GetModule(moduleName)

---@class Cache
local cache = QF:GetModule('cache')

---@param self Presets
---@param id string
---@return function
presets.spellCacheCallback = function (self, id)
    return function (_, spellID, success)
        if (success) then
            local data = self:getSpellData(spellID)
            if (data) then
                cache:saveSpellData(spellID, data)
                self:build()
            end
        end
        QF.handler:unregisterCallback('SPELL_DATA_LOAD_RESULT', id)
    end
end

---@param self Presets
---@param spellID number
---@return SpellDataItem|false
presets.getSpellData = function (self, spellID)
    if (cache:hasSpell(spellID)) then return cache:getSpellData(spellID) end

    if (not C_Spell.DoesSpellExist(spellID)) then return false end

    if (C_Spell.IsSpellDataCached(spellID)) then
        local spellInfo = C_Spell.GetSpellInfo(spellID)
        local spellDescription = C_Spell.GetSpellDescription(spellID)
        if (not spellDescription) then
            local spell = Spell:CreateFromSpellID(spellID)
            spell:ContinueOnSpellLoad(function ()
                local spellData = {
                    spellID = spellID,
                    name = spell:GetSpellName(),
                    iconID = spellInfo.iconID,
                    description = spell:GetSpellDescription()
                }
                cache:saveSpellData(spellID, spellData)
                self:build()
            end)
            return false
        else
            local spellData = {
                spellID = spellID,
                name = spellInfo.name,
                iconID = spellInfo.iconID,
                description = spellDescription
            }
            cache:saveSpellData(spellID, spellData)
            return spellData
        end
    else
        local id = QF.utils.generateNewId(5)
        QF.handler:registerCallback('SPELL_DATA_LOAD_RESULT', id,
            self:spellCacheCallback(id))
        C_Spell.RequestLoadSpellData(spellID)
        return false
    end
end

---@param self Presets
presets.fetchSpellCache = function (self)
    for _, data in pairs(QF.presets) do
        if (data.type == QF.LOOKUP_TYPE.SPELL) then
            for _, spellID in pairs(data.data) do
                self:getSpellData(spellID)
            end
        end
    end
end

local function addPresetInfo(data, ID, name)
    return QF.utils.shallowCloneMerge(data, {
        isPreset = true,
        presetName = name,
        presetID = ID,
        created = 999999999999999999999 -- Just so they show up at the end
    })
end

---Build preset suggestions
---@param self Presets
presets.build = function (self)
    for name, data in pairs(QF.presets) do
        QF.builtPresets[name] = QF.builtPresets[name] or {}
        if (data.type == QF.LOOKUP_TYPE.SPELL) then
            for _, spellID in pairs(data.data) do
                local spellData = self:getSpellData(spellID)
                if (spellData) then
                    QF.builtPresets[name][name .. spellID] = addPresetInfo({
                        icon = spellData.iconID,
                        name = spellData.name,
                        spellId = spellID,
                        type = QF.LOOKUP_TYPE.SPELL,
                        tags = spellData.description
                    }, spellID, name)
                end
            end
        elseif (data.type == QF.LOOKUP_TYPE.MOUNT) then
            if (data.all) then
                -- Get All mounts
                for _, mountID in pairs(C_MountJournal.GetMountIDs()) do
                    local mountName, spellID, icon, _, isUsable =
                        C_MountJournal.GetMountInfoByID(mountID)
                    if (isUsable) then
                        QF.builtPresets[name][name .. spellID] = addPresetInfo(
                            {
                                icon = icon,
                                name = mountName,
                                mountName = mountName,
                                tags = '',
                                type = QF.LOOKUP_TYPE.MOUNT
                            }, spellID, name)
                    end
                end
            end
        elseif (data.type == QF.LOOKUP_TYPE.TOY) then
            if (data.all) then
                for i = 1, C_ToyBox.GetNumToys() do
                    local toyID = C_ToyBox.GetToyFromIndex(i)
                    if (toyID > 0 and C_ToyBox.IsToyUsable(toyID)) then
                        local toyData = cache:getToyData(toyID)
                        if (not toyData) then
                            local itemID, toyName, icon =
                                C_ToyBox.GetToyInfo(toyID)
                            toyData = {
                                itemID = itemID,
                                toyName = toyName,
                                icon = icon
                            }
                            cache:saveToyData(toyID, toyData)
                        end
                        if toyData.toyName and PlayerHasToy(toyData.itemID) then
                            QF.builtPresets[name][name .. toyID] =
                                addPresetInfo({
                                    icon = toyData.icon,
                                    name = toyData.toyName,
                                    type = QF.LOOKUP_TYPE.TOY,
                                    itemId = toyData.itemID
                                }, toyID, name)
                        end
                    end
                end
            end
        elseif (data.type == QF.LOOKUP_TYPE.LUA) then
            if (data.built) then
                local built = data.getBuiltData()
                for _, data in pairs(built) do
                    QF.builtPresets[name][name .. data.id] = addPresetInfo(data,
                        data.id,
                        name)
                end
            end
        end
    end

    QF:GetModule('options-core'):PopulateOptions()
end

---@param self Presets
---@param preset table
presets.addToData = function (self, preset)
    local id = QF.utils.generateNewId()
    QF:SaveData(id, QF.utils.shallowCloneMerge(preset, {
        id = id,
        created = time(),
        isPreset = false,
        isNew = true
    }))
    return id
end

---Is Preset already added to data
---@param self Presets
---@param presetID string
---@param presetName string
---@return boolean
presets.isAddedToData = function (self, presetID, presetName)
    for _, v in pairs(QF.data) do
        if (v.presetName and v.presetName == presetName and v.presetID ==
                presetID) then
            return true
        end
    end
    return false
end

---Disable specific preset
---@param self Presets
---@param presetName string
---@param presetID string
presets.setDisabledPreset = function (self, presetName, presetID)
    QF.disabledPresets[presetName] = QF.disabledPresets[presetName] or {}
    QF.disabledPresets[presetName][presetID] = true
    QF.disabledPresets:SetValue(presetName, QF.disabledPresets[presetName])
end

---Is specific preset disabled
---@param self Presets
---@param presetName string
---@param presetID string
---@return boolean
presets.isDisabledPreset = function (self, presetName, presetID)
    return QF.disabledPresets[presetName] and
        QF.disabledPresets[presetName][presetID]
end

---Reset all or specific disabled presets
---@param self Presets
---@param presetName? string
presets.resetDisabled = function (self, presetName)
    if presetName then
        QF.disabledPresets:SetValue(presetName, {})
    else
        for key, t in pairs(QF.disabledPresets) do
            if (key ~= 'observable' and type(t) == 'table') then
                QF.disabledPresets:SetValue(key, {})
            end
        end
    end
end

---Does preset has any disabled presets
---@param self Presets
---@param presetName string
---@return boolean
presets.hasAnyDisabled = function (self, presetName)
    return QF.disabledPresets[presetName] and
        not QF.utils.isEmpty(QF.disabledPresets[presetName])
end

---Get available presets
---@param self Presets
---@return table
presets.getAvailable = function (self)
    local available = {}
    for name, data in pairs(QF.presets) do
        table.insert(available, { name = name, description = data.description })
    end

    return available
end

---@param self Presets
presets.init = function (self)
    --self:fetchSpellCache()
    -- Build at least initial presets
    -- Add some arbitrary delay cuz i cba
    C_Timer.After(5, function () presets:build() end)
end

---@param self Presets
---@param name string
presets.enable = function (self, name) QF.enabledPresets[name] = true end

---@param self Presets
---@param name string
presets.disable = function (self, name) QF.enabledPresets[name] = false end

presets.isEnabled = function (self, name) return QF.enabledPresets[name] end
