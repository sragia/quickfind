local _, QF = ...
local moduleName = 'options-core'

local options = QF:GetModule(moduleName)
-- Frames
local window = QF:GetModule('frame-window')
local optionContainer = QF:GetModule('frame-option-container')

options.init = function(self)
    local windowFrame = window:getFrame('Configuration', true)
    self.window = windowFrame

    if (not windowFrame.scrollFrame) then
        local scrollFrame = CreateFrame("ScrollFrame", nil, windowFrame.container, "ScrollBoxBaseTemplate")
        Mixin(scrollFrame, ScrollBoxMixin)
        scrollFrame:SetPoint("TOPLEFT", 0, -60)
        scrollFrame:SetPoint("BOTTOMRIGHT", 0, 50)

        local scrollChild = CreateFrame("Frame")
        scrollFrame:SetScrollChild(scrollChild)
        scrollChild:SetWidth(windowFrame.container:GetWidth())
        scrollChild:SetHeight(1)
        scrollFrame.child = scrollChild

        scrollFrame:SetScript("OnMouseWheel", function(self, delta)
            local currentValue = self:GetVerticalScroll()

            local max = 0
            for _, child in pairs({ self.child:GetChildren() }) do
                max = max + child:GetHeight()
            end
            max = max - scrollFrame:GetHeight()

            local scrollOffset = 40
            currentValue = math.min(math.max(currentValue + (delta > 0 and -1 or 1) * scrollOffset, 0), max)
            self:SetVerticalScroll(currentValue)
        end)

        windowFrame.scrollFrame = scrollChild
    end
    self.options = QF.data

    self:CreateSearchInput()
    self:PopulateOptions()
end

options.PopulateOptions = function(self)
    optionContainer:DestroyAllOptions()
    self.optionFrames = {}
    for _, optionData in ipairs(self.options) do
        table.insert(self.optionFrames, optionContainer:CreateOption(optionData))
    end

    for index, optionFrame in ipairs(self.optionFrames) do
        if (index == 1) then
            optionFrame:SetPoint("TOPLEFT", self.window.scrollFrame)
            optionFrame:SetPoint("TOPRIGHT", self.window.scrollFrame)
        else
            optionFrame:SetPoint("TOPLEFT", self.optionFrames[index - 1], "BOTTOMLEFT")
            optionFrame:SetPoint("TOPRIGHT", self.optionFrames[index - 1], "BOTTOMRIGHT")
        end
        optionFrame:SetParent(self.window.scrollFrame)
        optionFrame:Show()
    end
end

options.CreateSearchInput = function(self)
    if (self.editBox) then return end
    local editBox = CreateFrame("EditBox", nil, self.window.container)
    self.editBox = editBox
    editBox:SetAutoFocus(false)
    editBox:SetPoint("TOPLEFT", 30, 0)
    editBox:SetHeight(70)
    editBox:SetWidth(250)

    -- BG
    local tex = editBox:CreateTexture(nil, "BACKGROUND", nil, -5)
    tex:SetTexture([[Interface/Addons/QuickFind/Media/Texture/bar]])
    tex:SetVertexColor(0, 0, 0, 0.6)
    tex:SetPoint("TOPLEFT", -40, 8)
    tex:SetPoint("BOTTOMRIGHT", 40, -8)

    -- Icon
    local searchIcon = editBox:CreateTexture(nil, "BACKGROUND", nil, -5)
    searchIcon:SetTexture([[Interface/Addons/QuickFind/Media/Texture/icon-search]])
    searchIcon:SetVertexColor(1, 1, 1, 0.8)
    searchIcon:SetPoint("LEFT", -20, 0)
    searchIcon:SetSize(16, 16)

    local textFrame = editBox:CreateFontString(nil, "OVERLAY")
    textFrame:SetFont(QF.default.font, 8, "OUTLINE")
    textFrame:SetPoint("BOTTOMLEFT", editBox, "TOPLEFT", -20, -14)
    textFrame:SetWidth(0)
    textFrame:SetText("Search")

    editBox:SetFont([[Interface/Addons/QuickFind/Media/Font/Poppins.ttf]], 11, "OUTLINE")

    editBox:SetScript('OnTextChanged', function(editbox, changed)
        if (changed) then
            if (editbox:GetText() == '') then
                options.options = QF.data
            else
                local suggestions = QF.utils.suggestMatch(editbox:GetText(), QF.data)
                local filteredOptions = {}

                for _, suggestion in ipairs(suggestions) do
                    table.insert(filteredOptions, suggestion.data)
                end

                options.options = filteredOptions
            end
            options:PopulateOptions()
        end
    end)
    -- Base logic
    editBox:SetScript("OnEscapePressed", function()
        editBox:ClearFocus()
    end)
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
