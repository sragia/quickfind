local addonName = ...

---@class QF
local QF = select(2, ...)

local initIndx = 0

QF.modules = {}

---@class Frame
QF.handler = CreateFrame('FRAME')
QF.handler.callbacks = {}

---@param self Frame
---@param event string
---@param id string
---@param func function
QF.handler.registerCallback = function (self, event, id, func)
    if (not self.callbacks[event]) then
        QF.handler:RegisterEvent(event)
    end
    self.callbacks[event] = self.callbacks[event] or {}
    self.callbacks[event][id] = func

    return id
end

QF.handler.unregisterCallback = function (self, event, id)
    self.callbacks[event][id] = nil
    local hasMore = false
    for _ in pairs(self.callbacks[event]) do
        hasMore = true
    end
    if (not hasMore) then
        QF.handler:UnregisterEvent(event)
        self.callbacks[event] = nil
    end
end

---Get module
---@param self QF
---@param id string
---@return table
QF.GetModule = function (self, id)
    if (not self.modules[id]) then
        initIndx = initIndx + 1
        self.modules[id] = {
            _index = initIndx
        }

        QF.utils.addObserver(self.modules[id])
    end

    return self.modules[id]
end


QF.InitModules = function (self)
    for _, module in QF.utils.spairs(self.modules, function (t, a, b) return t[a]._index < t[b]._index end) do
        if (module.init) then
            module:init()
        end
    end
end

local function init()
    if not QF.data or next(QF.data) == nil then
        QF.data = {}
    end

    QF.utils.addObserver(QF.settings)
    QF.utils.addObserver(QF.disabledPresets, true)
    -- Add Any setting changes here

    if (not QF.settings.welcomeShown) then
        QF:GetModule('welcome-frame'):Show()
        QF.settings.welcomeShown = true
    end
end

QF.SaveData = function (self, id, data)
    self.data[id] = data
end

QF.SaveDataByKey = function (self, id, key, data)
    if (self.data[id]) then
        self.data[id][key] = data
    end
end

QF.DeleteByKey = function (self, id)
    self.data[id] = nil
end

QF.styles = {
    DEFAULT = 'default',
    COMPACT = 'compact',
}

QF.settings = {
    scale = QF.default.scale,
    maxSuggestions = QF.default.maxSuggestions,
    style = QF.styles.DEFAULT
}

---Get all suggestions - Saved and Enabled Presets
---@param self QF
QF.getAllSuggestions = function (self, filters, maxSuggestions, ignoreSources)
    local presetSuggestions = {}

    for name, suggestions in pairs(QF.builtPresets) do
        if (QF.enabledPresets[name]) then
            presetSuggestions = QF.utils.shallowCloneMerge(presetSuggestions, suggestions)
        end
    end

    -- Filter out by presets that were added to data and filters if provided
    local suggestions = QF.utils.shallowCloneMerge(QF.data, presetSuggestions)

    ---@class Presets
    local preset = QF:GetModule('presets')
    if (not ignoreSources) then
        local sources = QF:GetModule('api'):GetSources()

        for _, source in pairs(sources) do
            local ok, sourceSuggestions = pcall(source.get)
            if (ok) then
                local formattedSuggestions = {}
                -- Add icon path to all suggestions
                local i = 1
                for _, suggestion in pairs(sourceSuggestions) do
                    local cloned = CopyTable(suggestion)
                    if (source.iconPath) then
                        cloned.sourceIconPath = source.iconPath
                    end
                    cloned.sourceId = suggestion.id
                    cloned.isOutsideSource = true
                    cloned.id = 'source_' .. QF.utils.generateNewId(5)
                    formattedSuggestions['source_' .. source.name .. '_' .. i] = cloned
                    i = i + 1
                end

                suggestions = QF.utils.shallowCloneMerge(suggestions, formattedSuggestions or sourceSuggestions)
            else
                QF.utils.printOut('Error getting suggestions from source: ' .. source.name)
            end
        end
    end
    local filtered = {}
    for k, v in pairs(suggestions) do
        if (v.isNew) then
            -- New suggestions bypass filters/option cap
            filtered[k] = v
        end
    end
    local i = 0
    for k, v in QF.utils.spairs(suggestions, function (t, a, b)
        if (not t[a].created) then
            return false
        end
        if (not t[b].created) then
            return true
        end
        if (t[a].created and t[b].created) then
            return t[a].created < t[b].created
        end
        return true
    end) do
        if (not v.isPreset) or (not preset:isAddedToData(v.presetID, v.presetName) and not preset:isDisabledPreset(v.presetName, v.presetID)) and not v.isNew then
            local eligible = true
            if (filters) then
                for key, filter in pairs(filters) do
                    if not filter.value then
                        -- Do nothing
                    elseif (filter.type == 'exact') then
                        if (v[key] ~= filter.value) then
                            eligible = false
                        end
                    elseif (filter.type == 'match') then
                        local suggestions = QF.utils.suggestMatch(filter.value, { v })
                        if (#suggestions == 0) then
                            eligible = false
                        end
                    end
                end
            end
            if (eligible) then
                i = i + 1
                filtered[k] = v
                if (maxSuggestions and maxSuggestions <= i) then
                    return filtered
                end
            end
        end
    end
    return filtered
end

QF.GetNumSuggestions = function (self)
    local suggestions = self:getAllSuggestions()
    local i = 0
    for _ in pairs(suggestions) do
        i = i + 1
    end

    return i
end

QF.handler:RegisterEvent('ADDON_LOADED')
QF.handler:RegisterEvent('PLAYER_LOGOUT')
QF.handler:SetScript('OnEvent', function (self, event, ...)
    if (event == 'ADDON_LOADED' and ... == addonName) then
        QF.data = QuickFindData.data or QF.data
        QF.settings = QF.utils.tableMerge(QF.settings, QuickFindData.settings or {})
        QF.cache = QF.utils.tableMerge(QF.cache, QuickFindData.cache or {})
        QF.enabledPresets = QuickFindData.enabledPresets or QF.enabledPresets
        QF.disabledPresets = QuickFindData.disabledPresets or QF.disabledPresets
        QFGLOBAL = QF
        init()
        QF:InitModules()
    end
    if self.callbacks[event] then
        for _, func in pairs(self.callbacks[event]) do
            if (func) then
                func(event, ...)
            end
        end
    end
    if event == 'PLAYER_LOGOUT' then
        -- save things
        if QF.data and next(QF.data) ~= nil then
            QuickFindData = QuickFindData or {}
            QuickFindData.data = QF.data
        end
        QuickFindData.cache = QF.cache
        QuickFindData.enabledPresets = QF.enabledPresets
        QuickFindData.disabledPresets = QF.disabledPresets
        QF.settings.observable = nil
        QuickFindData.settings = QF.settings
        return
    end
end)

TEST_QF = QF
