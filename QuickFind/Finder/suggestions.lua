local _, QF = ...
local moduleName = 'suggestions'

local finder = QF:GetModule('finder')
local suggestions = QF:GetModule(moduleName)

suggestions.init = function(self)
    self.suggestionContainer = CreateFrame('Frame', 'QFSuggestionsContainer', UIParent)
    self.suggestionContainer:SetSize(1, 1)
    local left, bottom = finder.editBox:GetRect()
    local scale = finder.container:GetScale()
    self.suggestionContainer:SetScale(scale)
    self.suggestionContainer:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left - 25, bottom)

    -- Suggestion Pool
    self.buttonPool = CreateFramePool('BUTTON', self.suggestionContainer, "SecureActionButtonTemplate")

    -- Hide/Show Animations
    self.suggestionContainer.fadeIn = QF.utils.animation.fade(self.suggestionContainer, 0.2, 0, 1)
    self.suggestionContainer.fadeOut = QF.utils.animation.fade(self.suggestionContainer, 0.2, 1, 0.3)
    self.suggestionContainer.fadeOut:SetScript('OnFinished',
        function()
            self.suggestionContainer:Hide()
            self.buttonPool:ReleaseAll()
        end)
    QF.utils.animation.diveIn(self.suggestionContainer, 0.2, 0, 20, 'IN', self.suggestionContainer.fadeIn)
    QF.utils.animation.diveIn(self.suggestionContainer, 0.2, 0, -20, 'OUT', self.suggestionContainer.fadeOut)

    self:AttachToEditBox()
end

suggestions.Hide = function(self)
    if (self.suggestionContainer) then
        self.suggestionContainer.fadeOut:Play()
    end
end

suggestions.Show = function(self)
    if (self.suggestionContainer) then
        self.suggestionContainer:Show()
        self.suggestionContainer.fadeIn:Play()
    end
end

suggestions.Refresh = function(self, value)
    local suggestions = QF.utils.suggestMatch(value, QF.BASE_LOOKUPS)
    self.buttonPool:ReleaseAll()
    for index, suggestion in ipairs(suggestions) do
        if (index > QF.default.maxSuggestions) then
            break
        end
        local f = self.buttonPool:Acquire()
        f:SetPropagateKeyboardInput(true)
        self:ConfigureFrame(f)
        self:SetOnClick(f, suggestion)
        f:SetText(suggestion.data.name)
        f:SetIcon(suggestion.data.icon)
        f:SetTag(suggestion.data.type)
        f:HandleCD(suggestion.data)
        f:Show()

        f:SetPoint("TOPLEFT", self.suggestionContainer, "BOTTOMLEFT", 0, ((index - 1) * -32) - 15)
    end
end

