---------------------------------------------------------------------
-- Defines a set of spatial relations.
--
-- @module model.spatial
-- @author Joel dos Santos <joel@dossantos.cc>

local smt = require('lib.smt')


--- Module table
-- @field AXIS Spatial axis.
-- @field BORD Spatial borders for alignment and distribution.
local spatial = {}
spatial.AXIS = enum{'X', 'Y'}
spatial.BORD = enum{'OUT_INIT', 'INIT', 'CENTER', 'END', 'OUT_END', 'OUT'}



---------------------------------------------------------------------
-- Creates expression relating the size of two items.
-- 
-- The expression defines that the size of the first items must be
-- equal the second plus a value (optional).
-- 
-- @tparam item item1 The first region.
-- @tparam item item2 The second region.
-- @tparam spatial.AXIS axis The axis where to define the constraint.
-- @tparam number d Optional value to add to the second region size.
-- 
-- @treturn term Term representing the expression among item regions.
-- @treturn scenario The type of the relation. It is either
-- `SCENARIO.T` or `SCENARIO.S`.
-- 
-- @raise Error if one of the following occurs:
--
--  * one of the argument's type is not correct;
--  * an error occurs while building realtion info.
function spatial.same_size(item1, item2, axis, d)
    assert(typeof(item1) == 'item', 'Wrong type for argument item1.')
    assert(typeof(item2) == 'item', 'Wrong type for argument item2.')
    assert(type(axis) == 'number', 'Wrong type for argument axis.')
    assert(not d or type(d) == 'number', 'Wrong type for argument d.')
    
    local var1
    local var2
    if axis == spatial.AXIS.X then
        var1 = item1.xs
        var2 = item2.xs
    elseif axis == spatial.AXIS.Y then
        var1 = item1.ys
        var2 = item2.ys
    end
    
    if d then
        var2 = smt.sum{var2, smt.real(d)}
    end
    
    return smt.eq(var1, var2), SCENARIO.S
end


---------------------------------------------------------------------
-- Creates expression defining the minimum size of a region.
-- 
-- @tparam item item The item whose region we want to define the size.
-- @tparam spatial.AXIS axis The axis where to define the constraint.
-- @tparam number val The value to be used.
-- 
-- @treturn term Term representing the expression among item regions.
-- @treturn scenario The type of the relation. It is either
-- `SCENARIO.T` or `SCENARIO.S`.
-- 
-- @raise Error if one of the following occurs:
--
--  * one of the argument's type is not correct;
--  * an error occurs while building realtion info.
function spatial.min_size(item, axis, val)
    assert(typeof(item) == 'item', 'Wrong type for argument item.')
    assert(type(axis) == 'number', 'Wrong type for argument axis.')
    assert(type(val) == 'number', 'Wrong type for argument val.')
    
    local var
    if axis == spatial.AXIS.X then
        var = item.xs
    elseif axis == spatial.AXIS.Y then
        var = item.ys
    end
    
    return smt.ge(var, smt.real(val)), SCENARIO.S
end


---------------------------------------------------------------------
-- Creates expression defining the maximum size of a region.
-- 
-- @tparam item item The item whose region we want to define the size.
-- @tparam spatial.AXIS axis The axis where to define the constraint.
-- @tparam number val The value to be used.
-- 
-- @treturn term Term representing the expression among item regions.
-- @treturn scenario The type of the relation. It is either
-- `SCENARIO.T` or `SCENARIO.S`.
-- 
-- @raise Error if one of the following occurs:
--
--  * one of the argument's type is not correct;
--  * an error occurs while building realtion info.
function spatial.max_size(item, axis, val)
    assert(typeof(item) == 'item', 'Wrong type for argument item.')
    assert(type(axis) == 'number', 'Wrong type for argument axis.')
    assert(type(val) == 'number', 'Wrong type for argument val.')
    
    local var
    if axis == spatial.AXIS.X then
        var = item.xs
    elseif axis == spatial.AXIS.Y then
        var = item.ys
    end
    
    return smt.le(var, smt.real(val)), SCENARIO.S
end


---------------------------------------------------------------------
-- Creates expression aligning two items.
-- 
-- Item alignment follows one of the options in `spatial.BORD`.
-- OUT_INIT:
--    [ item1        ]|
--                    |[ item2            ]
-- 
-- INIT:
--    |[ item1        ]
--    |[ item2            ]
-- 
-- CENTER:
--      [ item1 |       ]
--    [ item2   |         ]
-- 
-- END:
--        [ item1        ]|
--    [ item2            ]|
-- 
-- OUT_END:
--                        |[ item1        ]
--    [ item2            ]|
-- 
-- @tparam string item1 Name of the first region.
-- @tparam string item2 Name of the second region.
-- @tparam spatial.AXIS axis The axis where to define the constraint.
-- @tparam spatial.BORD bord Bord to use for aligning regions.
-- 
-- @treturn term Term representing the expression among item regions.
-- @treturn scenario The type of the relation. It is either
-- `SCENARIO.T` or `SCENARIO.S`.
-- 
-- @raise Error if one of the following occurs:
--
--  * one of the argument's type is not correct;
--  * an error occurs while building realtion info.
function spatial.align(item1, item2, axis, bord)
    assert(typeof(item1) == 'item', 'Wrong type for argument item1.')
    assert(typeof(item2) == 'item', 'Wrong type for argument item2.')
    assert(type(axis) == 'number', 'Wrong type for argument axis.')
    assert(type(bord) == 'number', 'Wrong type for argument bord.')
    
    local var1
    local var2
    if axis == spatial.AXIS.X then
        var1 = 'x'
        var2 = 'x'
    elseif axis == spatial.AXIS.Y then
        var1 = 'y'
        var2 = 'y'
    end
    
    if bord == spatial.BORD.OUT_INIT then
        var1 = var1 .. 'e'
        var2 = var2 .. 'i'
    elseif bord == spatial.BORD.INIT then
        var1 = var1 .. 'i'
        var2 = var2 .. 'i'
    elseif bord == spatial.BORD.CENTER then
        var1 = var1 .. 'c'
        var2 = var2 .. 'c'
    elseif bord == spatial.BORD.END then
        var1 = var1 .. 'e'
        var2 = var2 .. 'e'
    elseif bord == spatial.BORD.OUT_END then
        var1 = var1 .. 'i'
        var2 = var2 .. 'e'
    else
        error('spatial.BORD option not supported', 2)
    end
    
    return smt.eq(item1[var1], item2[var2]), SCENARIO.S
end


return spatial