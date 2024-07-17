local _, QF = ...
local moduleName = 'frame-input-lua'

local luaEditor = QF:GetModule(moduleName)

luaEditor.init = function(self)
    self.scrollPool = CreateFramePool('ScrollFrame', UIParent, 'ScrollFrameTemplate')
    self.pool = CreateFramePool('EditBox', UIParent, 'BackdropTemplate')
end

local function ConfigureFrame(f)
    QF.utils.addObserver(f)
    f:SetMultiLine(true)
    f:SetAutoFocus(false)
    f:SetTextInsets(10, 10, 10, 10)
    Mixin(f, BackdropTemplateMixin)
    f:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8.blp",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8.blp",
        tile = false,
        tileSize = 0,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    f:SetBackdropColor(.1, .1, .1, .8)
    f:SetBackdropBorderColor(0, 0, 0, 1)
    f:SetFont(QF.default.font, 10, "OUTLINE")
    f:SetCursorPosition(0)
    f:SetText('// Write your code here')
    f:SetScript('OnMouseDown', function(self) self:SetFocus() end)
    f:Show()
    IndentationLib.enable(f)
    f.isConfigured = true
end

luaEditor.Get = function(self, options, parent)
    local scrollFrame = self.scrollPool:Acquire()
    Mixin(scrollFrame, ScrollBoxMixin)
    -- Hack to bypass need of creating view
    scrollFrame.view = {
        GetPanExtent = function()
            return 0
        end
    }
    local input = self.pool:Acquire()
    scrollFrame:SetScrollChild(input)
    scrollFrame.input = input
    scrollFrame.GetText = function(self)
        return input:GetText()
    end
    scrollFrame.SetText = function(self, text)
        return input:SetText(text)
    end
    if (not input.isConfigured) then
        ConfigureFrame(input)
    end
    if (parent) then
        scrollFrame:SetParent(parent)
    else
        scrollFrame:SetParent(nil)
    end
    scrollFrame.Destroy = function(self)
        self.pool:Release(self.input)
        self.scrollPool:Release(self)
    end
    if (options.text) then
        input:SetText(options.text)
    end

    scrollFrame:Show()
    return scrollFrame
end
