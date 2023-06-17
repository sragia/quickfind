local _, QF = ...
local moduleName = 'suggestions'

local finder = QF:GetModule('finder')
local suggestions = QF:GetModule(moduleName)

suggestions.init = function(self)
    self.suggestionContainer = CreateFrame('Frame', 'QFSuggestionsContainer', UIParent)
    self.suggestionContainer:SetSize(1, 1)

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
        local left, bottom = finder.editBox:GetRect()
        local scale = finder.container:GetScale()
        self.suggestionContainer:SetScale(scale)
        self.suggestionContainer:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left - 25, bottom - 15)
        self.suggestionContainer:Show()
        self.suggestionContainer.fadeIn:Play()
    end
end

suggestions.Refresh = function(self, value)
    local suggestions = QF.utils.suggestMatch(value, QF.data)
    self.buttonPool:ReleaseAll()
    for index, suggestion in ipairs(suggestions) do
        if (index > QF.default.maxSuggestions) then
            break
        end
        local f = self.buttonPool:Acquire()
        f:SetPropagateKeyboardInput(true)
        self:ConfigureFrame(f)
        f.index = index
        f.suggestion = suggestion
        self:SetOnClick(f, suggestion)
        f:init()
        f:Show()

        f:SetPoint("TOPLEFT", self.suggestionContainer, "BOTTOMLEFT", 0, ((index - 1) * -32) - 15)
    end
end

suggestions.ConfigureFrame = function(self, frame)
    frame:SetSize(320, 26)
    frame.hoverColor = { 1, 0.84, 0, 1 }
    frame.isDisabledColor = { 0.30, 0.30, 0.30, 1 }
    frame.isDisabled = false

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
        frame.SetDesatured = function(self, value)
            icon:SetDesaturated(value)
        end
    end
    frame:SetDesatured(false)

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
            tagTexture:SetVertexColor(unpack(QF.default.tagColors[tagType]))
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

    if (not frame.hoverContainer) then
        local hoverContainer = CreateFrame('Frame', nil, frame)
        hoverContainer:SetAllPoints()
        local hoverBorder = hoverContainer:CreateTexture()
        hoverContainer.border = hoverBorder
        frame.hoverContainer = hoverContainer
        hoverBorder:SetTexture(QF.default.barBorderGlow)
        hoverBorder:SetPoint('CENTER', -30)
        hoverBorder:SetHeight(75)
        hoverBorder:SetWidth(350)
        hoverContainer:SetAlpha(0)
        frame.animDur = 0.15
        frame.onHover = QF.utils.animation.fade(hoverContainer, frame.animDur, 0, 1)
        frame.onHoverLeave = QF.utils.animation.fade(hoverContainer, frame.animDur, 1, 0)
        frame.SetHoverColor = function(self)
            hoverBorder:SetVertexColor(unpack(self.hoverColor))
        end
        frame:SetHoverColor()
    end

    if (not frame.cdText) then
        local cdText = frame:CreateFontString(nil, "OVERLAY")
        cdText:SetFont(QF.default.font, 8, "OUTLINE")
        cdText:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
        cdText:SetWidth(0)
        frame.cdText = cdText
    else
        frame:SetScript("OnUpdate", nil)
        frame.cdText:SetText('')
    end

    if (not frame.notAvailable) then
        local notAvailable = frame:CreateFontString(nil, "OVERLAY")
        notAvailable:SetFont(QF.default.font, 8, "OUTLINE")
        notAvailable:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
        notAvailable:SetWidth(0)
        notAvailable:SetVertexColor(0.54, 0.54, 0.54, 1)
        notAvailable:SetText("Not Available")
        frame.notAvailable = notAvailable
    end
    frame.notAvailable:Hide()

    frame.HandleCD = function(self, suggestionData)
        local setCDText = function()
            local start, duration = 0, 0
            if suggestionData.type == QF.LOOKUP_TYPE.SPELL then
                start, duration = GetSpellCooldown(suggestionData.spellId)
            elseif suggestionData.type == QF.LOOKUP_TYPE.ITEM or suggestionData.type == QF.LOOKUP_TYPE.TOY then
                start, duration = GetItemCooldown(suggestionData.itemId)
            end

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
                        self:SetScript('OnUpdate', nil)
                    end
                    self.elapsed = 0
                end
            end)
        end
    end

    frame.SetSelected = function(self, value, noAnim)
        if (value) then
            if (noAnim) then
                self.hoverContainer:SetAlpha(1)
                self:SetTextColor(unpack(self.hoverColor))
            else
                self.onHover:Play()
                C_Timer.After(self.animDur / 2, function() frame:SetTextColor(unpack(self.hoverColor)) end)
            end
            _G['QFSelectedSuggestion'] = self
        else
            if (noAnim) then
                self.hoverContainer:SetAlpha(0)
                if (self.isDisabled) then
                    frame:SetTextColor(unpack(frame.isDisabledColor))
                else
                    frame:SetTextColor(1, 1, 1, 1)
                end
            else
                self.onHoverLeave:Play()
                C_Timer.After(self.animDur / 2,
                    function()
                        if (self.isDisabled) then
                            frame:SetTextColor(unpack(frame.isDisabledColor))
                        else
                            frame:SetTextColor(1, 1, 1, 1)
                        end
                    end
                )
            end
        end

        self.selected = value
    end

    frame.SetDisabled = function(self)
        self.isDisabled = true
        self.notAvailable:Show()
        self.hoverColor = { 0.54, 0.54, 0.54, 1 }
        self:SetTextColor(unpack(self.isDisabledColor))
        self:SetHoverColor()
        self:SetDesatured(true)
    end

    frame:SetScript("OnEnter", function(self) self:SetSelected(true) end)
    frame:SetScript("OnLeave", function(self) self:SetSelected(false) end)

    frame.init = function(self)
        local data = self.suggestion.data
        self:SetText(data.name)
        self:SetIcon(data.icon)
        self:SetTag(data.type)
        self:HandleCD(data)
        self:SetHoverColor()
        self:SetTextColor(1, 1, 1, 1)

        if (data.type == QF.LOOKUP_TYPE.SPELL) then
            if (not IsSpellKnown(data.spellId)) then
                self:SetDisabled()
            end
        elseif (data.type == QF.LOOKUP_TYPE.ITEM) then
            if (GetItemCount(data.itemId) <= 0) then
                self:SetDisabled()
            end
        end
    end
end

suggestions.SetOnClick = function(self, frame, suggestion)
    if (suggestion.data.type == QF.LOOKUP_TYPE.TOY or suggestion.data.type == QF.LOOKUP_TYPE.ITEM) then
        frame:SetAttribute("type", "item")
        local itemName = GetItemInfo(suggestion.data.itemId)
        frame:SetAttribute("item", itemName)
    elseif (suggestion.data.type == QF.LOOKUP_TYPE.SPELL) then
        frame:SetAttribute("type", "spell")
        frame:SetAttribute("spell", suggestion.data.spellId)
    end
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
