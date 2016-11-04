---------------------------------------------------------------------
-- Represent RCC relations.
--
-- @module model.rcc
-- @author Joel dos Santos <joel@dossantos.cc>

local smt = require('lib.smt')


--- Module table
local rcc = {}


---------------------------------------------------------------------
-- Creates expression for a given angle between item regions.
-- 
-- The expression relates the center of both regions so that the
-- first is at a given angle `phi` of the second. It is necessary
-- to define the distance between regions centers.
-- 
-- @tparam item item1 Name of the first region.
-- @tparam item item2 Name of the second region.
-- @tparam number/string angl Angle between regions. The angle can
-- be a number or a string representing a cardinal point (`E`, `NE`,
-- `N`, `NW`, `W`, `SW`, `S`, `SE`).
-- @tparam number dist Distance between regions centers.
-- 
-- @treturn table Table with parts of the expression among item
-- regions (expression must be used inside a `(and )` expression).
-- 
-- @raise Error if one of the following occurs:
--
--  * one of the argument's type is not correct;
--  * an error occurs while building realtion info.
local function angle(item1, item2, angl, dist)
    assert(typeof(item1) == 'item', 'Wrong type for argument item1.')
    assert(typeof(item2) == 'item', 'Wrong type for argument item2.')
    local _t = type(angl)
    assert(_t == 'number' or _t == 'string', 'Wrong type for argument angl.')
    assert(type(dist) == 'number', 'Wrong type for argument dist.')
    
    local delta
    if(type(angl) == 'number') then
        delta = 2.0
    else
        delta = 22.5
        if angl == 'E' then
            angl = 0.0
        elseif angl == 'NE' then
            angl = 45.0
        elseif angl == 'N' then
            angl = 90.0
        elseif angl == 'NW' then
            angl = 135.0
        elseif angl == 'W' then
            angl = 180.0
        elseif angl == 'SW' then
            angl = 225.0
        elseif angl == 'S' then
            angl = 270.0
        elseif angl == 'SE' then
            angl = 315.0
        end
    end
    
    local cmax = smt.real(math.cos(math.rad(angl + delta)) * dist)
    local cmin = smt.real(math.cos(math.rad(angl - delta)) * dist)
    local smax = smt.real(math.sin(math.rad(angl + delta)) * dist)
    local smin = smt.real(math.sin(math.rad(angl - delta)) * dist)
    
    local dx = smt.sub(item1.xc, item2.xc)
    local dy = smt.sub(item2.yc, item1.yc)
    local exp = {}
    
    if cmin < cmax then
        exp[#exp + 1] = smt.ge(dx, cmin)
        exp[#exp + 1] = smt.le(dx, cmax)
    elseif cmax < cmin then
        exp[#exp + 1] = smt.ge(dx, cmax)
        exp[#exp + 1] = smt.le(dx, cmin)
    elseif cmax > 0 then
        exp[#exp + 1] = smt.ge(dx, cmin)
        exp[#exp + 1] = smt.le(dx, dist)
    else
        exp[#exp + 1] = smt.ge(dx, smt.neg(dist))
        exp[#exp + 1] = smt.le(dx, cmax)
    end
    
    if smin < smax then
        exp[#exp + 1] = smt.ge(dy, smin)
        exp[#exp + 1] = smt.le(dy, smax)
    elseif smax < smin then
        exp[#exp + 1] = smt.ge(dy, smax)
        exp[#exp + 1] = smt.le(dy, smin)
    elseif smax > 0 then
        exp[#exp + 1] = smt.ge(dy, smin)
        exp[#exp + 1] = smt.le(dy, dist)
    else
        exp[#exp + 1] = smt.ge(dy, smt.neg(dist))
        exp[#exp + 1] = smt.le(dy, smax)
    end
    
    return exp
end


---------------------------------------------------------------------
-- Creates expression representing relation **disconnected** between
-- item regions.
-- 
-- @tparam item item1 Name of the first region.
-- @tparam item item2 Name of the second region.
-- @tparam number/string a Angle between regions. The angle can
-- be a number or a string representing a cardinal point (`E`, `NE`,
-- `N`, `NW`, `W`, `SW`, `S`, `SE`). If `nil` no angle (and distance)
-- is used.
-- @tparam number d Distance between regions centers. If `nil`
-- no distance (and angle) is used.
-- 
-- @treturn term Term representing the expression among item
-- regions.
-- @treturn scenario The type of the relation. It is either
-- `SCENARIO.T` or `SCENARIO.S`.
-- 
-- @raise Error if one of the following occurs:
--
--  * one of the argument's type is not correct;
--  * an error occurs while building realtion info.
function rcc.dcon(item1, item2, a, d)
    assert(typeof(item1) == 'item', 'Wrong type for argument item1.')
    assert(typeof(item2) == 'item', 'Wrong type for argument item2.')
    local _t = type(a)
    assert(not a or _t == 'number' or _t == 'string', 'Wrong type for argument a.')
    assert(not d or type(d) == 'number', 'Wrong type for argument d.')
    
    local exp = smt.lor{
                    smt.gt(item1.xi, item2.xe),
                    smt.lt(item1.xe, item2.xi),
                    smt.gt(item1.yi, item2.ye),
                    smt.lt(item1.ye, item2.yi)
                }
    if a and d then
        local t = angle(item1, item2, a, d)
        t[#t + 1] = exp
        return smt.land(t), SCENARIO.S
    else
        return exp, SCENARIO.S
    end
end


---------------------------------------------------------------------
-- Creates expression representing relation **externally connected**
-- between item regions.
-- 
-- @tparam item item1 Name of the first region.
-- @tparam item item2 Name of the second region.
-- @tparam number/string a Angle between regions. The angle can
-- be a number or a string representing a cardinal point (`E`, `NE`,
-- `N`, `NW`, `W`, `SW`, `S`, `SE`). If `nil` no angle (and distance)
-- is used.
-- @tparam number d Distance between regions centers. If `nil`
-- no distance (and angle) is used.
-- 
-- @treturn term Term representing the expression among item
-- regions.
-- @treturn scenario The type of the relation. It is either
-- `SCENARIO.T` or `SCENARIO.S`.
-- 
-- @raise Error if one of the following occurs:
--
--  * one of the argument's type is not correct;
--  * an error occurs while building realtion info.
function rcc.econ(item1, item2, a, d)
    assert(typeof(item1) == 'item', 'Wrong type for argument item1.')
    assert(typeof(item2) == 'item', 'Wrong type for argument item2.')
    local _t = type(a)
    assert(not a or _t == 'number' or _t == 'string', 'Wrong type for argument a.')
    assert(not d or type(d) == 'number', 'Wrong type for argument d.')
    
    local exp = smt.lor{
                    smt.land{
                        smt.lor{
                            smt.eq(item1.xi, item2.xe),
                            smt.eq(item1.xe, item2.xi)
                        },
                        smt.le(item1.yi, item2.ye),
                        smt.ge(item1.ye, item2.yi)
                    },
                    smt.land{
                        smt.lor{
                            smt.eq(item1.yi, item2.ye),
                            smt.eq(item1.ye, item2.yi)
                        },
                        smt.le(item1.xi, item2.xe),
                        smt.ge(item1.xe, item2.xi)
                    }
                }
    if a and d then
        local t = angle(item1, item2, a, d)
        t[#t + 1] = exp
        return smt.land(t), SCENARIO.S
    else
        return exp, SCENARIO.S
    end
end


---------------------------------------------------------------------
-- Creates expression representing relation **partially overlapping**
-- between item regions.
-- 
-- @tparam string item1 Name of the first region.
-- @tparam string item2 Name of the second region.
-- @tparam number/string a Angle between regions. The angle can
-- be a number or a string representing a cardinal point (`E`, `NE`,
-- `N`, `NW`, `W`, `SW`, `S`, `SE`). If `nil` no angle (and distance)
-- is used.
-- @tparam number d Distance between regions centers. If `nil`
-- no distance (and angle) is used.
-- 
-- @treturn term Term representing the expression among item
-- regions.
-- @treturn scenario The type of the relation. It is either
-- `SCENARIO.T` or `SCENARIO.S`.
-- 
-- @raise Error if one of the following occurs:
--
--  * one of the argument's type is not correct;
--  * an error occurs while building realtion info.
function rcc.pover(item1, item2, a, d)
    assert(typeof(item1) == 'item', 'Wrong type for argument item1.')
    assert(typeof(item2) == 'item', 'Wrong type for argument item2.')
    local _t = type(a)
    assert(not a or _t == 'number' or _t == 'string', 'Wrong type for argument a.')
    assert(not d or type(d) == 'number', 'Wrong type for argument d.')
    
    local exp = smt.lor{
                    smt.land{
                        smt.lt(item1.xi, item2.xi),
                        smt.gt(item1.xe, item2.xi),
                        smt.lt(item1.xe, item2.xe),
                        smt.lt(item1.yi, item2.ye),
                        smt.gt(item1.ye, item2.yi)
                    },
                    smt.land{
                        smt.gt(item1.xi, item2.xi),
                        smt.lt(item1.xi, item2.xe),
                        smt.gt(item1.xe, item2.xe),
                        smt.lt(item1.yi, item2.ye),
                        smt.gt(item1.ye, item2.yi)
                    },
                    smt.land{
                        smt.lt(item1.yi, item2.yi),
                        smt.gt(item1.ye, item2.yi),
                        smt.lt(item1.ye, item2.ye),
                        smt.lt(item1.xi, item2.xe),
                        smt.gt(item1.xe, item2.xi)
                    },
                    smt.land{
                        smt.gt(item1.yi, item2.yi),
                        smt.lt(item1.yi, item2.ye),
                        smt.gt(item1.ye, item2.ye),
                        smt.lt(item1.xi, item2.xe),
                        smt.gt(item1.xe, item2.xi)
                    }
                }
    if a and d then
        local t = angle(item1, item2, a, d)
        t[#t + 1] = exp
        return smt.land(t), SCENARIO.S
    else
        return exp, SCENARIO.S
    end
end


---------------------------------------------------------------------
-- Creates expression representing relation **tangential proper
-- part** between item regions.
-- 
-- @tparam string item1 Name of the first region.
-- @tparam string item2 Name of the second region.
-- @tparam number/string a Angle between regions. The angle can
-- be a number or a string representing a cardinal point (`E`, `NE`,
-- `N`, `NW`, `W`, `SW`, `S`, `SE`). If `nil` no angle (and distance)
-- is used.
-- @tparam number d Distance between regions centers. If `nil`
-- no distance (and angle) is used.
-- 
-- @treturn term Term representing the expression among item
-- regions.
-- @treturn scenario The type of the relation. It is either
-- `SCENARIO.T` or `SCENARIO.S`.
-- 
-- @raise Error if one of the following occurs:
--
--  * one of the argument's type is not correct;
--  * an error occurs while building realtion info.
function rcc.tpp(item1, item2, a, d)
    assert(typeof(item1) == 'item', 'Wrong type for argument item1.')
    assert(typeof(item2) == 'item', 'Wrong type for argument item2.')
    local _t = type(a)
    assert(not a or _t == 'number' or _t == 'string', 'Wrong type for argument a.')
    assert(not d or type(d) == 'number', 'Wrong type for argument d.')
    
    local exp = {}
    if a and d then
        exp = angle(item1, item2, a, d)
    end
    exp[#exp + 1] = smt.lor{
                        smt.land{
                            smt.lt(item1.xs, item2.xs),
                            smt.le(item1.ys, item2.ys)
                        },
                        smt.land{
                            smt.le(item1.xs, item2.xs),
                            smt.lt(item1.ys, item2.ys)
                        }
                    }
    exp[#exp + 1] = smt.lor{
                        smt.land{
                            smt.lor{
                                smt.eq(item1.xi, item2.xi),
                                smt.eq(item1.xe, item2.xe)
                            },
                            smt.ge(item1.yi, item2.yi),
                            smt.le(item1.ye, item2.ye)
                        },
                        smt.land{
                            smt.lor{
                                smt.eq(item1.yi, item2.yi),
                                smt.eq(item1.ye, item2.ye)
                            },
                            smt.ge(item1.xi, item2.xi),
                            smt.le(item1.xe, item2.xe)
                        }
                    }
    return smt.land(exp), SCENARIO.S
end


---------------------------------------------------------------------
-- Creates expression representing relation **non-tangential proper
-- part** between item regions.
-- 
-- @tparam string item1 Name of the first region.
-- @tparam string item2 Name of the second region.
-- @tparam number/string a Angle between regions. The angle can
-- be a number or a string representing a cardinal point (`E`, `NE`,
-- `N`, `NW`, `W`, `SW`, `S`, `SE`). If `nil` no angle (and distance)
-- is used.
-- @tparam number d Distance between regions centers. If `nil`
-- no distance (and angle) is used.
-- 
-- @treturn term Term representing the expression among item
-- regions.
-- @treturn scenario The type of the relation. It is either
-- `SCENARIO.T` or `SCENARIO.S`.
-- 
-- @raise Error if one of the following occurs:
--
--  * one of the argument's type is not correct;
--  * an error occurs while building realtion info.
function rcc.ntpp(item1, item2, a, d)
    assert(typeof(item1) == 'item', 'Wrong type for argument item1.')
    assert(typeof(item2) == 'item', 'Wrong type for argument item2.')
    local _t = type(a)
    assert(not a or _t == 'number' or _t == 'string', 'Wrong type for argument a.')
    assert(not d or type(d) == 'number', 'Wrong type for argument d.')
    
    local exp = {}
    if a and d then
        exp = angle(item1, item2, a, d)
    end
    exp[#exp + 1] = smt.gt(item1.xi, item2.xi)
    exp[#exp + 1] = smt.lt(item1.xe, item2.xe)
    exp[#exp + 1] = smt.gt(item1.yi, item2.yi)
    exp[#exp + 1] = smt.lt(item1.ye, item2.ye)
    return smt.land(exp), SCENARIO.S
end


---------------------------------------------------------------------
-- Creates expression representing relation **equal** between
-- item regions.
-- 
-- @tparam string item1 Name of the first region.
-- @tparam string item2 Name of the second region.
-- 
-- @treturn term Term representing the expression among item
-- regions.
-- @treturn scenario The type of the relation. It is either
-- `SCENARIO.T` or `SCENARIO.S`.
-- 
-- @raise Error if one of the following occurs:
--
--  * one of the argument's type is not correct;
--  * an error occurs while building realtion info.
function rcc.equal(item1, item2)
    assert(typeof(item1) == 'item', 'Wrong type for argument item1.')
    assert(typeof(item2) == 'item', 'Wrong type for argument item2.')
    
    return smt.land{
                smt.eq(item1.xi, item2.xi),
                smt.eq(item1.xe, item2.xe),
                smt.eq(item1.yi, item2.yi),
                smt.eq(item1.ye, item2.ye)
            }, SCENARIO.S
end


return rcc