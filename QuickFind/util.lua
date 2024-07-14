local _, QF = ...

QF.utils = {
    suggestMatch = function(userInput, source)
        local suggestions = {}
        for _, data in pairs(source) do
            local matchinString = (data.name or '') .. ',' .. (data.tags or '')
            local matchStart, matchEnd = string.find(string.lower(matchinString), string.lower(userInput), 1, true)
            if matchStart ~= nil then
                table.insert(suggestions,
                    {
                        str = matchinString,
                        score = matchEnd - matchStart + 1 + (matchStart - 1) / #matchinString,
                        data = data
                    })
            else
                local words = {}
                for word in string.gmatch(string.lower(userInput), "%S+") do
                    table.insert(words, word)
                end
                local pattern = ""
                for j = 1, #words do
                    pattern = pattern .. words[j] .. "%S*"
                end
                local phraseStart, phraseEnd = string.find(string.lower(matchinString), pattern, 1, true)
                if phraseStart ~= nil then
                    table.insert(suggestions, {
                        str = matchinString,
                        score = phraseEnd - phraseStart + 1 +
                            (phraseStart - 1) / #matchinString,
                        data = data
                    })
                end
            end
        end
        table.sort(suggestions, function(a, b) return a.score < b.score end)
        return suggestions
    end,
    transformSource = function(source)
        local t = {}
        for _, v in pairs(source) do
            table.insert(t, v.name .. ',' .. v.tags)
        end

        return t
    end,
    spairs = function(t, order)
        -- collect the keys
        local keys = {}
        for k in pairs(t) do
            keys[#keys + 1] = k
        end

        -- if order function given, sort by it by passing the table and keys a, b,
        -- otherwise just sort the keys
        if order then
            table.sort(
                keys,
                function(a, b)
                    return order(t, a, b)
                end
            )
        else
            table.sort(keys)
        end

        -- return the iterator function
        local i = 0
        return function()
            i = i + 1
            if keys[i] then
                return keys[i], t[keys[i]]
            end
        end
    end,
    generateNewId = function(length)
        local randCharSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        length = length or 10
        local output = ""
        for i = 1, length do
            local rand = math.random(#randCharSet)
            output = output .. string.sub(randCharSet, rand, rand)
        end
        return not QF.data[output] and output or QF.utils.generateNewId(length)
    end,
    animation = {
        fade = function(f, duration, from, to, ag)
            ag = ag or f:CreateAnimationGroup()
            local fade = ag:CreateAnimation("Alpha")
            fade:SetFromAlpha(from or 0)
            fade:SetToAlpha(to or 1)
            fade:SetDuration(duration or 1)
            fade:SetSmoothing((from > to) and "OUT" or "IN")
            ag:SetScript(
                "OnFinished",
                function()
                    f:SetAlpha(to)
                end
            )
            return ag
        end,
        diveIn = function(f, duration, xOff, yOff, smoothing, ag)
            ag = ag or f:CreateAnimationGroup()
            local translate = ag:CreateAnimation('Translation')
            translate:SetOffset(xOff, -yOff)
            translate:SetDuration(duration)
            translate:SetSmoothing(smoothing)
            ag:SetScript("OnPlay", function()
                if (smoothing == "OUT") then
                    return
                end

                for i = 1, f:GetNumPoints() do
                    local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint(i)
                    f:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs + yOff)
                end
            end)
            local finishScript = ag:GetScript("OnFinished")
            ag:SetScript("OnFinished", function(...)
                if (finishScript) then finishScript(...) end

                if (smoothing == "OUT") then
                    return
                end

                for i = 1, f:GetNumPoints() do
                    local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint(i)
                    f:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs - yOff)
                end
            end)

            return ag
        end
    },
    formatTime = function(time)
        if not time then
            return ""
        end
        local days = math.floor(time / (60 * 60 * 24))
        time = time - days * (60 * 60 * 24)
        local hours = math.floor(time / (60 * 60))
        time = time - hours * (60 * 60)
        local minutes = math.floor((time) / 60)
        local seconds = time % 60
        if days > 0 then
            return string.format("%dd %02d:%02d:%02d", days, hours, minutes, seconds)
        elseif hours > 0 then
            return string.format("%02d:%02d:%02d", hours, minutes, seconds)
        end
        return string.format("%02d:%02d", minutes, seconds)
    end,
    addObserver = function(t)
        if (t.observable) then
            return t
        end

        t.observable = {}
        t.Observe = function(_, key, onChangeFunc)
            if (type(key) == 'table') then
                for _, k in ipairs(key) do
                    t.observable[k] = t.observable[k] or {}
                    table.insert(t.observable[k], onChangeFunc)
                end
            else
                t.observable[key] = t.observable[key] or {}
                table.insert(t.observable[key], onChangeFunc)
            end
        end
        t.SetValue = function(_, key, value)
            t[key] = value
            if (t.observable[key]) then
                for _, func in ipairs(t.observable[key]) do
                    func(value)
                end
            end
        end

        return t
    end,
    tableMerge = function(t1, t2, rewriteArrays)
        for k, v in pairs(t2) do
            if type(v) == "table" then
                if type(t1[k] or false) == "table" then
                    if (rewriteArrays and isArray(t2[k])) then
                        t1[k] = v
                    else
                        tableMerge(t1[k] or {}, t2[k] or {}, rewriteArrays)
                    end
                else
                    t1[k] = v
                end
            else
                t1[k] = v
            end
        end
        return t1
    end
}
