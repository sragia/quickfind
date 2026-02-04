---@class QF
local QF = select(2, ...)

---@class API
local api = QF:GetModule('api')

api.sources = {}

---@class SourceData
---@field name string
---@field get function
---@field iconPath? string

---@param self API
---@param source SourceData
api.RegisterSource = function (self, source)
    self.sources[source.name] = source
end

---@return SourceData[]
api.GetSources = function (self)
    return self.sources
end

---@param source SourceData
---@return boolean
QuickFind.RegisterSource = function (self, source)
    api:RegisterSource(source)

    return true
end
