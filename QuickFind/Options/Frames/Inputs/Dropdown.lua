local _, QF = ...
local moduleName = 'frame-input-dropdown'

local dropdown = QF:GetModule(moduleName)

dropdown.init = function(self)
    self.pool = CreateFramePool('Frame', UIParent)
    self.optionItemPool = CreateFramePool('Frame', UIParent)
end

local function CreateOption(f)
    local option = dropdown.optionItemPool:Acquire()
    option:SetSize(205, 30)

    if (not option.valueDisplay) then
        local valueDisplay = option:CreateFontString(nil, "OVERLAY")
        option.valueDisplay = valueDisplay
        valueDisplay:SetFont(QF.default.font, 10, "OUTLINE")
        valueDisplay:SetPoint("LEFT")
        valueDisplay:SetWidth(0)

        option.SetOption = function(self, value, label)
            option.value = value
            option.valueDisplay:SetText(label)
        end

        local tex = option:CreateTexture(nil, "BACKGROUND")
        tex:SetTexture(QF.default.barBg)
        tex:SetVertexColor(0.15, 0.15, 0.15, 1)
        tex:SetPoint("TOPLEFT", -15, 25)
        tex:SetPoint("BOTTOMRIGHT", 15, -25)
        option.texture = tex
    end
    option:SetScript("OnMouseDown", function(self)
        f:SetInputValue(self.value)
        f:SetValue('isOpen', false)
    end)

    if (not option.hoverContainer) then
        local hoverContainer = CreateFrame('Frame', nil, option)
        hoverContainer:SetAllPoints()
        local hoverBorder = hoverContainer:CreateTexture()
        hoverContainer.border = hoverBorder
        option.hoverContainer = hoverContainer
        hoverBorder:SetTexture(QF.default.barBorderGlow)
        hoverBorder:SetPoint("TOPLEFT", -15, 28)
        hoverBorder:SetPoint("BOTTOMRIGHT", 15, -28)
        hoverContainer:SetAlpha(0)
        option.animDur = 0.15
        option.onHover = QF.utils.animation.fade(hoverContainer, option.animDur, 0, 1)
        option.onHoverLeave = QF.utils.animation.fade(hoverContainer, option.animDur, 1, 0)
        hoverBorder:SetVertexColor(1, 0.84, 0, 1)
    end

    option:SetScript("OnEnter", function(self)
        self.onHover:Play()
    end)
    option:SetScript("OnLeave", function(self) self.onHoverLeave:Play() end)
    return option
end

local function PopulateOptions(f, options)
    dropdown.optionItemPool:ReleaseAll()
    local previous
    local count = 0
    for value, label in pairs(options) do
        count = count + 1
        local option = CreateOption(f)
        option:SetOption(value, label)
        option:SetPoint("TOPLEFT",
            previous or f.optionContainer,
            previous and "BOTTOMLEFT" or "TOPLEFT",
            0,
            previous and -5 or 0
        )
        option:SetParent(f.optionContainer)
        option:Show()
        previous = option
    end
    f.optionContainer:SetHeight(70 * count)
end

local function ConfigureFrame(f, options)
    QF.utils.addObserver(f)
    f:SetSize(200, 70)
    f:SetFrameStrata('TOOLTIP')
    f.isOpen = false
    f.onChange = options.onChange
    f.options = options.options

    if (not f.valueDisplay) then
        local valueDisplay = f:CreateFontString(nil, "OVERLAY")
        f.valueDisplay = valueDisplay
        valueDisplay:SetFont(QF.default.font, 10, "OUTLINE")
        valueDisplay:SetPoint("LEFT")
        valueDisplay:SetWidth(0)
        f:Observe("value", function(value)
            local label = f.options[value] or value
            valueDisplay:SetText(label)
        end)

        f.SetInputValue = function(self, value)
            self:SetValue("value", value)
            if (self.onChange) then
                self.onChange(value)
            end
        end

        f:SetScript("OnMouseDown", function()
            f:SetValue("isOpen", not f.isOpen)
        end)

        local tex = f:CreateTexture(nil, "BACKGROUND")
        tex:SetTexture(QF.default.barBg)
        tex:SetVertexColor(0, 0, 0, 0.6)
        tex:SetPoint("TOPLEFT", -15, 5)
        tex:SetPoint("BOTTOMRIGHT", 15, -5)
        f.texture = tex
    end

    if (not f.chevron) then
        local chevron = f:CreateTexture(nil, "OVERLAY")
        chevron:SetSize(12, 12)
        chevron:SetPoint("RIGHT", -5, 0)
        chevron:SetTexture(QF.default.chevronDown)
        f:Observe("isOpen", function(value)
            if (value) then
                f.optionContainer:Show()
                PopulateOptions(f, f.options)
                chevron:SetRotation(math.rad(180))
            else
                f.optionContainer:Hide()
                chevron:SetRotation(math.rad(0))
            end
        end)
    end

    if (not f.label and options.label) then
        local textFrame = f:CreateFontString(nil, "OVERLAY")
        textFrame:SetFont(QF.default.font, 8, "OUTLINE")
        textFrame:SetPoint("BOTTOMLEFT", f.valueDisplay, "TOPLEFT", 0, 16)
        textFrame:SetWidth(0)
        f.label = textFrame
        textFrame:SetText(options.label)
    end

    if (not f.hoverContainer) then
        local hoverContainer = CreateFrame('Frame', nil, f)
        hoverContainer:SetAllPoints()
        local hoverBorder = hoverContainer:CreateTexture()
        hoverContainer.border = hoverBorder
        f.hoverContainer = hoverContainer
        hoverBorder:SetTexture(QF.default.barBorderGlow)
        hoverBorder:SetPoint("TOPLEFT", -15, 5)
        hoverBorder:SetPoint("BOTTOMRIGHT", 15, -5)
        hoverContainer:SetAlpha(0)
        f.animDur = 0.15
        f.onHover = QF.utils.animation.fade(hoverContainer, f.animDur, 0, 1)
        f.onHoverLeave = QF.utils.animation.fade(hoverContainer, f.animDur, 1, 0)
        hoverBorder:SetVertexColor(1, 0.84, 0, 1)
    end

    f:SetScript("OnEnter", function(self)
        self.onHover:Play()
    end)
    f:SetScript("OnLeave", function(self) self.onHoverLeave:Play() end)
    if (not f.optionContainer) then
        local optionContainer = CreateFrame("Frame", nil, UIParent)
        optionContainer:SetHeight(1)
        optionContainer:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 0, 15)
        optionContainer:SetPoint("TOPRIGHT", f, "BOTTOMRIGHT", 0, 15)
        optionContainer:SetFrameStrata("FULLSCREEN_DIALOG")
        optionContainer:SetFrameLevel(99)
        f.optionContainer = optionContainer
        optionContainer:Hide()
        optionContainer:SetScript("OnEnter", function() end)
        optionContainer:SetScript("OnLeave", function() end)
    end

    if (options.initial) then
        f:SetValue('value', options.initial)
    end
end



dropdown.Get = function(self, options, parent)
    local input = self.pool:Acquire()
    ConfigureFrame(input, options)
    if (parent) then
        input:SetParent(parent)
    else
        input:SetParent(nil)
    end
    input.Destroy = function(self)
        self.pool:Release(self)
    end
    input:Show()
    return input
end
