---------------------------------------------------------------------
-- Lua library for accessing SMT solver (Yices).
-- Export functions to be used by Lua to create terms and assert
-- properties on them.
-- 
-- @module lib.smt
-- @author Joel dos Santos <joel@dossantos.cc>

require('lib.util')
package.cpath = package.cpath .. ';./lib/?.so'
local solver = require('yices')


--- Class to represent a type. Holds information about the type.
-- @field __type Class type name.
-- @field new Function to create new type objects.
local solver_type = {
    __type = 'type',
    
    new = function (self, i, n)
        assert(typeof(i) == 'integer', 'Wrong type for argument i.')
        assert(not n or typeof(n) == 'string', 'Wrong type for argument n.')
        
        self.__index = self
        return setmetatable({index = i, name = n}, self)
    end
}


--- Class to represent a term. Holds information about the term.
-- @field __type Class type name.
-- @field new Function to create new term objects.
local solver_term = {
    __type = 'term',
    
    new = function (self, i, n)
        assert(typeof(i) == 'integer', 'Wrong type for argument i.')
        assert(not n or typeof(n) == 'string', 'Wrong type for argument n.')
        
        self.__index = self
        return setmetatable({index = i, name = n}, self)
    end
}


--- Module table
-- @field INT `Integer` primitive type.
-- @field REAL `Real` primitive type.
-- @field BOOL `Boolean` primitive type.
-- @field TRUE The constant `true`.
-- @field FALSE The constant `false`.
-- @field CONTEXT List of contexts currently in use.
local smt = {}
smt.CONTEXT = {}
smt.MODEL = {}


-- Gather inexistent values from the solver
setmetatable(smt, smt)
function smt.__index(t, k)
    if k == 'INT' then
        t[k] = solver_type:new(solver.int_type())
    elseif k == 'REAL' then
        t[k] = solver_type:new(solver.real_type())
    elseif k == 'BOOL' then
        t[k] = solver_type:new(solver.bool_type())
    elseif k == 'TRUE' then
        t[k] = solver_term:new(solver.const_true())
    elseif k == 'FALSE' then
        t[k] = solver_term:new(solver.const_false())
    else
        return nil
    end
    return t[k]
end


---------------------------------------------------------------------
-- Global initialization. This function must be called before
-- anything else to initialize the solver internal data structure.
-- 
-- @raise Error if the solver is already initiated.
function smt.init()
    assert(not smt.INIT, 'Solver is already initiated.')
    
    solver.init()
    smt.INIT = true
end


---------------------------------------------------------------------
-- Global cleanup. This function deletes all internal data structures
-- allocated by the solver  (including all contexts, models). It must
-- be called when the solver is no longer use.
-- 
-- @raise Error if the solver is not yet initiated.
function smt.exit()
    assert(smt.INIT, 'Solver is not yet initiated.')
    
    solver.exit()
    smt.INIT = nil
end


---------------------------------------------------------------------
-- Creates a context for the given model.
-- 
-- @tparam model model Model for which create the context.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `model` type is not the exepcted one;
--  * there is already a context for the model;
--  * error occurs while creating the context.
function smt.create_context(model)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(model) == 'model', 'Wrong type for argument model.')
    assert(not smt.CONTEXT[model], 'There is already a context built for this model.')
    
    local ctx_name = tostring(model):sub(7) .. '_ctx'
    solver.new_context(ctx_name);
    smt.CONTEXT[model] = ctx_name
end


---------------------------------------------------------------------
-- Destroy the context of a given model.
-- 
-- @tparam model model Model for which destroy the context.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `model` type is not the exepcted one;
--  * there is not a context for the model.
function smt.destroy_context(model)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(model) == 'model', 'Wrong type for argument model.')
    assert(smt.CONTEXT[model], 'There is not a context for this model.')
    
    solver.free_context(smt.CONTEXT[model]);
    smt.CONTEXT[model] = nil
end


---------------------------------------------------------------------
-- Marks a backtracking point in the model's context.
-- 
-- @tparam model model Model for which create a backtracking point.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `model` type is not the exepcted one;
--  * there is not a context for the model;
--  * an error occurs while marking the backtracking point.
function smt.mark_backtrack(model)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(model) == 'model', 'Wrong type for argument model.')
    assert(smt.CONTEXT[model], 'There is not a context for this model.')
    
    solver.mark_backtrack(smt.CONTEXT[model]);
end


