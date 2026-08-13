---@class QF
local QF = select(2, ...)
local moduleName = 'presets'

---@class SpellDataItem : {spellID: number, name: string, iconID: string, description: string}

---@class Presets
local presets = QF:GetModule(moduleName)

---@class Cache
local cache = QF:GetModule('cache')

-- Stay well under the script timeout and keep login/frames responsive.
local BUILD_TIME_BUDGET_MS = 10

-- spellID -> { [presetName] = true } while client spell data is still loading
local pendingSpellPresets = {}

local function addPresetInfo(data, ID, name)
    return QF.utils.shallowCloneMerge(data, {
        isPreset = true,
        presetName = name,
        presetID = ID,
        created = 999999999999999999999 -- Just so they show up at the end
    })
end

local function ensureBucket(name)
    QF.builtPresets[name] = QF.builtPresets[name] or {}
    return QF.builtPresets[name]
end

---Yield the in-progress build when this frame's time budget is spent.
---@param self Presets
presets.yield = function (self)
    if not coroutine.running() then return end
    if debugprofilestop() - (self._buildStart or 0) >= BUILD_TIME_BUDGET_MS then
        coroutine.yield()
    end
end

---@param self Presets
---@param name string
---@param spellID number
---@param spellData SpellDataItem
presets.addSpellEntry = function (self, name, spellID, spellData)
    local bucket = ensureBucket(name)
    bucket[name .. spellID] = addPresetInfo({
        icon = spellData.iconID,
        name = spellData.name,
        spellId = spellID,
        type = QF.LOOKUP_TYPE.SPELL,
        tags = spellData.description
    }, spellID, name)
end

---@param self Presets
---@param spellID number
---@param spellData SpellDataItem
presets.addPendingSpellEntries = function (self, spellID, spellData)
    local names = pendingSpellPresets[spellID]
    pendingSpellPresets[spellID] = nil
    if not names then return end
    for name in pairs(names) do
        self:addSpellEntry(name, spellID, spellData)
    end
end

---@param self Presets
presets.ensureSpellLoadHandler = function (self)
    if self._spellLoadHandler then return end
    self._spellLoadHandler = true
    QF.handler:registerCallback('SPELL_DATA_LOAD_RESULT', 'presets', function (_, spellID, success)
        if not pendingSpellPresets[spellID] then return end
        if not success then
            pendingSpellPresets[spellID] = nil
            return
        end
        local spellData = self:getSpellData(spellID)
        if spellData then
            self:addPendingSpellEntries(spellID, spellData)
        end
    end)
end

---@param self Presets
---@param spellID number
---@param presetName? string
---@return SpellDataItem|false
presets.getSpellData = function (self, spellID, presetName)
    if (cache:hasSpell(spellID)) then return cache:getSpellData(spellID) end

    if (not C_Spell.DoesSpellExist(spellID)) then return false end

    local function trackPending()
        if not presetName then return end
        pendingSpellPresets[spellID] = pendingSpellPresets[spellID] or {}
        pendingSpellPresets[spellID][presetName] = true
    end

    if (C_Spell.IsSpellDataCached(spellID)) then
        local spellInfo = C_Spell.GetSpellInfo(spellID)
        local spellDescription = C_Spell.GetSpellDescription(spellID)
        if (not spellDescription) then
            trackPending()
            local spell = Spell:CreateFromSpellID(spellID)
            spell:ContinueOnSpellLoad(function ()
                local spellData = {
                    spellID = spellID,
                    name = spell:GetSpellName(),
                    iconID = spellInfo.iconID,
                    description = spell:GetSpellDescription()
                }
                cache:saveSpellData(spellID, spellData)
                self:addPendingSpellEntries(spellID, spellData)
            end)
            return false
        end
        local spellData = {
            spellID = spellID,
            name = spellInfo.name,
            iconID = spellInfo.iconID,
            description = spellDescription
        }
        cache:saveSpellData(spellID, spellData)
        return spellData
    end

    if pendingSpellPresets[spellID] then
        trackPending()
        return false
    end

    trackPending()
    self:ensureSpellLoadHandler()
    C_Spell.RequestLoadSpellData(spellID)
    return false
