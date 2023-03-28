local _, QF = ...
local moduleName = 'finder'

local finder = QF:GetModule(moduleName)
local suggestions = QF:GetModule('suggestions')

finder.init = function(self)
    self:CreateSearchBox()
    self:CreateEditBox()
end

finder.ShowFinder = function(self)
    if (self.finderFrame) then
        self.editBox:SetText('')
        self.container:Show()
        self.container.fadeIn:Play()
        self.editBox:SetFocus()
        if (suggestions.Show) then
            suggestions:Show()
        end
    end
end

finder.HideFinder = function(self)
    if (self.finderFrame and self.finderFrame:IsShown()) then
        self.container.fadeOut:Play()
        if (suggestions.Hide) then
            suggestions:Hide()
        end
    end
end

finder.CreateSearchBox = function(self)
    local finderFrame = CreateFrame("Frame", 'QFFinder', UIParent)
    self.finderFrame = finderFrame
    finderFrame:SetPropagateKeyboardInput(true)
    finderFrame:SetScript("OnKeyDown", function(_, key)
        if (key == "P" and IsControlKeyDown()) then
            self:ShowFinder()
        end
    end)
    finderFrame:SetPoint("TOP", UIParent, "TOP", 0, -200)
    finderFrame:SetHeight(1)
    finderFrame:SetWidth(1)

    self.container = CreateFrame("Frame", nil, finderFrame)
    self.container:SetAllPoints()
    self.container:Hide()
    self.container.fadeIn = QF.utils.animation.fade(self.container, 0.2, 0, 1)
    self.container.fadeOut = QF.utils.animation.fade(self.container, 0.2, 1, 0.3)
    self.container.fadeOut:SetScript('OnFinished', function() self.container:Hide() end)
    self.container:SetPropagateKeyboardInput(true)
    self.container:SetScale(QF.default.scale)

    QF.utils.animation.diveIn(self.container, 0.2, 0, 20, 'IN', self.container.fadeIn)
    QF.utils.animation.diveIn(self.container, 0.2, 0, -20, 'OUT', self.container.fadeOut)
end

finder.CreateEditBox = function(self)
    local editBox = CreateFrame("EditBox", "QFFinderEditBox", self.container)
    self.editBox = editBox
    editBox:SetFrameStrata("DIALOG")
    editBox:SetAutoFocus(false)
    editBox:SetPoint("TOP", 30)
    editBox:SetWidth(270)
    editBox:SetHeight(23)

    -- BG
    local tex = editBox:CreateTexture(nil, "BACKGROUND", nil, -5)
    tex:SetTexture([[Interface/Addons/QuickFind/Media/Texture/bar]])
    tex:SetVertexColor(0, 0, 0, 0.6)
    tex:SetPoint('CENTER', -30)
    tex:SetHeight(75)
    tex:SetWidth(350)

    -- Icon
    local searchIcon = editBox:CreateTexture(nil, "BACKGROUND", nil, -5)
    searchIcon:SetTexture([[Interface/Addons/QuickFind/Media/Texture/icon-search]])
    searchIcon:SetVertexColor(1, 1, 1, 0.8)
    searchIcon:SetPoint("LEFT", -20, 0)
    searchIcon:SetSize(16, 16)


    editBox:SetFont([[Interface/Addons/QuickFind/Media/Font/Poppins.ttf]], 9, "OUTLINE")


    -- Base logic
    editBox:SetScript("OnEscapePressed", function()
        self:HideFinder()
    end)
    editBox:SetScript("OnEditFocusLost", function()
        self:HideFinder()
    end)
end
