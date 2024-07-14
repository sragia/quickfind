local _, QF = ...
local moduleName = 'frame-window'

local window = QF:GetModule(moduleName)

window.init = function(self)
    window.pool = CreateFramePool('Frame', UIParent)
end

local configureFrame = function(frame)
    frame:SetSize(1000, 500)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:EnableMouse(true)
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("DIALOG")
    frame:SetResizable(true)

    frame.fadeIn = QF.utils.animation.fade(frame, 0.2, 0, 1)
    frame.fadeOut = QF.utils.animation.fade(frame, 0.2, 1, 0)
    frame.fadeOut:SetScript('OnFinished', function() frame:Hide() end)
    QF.utils.animation.diveIn(frame, 0.2, 0, 20, 'IN', frame.fadeIn)
    QF.utils.animation.diveIn(frame, 0.2, 0, -20, 'OUT', frame.fadeOut)

    frame.ShowWindow = function(self)
        self:Show()
        self.fadeIn:Play()
    end

    frame.HideWindow = function(self)
        self.fadeOut:Play()
    end

    if (not frame.Texture) then
        local bg = frame:CreateTexture()
        frame.Texture = bg
        bg:SetTexture(QF.default.windowBg)
        bg:SetVertexColor(0, 0, 0, 0.6)
        bg:SetTextureSliceMargins(35, 35, 35, 35)
        bg:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
        bg:SetAllPoints()
    end

    if (not frame.resizeBtn) then
        local resizeBtn = CreateFrame("Button", nil, frame, "PanelResizeButtonTemplate");
        frame.resizeBtn = resizeBtn
        resizeBtn:SetPoint("BOTTOM")
        resizeBtn:SetSize(40, 10)
        resizeBtn:SetNormalTexture(QF.default.expandBtn)
        resizeBtn:SetHighlightTexture(QF.default.expandBtnHighlight)
        resizeBtn:Init(frame, 1000, 500, 1000, 1200);
    end


    if (not frame.title) then
        local title = frame:CreateFontString(nil, "OVERLAY")
        title:SetFont(QF.default.font, 11, "OUTLINE")
        title:SetPoint("TOP", 0, -25)

        frame.title = title

        frame.SetTitle = function(self, text)
            title:SetText(text)
        end
    end

    if (not frame.logo) then
        local logo = CreateFrame('Frame', nil, frame)
        logo:SetSize(99, 34)
        logo:SetPoint("TOPLEFT", frame, 11, -13.5)
        frame.logo = logo

        local bg = logo:CreateTexture()
        bg:SetTexture(QF.default.logoBg)
        bg:SetVertexColor(255, 255, 255, 1)
        bg:SetTexCoord(0.1, 0.9, 0.23, 0.77)
        bg:SetAllPoints()

        local name = logo:CreateFontString(nil, "OVERLAY")
        name:SetFont(QF.default.font, 11)
        name:SetPoint("CENTER")
        name:SetText("QuickFind")
        name:SetVertexColor(0, 0, 0, 1)
    end

    if (not frame.close) then
        local closeContainer = CreateFrame("Button", nil, frame)
        closeContainer:SetSize(44, 34)
        closeContainer:SetPoint("TOPRIGHT", -12, -15)

        local withSettings = closeContainer:CreateTexture(nil, "BACKGROUND")
        withSettings:SetTexture(QF.default.closeWithSettings)
        withSettings:SetVertexColor(0.701, 0.043, 0.243, 0.6)
        withSettings:SetTexCoord(0.14, 0.86, 0.23, 0.77)
        withSettings:SetAllPoints()
        withSettings:Hide()


        local withoutSettings = closeContainer:CreateTexture(nil, "BACKGROUND")
        withoutSettings:SetTexture(QF.default.closeNoSettings)
        withoutSettings:SetVertexColor(0.701, 0.043, 0.243, 0.6)
        withoutSettings:SetTexCoord(0.14, 0.86, 0.23, 0.77)
        withoutSettings:SetAllPoints()
        withoutSettings:Hide()

        local closeIcon = closeContainer:CreateTexture(nil, "OVERLAY")
        closeIcon:SetPoint("CENTER")
        closeIcon:SetTexture(QF.default.closeIcon)
        closeIcon:SetVertexColor(255, 255, 255, 1)
        closeIcon:SetSize(13, 13)

        frame.SetCloseStyle = function(_, hasSettings)
            if (hasSettings) then
                withoutSettings:Hide()
                withSettings:Show()
            else
                withoutSettings:Show()
                withSettings:Hide()
            end
        end

        closeContainer:EnableMouse(true)
        closeContainer:SetMouseClickEnabled()
        closeContainer:SetScript("OnClick", function()
            if (frame:IsShown()) then
                frame:HideWindow()
            end
        end)
        closeContainer:SetScript("OnEnter", function(_)
            withoutSettings:SetVertexColor(0.751, 0.093, 0.293, 1)
            withSettings:SetVertexColor(0.751, 0.093, 0.293, 1)
        end)
        closeContainer:SetScript("OnLeave", function(_)
            withoutSettings:SetVertexColor(0.701, 0.043, 0.243, 0.6)
            withSettings:SetVertexColor(0.701, 0.043, 0.243, 0.6)
        end)
    end

    if (not frame.settingBtn) then
        local settingContainer = CreateFrame("Button", nil, frame)
        settingContainer:SetSize(99, 36)
        settingContainer:SetPoint("TOPRIGHT", -54, -15)
        frame.settingBtn = settingContainer


        local bg = settingContainer:CreateTexture(nil, "BACKGROUND")
        bg:SetTexture(QF.default.settingsBg)
        bg:SetVertexColor(0, 0, 0, 0.6)
        bg:SetTexCoord(0.1, 0.9, 0.21, 0.79)
        bg:SetAllPoints()

        local text = settingContainer:CreateFontString(nil, "OVERLAY")
        text:SetFont(QF.default.font, 11)
        text:SetPoint("LEFT", 15, 1)
        text:SetText("Settings")
        text:SetVertexColor(1, 1, 1, 1)


        local icon = settingContainer:CreateTexture(nil, "OVERLAY")
        icon:SetPoint("LEFT", text, "RIGHT", 3, 0)
        icon:SetTexture(QF.default.settingsIcon)
        icon:SetVertexColor(255, 255, 255, 1)
        icon:SetSize(18, 18)

        settingContainer:Hide()

        settingContainer:SetScript("OnEnter", function()
            bg:SetVertexColor(0.1, 0.1, 0.1, 0.6)
        end)
        settingContainer:SetScript("OnLeave", function()
            bg:SetVertexColor(0, 0, 0, 0.6)
        end)
    end

    if (not frame.container) then
        local container = CreateFrame("Frame", nil, frame)
        frame.container = container
        container:SetPoint("TOPLEFT", 30, -65)
        container:SetPoint("BOTTOMRIGHT", -30, 30)
    end

    frame.ShowSettingsBtn = function(self, show, onSettingsClick)
        self:SetCloseStyle(show)
        if (onSettingsClick) then
            self.settingBtn:SetScript("OnMouseUp", onSettingsClick)
        end
        if (show) then
            self.settingBtn:Show()
        end
    end
end


window.getFrame = function(self, config)
    local f = window.pool:Acquire()
    configureFrame(f)
    f:ShowSettingsBtn(config.showSettings, config.onSettingsClick)
    if (config.frameLevel) then
        f:SetFrameLevel(config.frameLevel)
    end

    if (config.offset) then
        f:SetPoint("CENTER", config.offset.x, config.offset.y)
    end

    f:SetTitle(config.title)
    return f
end