---------------------------------------------------------------------
-- Backtracks the context to a previous backtracking point.
-- 
-- @tparam model model Model where to backtrack.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `model` type is not the exepcted one;
--  * there is not a context for the model;
--  * an error occurs while backtracking.
function smt.backtrack(model)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(model) == 'model', 'Wrong type for argument model.')
    assert(smt.CONTEXT[model], 'There is not a context for this model.')
    
    solver.backtrack(smt.CONTEXT[model]);
end


---------------------------------------------------------------------
-- Creates a type from an expression.
-- 
-- @tparam string exp The expression to be parsed.
-- 
-- @treturn type Object representing the type.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `exp` is not a string;
--  * an error occurs while creating the type.
function smt.parse_type(exp)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(exp) == 'string', 'Wrong type for argument exp.')
    
    return solver_type:new(solver.parse_type(exp))
end


---------------------------------------------------------------------
-- Creates a constant inside the context.
-- Equivalent to the expression `(define name :: type)`.
-- The constant name is optional.
-- 
-- @tparam type type The type of the constant.
-- @tparam string name The name of the constant.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `type` type is not an type value;
--  * `name` is not `nil` or a `string`;
--  * an error occurs while creating the term.
function smt.constant(type, name)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(type) == 'type', 'Wrong type for argument type.')
    assert(not name or typeof(name) == 'string', 'Wrong type for argument name.')
    
    if name then
        return solver_term:new(solver.new_term(type.index, name), name)
    else
        return solver_term:new(solver.new_term(type.index))
    end
end


---------------------------------------------------------------------
-- Creates a function inside the context.
-- Equivalent to the expression `(define name :: (-> args type))`.
-- The function name is optional.
-- 
-- @tparam table args Table with the types of all arguments.
-- @tparam type type The type of the function.
-- @tparam string name The name of the function.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `args` is not a table or is empty;
--  * `type` type is not an type value;
--  * `name` is not `nil` or a `string`;
--  * an error occurs while creating the term.
function smt.create_function(args, type, name)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(args) == 'table' and #args > 0, 'Wrong type for argument args.')
    assert(typeof(type) == 'type', 'Wrong type for argument type.')
    assert(not name or typeof(name) == 'string', 'Wrong type for argument name.')
    
    local _a = {}
    for i = 1, #args do
        assert(typeof(args[i]) == 'type', 'Table args must have only types.')
        _a[i] = args[i].index
    end
    
    local type = solver.function_type(_a, type.index)
    return solver_term:new(solver.new_term(type, name), name)
end


---------------------------------------------------------------------
-- Converts `val` to a constant integer term.
-- 
-- @tparam number val Integer to be converted to a term.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `val` is not an integer value;
--  * an error occurs while creating the term.
function smt.int(val)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(val) == 'integer', 'Wrong type for argument val.')
    
    return solver_term:new(solver.int_term(val))
end


---------------------------------------------------------------------
-- Converts `val` to a constant real term.
-- 
-- @tparam number val Double to be converted to a term.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `val` is not a number;
--  * an error occurs while creating the term.
function smt.real(val)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(({typeof(val)})[2] == 'number', 'Wrong type for argument val.')
    
    return solver_term:new(solver.real_term(tostring(val / 1.0)))
end


---------------------------------------------------------------------
-- Returns the opposite of a term. This is equivalent to `(- t)`.
-- 
-- @tparam term term The term to be preceded with a minus sign.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `term` type is not an term value;
--  * an error occurs while creating the term.
function smt.neg(term)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(term) == 'term', 'Wrong type for argument term.')
    
    return solver_term:new(solver.neg_term(term.index))
end


---------------------------------------------------------------------
-- Constructs the sum `(+ t[0] ... t[n-1])`.
-- 
-- @tparam table terms Table with the terms to be added.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `terms` is not a table or it does not have at leat two terms;
--  * an error occurs while creating the term.
function smt.sum(terms)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(terms) == 'table', 'Wrong type for argument terms.')
    assert(#terms > 1, 'You must indicate at least two terms.')
    
    local t = {}
    for i = 1, #terms do
        assert(typeof(terms[i]) == 'term', 'Table terms must have only terms.')
        t[i] = terms[i].index
    end
    return solver_term:new(solver.sum_terms(t))
end


---------------------------------------------------------------------
-- Returns the difference `(- t1 t2)`.
-- 
-- @tparam term t1 Object representing a term.
-- @tparam term t2 Object representing a term.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `t1` type is not an term value;
--  * `t2` type is not an term value;
--  * an error occurs while creating the term.
function smt.sub(t1, t2)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(t1) == 'term', 'Wrong type for argument t1.')
    assert(typeof(t2) == 'term', 'Wrong type for argument t2.')
    
    return solver_term:new(solver.sub_term(t1.index, t2.index))
