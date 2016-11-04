---------------------------------------------------------------------
-- Represents possible animations for media items positioning values.
-- 
-- @module model.animation
-- @author Joel dos Santos <joel@dossantos.cc>

local smt = require('lib.smt')


--- Module table
local animation = {}


---------------------------------------------------------------------
-- Creates a polynomial function for the given coefficients.
--    cn*x^n + ... + c1.x + c0
-- 
-- @tparam term x The indeterminate of the polynomial.
-- @tparam table c Table of coefficients of the polynomial.
-- 
-- @treturn term The polynomial function.
local function polynom_fun(x, c)
    local f = {}
    
    -- order 0 term
    if c[1] ~= 0 then
        f[#f + 1] = smt.real(c[1])
    end
    
    -- order 1 term
    if c[2] ~= 0 then
        if c[2] == 1 then
            f[#f + 1] = x
        else
            f[#f + 1] = smt.mul(smt.real(c[2]), x)
        end
    end
    
    -- high-order terms
    for i = 3,#c do
        if c[i] ~= 0 then
            if c[i] == 1 then
                f[#f + 1] = smt.pow(x, smt.int(i - 1))
            else
                f[#f + 1] = smt.mul(smt.real(c[i]), smt.pow(x, smt.int(i - 1)))
            end
        end
    end
    
    if #f == 1 then
        f = f[1]
    else
        f = smt.sum(f)
    end
    
    return f
end


---------------------------------------------------------------------
-- Creates an animation expression.
-- The expression defines how a given value evolves in relation to
-- type. It is based on the polynomial expression as function of time.
--    cn*x^n + ... + c1.x + c0
-- 
-- @tparam term var_T String representing the time variable.
-- @tparam term t_end Term representing the final time of the
-- animation.
-- @tparam table coef Table of coefficients of the polynomial.
-- 
-- @treturn term Value before the animation begins.
-- @treturn term Value expression during the animation.
-- @treturn term Value after the animation ends.
-- 
-- @raise Error if one of the following occurs:
--
--  * one of the argument's type is not correct;
--  * an error occurs while building realtion info.
function animation.polynomial(var_T, t_end, coef)
    assert(typeof(var_T) == 'term', 'Wrong type for argument var_T.')
    assert(typeof(t_end) == 'term', 'Wrong type for argument t_end.')
    assert(type(coef) == 'table', 'Wrong type for argument coef.')
    
    -- value before animation begins
    local f_before = smt.real(coef[1])
    
    -- value during the animation
    local f_during = polynom_fun(var_T, coef)
    
    -- value after the animation ends
    local f_after = polynom_fun(t_end, coef)
    
    return f_before, f_during, f_after
end


return animation