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
        -- TODO: Remove before release
        QF.data = {}
        for _, optionData in ipairs(QF.BASE_LOOKUPS) do
            QF.data[optionData.id] = optionData
        end
    end
end

QF.SaveData = function(self, id, data)
    if (self.data[id]) then
        self.data[id] = data
    end
end

QF.SaveDataByKey = function(self, id, key, data)
    if (self.data[id]) then
        self.data[id][key] = data
    end
end

QF.handler:RegisterEvent("ADDON_LOADED")
QF.handler:RegisterEvent("PLAYER_LOGOUT")
QF.handler:SetScript("OnEvent", function(self, event, arg1)
    if (event == "ADDON_LOADED" and arg1 == addonName) then
        QF.data = QuickFindData
        init()
        QF:InitModules()
    end
    if event == "PLAYER_LOGOUT" then
        -- save things
        if QF.data and next(QF.data) ~= nil then
            QuickFindData = QF.data
        end
        return
    end
end)
