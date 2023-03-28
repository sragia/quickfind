local _, QF = ...
local moduleName = 'frame-option-container'

local optionContainer = QF:GetModule(moduleName)

optionContainer.init = function(self)
    self.pool = CreateFramePool('Frame', UIParent)
end
