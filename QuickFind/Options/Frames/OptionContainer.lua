local _, QF = ...
local moduleName = 'frame-option-container'

local optionContainer = QF:GetModule(moduleName)

-- Inputs
local textInput = QF:GetModule('frame-input-text')
local dropdown = QF:GetModule('frame-input-dropdown')

local optionHeight, optionHeightOpen = 50, 170

local typeOptions = {
    [QF.LOOKUP_TYPE.SPELL] = 'Spell',
    [QF.LOOKUP_TYPE.TOY] = 'Toy',
    [QF.LOOKUP_TYPE.ITEM] = 'Item',
    [QF.LOOKUP_TYPE.MOUNT] = 'Mount'
}

optionContainer.init = function(self)
    self.pool = CreateFramePool('Frame', UIParent, nil, function(framePool, frame)
        frame:Hide();
        frame:ClearAllPoints();
        frame.data = {}
        if (frame.created) then
            frame:SetIcon(QF.default.unknownIcon)
            frame:SetTag('Unknown')
            frame:SetText('Unknown')
            frame:SetValue('isOpen', false)
        end
    end)
end

local onValueChange = function(id, key, f)
    return function(value)
        QF:SaveDataByKey(id, key, value);
        f.data[key] = value
        f:SetValue('data', f.data)
    end
end

local function renderLayout(f, inputs)
    local previous
    local index = 0
    local row = 0
    table.sort(inputs, function(a, b) return a.order < b.order end)
    for _, input in ipairs(inputs) do
        input.frame:ClearAllPoints()
        if (not input.depends or input.depends(f.data)) then
            index = index + 1
            if (index > 4 or index == 1) then
                row = index > 4 and row + 1 or row
                index = 1
                input.frame:SetPoint("TOPLEFT", 20, row * -55 + -5)
            else
                input.frame:SetPoint("TOPLEFT", previous, "TOPRIGHT", 25, 0)
            end
            previous = input.frame
            input.frame:Show()
        else
            input.frame:Hide()
        end
    end
end

