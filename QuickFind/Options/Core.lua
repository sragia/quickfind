local _, QF = ...
local moduleName = 'options-core'

local options = QF:GetModule(moduleName)
-- Frames
local window = QF:GetModule('frame-window')


options.init = function(self)
    local windowFrame = window:getFrame('Configuration', true)
    self.window = windowFrame
end

options.ShowFrame = function(self)
    self.window:ShowWindow()
end

options.HideFrame = function(self)
    self.window:HideWindow()
end


SLASH_QF1, SLASH_QF2 = "/QF", "/QUICKFIND"
function SlashCmdList.QF(msg)
    options:ShowFrame()
end