end


---------------------------------------------------------------------
-- Returns the product `(* t1 t2)`.
-- 
-- @tparam term t1 Object representing a term.
-- @tparam term t2 Object representing a term.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `t1` type is not an term value;
--  * `t2` type is not an term value;
--  * an error occurs while creating the term.
function smt.mul(t1, t2)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(t1) == 'term', 'Wrong type for argument t1.')
    assert(typeof(t2) == 'term', 'Wrong type for argument t2.')
    
    return solver_term:new(solver.mul_term(t1.index, t2.index))
end


---------------------------------------------------------------------
-- Constructs the quotient `(/ t1 t2)`.
-- Term `t1` must be an arithmetic term and `t2` must be a non-zero
-- arithmetic constant.
-- 
-- @tparam term t1 Object representing a term.
-- @tparam term t2 Object representing a term.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `t1` type is not an term value;
--  * `t2` type is not an term value;
--  * an error occurs while creating the term.
function smt.div(t1, t2)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(t1) == 'term', 'Wrong type for argument t1.')
    assert(typeof(t2) == 'term', 'Wrong type for argument t2.')
    
    return solver_term:new(solver.div_term(t1.index, t2.index))
end


---------------------------------------------------------------------
-- Raises `t` to power `d`.
-- When `d` is zero, this function returns the constant 1 even if
-- `t` is zero.
-- 
-- @tparam term t Object representing a term.
-- @tparam term d Object representing the power value.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `t` type is not an term value;
--  * `d` type is not an integer value;
--  * an error occurs while creating the term.
function smt.pow(t, d)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(t) == 'term', 'Wrong type for argument t.')
    assert(typeof(d) == 'term', 'Wrong type for argument d.')
    
    return solver_term:new(solver.pow_term(t.index, d.index))
end


---------------------------------------------------------------------
-- Creates the arithmetic equality `(= t1 t2)`.
-- 
-- @tparam term t1 Object representing a term.
-- @tparam term t2 Object representing a term.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `t1` type is not an term value;
--  * `t2` type is not an term value;
--  * an error occurs while creating the term.
function smt.eq(t1, t2)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(t1) == 'term', 'Wrong type for argument t1.')
    assert(typeof(t2) == 'term', 'Wrong type for argument t2.')
    
    return solver_term:new(solver.eq_term(t1.index, t2.index))
end


---------------------------------------------------------------------
-- Creates the arithmetic disequality `(/= t1 t2)`.
-- 
-- @tparam term t1 Object representing a term.
-- @tparam term t2 Object representing a term.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `t1` type is not an term value;
--  * `t2` type is not an term value;
--  * an error occurs while creating the term.
function smt.ne(t1, t2)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(t1) == 'term', 'Wrong type for argument t1.')
    assert(typeof(t2) == 'term', 'Wrong type for argument t2.')
    
    return solver_term:new(solver.ne_term(t1.index, t2.index))
end


---------------------------------------------------------------------
-- Creates the inequality `(>= t1 t2)`.
-- 
-- @tparam term t1 Object representing a term.
-- @tparam term t2 Object representing a term.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `t1` type is not an term value;
--  * `t2` type is not an term value;
--  * an error occurs while creating the term.
function smt.ge(t1, t2)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(t1) == 'term', 'Wrong type for argument t1.')
    assert(typeof(t2) == 'term', 'Wrong type for argument t2.')
    
    return solver_term:new(solver.ge_term(t1.index, t2.index))
end


---------------------------------------------------------------------
-- Creates the inequality `(<= t1 t2)`.
-- 
-- @tparam term t1 Object representing a term.
-- @tparam term t2 Object representing a term.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `t1` type is not an term value;
--  * `t2` type is not an term value;
--  * an error occurs while creating the term.
function smt.le(t1, t2)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(t1) == 'term', 'Wrong type for argument t1.')
    assert(typeof(t2) == 'term', 'Wrong type for argument t2.')
    
    return solver_term:new(solver.le_term(t1.index, t2.index))
end


