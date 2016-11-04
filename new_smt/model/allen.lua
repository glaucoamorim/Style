---------------------------------------------------------------------
-- Represent Allen relations.
-- 
-- @module model.allen
-- @author Joel dos Santos <joel@dossantos.cc>

local smt = require('lib.smt')


--- Module table
local allen = {}


---------------------------------------------------------------------
-- Creates expression representing relation **before** between
-- item intervals.
-- 
-- The delay between intervals, if defined, act as follows:
--    [  item 1  ] |-- d --| [  item 2  ]
-- 
-- @tparam item item1 Name of the first interval.
-- @tparam item item2 Name of the second interval.
-- @tparam number d Delay between intervals. If `nil` no delay is used.
-- 
-- @treturn term Term representing the expression among item
-- intervals.
-- @treturn scenario The type of the relation. It is either
-- `SCENARIO.T` or `SCENARIO.S`.
-- 
-- @raise Error if one of the following occurs:
--
--  * one of the argument's type is not correct;
--  * an error occurs while building realtion info.
function allen.before(item1, item2, d)
    assert(typeof(item1) == 'item', 'Wrong type for argument item1.')
    assert(typeof(item2) == 'item', 'Wrong type for argument item2.')
    assert(not d or type(d) == 'number', 'Wrong type for argument d.')
    
    if d then
        return smt.eq(smt.sum{item1.te, smt.real(d)}, item2.ti), SCENARIO.T
    else
        return smt.lt(item1.te, item2.ti), SCENARIO.T
    end
end


---------------------------------------------------------------------
-- Creates expression representing relation **meets** between
-- item intervals.
-- 
-- @tparam item item1 Name of the first interval.
-- @tparam item item2 Name of the second interval.
-- 
-- @treturn term Term representing the expression among item
-- intervals.
-- @treturn scenario The type of the relation. It is either
-- `SCENARIO.T` or `SCENARIO.S`.
-- 
-- @raise Error if one of the following occurs:
--
--  * one of the argument's type is not correct;
--  * an error occurs while building realtion info.
function allen.meets(item1, item2)
    assert(typeof(item1) == 'item', 'Wrong type for argument item1.')
    assert(typeof(item2) == 'item', 'Wrong type for argument item2.')
    
    return smt.eq(item1.te, item2.ti), SCENARIO.T
end


---------------------------------------------------------------------
-- Creates expression representing relation **overlaps** between
-- item intervals.
-- 
-- The delay between intervals, if defined, act as follows:
--    [  item 1  ]
--    |- d -| [  item 2  ]
-- 
-- @tparam item item1 Name of the first interval.
-- @tparam item item2 Name of the second interval.
-- @tparam number d Delay between intervals. If `nil` no delay is used.
-- 
-- @treturn term Term representing the expression among item
-- intervals.
-- @treturn scenario The type of the relation. It is either
-- `SCENARIO.T` or `SCENARIO.S`.
-- 
-- @raise Error if one of the following occurs:
--
--  * one of the argument's type is not correct;
--  * an error occurs while building realtion info.
function allen.overlaps(item1, item2, d)
    assert(typeof(item1) == 'item', 'Wrong type for argument item1.')
    assert(typeof(item2) == 'item', 'Wrong type for argument item2.')
    assert(not d or type(d) == 'number', 'Wrong type for argument d.')
    
    local exp
    if d then
        exp = smt.eq(item2.ti, smt.sum{item1.ti, smt.real(d)})
    else
        exp = smt.lt(item1.te, item2.ti)
    end
    
    return smt.land{
                smt.lt(item1.ti, item2.ti),
                exp,
                smt.lt(item1.te, item2.te)}, SCENARIO.T
end


---------------------------------------------------------------------
-- Creates expression representing relation **starts** between
-- item intervals.
-- 
-- @tparam item item1 Name of the first interval.
-- @tparam item item2 Name of the second interval.
-- 
-- @treturn term Term representing the expression among item
-- intervals.
-- @treturn scenario The type of the relation. It is either
-- `SCENARIO.T` or `SCENARIO.S`.
-- 
-- @raise Error if one of the following occurs:
--
--  * one of the argument's type is not correct;
--  * an error occurs while building realtion info.
function allen.starts(item1, item2)
    assert(typeof(item1) == 'item', 'Wrong type for argument item1.')
    assert(typeof(item2) == 'item', 'Wrong type for argument item2.')
    
    return smt.land{
                smt.eq(item1.ti, item2.ti),
                exp,
                smt.lt(item1.te, item2.te)}, SCENARIO.T
end


---------------------------------------------------------------------
-- Creates expression representing relation **during** between
-- item intervals.
-- 
-- The delay between intervals, if defined, act as follows:
--    [        item 1        ]
--    |- d -| [  item 2  ]
-- 
-- @tparam item item1 Name of the first interval.
-- @tparam item item2 Name of the second interval.
-- @tparam number d Delay between intervals. If `nil` no delay is used.
-- 
-- @treturn term Term representing the expression among item
-- intervals.
-- @treturn scenario The type of the relation. It is either
-- `SCENARIO.T` or `SCENARIO.S`.
-- 
-- @raise Error if one of the following occurs:
--
--  * one of the argument's type is not correct;
--  * an error occurs while building realtion info.
function allen.during(item1, item2, d)
    assert(typeof(item1) == 'item', 'Wrong type for argument item1.')
    assert(typeof(item2) == 'item', 'Wrong type for argument item2.')
    assert(not d or type(d) == 'number', 'Wrong type for argument d.')
    
    local exp
    if d then
        exp = smt.eq(item1.ti, smt.sum{item2.ti, smt.real(d)})
    else
        exp = smt.lt(item1.ti, item2.ti)
    end
    
    return smt.land{
                exp,
                smt.lt(item1.te, item2.te)}, SCENARIO.T
end


---------------------------------------------------------------------
-- Creates expression representing relation **finishes** between
-- item intervals.
-- 
-- @tparam item item1 Name of the first interval.
-- @tparam item item2 Name of the second interval.
-- 
-- @treturn term Term representing the expression among item
-- intervals.
-- @treturn scenario The type of the relation. It is either
-- `SCENARIO.T` or `SCENARIO.S`.
-- 
-- @raise Error if one of the following occurs:
--
--  * one of the argument's type is not correct;
--  * an error occurs while building realtion info.
function allen.finishes(item1, item2)
    assert(typeof(item1) == 'item', 'Wrong type for argument item1.')
    assert(typeof(item2) == 'item', 'Wrong type for argument item2.')
    
    return smt.land{
                smt.gt(item1.ti, item2.ti),
                exp,
                smt.eq(item1.te, item2.te)}, SCENARIO.T
end


---------------------------------------------------------------------
-- Creates expression representing relation **equals** between
-- item intervals.
-- 
-- @tparam item item1 Name of the first interval.
-- @tparam item item2 Name of the second interval.
-- 
-- @treturn term Term representing the expression among item
-- intervals.
-- @treturn scenario The type of the relation. It is either
-- `SCENARIO.T` or `SCENARIO.S`.
-- 
-- @raise Error if one of the following occurs:
--
--  * one of the argument's type is not correct;
--  * an error occurs while building realtion info.
function allen.equals(item1, item2)
    assert(typeof(item1) == 'item', 'Wrong type for argument item1.')
    assert(typeof(item2) == 'item', 'Wrong type for argument item2.')
    
    return smt.land{
                smt.eq(item1.ti, item2.ti),
                smt.eq(item1.te, item2.te)}, SCENARIO.T
end


return allen