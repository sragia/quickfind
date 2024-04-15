local addonName, QF = ...

local initIndx = 0

QF.modules = {}

QF.handler = CreateFrame("FRAME")

QF.GetModule = function(self, id)
    if (not self.modules[id]) then
        initIndx = initIndx + 1
        self.modules[id] = {
            _index = initIndx
        }

        QF.utils.addObserver(self.modules[id])
    end

    return self.modules[id]
end


QF.InitModules = function(self)
    for _, module in QF.utils.spairs(self.modules, function(t, a, b) return t[a]._index < t[b]._index end) do
        if (module.init) then
            module:init()
        end
    end
end

local function init()
    if not QF.data or next(QF.data) == nil then
        QF.data = {}
        for _, optionData in ipairs(QF.BASE_LOOKUPS) do
            optionData.created = time()
            QF.data[optionData.id] = optionData
        end
    end

    QF.utils.addObserver(QF.settings)
    -- Add Any setting changes here
end

QF.SaveData = function(self, id, data)
    self.data[id] = data
end

QF.SaveDataByKey = function(self, id, key, data)
    if (self.data[id]) then
        self.data[id][key] = data
    end
end

QF.DeleteByKey = function(self, id)
    self.data[id] = nil
end

QF.settings = {
    scale = QF.default.scale,
    maxSuggestions = QF.default.maxSuggestions
}

QF.handler:RegisterEvent("ADDON_LOADED")
QF.handler:RegisterEvent("PLAYER_LOGOUT")
QF.handler:SetScript("OnEvent", function(_, event, arg1)
    if (event == "ADDON_LOADED" and arg1 == addonName) then
        QF.data = QuickFindData.data or QF.data
        QF.settings = QF.utils.tableMerge(QF.settings, QuickFindData.settings or {})
        QFGLOBAL = QF
        init()
        QF:InitModules()
    end
    if event == "PLAYER_LOGOUT" then
        -- save things
        if QF.data and next(QF.data) ~= nil then
            QuickFindData = QuickFindData or {}
            QuickFindData.data = QF.data
            QF.settings.observable = nil
            QuickFindData.settings = QF.settings
        end
        return
    end
end)