end

---@param self Presets
presets.buildAll = function (self)
    for name, data in pairs(QF.presets) do
        local bucket = ensureBucket(name)
        if (data.type == QF.LOOKUP_TYPE.SPELL) then
            for _, spellID in pairs(data.data) do
                if not bucket[name .. spellID] then
                    local spellData = self:getSpellData(spellID, name)
                    if (spellData) then
                        self:addSpellEntry(name, spellID, spellData)
                    end
                end
                self:yield()
            end
        elseif (data.type == QF.LOOKUP_TYPE.MOUNT) then
            if (data.all) then
                local mountIDs = C_MountJournal.GetMountIDs()
                for i = 1, #mountIDs do
                    local mountName, spellID, icon, _, isUsable =
                        C_MountJournal.GetMountInfoByID(mountIDs[i])
                    if (isUsable) then
                        bucket[name .. spellID] = addPresetInfo({
                            icon = icon,
                            name = mountName,
                            mountName = mountName,
                            tags = '',
                            type = QF.LOOKUP_TYPE.MOUNT
                        }, spellID, name)
                    end
                    self:yield()
                end
            end
        elseif (data.type == QF.LOOKUP_TYPE.TOY) then
            if (data.all) then
                local numToys = C_ToyBox.GetNumToys()
                for i = 1, numToys do
                    local toyID = C_ToyBox.GetToyFromIndex(i)
                    if (toyID > 0 and C_ToyBox.IsToyUsable(toyID)) then
                        local toyData = cache:getToyData(toyID)
                        if (not toyData) then
                            local itemID, toyName, icon = C_ToyBox.GetToyInfo(toyID)
                            toyData = {
                                itemID = itemID,
                                toyName = toyName,
                                icon = icon
                            }
                            cache:saveToyData(toyID, toyData)
                        end
                        if toyData.toyName and PlayerHasToy(toyData.itemID) then
                            bucket[name .. toyID] = addPresetInfo({
                                icon = toyData.icon,
                                name = toyData.toyName,
                                type = QF.LOOKUP_TYPE.TOY,
                                itemId = toyData.itemID
                            }, toyID, name)
                        end
                    end
                    self:yield()
                end
            end
        elseif (data.type == QF.LOOKUP_TYPE.LUA) then
            if (data.built) then
                local built = data.getBuiltData()
                for _, item in pairs(built) do
                    bucket[name .. item.id] = addPresetInfo(item, item.id, name)
                    self:yield()
                end
            end
        end
    end
end

---@param self Presets
presets.resumeBuild = function (self)
    if not self._buildCo or coroutine.status(self._buildCo) == 'dead' then
        self._buildCo = nil
        self._buildScheduled = false
        return
    end

    self._buildStart = debugprofilestop()
    local ok, err = coroutine.resume(self._buildCo)
    if not ok then
        self._buildCo = nil
        self._buildScheduled = false
        geterrorhandler()(err)
        return
    end

    if self._buildCo and coroutine.status(self._buildCo) ~= 'dead' then
        C_Timer.After(0, function () self:resumeBuild() end)
    else
        self._buildCo = nil
        self._buildScheduled = false
    end
end

---Build preset suggestions across frames so a cold cache cannot hitch or time out.
---@param self Presets
presets.build = function (self)
    if self._buildCo and coroutine.status(self._buildCo) ~= 'dead' then
        return
    end
    self._buildCo = coroutine.create(function ()
        self:buildAll()
    end)
    if not self._buildScheduled then
        self._buildScheduled = true
        C_Timer.After(0, function () self:resumeBuild() end)
    end
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