local function AddOptions(f, data)
    local bodyFrame = f.body
    f.inputTypes = f.inputTypes or {}
    if not bodyFrame.type then
        local input = dropdown:Get({
            label = 'Type',
            initial = data.type,
            options = typeOptions
        }, bodyFrame);
        bodyFrame.type = input
        table.insert(f.inputTypes, {
            frame = input,
            order = 0
        })
    end
    bodyFrame.type.onChange = function(value)
        QF:SaveDataByKey(data.id, 'type', value);
        f.data.type = value
        f:SetValue('data', f.data)
        renderLayout(f, f.inputTypes)
    end
    bodyFrame.type.valueDisplay:SetText(data.type and typeOptions[data.type] or '')


    if not bodyFrame.name then
        local input = textInput:Get({
            label = 'Name',
            initial = data.name
        }, bodyFrame);
        bodyFrame.name = input
        table.insert(f.inputTypes, {
            frame = input,
            order = 10
        })
    end
    bodyFrame.name.onChange = onValueChange(data.id, 'name', f)
    bodyFrame.name.editBox:SetText(data.name or '')

    if not bodyFrame.tags then
        local input = textInput:Get({
            label = 'Tags',
            initial = data.tags
        }, bodyFrame);
        bodyFrame.tags = input
        table.insert(f.inputTypes, {
            frame = input,
            order = 20
        })
    end
    bodyFrame.tags.onChange = onValueChange(data.id, 'tags', f)
    bodyFrame.tags.editBox:SetText(data.tags or '')

    if not bodyFrame.spellId then
        local input = textInput:Get({
            label = 'Spell ID',
            initial = data.spellId
        }, bodyFrame);
        bodyFrame.spellId = input
        table.insert(f.inputTypes, {
            frame = input,
            order = 5,
            depends = function(data)
                if (data.type ~= QF.LOOKUP_TYPE.SPELL) then
                    return false
                end
                return true
            end
        })
    end
    bodyFrame.spellId.onChange = onValueChange(data.id, 'spellId', f)
    bodyFrame.spellId.editBox:SetText(data.spellId or '')

    if not bodyFrame.mountName then
        local input = textInput:Get({
            label = 'Mount Name',
            initial = data.mountName
        }, bodyFrame);
        bodyFrame.mountName = input
        table.insert(f.inputTypes, {
            frame = input,
            order = 5,
            depends = function(data)
                if (data.type ~= QF.LOOKUP_TYPE.MOUNT) then
                    return false
                end
                return true
            end
        })
    end
    bodyFrame.mountName.onChange = onValueChange(data.id, 'mountName', f)
    bodyFrame.mountName.editBox:SetText(data.mountName or '')

    if not bodyFrame.icon then
        local input = textInput:Get({
            label = 'Icon ID',
            initial = data.icon
        }, bodyFrame);
        bodyFrame.icon = input
        table.insert(f.inputTypes, {
            frame = input,
            order = 30,
        })
    end
    bodyFrame.icon.onChange = onValueChange(data.id, 'icon', f)
    bodyFrame.icon.editBox:SetText(data.icon or '')

    if not bodyFrame.itemId then
        local input = textInput:Get({
            label = 'Item ID',
            initial = data.itemId
        }, bodyFrame);
        bodyFrame.itemId = input
        table.insert(f.inputTypes, {
            frame = input,
            order = 5,
            depends = function(data)
                if (data.type ~= QF.LOOKUP_TYPE.ITEM and data.type ~= QF.LOOKUP_TYPE.TOY) then
                    return false
                end
                return true
            end
        })
    end
    bodyFrame.itemId.onChange = onValueChange(data.id, 'itemId', f)
    bodyFrame.itemId.editBox:SetText(data.itemId or '')
    renderLayout(f, f.inputTypes)

    if (not bodyFrame.deleteBtn) then
        local btn = CreateFrame('Button', nil, bodyFrame)
        bodyFrame.deleteBtn = btn
        btn:SetSize(60, 40)
        btn:SetPoint("BOTTOMRIGHT", -30, 25)
        btn:SetFrameLevel(bodyFrame:GetFrameLevel() + 10)

        local textFrame = btn:CreateFontString(nil, "OVERLAY")
        textFrame:SetFont(QF.default.font, 10, "OUTLINE")
        textFrame:SetPoint("CENTER")
        textFrame:SetWidth(0)
        textFrame:SetText('Delete')
        textFrame:SetVertexColor(0.52, 0, 0.04, 1)
        btn.text = textFrame

        local hoverContainer = CreateFrame('Frame', nil, btn)
        hoverContainer:SetAllPoints()
        local hoverBorder = hoverContainer:CreateTexture()
        hoverContainer.border = hoverBorder
        btn.hoverContainer = hoverContainer
        hoverContainer:SetFrameLevel(btn:GetFrameLevel() - 1)
        hoverBorder:SetTexture(QF.default.barBg)
        hoverBorder:SetPoint("TOPLEFT", 0, 8)
        hoverBorder:SetPoint("BOTTOMRIGHT", 0, -8)
        hoverContainer:SetAlpha(0)
        btn.animDur = 0.15
        btn.onHover = QF.utils.animation.fade(hoverContainer, btn.animDur, 0, 1)
        btn.onHoverLeave = QF.utils.animation.fade(hoverContainer, btn.animDur, 1, 0)
        hoverBorder:SetVertexColor(0.52, 0, 0.04, 1)

        btn:SetScript('OnLeave', function(self)
            self.onHoverLeave:Play()
            self.text:SetVertexColor(0.52, 0, 0.04, 1)
        end)
        btn:SetScript('OnEnter', function(self)
            self.onHover:Play()
            self.text:SetVertexColor(1, 1, 1, 1)
        end)
        btn:SetScript('OnClick', function()
            f.onDelete()
        end)

        btn:SetPoint('BOTTOMRIGHT', -12, 5)
    end
end

local function AddOptionBody(f)
    if (not f.created) then
        f:Observe("isOpen", function(isOpen)
            if (isOpen) then
                f:SetHeight(optionHeightOpen)
            else
                f:SetHeight(optionHeight)
            end
        end)
    end

    if (not f.body) then
        local body = CreateFrame("Frame", nil, f)
        body:SetPoint("TOPLEFT", f.bg, "BOTTOMLEFT", 0, 6)
        body:SetPoint("TOPRIGHT", f.bg, "BOTTOMRIGHT", 0, 6)
        body:SetHeight(optionHeightOpen - optionHeight)
        f.body = body

        local bg = body:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetTexture(QF.default.optionBodyBg)
        bg:SetVertexColor(0.05, 0.05, 0.05, 0.6)

        body:Hide()
        f:Observe("isOpen", function(isOpen)
            if (isOpen) then
                body:Show()
            else
                body:Hide()
            end
        end)
    end

    if (not f.created) then
        f:Observe("data", function(data)
            AddOptions(f, data)
        end)
    end
end

