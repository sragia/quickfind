---@class QF
local QF = select(2, ...)
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
---@class DropdownInput
local dropdown = QF:GetModule('frame-input-dropdown')
---@class TooltipInput
local tooltip = QF:GetModule('frame-input-tooltip')
---@class Presets
local presets = QF:GetModule('presets')

options.CreatePresets = function (self)
    local baseOptionsWindow = self.window
    if not baseOptionsWindow.presetsBtn then
        local btn = button:Get({
            text = 'Presets',
            onClick = function () self:openPresets() end,
            width = 80,
            height = 50,
            startAlpha = 0.1,
            endAlpha = 1,
            color = { 26 / 255, 207 / 255, 224 / 255, 1 }
        }, baseOptionsWindow);
        btn:SetPoint('BOTTOMRIGHT', baseOptionsWindow.scrollFrame, 'TOPRIGHT', 0, -2);
    end

    local window = self.presets

    local allPresetDisabledReset = button:Get({
        text = 'Reset All Disabled Presets',
        onClick = function ()
            presets:resetDisabled()
            options:PopulateOptions()
        end,
        width = 160,
        height = 50,
        startAlpha = 0,
        endAlpha = 1,
        color = { 165 / 255, 30 / 255, 34 / 255, 1 }
    }, window)
    allPresetDisabledReset:SetPoint('BOTTOMLEFT', 40, 30)



    local previous = nil
    for _, preset in pairs(presets:getAvailable()) do
        local input = toggle:Get({ text = preset.name, value = presets:isEnabled(preset.name) }, window.container)
        if (previous) then
            input:SetPoint('TOPLEFT', previous, 0, -30)
        else
            input:SetPoint('TOPLEFT', 15, -15)
        end
        input:Observe('value', function (value)
            if (value) then
                presets:enable(preset.name)
            else
                presets:disable(preset.name)
            end
            self:PopulateOptions()
        end)

        local description = input:CreateFontString(nil, 'OVERLAY')
        description:SetFont(QF.default.font, 10, 'OUTLINE')
        description:SetText(preset.description)
        description:SetVertexColor(0.6, 0.6, 0.6, 1)
        description:SetPoint('LEFT', input.label, 'RIGHT', 5, 0)

        -- Reset button
        local resetPreset = CreateFrame('Frame', nil, input)
        resetPreset:SetSize(18, 18)
        resetPreset:SetPoint('LEFT', description, 'RIGHT', 5, 0)
        local resetTex = resetPreset:CreateTexture()
        resetTex:SetTexture(QF.textures.icon.reset)
        resetTex:SetAllPoints()

        local resetTooltip = tooltip:Get({ text = 'Reset disabled presets' }, resetPreset)

        resetPreset:SetScript('OnMouseDown', function (self)
            presets:resetDisabled(preset.name)
            options:PopulateOptions()
        end)

        resetPreset:SetScript('OnEnter', function ()
            resetTooltip:ShowTooltip()
            resetTex:SetVertexColor(165 / 255, 30 / 255, 34 / 255, 1)
        end)

        resetPreset:SetScript('OnLeave', function ()
            resetTooltip:HideTooltip()
            resetTex:SetVertexColor(1, 1, 1, 1)
        end)

        if (not presets:hasAnyDisabled(preset.name)) then
            resetPreset:Hide()
        end

        QF.disabledPresets:Observe(preset.name, function ()
            if (presets:hasAnyDisabled(preset.name)) then
                resetPreset:Show()
            else
                resetPreset:Hide()
            end
        end)


        previous = input
    end
end

options.openPresets = function (self)
    self.presets:ShowWindow()
end