suggestions.ConfigureFrame = function(self, frame)
    frame:SetSize(320, 26)

    if (not frame.bg) then
        -- BG
        local tex = frame:CreateTexture()
        frame.bg = tex
        tex:SetTexture(QF.default.barBg)
        tex:SetVertexColor(0, 0, 0, 0.6)
        tex:SetPoint('CENTER', -80)
        tex:SetHeight(75)
        tex:SetWidth(350)
    end

    if (not frame.icon) then
        local iconContainer = CreateFrame('Frame')
        iconContainer:SetParent(frame)
        iconContainer:SetSize(18, 18)
        iconContainer:SetPoint('LEFT', 5, 0)
        local icon = iconContainer:CreateTexture()
        icon:SetAllPoints()
        icon:SetSize(18, 18)
        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

        local mask = iconContainer:CreateMaskTexture()
        mask:SetTexture([[Interface/Addons/QuickFind/Media/Texture/icon-mask]])
        mask:SetAllPoints();

        icon:AddMaskTexture(mask)

        frame.icon = iconContainer;
        frame.SetIcon = function(_, iconId)
            icon:SetTexture(iconId)
        end
    end

    if (not frame.tag) then
        local tagContainer = CreateFrame('Frame')
        tagContainer:SetParent(frame)
        tagContainer:SetPoint('LEFT', frame.icon, 'RIGHT', 10, 0)
        tagContainer:SetSize(1, 1)

        local tag = tagContainer:CreateFontString(nil, "OVERLAY")
        tag:SetFont(QF.default.font, 6, "OUTLINE")
        tag:SetPoint("LEFT")
        tag:SetWidth(0)

        local tagTexture = tagContainer:CreateTexture()
        tagTexture:SetTexture(QF.default.barBg)
        tagTexture:SetPoint("CENTER")
        tagTexture:SetHeight(23)
        -- tagTexture:SetWidth(31)
        tagTexture:SetPoint('LEFT', tag, -5, 0)
        tagTexture:SetPoint('RIGHT', tag, 5, 0)
        tagTexture:SetVertexColor(0.44, 0, 0.94)

        frame.tag = tag

        frame.SetTag = function(_, tagType)
            tag:SetText(tagType)
        end
    end

    if (not frame.text) then
        local textFrame = frame:CreateFontString(nil, "OVERLAY")
        textFrame:SetFont(QF.default.font, 8, "OUTLINE")
        textFrame:SetPoint("LEFT", frame.tag, "RIGHT", 10, 0)
        textFrame:SetWidth(0)
        frame.text = textFrame
        frame.SetText = function(_, value) textFrame:SetText(value) end
        frame.SetTextColor = function(_, r, g, b, a) textFrame:SetVertexColor(r, g, b, a) end
    end

    if (not frame.hoverBorder) then
        local hoverContainer = CreateFrame('Frame', null, frame)
        hoverContainer:SetAllPoints()
        local hoverBorder = hoverContainer:CreateTexture()
        frame.hoverBorder = hoverBorder
        hoverBorder:SetTexture(QF.default.barBorderGlow)
        hoverBorder:SetVertexColor(1, 0.84, 0, 1)
        hoverBorder:SetPoint('CENTER', -30)
        hoverBorder:SetHeight(75)
        hoverBorder:SetWidth(350)
        hoverContainer:SetAlpha(0)
        local animDur = 0.15
        frame.onHover = QF.utils.animation.fade(hoverContainer, animDur, 0, 1)
        frame.onHoverLeave = QF.utils.animation.fade(hoverContainer, animDur, 1, 0)

        frame:SetScript('OnEnter', function(self)
            self.onHover:Play()
            C_Timer.After(animDur / 2, function() frame:SetTextColor(1, 0.84, 0, 1) end)
            self:SetTextColor(1, 0.84, 0, 1)
        end)
        frame:SetScript('OnLeave', function(self)
            self.onHoverLeave:Play()
            C_Timer.After(animDur / 2, function() frame:SetTextColor(1, 1, 1, 1) end)
        end)
    end

    if (not frame.cdText) then
        local cdText = frame:CreateFontString(nil, "OVERLAY")
        cdText:SetFont(QF.default.font, 8, "OUTLINE")
        cdText:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
        cdText:SetWidth(0)
        frame.cdText = cdText
    else
        frame:SetScript("OnUpdate", null)
        frame.cdText:SetText('')
    end

    frame.HandleCD = function(self, suggestionData)
        local setCDText = function()
            local start, duration = GetSpellCooldown(suggestionData.spellId)
            if (start + duration > GetTime()) then
                self.cdText:SetText('On CD: ' ..
                    WrapTextInColorCode(QF.utils.formatTime(start + duration - GetTime()), "ffc1c1c1"))
                return true
            end
            return false
        end
        local onCD = setCDText()
        if (onCD) then
            frame.elapsed = 0
            frame:SetScript("OnUpdate", function(self, elapsed)
                self.elapsed = self.elapsed + elapsed
                if (self.elapsed >= 1) then
                    local onCD = setCDText()
                    if (not onCD) then
                        self.cdText:SetText('')
                        self:SetScript('OnUpdate', null)
                    end
                    self.elapsed = 0
                end
            end)
        end
    end
end

suggestions.SetOnClick = function(self, frame, suggestion)
    frame:SetAttribute("type", "spell")
    frame:SetAttribute("spell", suggestion.data.spellId)
    frame:SetScript("PostClick", function()
        finder:HideFinder()
    end)
end

suggestions.AttachToEditBox = function(self)
    finder.editBox:SetScript('OnTextChanged', function(editbox, changed)
        if (changed) then
            suggestions:Refresh(editbox:GetText())
        end
    end)
end
