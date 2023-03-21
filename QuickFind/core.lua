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

QF.handler:RegisterEvent("ADDON_LOADED")
QF.handler:SetScript("OnEvent", function(self, event, arg1)
    if (event == "ADDON_LOADED" and arg1 == addonName) then
        QF:InitModules()
    end
end)
