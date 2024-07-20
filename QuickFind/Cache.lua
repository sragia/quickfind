---@class QF
local QF = select(2, ...)

local moduleName = 'cache'

---@class Cache
local cache = QF:GetModule(moduleName)

---Have spell data in cache
---@param self Cache
---@param spellID number
---@return boolean
cache.hasSpell = function (self, spellID)
    return QF.cache.spells[spellID] and true or false
end

--- Get Spell Data from Cache
---@param self Cache
---@param spellID number
---@return table|false
cache.getSpellData = function (self, spellID)
    local data = QF.cache.spells[spellID]
    if (not data) then
        return false
    end

    return data
end

---Save spell data into cache
---@param self Cache
---@param spellID number
---@param data table
cache.saveSpellData = function (self, spellID, data)
    QF.cache.spells[spellID] = data
end

---Save toy data into cache
---@param self Cache
---@param toyID any
---@param data any
cache.saveToyData = function (self, toyID, data)
    QF.cache.toys[toyID] = data
end

---Get toy data from cache
---@param self Cache
---@param toyID any
cache.getToyData = function (self, toyID)
    local data = QF.cache.toys[toyID]
    if (not data) then
        return false
    end

    return data
end