---------------------------------------------------------------------
-- Creates the inequality `(> t1 t2)`.
-- 
-- @tparam term t1 Object representing a term.
-- @tparam term t2 Object representing a term.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `t1` type is not an term value;
--  * `t2` type is not an term value;
--  * an error occurs while creating the term.
function smt.gt(t1, t2)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(t1) == 'term', 'Wrong type for argument t1.')
    assert(typeof(t2) == 'term', 'Wrong type for argument t2.')
    
    return solver_term:new(solver.gt_term(t1.index, t2.index))
end


---------------------------------------------------------------------
-- Creates the inequality `(< t1 t2)`.
-- 
-- @tparam term t1 Object representing a term.
-- @tparam term t2 Object representing a term.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `t1` type is not an term value;
--  * `t2` type is not an term value;
--  * an error occurs while creating the term.
function smt.lt(t1, t2)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(t1) == 'term', 'Wrong type for argument t1.')
    assert(typeof(t2) == 'term', 'Wrong type for argument t2.')
    
    return solver_term:new(solver.lt_term(t1.index, t2.index))
end


---------------------------------------------------------------------
-- States that a value is between two others.
-- 
-- @tparam term t1 Object representing a term.
-- @tparam term x Object representing a term.
-- @tparam term t2 Object representing a term.
-- @tparam boolean inc_bord Boolean indicating if the border values
-- `t1` and `t2` should be included. According to this parameter, the
-- expression will be `t1 <= x <= t2` or `t1 < x < t2`.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `t1` type is not an term value;
--  * `x` type is not an term value;
--  * `t2` type is not an term value;
--  * an error occurs while creating the term.
function smt.between(t1, x, t2, inc_bord)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(t1) == 'term', 'Wrong type for argument t1.')
    assert(typeof(x) == 'term', 'Wrong type for argument x.')
    assert(typeof(t2) == 'term', 'Wrong type for argument t2.')
    assert(inc_bord == nil or type(inc_bord) == 'boolean', 'Wrong type for argument inc_bord.')
    
    if inc_bord then
        return solver_term:new(solver.and_terms({solver.le_term(t1.index, x.index), solver.le_term(x.index, t2.index)}))
    else
        return solver_term:new(solver.and_terms({solver.lt_term(t1.index, x.index), solver.lt_term(x.index, t2.index)}))
    end
end


---------------------------------------------------------------------
-- Returns the negation of a term `(not term)`.
-- 
-- @tparam term term Object representing the term to be negated.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `term` type is not an term value;
--  * an error occurs while creating the term.
function smt.lnot(term)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(term) == 'term', 'Wrong type for argument term.')
    
    return solver_term:new(solver.not_term(term.index))
end


---------------------------------------------------------------------
-- Constructs the conjunction `(and t[0] ... t[n-1])`.
-- 
-- @tparam table terms Table with the terms to be in the conjunction.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `terms` is not a table or it does not have at least two terms;
--  * an error occurs while creating the term.
function smt.land(terms)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(terms) == 'table', 'Wrong type for argument terms.')
    assert(#terms > 1, 'You must indicate at least two terms.')
    
    local t = {}
    for i = 1, #terms do
        assert(typeof(terms[i]) == 'term', 'Table terms must have only terms.')
        t[i] = terms[i].index
    end
    return solver_term:new(solver.and_terms(t))
end


---------------------------------------------------------------------
-- Constructs the disjunction `(or t[0] ... t[n-1])`.
-- 
-- @tparam table terms Table with the terms to be in the disjunction.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `terms` is not a table or it does not have at least two terms;
--  * an error occurs while creating the term.
function smt.lor(terms)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(terms) == 'table', 'Wrong type for argument terms.')
    assert(#terms > 1, 'You must indicate at least two terms.')
    
    local t = {}
    for i = 1, #terms do
        assert(typeof(terms[i]) == 'term', 'Table terms must have only terms.')
        t[i] = terms[i].index
    end
    return solver_term:new(solver.or_terms(t))
end


---------------------------------------------------------------------
-- Creates the equivalence `(<=> t1 t2)`.
-- 
-- @tparam term t1 Object representing a term.
-- @tparam term t2 Object representing a term.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `t1` type is not an term value;
--  * `t2` type is not an term value;
--  * an error occurs while creating the term.
function smt.iff(t1, t2)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(t1) == 'term', 'Wrong type for argument t1.')
    assert(typeof(t2) == 'term', 'Wrong type for argument t2.')
    
    return solver_term:new(solver.iff_term(t1.index, t2.index))
end


