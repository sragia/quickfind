---@class QF
local QF = select(2, ...)

local moduleName = 'frame-input-toggle'

---@class ToggleOptions : {text: string, value:boolean, onChange: function}

---@class ToggleInput
local toggle = QF:GetModule(moduleName)
toggle.pool = {}

toggle.init = function(self)
    self.pool = CreateFramePool('Frame', UIParent)
end

---@param f Frame
---@param options ToggleOptions
local function ConfigureFrame(f, options)
    QF.utils.addObserver(f)
    f:SetSize(49, 20)

    local base = f:CreateTexture(nil, "ARTWORK")
    base:SetTexture(QF.default.toggle)
    base:SetTexCoord(1 / 256, 167 / 256, 181 / 256, 248 / 256)
    base:SetAllPoints()

    local borderDisabled = f:CreateTexture(nil, "ARTWORK")
    borderDisabled:SetTexture(QF.default.toggle)
    borderDisabled:SetTexCoord(1 / 256, 167 / 256, 90 / 256, 157 / 256)
    borderDisabled:SetAllPoints()

    local borderEnabled = f:CreateTexture(nil, "ARTWORK")
    borderEnabled:SetTexture(QF.default.toggle)
    borderEnabled:SetTexCoord(1 / 256, 167 / 256, 1 / 256, 68 / 256)
    borderEnabled:SetAllPoints()
    borderEnabled:SetAlpha(0)

    local thumbDisabled = f:CreateTexture(nil, "OVERLAY")
    thumbDisabled:SetTexture(QF.default.toggle)
    thumbDisabled:SetTexCoord(176 / 256, 255 / 256, 84 / 256, 163 / 256)
    thumbDisabled:SetSize(25, 25)
    thumbDisabled:SetPoint("CENTER", base, "LEFT", 10, 0)

    local thumbEnabled = f:CreateTexture(nil, "OVERLAY")
    thumbEnabled:SetTexture(QF.default.toggle)
    thumbEnabled:SetTexCoord(176 / 256, 255 / 256, 1 / 256, 80 / 256)
    thumbEnabled:SetSize(25, 25)
    thumbEnabled:SetPoint("CENTER", base, "LEFT", 10, 0)
    thumbEnabled:SetAlpha(0)

    local duration = 0.2
    local moveBy = 29

    -- KMS part
    local thumbEnabledEnableGroup = QF.utils.animation.getAnimationGroup(thumbEnabled)
    QF.utils.animation.fade(thumbEnabled, duration, 0, 1, thumbEnabledEnableGroup)
    QF.utils.animation.move(thumbEnabled, duration, moveBy, 0, thumbEnabledEnableGroup)

    local thumbEnabledDisableGroup = QF.utils.animation.getAnimationGroup(thumbEnabled)
    QF.utils.animation.fade(thumbEnabled, duration, 1, 0, thumbEnabledDisableGroup)
    QF.utils.animation.move(thumbEnabled, duration, -moveBy, 0, thumbEnabledDisableGroup)

    local thumbDisabledEnableGroup = QF.utils.animation.getAnimationGroup(thumbDisabled)
    QF.utils.animation.fade(thumbDisabled, duration, 1, 0, thumbDisabledEnableGroup)
    QF.utils.animation.move(thumbDisabled, duration, moveBy, 0, thumbDisabledEnableGroup)

    local thumbDisabledDisableGroup = QF.utils.animation.getAnimationGroup(thumbDisabled)
    QF.utils.animation.fade(thumbDisabled, duration, 0, 1, thumbDisabledDisableGroup)
    QF.utils.animation.move(thumbDisabled, duration, -moveBy, 0, thumbDisabledDisableGroup)

    local borderDisabledDisableGroup = QF.utils.animation.getAnimationGroup(borderDisabled)
    QF.utils.animation.fade(borderDisabled, duration, 0, 1, borderDisabledDisableGroup)
    local borderDisabledEnableGroup = QF.utils.animation.getAnimationGroup(borderDisabled)
    QF.utils.animation.fade(borderDisabled, duration, 1, 0, borderDisabledEnableGroup)

    local borderEnabledDisableGroup = QF.utils.animation.getAnimationGroup(borderEnabled)
    QF.utils.animation.fade(borderEnabled, duration, 1, 0, borderEnabledDisableGroup)
    local borderEnabledEnableGroup = QF.utils.animation.getAnimationGroup(borderEnabled)
    QF.utils.animation.fade(borderEnabled, duration, 0, 1, borderEnabledEnableGroup)


    f.Enable = function(self)
        thumbEnabledEnableGroup:Play()
        thumbDisabledEnableGroup:Play()
        borderDisabledEnableGroup:Play()
        borderEnabledEnableGroup:Play()
    end

    f.Disable = function(self)
        thumbEnabledDisableGroup:Play()
        thumbDisabledDisableGroup:Play()
        borderDisabledDisableGroup:Play()
        borderEnabledDisableGroup:Play()
    end

    f.Toggle = function(self)
        f:SetValue('value', not f.value)
    end

    f:Observe('value', function(value, oldValue)
        if (value == oldValue) then
            return
        end

        if (value) then
            f:Enable()
        else
            f:Disable();
        end
    end)

    f:SetScript('OnMouseDown', function(self)
        self:Toggle()
    end)

    local text = f:CreateFontString(nil, 'OVERLAY')
    text:SetWidth(0)
    text:SetFont(QF.default.font, 12, "OUTLINE")
    text:SetPoint("LEFT", base, "RIGHT", 10, 0)
    text:SetText(options.text)

    f.isConfigured = true
end

---@param self ToggleInput
---@param options ToggleOptions
---@param parent FRAME
---@return FRAME
toggle.Get = function(self, options, parent)
    ---@type FRAME
    local input = self.pool:Acquire()
    input.value = false
    if (not input.isConfigured) then
        ConfigureFrame(input, options)
    end

    if (parent) then
        input:SetParent(parent)
    else
        input:SetParent(nil)
    end

    input.Destroy = function(self)
        self.pool:Release(self)
    end

    input:SetValue('value', not not options.value)

    input:Show()
    return input
end
