local _, QF = ...
local moduleName = 'frame-input-button'

local button = QF:GetModule(moduleName)

button.init = function(self)
    self.pool = CreateFramePool('Button', UIParent)
end

local function ConfigureFrame(f, options)
    QF.utils.addObserver(f)
    f:SetSize(
        options.width or 205,
        options.height or 70
    )
    f.onClick = options.onClick

    f:SetScript('OnClick', function()
        f.onClick()
    end)

    if not f.text and options.text then
        f.text = f:CreateFontString(nil, "OVERLAY")
        f.text:SetFont(QF.default.font, 10, "OUTLINE")
        f.text:SetPoint("CENTER")
        f.text:SetWidth(0)
        f.text:SetText(options.text)
        f.text:SetVertexColor(1, 1, 1, 1)
    end

    if not f.hover then
        f.hover = CreateFrame('Frame', nil, f)
        f.hover:SetAllPoints()
        local hoverBorder = f.hover:CreateTexture()
        f.hover:SetFrameLevel(f:GetFrameLevel() - 1)
        hoverBorder:SetTexture(QF.default.barBg)
        hoverBorder:SetPoint("TOPLEFT", 0, 8)
        hoverBorder:SetPoint("BOTTOMRIGHT", 0, -8)
        f.hover:SetAlpha(0.15)
        f.animDur = 0.15
        f.onHover = QF.utils.animation.fade(f.hover, f.animDur, 0.15, 1)
        f.onHoverLeave = QF.utils.animation.fade(f.hover, f.animDur, 1, 0.15)
        hoverBorder:SetVertexColor(1, 0.84, 0, 1)

        f:SetScript('OnLeave', function(self)
            self.onHoverLeave:Play()
        end)
        f:SetScript('OnEnter', function(self)
            self.onHover:Play()
        end)
    end
end



button.Get = function(self, options, parent)
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
