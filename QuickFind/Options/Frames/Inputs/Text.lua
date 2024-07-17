local _, QF = ...
local moduleName = 'frame-input-text'

local textInput = QF:GetModule(moduleName)

textInput.init = function(self)
    self.pool = CreateFramePool('Frame', UIParent)
end

local function ConfigureFrame(f, options)
    QF.utils.addObserver(f)
    f:SetSize(200, 70)
    f.onChange = options.onChange

    if (not f.editBox) then
        local editBox = CreateFrame("EditBox", nil, f)
        f.editBox = editBox
        editBox:SetAutoFocus(false)
        editBox:SetFont(QF.default.font, 10, "OUTLINE")
        editBox:SetPoint("TOPLEFT")
        editBox:SetPoint("BOTTOMRIGHT")


        local tex = editBox:CreateTexture(nil, "BACKGROUND")
        tex:SetTexture(QF.default.barBg)
        tex:SetVertexColor(0, 0, 0, 0.6)
        tex:SetPoint("TOPLEFT", -15, 5)
        tex:SetPoint("BOTTOMRIGHT", 15, -5)
        f.editBox.texture = tex

        f.SetInputValue = function(self, value)
            self:SetValue("inputValue", value)
            if (f.onChange) then
                f.onChange(value)
            end
        end

        editBox:SetScript('OnTextChanged', function(editbox, changed)
            if (changed) then
                f:SetInputValue(editbox:GetText())
            end
        end)

        editBox:SetScript("OnEscapePressed", function(self)
            self:ClearFocus()
        end)
    end

    if (not f.label and options.label) then
        local textFrame = f:CreateFontString(nil, "OVERLAY")
        textFrame:SetFont(QF.default.font, 8, "OUTLINE")
        textFrame:SetPoint("BOTTOMLEFT", f.editBox, "TOPLEFT", 0, -15)
        textFrame:SetWidth(0)
        f.label = textFrame
        textFrame:SetText(options.label)
    end

    if (not f.editBox.hoverContainer) then
        local hoverContainer = CreateFrame('Frame', nil, f.editBox)
        hoverContainer:SetAllPoints()
        local hoverBorder = hoverContainer:CreateTexture()
        hoverContainer.border = hoverBorder
        f.editBox.hoverContainer = hoverContainer
        hoverBorder:SetTexture(QF.default.barBorderGlow)
        hoverBorder:SetPoint("TOPLEFT", -15, 5)
        hoverBorder:SetPoint("BOTTOMRIGHT", 15, -5)
        hoverContainer:SetAlpha(0)
        f.editBox.animDur = 0.15
        f.editBox.onHover = QF.utils.animation.fade(hoverContainer, f.editBox.animDur, 0, 1)
        f.editBox.onHoverLeave = QF.utils.animation.fade(hoverContainer, f.editBox.animDur, 1, 0)
        hoverBorder:SetVertexColor(1, 0.84, 0, 1)
        f.editBox:SetScript("OnEnter", function(self)
            self.onHover:Play()
        end)
        f.editBox:SetScript("OnLeave", function(self)
            if (not self:HasFocus()) then
                self.onHoverLeave:Play()
            end
        end)
        f.editBox:SetScript("OnEditFocusLost", function(self)
            if (not self:IsMouseOver()) then
                self.onHoverLeave:Play()
            end
        end)
    end

    if (options.initial) then
        f.editBox:SetText(options.initial)
    end
end



textInput.Get = function(self, options, parent)
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
