---------------------------------------------------------------------
-- Utilitary functions. All functions are declared as global.
-- 
-- @module lib.util
-- @author Joel dos Santos <joel@dossantos.cc>


---------------------------------------------------------------------
-- Creates an enumeration table.
-- The enumeration constants are created according to a list of
-- strings passed as parameter.
-- 
-- The resulting *enum* table will raise an **error** if the user
-- tryes to access a non-existent key or create a new key in the
-- *enum* table.
-- 
-- @tparam table t List of constants (defined as *strings*) for the
-- enumeration.
-- @treturn table Enumeration table.
-- @raise Error if any of the parameters are of wrong type.
-- @usage
-- local types = enum{"S", "T"}
-- if val == types.S then
--    ...
-- elseif val == types.T then
--    ...
-- end
function enum(t)
    assert(type(t) == 'table', 'Wrong type for argument t (function enum).')
    
    local _p = {}
    local _m = {}
    
    for i,v in ipairs(t) do
        _m[v] = i
    end
    
    function _m.__index (t, k)
        if _m[k] then
            return _m[k]
        else
            error("no key " .. tostring(k) .. " available in enum", 2)
        end
    end
    
    function _m.__newindex (t, k, v)
        error("can not create new key inside enum", 2)
    end
    
    setmetatable(_p, _m)
    return _p
end


--- local type table
local _t = {
    number = function (v)
        return (v % 1 == 0) and 'integer' or 'double'
    end,
    
    table = function (v)
        return v.__type or 'table'
    end
}


---------------------------------------------------------------------
-- Gets the type name of a given value. This function extends Lua's
-- `type` function so to indicate whether a number is an `integer` or
-- a `double` and also get the type of tables.
-- 
-- @param v The value for each get the type name.
-- @treturn string The type name of `v`.
function typeof(v)
    local k = type(v)
    local f = _t[k]
    return f and f(v) or k, k
end