options.init = function (self)
    local settingsFrame = window:getFrame({ title = 'Settings', showSettings = false, frameLevel = 50, offset = { x = 400, y = 200 } })
    self.settings = settingsFrame
    local windowFrame = window:getFrame({
        title = 'Configuration',
        showSettings = true,
        onSettingsClick = function ()
            settingsFrame:ShowWindow()
        end,
        frameLevel = 10
    })
    self.window = windowFrame
    local presetsFrame = window:getFrame({ title = 'Presets', showSettings = false, frameLevel = 50, offset = { x = 200, y = 200 } })
    self.presets = presetsFrame


    if (not self.notificationTxt) then
        local notificationContainer = CreateFrame('Frame', nil, windowFrame)
        notificationContainer:SetHeight(80)
        local notificationTxt = notificationContainer:CreateFontString(nil, 'OVERLAY')
        notificationTxt:SetPoint('CENTER')
        notificationTxt:SetFont(QF.default.font, 11, 'OUTLINE')
        notificationTxt:SetText(
            'You have reached suggestion cap that options can show. Try more specific filters, to find what you want.')
        notificationTxt:SetVertexColor(0.65, 0.65, 0.65, 1)
        local notificationTxt2 = notificationContainer:CreateFontString(nil, 'OVERLAY')
        notificationTxt2:SetPoint('TOP', notificationTxt, 'BOTTOM', 0, -5)
        notificationTxt2:SetFont(QF.default.font, 6, 'OUTLINE')
        notificationTxt2:SetText(
            'Options just get really laggy, if we try to show hundreds of options. I hope you understand. But really try filters.')
        notificationTxt2:SetVertexColor(0.4, 0.4, 0.4, 1)
        self.notificationTxt = notificationContainer
    end

    if (not self.noSuggestionsTxt) then
        local noSuggestionsNotificationContainer = CreateFrame('Frame', nil, windowFrame)
        noSuggestionsNotificationContainer:SetHeight(80)
        local noSuggestionsTxt = noSuggestionsNotificationContainer:CreateFontString(nil, 'OVERLAY')
        noSuggestionsTxt:SetPoint('CENTER')
        noSuggestionsTxt:SetFont(QF.default.font, 11, 'OUTLINE')
        noSuggestionsTxt:SetText(
            'No suggestions found. Try creating new or enable some presets.')
        noSuggestionsTxt:SetVertexColor(0.65, 0.65, 0.65, 1)
        self.noSuggestionsTxt = noSuggestionsNotificationContainer
    end

    if (not windowFrame.scrollFrame) then
        local scrollFrame = CreateFrame('ScrollFrame', nil, windowFrame.container, 'ScrollFrameTemplate')
        Mixin(scrollFrame, ScrollBoxMixin)
        -- Hack to bypass need of creating view
        scrollFrame.view = {
            GetPanExtent = function ()
                return 0
            end
        }
        scrollFrame:SetPoint('TOPLEFT', 0, -60)
        scrollFrame:SetPoint('BOTTOMRIGHT', -20, 50)
        local scrollChild = CreateFrame('Frame')
        scrollFrame:SetScrollChild(scrollChild)
        scrollChild:SetWidth(windowFrame.container:GetWidth() - 20)
        scrollChild:SetHeight(windowFrame.container:GetHeight())
        scrollFrame.child = scrollChild

        scrollFrame.GetBottomScrollValue = function (self)
            local max = 0
            for _, child in pairs({ self.child:GetChildren() }) do
                if (child:IsShown()) then
                    max = max + child:GetHeight()
                end
            end
            max = max - self:GetHeight()

            return max
        end

        scrollFrame:SetScript('OnMouseWheel', function (self, delta)
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
        btn:SetPoint('BOTTOMRIGHT', -30, 25)
        btn:SetFrameLevel(windowFrame:GetFrameLevel() + 10)

        local textFrame = btn:CreateFontString(nil, 'OVERLAY')
        textFrame:SetFont(QF.default.font, 10, 'OUTLINE')
        textFrame:SetPoint('CENTER')
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
        hoverBorder:SetPoint('TOPLEFT', 0, 8)
        hoverBorder:SetPoint('BOTTOMRIGHT', 0, -8)
        hoverContainer:SetAlpha(0)
        btn.animDur = 0.15
        btn.onHover = QF.utils.animation.fade(hoverContainer, btn.animDur, 0, 1)
        btn.onHoverLeave = QF.utils.animation.fade(hoverContainer, btn.animDur, 1, 0)
        hoverBorder:SetVertexColor(1, 0.84, 0, 1)

        btn:SetScript('OnLeave', function (self)
            self.onHoverLeave:Play()
            self.text:SetVertexColor(1, 1, 1, 1)
            self.text:SetFont(QF.default.font, 10, 'OUTLINE')
        end)
        btn:SetScript('OnEnter', function (self)
            self.onHover:Play()
            self.text:SetVertexColor(0, 0, 0, 1)
            self.text:SetFont(QF.default.font, 10, 'NONE')
        end)
        btn:SetScript('OnClick', function ()
            local id = QF.utils.generateNewId()
            QF:SaveData(id, {
                id = id,
                created = time()
            })
            options:PopulateOptions()
            options:ScrollToID(id)
        end)
    end

    self:CreateSearchInput()
    self:CreateFilters()
    self:PopulateOptions()
    self:PopulateSettings()
    self:CreatePresets()
end

options.ScrollToEnd = function (self)
    self.window.scrollFrame:SetVerticalScroll(self.window.scrollFrame:GetBottomScrollValue())
end

options.ScrollToStart = function (self)
    self.window.scrollFrame:SetVerticalScroll(0)
end

options.ScrollToID = function (self, id)
    self:ScrollToStart()
    local scrollTop = self.window.scrollFrame:GetTop()
    for _, option in ipairs(self.optionFrames) do
        if (option.optionId == id) then
            local optionTop = option:GetTop()
            self.window.scrollFrame:SetVerticalScroll(scrollTop - optionTop)
            return
        end
    end
end

options.OnDelete = function (id)
    return function ()
        QF:DeleteByKey(id)
        options:PopulateOptions()
        options:ScrollToStart()
    end
end

local optionCap = 70
options.PopulateOptions = function (self)
    optionContainer:DestroyAllOptions()
    self.optionFrames = {}
    local numSuggestions = QF:GetNumSuggestions()
    for id, optionData in QF.utils.spairs(QF:getAllSuggestions(self.filters, optionCap), function (t, a, b)
        if (t[a].created and t[b].created) then
            return t[a].created < t[b].created
        end
        return true
    end) do
        if (optionData) then
            table.insert(self.optionFrames, optionContainer:CreateOption(optionData, self.OnDelete(id), self))
        end
    end

    self.notificationTxt:ClearAllPoints()
    self.noSuggestionsTxt:Hide()
    self.noSuggestionsTxt:ClearAllPoints()
    self.noSuggestionsTxt:Hide()
    if (#self.optionFrames == optionCap and optionCap < numSuggestions) then
        self.notificationTxt:Show()
        table.insert(self.optionFrames, self.notificationTxt)
    end

    if (#self.optionFrames == 0 and QF.utils.isEmpty(self.filters)) then
        self.noSuggestionsTxt:Show()
        table.insert(self.optionFrames, self.noSuggestionsTxt)
    end

    for index, optionFrame in ipairs(self.optionFrames) do
        if (index == 1) then
            optionFrame:SetPoint('TOPLEFT', self.window.scrollChild)
            optionFrame:SetPoint('TOPRIGHT', self.window.scrollChild)
        else
            optionFrame:SetPoint('TOPLEFT', self.optionFrames[index - 1], 'BOTTOMLEFT')
            optionFrame:SetPoint('TOPRIGHT', self.optionFrames[index - 1], 'BOTTOMRIGHT')
        end
        optionFrame:SetParent(self.window.scrollChild)
        optionFrame:Show()
    end
end

options.CreateSearchInput = function (self)
    if (self.editBox) then return end
    local editBox = CreateFrame('EditBox', nil, self.window.container)
    self.editBox = editBox
    editBox:SetAutoFocus(false)
    editBox:SetPoint('TOPLEFT', 30, 0)
    editBox:SetHeight(70)
    editBox:SetWidth(250)

    -- BG
    local tex = editBox:CreateTexture(nil, 'BACKGROUND', nil, -5)
    tex:SetTexture([[Interface/Addons/QuickFind/Media/Texture/bar]])
    tex:SetVertexColor(0, 0, 0, 0.6)
    tex:SetPoint('TOPLEFT', -40, 8)
    tex:SetPoint('BOTTOMRIGHT', 40, -8)

    -- Icon
    local searchIcon = editBox:CreateTexture(nil, 'BACKGROUND', nil, -5)
    searchIcon:SetTexture([[Interface/Addons/QuickFind/Media/Texture/icon-search]])
    searchIcon:SetVertexColor(1, 1, 1, 0.8)
    searchIcon:SetPoint('LEFT', -20, 0)
    searchIcon:SetSize(16, 16)

    local textFrame = editBox:CreateFontString(nil, 'OVERLAY')
    textFrame:SetFont(QF.default.font, 8, 'OUTLINE')
    textFrame:SetPoint('BOTTOMLEFT', editBox, 'TOPLEFT', -20, -14)
    textFrame:SetWidth(0)
    textFrame:SetText('Search')

    editBox:SetFont([[Interface/Addons/QuickFind/Media/Font/Poppins.ttf]], 11, 'OUTLINE')

    editBox:SetScript('OnTextChanged', function (editbox, changed)
        if (changed) then
            self.filters['search'] = { type = 'match', value = editbox:GetText() }
            self:SetValue('filters', self.filters)
            options:PopulateOptions()
            options:ScrollToStart();
        end
    end)
    -- Base logic
    editBox:SetScript('OnEscapePressed', function ()
        editBox:ClearFocus()
    end)
end

options.ResetFilters = function (self)
    self:SetValue('filters', {})
    self.typeDropdown:SetValue('value', '')
    self.editBox:SetText('')
    self:PopulateOptions()
end

options.CreateFilters = function (self)
    self.filters = {}
    local typeDropdown = dropdown:Get({
        label = 'Type',
        options = QF.utils.shallowCloneMerge(QF.typeOptions, { preset = 'Preset' }),
        onChange = function (value)
            if (value == 'preset') then
                self.filters['isPreset'] = { value = true, type = 'exact' }
                self.filters['type'] = nil
            else
                self.filters['type'] = { value = value, type = 'exact' }
                self.filters['isPreset'] = nil
            end
            self:SetValue('filters', self.filters)
            self:PopulateOptions()
        end,
        width = 130
    }, self.window)
    self.typeDropdown = typeDropdown

    typeDropdown:SetPoint('LEFT', self.editBox, 'RIGHT', 50, 0)

    local resetBtn = button:Get({
        text = 'Reset',
        width = 80,
        startAlpha = 0.1,
        endAlpha = 1,
        onClick = function ()
            self:ResetFilters()
        end,
        color = { 237 / 255, 26 / 255, 86 / 255, 1 }
    }, self.window);
    resetBtn:Hide()
    self:Observe('filters', function (value)
        local hasOptions = false
        for _ in pairs(value) do
            hasOptions = true
        end
        if hasOptions then
            resetBtn:Show()
        else
            resetBtn:Hide()
        end
        self:ScrollToStart()
    end)

    resetBtn:SetPoint('LEFT', typeDropdown, 'RIGHT', 20, 0)
end

options.PopulateSettings = function (self)
    local sFrame = self.settings

    if (not sFrame.scaleInput) then
        local scaleInput = textInput:Get({
            label = 'Search Scale',
            initial = QF.settings.scale
        }, sFrame.container)
        scaleInput.onChange = function (value)
            if (tonumber(value)) then
                QF.settings:SetValue('scale', tonumber(value));
            end
        end
        scaleInput:SetPoint('TOPLEFT', 20, 0)
        sFrame.scaleInput = scaleInput
    end

    if (not sFrame.maxSuggestions) then
        local maxSuggestions = textInput:Get({
            label = 'Max Available Suggestions',
            initial = QF.settings.maxSuggestions
        }, sFrame.container)
        maxSuggestions.onChange = function (value)
            if (tonumber(value)) then
                QF.settings:SetValue('maxSuggestions', tonumber(value));
            end
        end
        maxSuggestions:SetPoint('TOPLEFT', sFrame.scaleInput, 'TOPRIGHT', 20, 0)
        sFrame.maxSuggestions = maxSuggestions
    end
end

options.ShowFrame = function (self)
    self.window:ShowWindow()
end

options.HideFrame = function (self)
    self.window:HideWindow()
end


SLASH_QF1, SLASH_QF2 = '/QF', '/QUICKFIND'
function SlashCmdList.QF(msg)
    options:ShowFrame()
end
