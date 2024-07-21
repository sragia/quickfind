---@class QF
local QF = select(2, ...)

local moduleName = 'frame-input-tooltip'

---@class TooltipOptions : {text: string}

---@class TooltipInput
local tooltip = QF:GetModule(moduleName)
tooltip.pool = {}

tooltip.init = function (self)
    self.pool = CreateFramePool('Frame', UIParent)
end

---@param f Frame
local function ConfigureFrame(f)
    QF.utils.addObserver(f)
    f:SetSize(1, 1)
    f:SetFrameStrata('TOOLTIP')
    local text = f:CreateFontString(nil, 'OVERLAY')
    text:SetFont(QF.default.font, 10, 'OUTLINE')
    text:SetVertexColor(1, 1, 1, 1)
    text:SetPoint('CENTER')
    text:SetWidth(0)

    f.SetText = function (self, value)
        text:SetText(value)
    end

    local bg = f:CreateTexture()
    bg:SetTexture(QF.default.barBg)
    bg:SetPoint('TOPLEFT', text, -15, 25)
    bg:SetPoint('BOTTOMRIGHT', text, 15, -25)
    bg:SetVertexColor(0, 0, 0, 0.5)

    local showAG = QF.utils.animation.getAnimationGroup(f)
    QF.utils.animation.diveIn(f, 0.2, 0, 10, 'IN', showAG)
    QF.utils.animation.fade(f, 0.2, 0.2, 1, showAG)
    local hideAG = QF.utils.animation.getAnimationGroup(f)
    QF.utils.animation.diveIn(f, 0.2, 0, -10, 'OUT', hideAG)
    QF.utils.animation.fade(f, 0.2, 1, 0, hideAG)
    hideAG:SetScript('OnFinished', function () f:Hide() end)

    f.ShowTooltip = function (self)
        self:Show()
        showAG:Play()
    end

    f.HideTooltip = function (self)
        hideAG:Play()
    end

    f:Hide()
    f.isConfigured = true
end

---@param self TooltipInput
---@param options TooltipOptions
---@param parent FRAME
---@return FRAME
tooltip.Get = function (self, options, parent)
    ---@type FRAME
    local tooltip = self.pool:Acquire()
    if (not tooltip.isConfigured) then
        ConfigureFrame(tooltip)
    end

    if (parent) then
        tooltip:SetPoint('BOTTOM', parent, 'TOP', 0, 15)
    end

    tooltip:SetText(options.text)

    tooltip.Destroy = function (self)
        tooltip.pool:Release(self)
    end

    return tooltip
end
