local _, QF = ...
local moduleName = 'frame-input-button'

---@class ButtonOptions : {text: string, width: number, height: number, onClick: function, startAlpha: number, endAlpha: number}

---@class ButtonInput
local button = QF:GetModule(moduleName)

button.init = function(self)
    self.pool = CreateFramePool('Button', UIParent)
end

---@param f Frame
---@param options ButtonOptions
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
        f.hover:SetAlpha(options.startAlpha or 0.15)
        f.animDur = 0.15
        f.onHover = QF.utils.animation.fade(f.hover, f.animDur, options.startAlpha or 0.15, options.endAlpha or 1)
        f.onHoverLeave = QF.utils.animation.fade(f.hover, f.animDur, options.endAlpha or 1, options.startAlpha or 0.15)
        hoverBorder:SetVertexColor(1, 0.84, 0, 1)

        f:SetScript('OnLeave', function(self)
            self.onHoverLeave:Play()
        end)
        f:SetScript('OnEnter', function(self)
            self.onHover:Play()
        end)
    end
end


---comment
---@param self ButtonInput
---@param options ButtonOptions
---@param parent Frame?
---@return Frame
button.Get = function(self, options, parent)
    local input = self.pool:Acquire()
    ConfigureFrame(input, options)
    if (parent) then
        input:SetParent(parent)
        input:SetFrameLevel(parent:GetFrameLevel() + 5)
    else
        input:SetParent(nil)
    end
    input.Destroy = function(self)
        self.pool:Release(self)
    end
    input:Show()
    return input
end
