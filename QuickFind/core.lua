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
    -- Add Any setting changes here
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

QF.settings = {
    scale = QF.default.scale,
    maxSuggestions = QF.default.maxSuggestions
}

---Get all suggestions - Saved and Enabled Presets
---@param self QF
QF.getAllSuggestions = function (self)
    local presetSuggestions = {}

    for name, suggestions in pairs(QF.builtPresets) do
        if (QF.enabledPresets[name]) then
            presetSuggestions = QF.utils.shallowCloneMerge(presetSuggestions, suggestions)
        end
    end

    ---@class Presets
    local preset = QF:GetModule('presets')

    -- Filter out presets that were added to data
    local suggestions = QF.utils.shallowCloneMerge(QF.data, presetSuggestions)
    local filtered = {}
    for k, v in pairs(suggestions) do
        if (not v.isPreset) or (not preset:isAddedToData(v.presetID, v.presetName)) then
            filtered[k] = v
        end
    end

    return filtered
end

QF.handler:RegisterEvent('ADDON_LOADED')
QF.handler:RegisterEvent('PLAYER_LOGOUT')
QF.handler:SetScript('OnEvent', function (self, event, ...)
    if (event == 'ADDON_LOADED' and ... == addonName) then
        QF.data = QuickFindData.data or QF.data
        QF.settings = QF.utils.tableMerge(QF.settings, QuickFindData.settings or {})
        QF.cache = QuickFindData.cache or QF.cache
        QF.enabledPresets = QuickFindData.enabledPresets or QF.enabledPresets
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
            QuickFindData.cache = QF.cache
            QuickFindData.enabledPresets = QF.enabledPresets
            QF.settings.observable = nil
            QuickFindData.settings = QF.settings
        end
        return
    end
end)
