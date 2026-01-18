---@class QF
local QF = select(2, ...)

---@class ExalityFrames
local EXFrames = QF.EXFrames


local welcome = QF:GetModule('welcome-frame')

welcome.window = nil

welcome.Setup = function (self)
    self.window = EXFrames:GetFrame('window-frame'):Create({
        title = 'Welcome to QuickFind',
        size = { 500, 420 }
    })
    self.window:Configure({
        disableResize = true,
    })

    local container = self.window.container

    local title = container:CreateFontString(nil, 'OVERLAY')
    title:SetFont(QF.default.font, 18, 'OUTLINE')
    title:SetPoint('TOP')
    title:SetText('Welcome to QuickFind')

    local description = container:CreateFontString(nil, 'OVERLAY')
    description:SetFont(QF.default.font, 8, 'OUTLINE')
    description:SetVertexColor(0.7, 0.7, 0.7, 1)
    description:SetPoint('TOP', title, 'BOTTOM', 0, -10)
    description:SetText("Don't worry, this is the last time you'll see this window.")

    local openConfigText = container:CreateFontString(nil, 'OVERLAY')
    openConfigText:SetFont(QF.default.font, 12, 'OUTLINE')
    openConfigText:SetPoint('TOP', description, 'BOTTOM', 0, -10)
    openConfigText:SetText('To get started, open the configuration by pressing the button below.')

    local openConfigBtn = EXFrames:GetFrame('button'):Create({
        text = 'Open Configuration',
        onClick = function ()
            QF:GetModule('options-core'):ShowFrame()
        end,
        size = { 200, 30 },
        color = { 185 / 255, 0, 227 / 255, 1 }
    }, container)
    openConfigBtn:SetPoint('TOP', openConfigText, 'BOTTOM', 0, -10)

    local orText = container:CreateFontString(nil, 'OVERLAY')
    orText:SetFont(QF.default.font, 11, 'OUTLINE')
    orText:SetPoint('TOP', openConfigBtn, 'BOTTOM', 0, -10)
    orText:SetText('Or type |cffb900e3/QF|r anytime.')

    local openSuggestionsText = container:CreateFontString(nil, 'OVERLAY')
    openSuggestionsText:SetFont(QF.default.font, 12, 'OUTLINE')
    openSuggestionsText:SetPoint('TOP', orText, 'BOTTOM', 0, -10)
    openSuggestionsText:SetText('To open the suggestions, press |cffb900e3CTRL-P|r.')

    local orChangeKeyText = container:CreateFontString(nil, 'OVERLAY')
    orChangeKeyText:SetFont(QF.default.font, 11, 'OUTLINE')
    orChangeKeyText:SetPoint('TOP', openSuggestionsText, 'BOTTOM', 0, -10)
    orChangeKeyText:SetText(
        'You can change the keybind by opening the configuration settings\n or ingame keybindings menu.')

    local settingsImage = container:CreateTexture(nil, 'OVERLAY')
    settingsImage:SetTexture([[Interface/Addons/QuickFind/Media/Texture/welcome-settings.png]])
    settingsImage:SetPoint('TOP', orChangeKeyText, 'BOTTOM', 0, -10)
    settingsImage:SetSize(280, 280 * 219 / 357)
end

welcome.Show = function (self)
    if (not self.window) then
        self:Setup()
    end

    self.window:ShowWindow()
end
