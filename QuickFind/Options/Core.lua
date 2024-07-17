local _, QF = ...
local moduleName = 'options-core'

local options = QF:GetModule(moduleName)
-- Frames
local window = QF:GetModule('frame-window')
local optionContainer = QF:GetModule('frame-option-container')
local textInput = QF:GetModule('frame-input-text')
---@class ButtonInput
local button = QF:GetModule('frame-input-button')
---@class ToggleInput
local toggle = QF:GetModule('frame-input-toggle')
---@class Presets
local presets = QF:GetModule('presets')

options.createPresets = function(self)
    local baseOptionsWindow = self.window
    if not baseOptionsWindow.presetsBtn then
        local btn = button:Get({
            text = 'Presets',
            onClick = function() self:openPresets() end,
            width = 80,
            height = 50,
            startAlpha = 0.1,
            endAlpha = 1,
            color = { 26 / 255, 207 / 255, 224 / 255, 1 }
        }, baseOptionsWindow);
        btn:SetPoint("BOTTOMRIGHT", baseOptionsWindow.scrollFrame, "TOPRIGHT", 0, -2);
    end

    local window = self.presets

    local previous = nil
    for _, presetName in pairs(presets:getAvailable()) do
        local input = toggle:Get({ text = presetName, value = presets:isEnabled(presetName) }, window.container)
        if (previous) then
            input:SetPoint("TOPLEFT", previous, 0, -25)
        else
            input:SetPoint("TOPLEFT", 15, -15)
        end
        input:Observe('value', function(value)
            if (value) then
                presets:enable(presetName)
            else
                presets:disable(presetName)
            end
        end)
        previous = input
    end
end

options.openPresets = function(self)
    self.presets:ShowWindow()
end

options.init = function(self)
    local settingsFrame = window:getFrame({ title = 'Settings', showSettings = false, frameLevel = 50, offset = { x = 400, y = 200 } })
    self.settings = settingsFrame
    local windowFrame = window:getFrame({
        title = 'Configuration',
        showSettings = true,
        onSettingsClick = function()
            settingsFrame:ShowWindow()
        end,
        frameLevel = 10
    })
    self.window = windowFrame
    local presetsFrame = window:getFrame({ title = 'Presets', showSettings = false, frameLevel = 50, offset = { x = 200, y = 200 } })
    self.presets = presetsFrame

    if (not windowFrame.scrollFrame) then
        local scrollFrame = CreateFrame("ScrollFrame", nil, windowFrame.container, "ScrollFrameTemplate")
        Mixin(scrollFrame, ScrollBoxMixin)
        -- Hack to bypass need of creating view
        scrollFrame.view = {
            GetPanExtent = function()
                return 0
            end
        }
        scrollFrame:SetPoint("TOPLEFT", 0, -60)
        scrollFrame:SetPoint("BOTTOMRIGHT", -20, 50)
        local scrollChild = CreateFrame("Frame")
        scrollFrame:SetScrollChild(scrollChild)
        scrollChild:SetWidth(windowFrame.container:GetWidth() - 20)
        scrollChild:SetHeight(windowFrame.container:GetHeight())
        scrollFrame.child = scrollChild

        scrollFrame.GetBottomScrollValue = function(self)
            local max = 0
            for _, child in pairs({ self.child:GetChildren() }) do
                if (child:IsShown()) then
                    max = max + child:GetHeight()
                end
            end
            max = max - self:GetHeight()

            return max
        end

        scrollFrame:SetScript("OnMouseWheel", function(self, delta)
            local currentValue = self:GetVerticalScroll()
            local max = self:GetBottomScrollValue()
            local scrollOffset = 40
            currentValue = math.min(math.max(currentValue + (delta > 0 and -1 or 1) * scrollOffset, 0),
                max + scrollOffset)
            self:SetVerticalScroll(currentValue)
        end)

        windowFrame.scrollFrame = scrollFrame
        windowFrame.scrollChild = scrollChild
    end

    if (not windowFrame.addNewBtn) then
        local btn = CreateFrame('Button', nil, windowFrame)
        windowFrame.addNewBtn = btn
        btn:SetSize(60, 40)
        btn:SetPoint("BOTTOMRIGHT", -30, 25)
        btn:SetFrameLevel(windowFrame:GetFrameLevel() + 10)

        local textFrame = btn:CreateFontString(nil, "OVERLAY")
        textFrame:SetFont(QF.default.font, 10, "OUTLINE")
        textFrame:SetPoint("CENTER")
        textFrame:SetWidth(0)
        textFrame:SetText('New')
        btn.text = textFrame

        local hoverContainer = CreateFrame('Frame', nil, btn)
        hoverContainer:SetAllPoints()
        local hoverBorder = hoverContainer:CreateTexture()
        hoverContainer.border = hoverBorder
        btn.hoverContainer = hoverContainer
        hoverContainer:SetFrameLevel(btn:GetFrameLevel() - 1)
        hoverBorder:SetTexture(QF.default.barBg)
        hoverBorder:SetPoint("TOPLEFT", 0, 8)
        hoverBorder:SetPoint("BOTTOMRIGHT", 0, -8)
        hoverContainer:SetAlpha(0)
        btn.animDur = 0.15
        btn.onHover = QF.utils.animation.fade(hoverContainer, btn.animDur, 0, 1)
        btn.onHoverLeave = QF.utils.animation.fade(hoverContainer, btn.animDur, 1, 0)
        hoverBorder:SetVertexColor(1, 0.84, 0, 1)

        btn:SetScript('OnLeave', function(self)
            self.onHoverLeave:Play()
            self.text:SetVertexColor(1, 1, 1, 1)
            self.text:SetFont(QF.default.font, 10, "OUTLINE")
        end)
        btn:SetScript('OnEnter', function(self)
            self.onHover:Play()
            self.text:SetVertexColor(0, 0, 0, 1)
            self.text:SetFont(QF.default.font, 10, "NONE")
        end)
        btn:SetScript('OnClick', function()
            local id = QF.utils.generateNewId()
            QF:SaveData(id, {
                id = id,
                created = time()
            })
            options.options = QF.data
            options:PopulateOptions()
            options.window.scrollFrame:SetVerticalScroll(options.window.scrollFrame:GetBottomScrollValue())
        end)
    end
    self.options = QF.data

    self:CreateSearchInput()
    self:PopulateOptions()
    self:PopulateSettings()
    self:createPresets()
