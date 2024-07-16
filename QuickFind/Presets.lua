---@class QF
local QF = select(2, ...)
local moduleName = 'presets'

---@class SpellDataItem : {spellID: number, name: string, iconID: string}

---@class Presets
local presets = QF:GetModule(moduleName)

---@class Cache
local cache = QF:GetModule('cache')

---@param self Presets
---@param id string
---@return function
presets.spellCacheCallback = function(self, id)
    return function(_, spellID, success)
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
presets.getSpellData = function(self, spellID)
    if (cache:hasSpell(spellID)) then
        return cache:getSpellData(spellID)
    end

    if (not C_Spell.DoesSpellExist(spellID)) then
        return false
    end

    if (C_Spell.IsSpellDataCached(spellID)) then
        local spellInfo = C_SpellBook.GetSpellInfo(spellID)
        local spellData = {
            spellID = spellID,
            name = spellInfo.name,
            iconID = spellInfo.iconID
        }
        cache:saveSpellData(spellID, spellData)
        return spellData
    else
        local id = QF.utils.generateNewId(5)
        QF.handler:registerCallback('SPELL_DATA_LOAD_RESULT', id, self:spellCacheCallback(id))
        C_Spell.RequestLoadSpellData(spellID)
        return false
    end
end

---@param self Presets
presets.fetchSpellCache = function(self)
    for _, data in pairs(QF.presets) do
        if (data.type == QF.LOOKUP_TYPE.SPELL) then
            for _, spellID in pairs(data.data) do
                self:getSpellData(spellID)
            end
        end
    end
end

---Build preset suggestions
---@param self Presets
presets.build = function(self)
    for name, data in pairs(QF.presets) do
        QF.builtPresets[name] = QF.builtPresets[name] or {}
        for _, spellID in pairs(data.data) do
            local spellData = self:getSpellData(spellID)
            if (spellData) then
                QF.builtPresets[name][spellID] = {
                    icon = spellData.iconID,
                    name = spellData.name,
                    spellID = spellID,
                    type = QF.LOOKUP_TYPE.SPELL,
                    tags = ''
                }
            end
        end
    end
end

---Get available presets
---@param self Presets
---@return table
presets.getAvailable = function(self)
    local available = {}
    for name, _ in pairs(QF.presets) do
        table.insert(available, name)
    end

    return available
end

---@param self Presets
presets.init = function(self)
    self:fetchSpellCache()
    -- Build at least initial presets
    self:build()
end

---@param self Presets
---@param name string
presets.enable = function(self, name)

end

---@param self Presets
---@param name string
presets.disable = function(self, name)
end
