local _, QF = ...
local moduleName = 'finder'

local finder = QF:GetModule(moduleName)
local suggestions = QF:GetModule('suggestions')

finder.style = {
    [QF.styles.DEFAULT] = {
        width = 270,
        height = 23,
        point = { 'TOP', 30 },
        bgColor = { 0, 0, 0, 0.6 },
        bgTexture = [[Interface/Addons/QuickFind/Media/Texture/bar]],
        bgSliceMargins = { 0, 0, 0, 0 },
        bgSliceMode = Enum.UITextureSliceMode.Stretched,
        bgHeight = 75,
        bgWidth = 350,
        bgPoint = { 'CENTER', -30 },
        iconPoint = { 'LEFT', -20, 0 },
        iconSize = 16,
        iconColor = { 1, 1, 1, 0.8 },
        iconTexture = [[Interface/Addons/QuickFind/Media/Texture/icon-search]],
        showBorder = false
    },
    [QF.styles.COMPACT] = {
        width = 260,
        height = 20,
        point = { 'CENTER', 15, 0 },
        bgColor = { 0, 0, 0, 0.6 },
        bgTexture = QF.textures.styles.compact.background,
        bgSliceMargins = { 5, 5, 5, 5 },
        bgSliceMode = Enum.UITextureSliceMode.Stretched,
        bgHeight = 20,
        bgWidth = 270,
        bgPoint = { 'CENTER', -15, 0 },
        iconPoint = { 'LEFT', -15, 0 },
        iconSize = 12,
        iconColor = { 1, 1, 1, 0.8 },
        iconTexture = [[Interface/Addons/QuickFind/Media/Texture/icon-search]],
        showBorder = true,
        borderTexture = QF.textures.styles.compact.border,
        borderColor = { 0, 0, 0, 1 },
        borderPoint = { 'CENTER', -15, 0 },
        borderHeight = 20,
        borderWidth = 270,
        borderSliceMargins = { 5, 5, 5, 5 },
        borderSliceMode = Enum.UITextureSliceMode.Stretched,
    }
}

finder.init = function (self)
    self:CreateSearchBox()
    self:CreateEditBox()
    self:Style()

    QF.settings:Observe('style', function ()
        self:Style()
    end)
end

finder.ShowFinder = function (self)
    if (self.finderFrame and not InCombatLockdown()) then
        self.editBox:SetText('')
        self.container:Show()
        self.container.fadeIn:Play()
        self.container:SetScale(QF.settings.scale)
        self.editBox:SetFocus()
        if (suggestions.Show) then
            suggestions:Show()
        end
    end
end

finder.HideFinder = function (self)
    if (self.finderFrame and self.finderFrame:IsShown()) then
        self.container.fadeOut:Play()
        if (suggestions.Hide) then
            suggestions:Hide()
        end
    end
end

finder.CreateSearchBox = function (self)
    local finderFrame = CreateFrame('Frame', 'QFFinder', UIParent)
    self.finderFrame = finderFrame

    QuickFind.OpenSuggestions = function ()
        self:ShowFinder()
    end
    finderFrame:SetPoint('TOP', UIParent, 'TOP', 0, -200)
    finderFrame:SetHeight(1)
    finderFrame:SetWidth(1)

    self.container = CreateFrame('Frame', nil, finderFrame)
    self.container:RegisterEvent('PLAYER_REGEN_DISABLED')
    self.container:SetScript('OnEvent', function (self, event)
        if (event == 'PLAYER_REGEN_DISABLED') then
            self:Hide()
        end
    end)
    self.container:SetAllPoints()
    self.container:Hide()
    self.container.fadeIn = QF.utils.animation.fade(self.container, 0.2, 0, 1)
    self.container.fadeOut = QF.utils.animation.fade(self.container, 0.2, 1, 0.3)
    self.container.fadeOut:SetScript('OnFinished', function () self.container:Hide() end)
    self.container:SetPropagateKeyboardInput(true)
    self.container:SetScale(QF.settings.scale)

    QF.utils.animation.diveIn(self.container, 0.2, 0, 20, 'IN', self.container.fadeIn)
    QF.utils.animation.diveIn(self.container, 0.2, 0, -20, 'OUT', self.container.fadeOut)