local function ConfigureFrame(f)
    if (not f.created) then
        QF.utils.addObserver(f)
        f.isOpen = false
        f:SetHeight(optionHeight)
    end

    if (not f.bg) then
        local bgContainer = CreateFrame("Button", nil, f)
        bgContainer:SetFrameLevel(f:GetFrameLevel() - 1)
        f.bg = bgContainer
        bgContainer:SetPoint("TOPLEFT")
        bgContainer:SetPoint("TOPRIGHT")
        bgContainer:SetHeight(optionHeight)

        bgContainer:SetScript("OnClick", function()
            f:SetValue("isOpen", not f.isOpen)
        end)

        local bg = bgContainer:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetTexture(QF.default.optionOpenBg)
        bg:SetTexture(QF.default.optionClosedBg)
        bg:SetVertexColor(0, 0, 0, 0.6)

        f:Observe("isOpen", function(value)
            bg:SetTexture(value and QF.default.optionOpenBg or QF.default.optionClosedBg)
        end)
    end

    if (not f.icon) then
        local iconContainer = CreateFrame('Frame', nil, f.bg)
        iconContainer:SetSize(26, 26)
        iconContainer:SetPoint('LEFT', 12, 0)
        local icon = iconContainer:CreateTexture()
        icon:SetAllPoints()
        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        icon:SetTexture(134400) -- Default Question Mark

        local mask = iconContainer:CreateMaskTexture()
        mask:SetTexture([[Interface/Addons/QuickFind/Media/Texture/icon-mask]])
        mask:SetAllPoints();

        icon:AddMaskTexture(mask)

        f.icon = iconContainer;
        f.SetIcon = function(_, iconId)
            icon:SetTexture(iconId)
            if not icon:GetTexture() then
                icon:SetTexture(QF.default.unknownIcon)
            end
        end
        f:Observe("data", function(data)
            if (data and data.icon) then
                f:SetIcon(data.icon)
            end
        end)
    end

    if (not f.tag) then
        local tagContainer = CreateFrame('Frame', nil, f.bg)
        tagContainer:SetPoint('LEFT', f.icon, 'RIGHT', 15, 0)
        tagContainer:SetSize(1, 1)

        local tag = tagContainer:CreateFontString(nil, "OVERLAY")
        tag:SetFont(QF.default.font, 9, "OUTLINE")
        tag:SetPoint("LEFT")
        tag:SetWidth(0)

        local tagTexture = tagContainer:CreateTexture()
        tagTexture:SetTexture(QF.default.barBg)
        tagTexture:SetPoint("CENTER")
        tagTexture:SetHeight(35)
        tagTexture:SetPoint('LEFT', tag, -5, 0)
        tagTexture:SetPoint('RIGHT', tag, 5, 0)
        tagTexture:SetVertexColor(0.44, 0, 0.94)
        tag:SetText("Unknown")

        f.tag = tag

        f.SetTag = function(_, tagType)
            tag:SetText(tagType)
            tagTexture:SetVertexColor(unpack(QF.default.tagColors[tagType] or { 0.44, 0, 0.94 }))
        end

        f:Observe("data", function(data)
            if (data and data.type) then
                f:SetTag(data.type)
            end
        end)
    end

    if (not f.text) then
        local textFrame = f:CreateFontString(nil, "OVERLAY")
        textFrame:SetFont(QF.default.font, 14, "OUTLINE")
        textFrame:SetPoint("LEFT", f.tag, "RIGHT", 15, 0)
        textFrame:SetWidth(0)
        f.text = textFrame
        f.SetText = function(_, value) textFrame:SetText(value) end

        f:Observe("data", function(data)
            if (data and data.name) then
                f:SetText(data.name)
            end
        end)
    end

    if (not f.chevron) then
        local chevron = f:CreateTexture(nil, "OVERLAY")
        chevron:SetSize(16, 16)
        chevron:SetPoint("RIGHT", f.bg, -20, 0)
        chevron:SetTexture(QF.default.chevronDown)

        f:Observe("isOpen", function(value)
            if (value) then
                chevron:SetRotation(math.rad(180))
            else
                chevron:SetRotation(math.rad(0))
            end
        end)
    end

    AddOptionBody(f)
    f.created = true
end

optionContainer.CreateOption = function(self, data, onDelete)
    local frame = self.pool:Acquire()
    ConfigureFrame(frame)

    frame:SetValue("data", data)
    frame.onDelete = onDelete
    if (not data.type) then
        frame:SetValue('isOpen', true)
    end
    return frame
end

optionContainer.DestroyOption = function(self, frame)
    self.pool:Release(frame)
end

optionContainer.DestroyAllOptions = function(self)
    self.pool:ReleaseAll()
end