---------------------------------------------------------------------
-- Creates the implication `(=> t1 t2)`.
-- 
-- @tparam term t1 Object representing a term.
-- @tparam term t2 Object representing a term.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `t1` type is not an term value;
--  * `t2` type is not an term value;
--  * an error occurs while creating the term.
function smt.imp(t1, t2)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(t1) == 'term', 'Wrong type for argument t1.')
    assert(typeof(t2) == 'term', 'Wrong type for argument t2.')
    
    return solver_term:new(solver.imp_term(t1.index, t2.index))
end


---------------------------------------------------------------------
-- Returns the term `(ite c t1 t2)` which means if `c` then `t1`
-- else `t2`.
-- 
-- `c` must be a Boolean term; `t1` and `t2` must be two terms of
-- compatible types.
-- 
-- @tparam term c Object representing a term.
-- @tparam term t1 Object representing a term.
-- @tparam term t2 Object representing a term.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `c` type is not an term value;
--  * `t1` type is not an term value;
--  * `t2` type is not an term value;
--  * an error occurs while creating the term.
function smt.ite(c, t1, t2)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(c) == 'term', 'Wrong type for argument c.')
    assert(typeof(t1) == 'term', 'Wrong type for argument t1.')
    assert(typeof(t2) == 'term', 'Wrong type for argument t2.')
    
    return solver_term:new(solver.ite_term(c.index, t1.index, t2.index))
end


---------------------------------------------------------------------
-- Returns the term `(distinct t[0] ... t[n-1])`. All elements of `t`
-- must have compatible types.
-- 
-- @tparam table terms Table with the terms to be in the disjunction.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `terms` is not a table or it does not have at least two terms;
--  * an error occurs while creating the term.
function smt.distinct(terms)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(terms) == 'table', 'Wrong type for argument terms.')
    assert(#term > 1, 'You must indicate at least two terms.')
    
    local t = {}
    for i = 1, #terms do
        assert(typeof(terms[i]) == 'term', 'Table terms must have only terms.')
        t[i] = term[i].index
    end
    return solver_term:new(solver.distinct_terms(t))
end


---------------------------------------------------------------------
-- Constructs the term `(fun t[0] ... t[n-1])`.
-- 
-- This applies function `fun` to the arguments `t[0] ... t[n-1]`,
-- where fun can be any term of function type.
-- 
-- @tparam term fun Object representing the function term.
-- @tparam table t Table with the terms to be used as arguments.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `fun` type is not an term value;
--  * `terms` is not a table or it is empty;
--  * an error occurs while creating the term.
function smt.apply(fun, t)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(fun) == 'term', 'Wrong type for argument fun.')
    assert(typeof(t) == 'table', 'Wrong type for argument terms.')
    assert(#t > 0, 'You must indicate at least one term.')
    
    local _t = {}
    for i = 1, #t do
        assert(typeof(t[i]) == 'term', 'Table t must have only terms.')
        _t[i] = t[i].index
    end
    
    return solver_term:new(solver.apply_function(fun.index, _t))
end


---------------------------------------------------------------------
-- Creates a term from an expression.
-- 
-- @tparam string exp The expression to be parsed.
-- 
-- @treturn term Object representing the term.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `exp` is not a string;
--  * an error occurs while creating the term.
function smt.parse_term(exp)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(exp) == 'string', 'Wrong type for argument exp.')
    
    return solver_term:new(solver.parse_term(exp))
end


---------------------------------------------------------------------
-- Asserts an expression in the context.
-- Equivalent to the command `(assert expression)`.
-- 
-- @tparam model model Model for which context the term will be asserted.
-- @tparam term term Object representing the term to be asserted.
--
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `model` type is not the exepcted one;
--  * there is not a context for the model;
--  * `term` type is not an term value;
--  * an error occurs while asserting the term.
function smt.assert(model, term)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(model) == 'model', 'Wrong type for argument model.')
    assert(smt.CONTEXT[model], 'There is not a context for this model.')
    assert(typeof(term) == 'term', 'Wrong type for argument term.')
    
    solver.assert_formula(smt.CONTEXT[model], term.index)
end


---------------------------------------------------------------------
-- Checks whether a context is satisfiable.
-- 
-- @tparam model model Model for which context will be checked.
-- 
-- @treturn bool True if the context is satisfiable and false
-- otherwise, returns `nil` for any other result.
--
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `model` type is not the exepcted one;
--  * there is not a context for the model;
--  * an error occurs while checking the context.
function smt.check(model)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(model) == 'model', 'Wrong type for argument model.')
    assert(smt.CONTEXT[model], 'There is not a context for this model.')
    
    smt.SAT = solver.check_context(smt.CONTEXT[model])
    return smt.SAT