end

finder.CreateEditBox = function (self)
    local editBox = CreateFrame('EditBox', 'QFFinderEditBox', self.container)
    self.editBox = editBox
    editBox:SetFrameStrata('DIALOG')
    editBox:SetAutoFocus(false)
    editBox:SetPoint('TOP', 30)
    editBox:SetWidth(270)
    editBox:SetHeight(23)

    -- BG
    local tex = editBox:CreateTexture(nil, 'BACKGROUND', nil, -5)
    tex:SetTexture([[Interface/Addons/QuickFind/Media/Texture/bar]])
    tex:SetTextureSliceMargins(0, 0, 0, 0)
    tex:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
    tex:SetVertexColor(0, 0, 0, 0.6)
    tex:SetPoint('CENTER', -30)
    tex:SetHeight(75)
    tex:SetWidth(350)
    editBox.Background = tex

    local border = editBox:CreateTexture(nil, 'BACKGROUND', nil, -5)
    border:SetTexture(QF.textures.styles.compact.border)
    border:SetVertexColor(1, 1, 1, 1)
    border:SetTextureSliceMargins(0, 0, 0, 0)
    border:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
    border:SetPoint('CENTER', -30)
    border:SetHeight(75)
    border:SetWidth(350)
    editBox.Border = border
    border:Hide()

    -- Icon
    local searchIcon = editBox:CreateTexture(nil, 'BACKGROUND', nil, -5)
    searchIcon:SetTexture([[Interface/Addons/QuickFind/Media/Texture/icon-search]])
    searchIcon:SetVertexColor(1, 1, 1, 0.8)
    searchIcon:SetPoint('LEFT', -20, 0)
    searchIcon:SetSize(16, 16)
    editBox.SearchIcon = searchIcon


    editBox:SetFont([[Interface/Addons/QuickFind/Media/Font/Poppins.ttf]], 9, 'OUTLINE')


    -- Base logic
    editBox:SetScript('OnKeyDown', function (self, key)
        self:SetPropagateKeyboardInput(key == 'ENTER')
        if (key == 'TAB' or key == 'DOWN') then
            suggestions:SelectNext()
        elseif (key == 'UP') then
            suggestions:SelectNext(true)
        end
    end)
    editBox:SetScript('OnEscapePressed', function ()
        self:HideFinder()
    end)
    editBox:SetScript('OnEditFocusLost', function ()
        self:HideFinder()
    end)
end

finder.Style = function (self)
    if (self.editBox) then
        local style = self.style[QF.settings.style]
        if (style) then
            self.editBox:SetWidth(style.width)
            self.editBox:SetHeight(style.height)
            self.editBox:SetPoint(unpack(style.point))
            self.editBox.Background:SetVertexColor(unpack(style.bgColor))
            self.editBox.Background:SetTexture(style.bgTexture)
            self.editBox.Background:SetHeight(style.bgHeight)
            self.editBox.Background:SetWidth(style.bgWidth)
            self.editBox.Background:SetPoint(unpack(style.bgPoint))
            self.editBox.Background:SetTextureSliceMargins(unpack(style.bgSliceMargins))
            self.editBox.Background:SetTextureSliceMode(style.bgSliceMode)
            self.editBox.SearchIcon:SetSize(style.iconSize, style.iconSize)
            self.editBox.SearchIcon:SetVertexColor(unpack(style.iconColor))
            self.editBox.SearchIcon:SetTexture(style.iconTexture)
            self.editBox.SearchIcon:SetPoint(unpack(style.iconPoint))

            if (style.showBorder) then
                self.editBox.Border:SetTexture(style.borderTexture)
                self.editBox.Border:SetVertexColor(unpack(style.borderColor))
                self.editBox.Border:SetTextureSliceMargins(unpack(style.borderSliceMargins))
                self.editBox.Border:SetTextureSliceMode(style.borderSliceMode)
                self.editBox.Border:SetPoint(unpack(style.borderPoint))
                self.editBox.Border:SetHeight(style.borderHeight)
                self.editBox.Border:SetWidth(style.borderWidth)
                self.editBox.Border:Show()
            else
                self.editBox.Border:Hide()
            end
        end
    end
end