end

options.OnDelete = function(id)
    return function()
        QF:DeleteByKey(id)
        options.options = QF.data
        options:PopulateOptions()
        options.window.scrollFrame:SetVerticalScroll(options.window.scrollFrame:GetBottomScrollValue())
    end
end

options.PopulateOptions = function(self)
    optionContainer:DestroyAllOptions()
    self.optionFrames = {}
    for id, optionData in QF.utils.spairs(self.options, function(t, a, b)
        if (t[a].created and t[b].created) then
            return t[a].created < t[b].created
        end
        return true
    end) do
        if (optionData) then
            table.insert(self.optionFrames, optionContainer:CreateOption(optionData, self.OnDelete(id)))
        end
    end

    for index, optionFrame in ipairs(self.optionFrames) do
        if (index == 1) then
            optionFrame:SetPoint("TOPLEFT", self.window.scrollChild)
            optionFrame:SetPoint("TOPRIGHT", self.window.scrollChild)
        else
            optionFrame:SetPoint("TOPLEFT", self.optionFrames[index - 1], "BOTTOMLEFT")
            optionFrame:SetPoint("TOPRIGHT", self.optionFrames[index - 1], "BOTTOMRIGHT")
        end
        optionFrame:SetParent(self.window.scrollChild)
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
            options.window.scrollFrame:SetVerticalScroll(0)
        end
    end)
    -- Base logic
    editBox:SetScript("OnEscapePressed", function()
        editBox:ClearFocus()
    end)
end

options.PopulateSettings = function(self)
    local sFrame = self.settings

    if (not sFrame.scaleInput) then
        local scaleInput = textInput:Get({
            label = 'Search Scale',
            initial = QF.settings.scale
        }, sFrame.container)
        scaleInput.onChange = function(value)
            if (tonumber(value)) then
                QF.settings:SetValue('scale', tonumber(value));
            end
        end
        scaleInput:SetPoint("TOPLEFT", 20, 0)
        sFrame.scaleInput = scaleInput
    end

    if (not sFrame.maxSuggestions) then
        local maxSuggestions = textInput:Get({
            label = 'Max Available Suggestions',
            initial = QF.settings.maxSuggestions
        }, sFrame.container)
        maxSuggestions.onChange = function(value)
            if (tonumber(value)) then
                QF.settings:SetValue('maxSuggestions', tonumber(value));
            end
        end
        maxSuggestions:SetPoint("TOPLEFT", sFrame.scaleInput, 'TOPRIGHT', 20, 0)
        sFrame.maxSuggestions = maxSuggestions
    end
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