end


---------------------------------------------------------------------
-- Creates a valoration, modeling a satisfiable context.
-- 
-- @tparam model model Model for which context will be modeled.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `model` type is not the exepcted one;
--  * there is not a context for the model;
--  * the context is not satisfiable;
--  * an error occurs while modeling the context.
function smt.create_model(model)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(model) == 'model', 'Wrong type for argument model.')
    assert(smt.CONTEXT[model], 'There is not a context for this model.')
    assert(smt.SAT, 'Context is not sat, can not evaluate it.')
    
    local mld_name = tostring(model):sub(7) .. '_mdl'
    solver.get_model(smt.CONTEXT[model], mld_name)
    smt.MODEL[model] = mld_name
end


---------------------------------------------------------------------
-- Destroys a model created from a satisfiable context.
-- 
-- @tparam model model Model for which context was modeled.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `model` type is not the exepcted one;
--  * there is not a modeling for the context.
function smt.destroy_model(model)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(model) == 'model', 'Wrong type for argument model.')
    assert(smt.MODEL[model], 'There is not a modeling for this context.')
    
    solver.free_model(smt.MODEL[model])
    smt.MODEL[model] = nil
end


---------------------------------------------------------------------
-- Get the value of a constant from a satisfiable context. The
-- function also store the term value in the term passed as argument
-- or in a new term created when argument `term` is a string.
-- 
-- @tparam model model Model from which context the term will be evaluated.
-- @tparam term term Term to be asserted.
-- @tparam type type The type of the term.
-- 
-- @return The value for the given constant (`number` or `string`)
-- or `nil` if the value is not defined.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `model` type is not the exepcted one;
--  * there is not a modeling for the context;
--  * `term` type is not an term value;
--  * an error occur while evaluating the term.
function smt.eval(model, term, type)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(model) == 'model', 'Wrong type for argument model.')
    assert(smt.MODEL[model], 'There is not a modeling for this context.')
    assert(typeof(term) == 'term', 'Wrong type for argument term.')
    assert(typeof(type) == 'type', 'Wrong type for argument type.')
    
    local value
    if type == smt.REAL then
        value = solver.get_real_value(smt.MODEL[model], term.index)
    elseif type == smt.BOOL then
        value = solver.get_bool_value(smt.MODEL[model], term.index)
    elseif type == smt.INT then
        value = solver.get_int_value(smt.MODEL[model], term.index)
    end
    term.value = value
    
    return value;
end


---------------------------------------------------------------------
-- Pretty print the entire model.
-- 
-- @tparam number term Integer representing the term to be asserted.
-- @tparam number width Number of columns for presenting the model.
-- @tparam number height Number of lines for presenting the model.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `term` type is not an term value;
--  * `width` and `height` are not numbers;
--  * an error occur while printing the term.
function smt.print_term(term, width, height)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(term) == 'term', 'Wrong type for argument term.')
    assert(({typeof(width)})[2] == 'number', 'Wrong type for argument width.')
    assert(({typeof(height)})[2] == 'number', 'Wrong type for argument height.')
    
    solver.pp_term(term.index, width, height)
end


---------------------------------------------------------------------
-- Pretty print the entire model.
-- 
-- @tparam model model Model from which context will be printed.
-- @tparam number width Number of columns for presenting the model.
-- @tparam number height Number of lines for presenting the model.
-- 
-- @raise Error if one of the following occurs:
--
--  * the solver is not yet initiated;
--  * `model` type is not the exepcted one;
--  * there is not a modeling for the context;
--  * `width` and `height` are not numbers;
--  * an error occur while printing the context modeling.
function smt.print_model(model, width, height)
    assert(smt.INIT, 'You must initiate the solver first.')
    assert(typeof(model) == 'model', 'Wrong type for argument model.')
    assert(smt.MODEL[model], 'There is not a modeling for this context.')
    assert(({typeof(width)})[2] == 'number', 'Wrong type for argument width.')
    assert(({typeof(height)})[2] == 'number', 'Wrong type for argument height.')
    
    solver.pp_model(smt.MODEL[model], width, height)
end


-- returns a proxy to avoid modifications in the module table
local proxy = {}
local mt = {
    __index = smt,
    __newindex = function (t, k, v)
        error('Forbidden attempt to update smt module field.', 2)
    end
}
setmetatable(proxy, mt)
return proxy