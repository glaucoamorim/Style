/////////////////////////////////////////////////////////////////////
// C library for accessing Yices.
// Export functions to be used by Lua to create terms and assert
// properties on them.
// 
// @module lib.yices
// @usage
//    package.cpath = package.cpath .. ';./lib/?.so'
//    require("yices")
// @author Joel dos Santos <joel@dossantos.cc>


#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <yices.h>
#include <lua.h>
#include <lauxlib.h>



/////////////////////////////////////////////////////////////////////
// Throws an error back to Lua.
// 
// [Yices error reporting](http://yices.csl.sri.com/doc/error-reports.html#error-reports)
// 
// @function l_throw_error
// @local here
// @tparam lua_State* L Pointer to lua state.
static int l_throw_error(lua_State *L) {
    int str_parts = 0;
    error_report_t *report = yices_error_report();
    
    if(report->code == 0)
        return 0;
    
    switch(report->code) {
        case INVALID_TYPE:
            lua_pushstring(L, "Invalid type argument");
            break;
        
        case INVALID_TERM:
            lua_pushstring(L, "Invalid term argument");
            break;
        
        case INVALID_FLOAT_FORMAT:
            lua_pushstring(L, "The input float does not have the right format");
            break;
        
        case TOO_MANY_ARGUMENTS:
            lua_pushstring(L, "Attempt to create a type or term of arity larger accepted");
            break;
        
        case DIVISION_BY_ZERO:
            lua_pushstring(L, "Zero divider in a rational constant");
            break;
        
        case POS_INT_REQUIRED:
            lua_pushstring(L, "Bad integer argument: the function expects a positive argument");
            break;
        
        case NONNEG_INT_REQUIRED:
            lua_pushstring(L, "Bad integer argument: the function expects a non-negative argument");
            break;
        
        case FUNCTION_REQUIRED:
            lua_pushstring(L, "Bad term argument: a term of function type is expected");
            break;
        
        case ARITHTERM_REQUIRED:
            lua_pushstring(L, "Bad term argument: an arithmetic term (of type Int or Real) is expected");
            break;
        
        case WRONG_NUMBER_OF_ARGUMENTS:
            lua_pushstring(L, "Wrong number of arguments in a function application or function update");
            break;
        
        case TYPE_MISMATCH:
            lua_pushstring(L, "Type error in various term constructor");
            break;
        
        case INCOMPATIBLE_TYPES:
            lua_pushstring(L, "Error in functions that require terms of compatible types");
            break;
        
        case ARITHCONSTANT_REQUIRED:
            lua_pushstring(L, "Invalid term: an arithmetic constant is expected");
            break;
        
        case SYNTAX_ERROR:
            lua_pushstring(L, "Syntax error");
            break;
        
        case UNDEFINED_TYPE_NAME:
            lua_pushstring(L, "A name is not defined in the symbol table for types");
            break;
        
        case UNDEFINED_TERM_NAME:
            lua_pushstring(L, "A name is not defined in the symbol table for terms");
            break;
        
        case REDEFINED_TYPE_NAME:
            lua_pushstring(L, "Attempt to redefine an existing type name");
            break;
        
        case REDEFINED_TERM_NAME:
            lua_pushstring(L, "Attempt to redefine an existing term name");
            break;
        
        case INTEGER_OVERFLOW:
            lua_pushstring(L, "Integer constant can’t be converted to a signed 32bit integer");
            break;
        
        case INTEGER_REQUIRED:
            lua_pushstring(L, "Rational constant provided when an integer is expected");
            break;
        
        case RATIONAL_REQUIRED:
            lua_pushstring(L, "Invalid argument: a rational constant is expected");
            break;
        
        case TYPE_REQUIRED:
            lua_pushstring(L, "Error in a definition or declaration: a type is expected");
            break;
        
        case NON_CONSTANT_DIVISOR:
            lua_pushstring(L, "Attempt to divide by a non-constant arithmetic term");
            break;
        
        case ARITH_ERROR:
            lua_pushstring(L, "Error in an arithmetic operation: an argument is not an arithmetic term");
            break;
        
        case CTX_INVALID_OPERATION:
            lua_pushstring(L, "Invalid operation on a context: the context is in a state that does not allow the operation to be performed");
            break;
        
        case CTX_OPERATION_NOT_SUPPORTED:
            lua_pushstring(L, "Invalid operation on a context: the context is not configured to support this operation");
            break;
        
        case EVAL_UNKNOWN_TERM:
            lua_pushstring(L, "The model does not assign a value to the specified term");
            break;
        
        case OUTPUT_ERROR:
            lua_pushstring(L, "Error when attempting to write to a stream");
            break;
        
        case INTERNAL_EXCEPTION:
            lua_pushstring(L, "Catch-all code for any other error");
            break;
        
        default:
            lua_pushstring(L, "Error");
    }
    str_parts++;
    
    if(report->line != 0 && report->column != 0) {
        lua_pushstring(L, " (line ");
        lua_pushnumber(L, report->line);
        lua_pushstring(L, ", column ");
        lua_pushnumber(L, report->column);
        lua_pushstring(L, ")");
        str_parts += 5;
    }
    
    if(report->term1 != 0 && report->type1 != 0) {
        lua_pushstring(L, " [term ");
        lua_pushnumber(L, report->type1);
        lua_pushstring(L, "] ");
        lua_pushnumber(L, report->term1);
        lua_pushstring(L, " ");
        str_parts += 5;
    }
    
    if(report->term2 != 0 && report->type2 != 0) {
        lua_pushstring(L, " [term ");
        lua_pushnumber(L, report->type2);
        lua_pushstring(L, "] ");
        lua_pushnumber(L, report->term2);
        lua_pushstring(L, " ");
        str_parts += 5;
    }
    
    if(report->badval != 0) {
        lua_pushstring(L, " [bad value ");
        lua_pushnumber(L, report->badval);
        lua_pushstring(L, "]");
        str_parts += 3;
    }
        
    lua_concat(L, str_parts);
    yices_clear_error();
    lua_error(L);
    // printf("%s\n", lua_tostring(L, -1));
    return 0;
}


/////////////////////////////////////////////////////////////////////
// Global initialization.
// 
// This function must be called before anything else to initialize
// Yices’s internal data structure.
// 
// [Yices global initialization and cleanup](http://yices.csl.sri.com/doc/global-initialization.html)
// 
// @function init
static int l_yices_init(lua_State *L) {
    yices_init();
    l_throw_error(L);
    return 0;
}


/////////////////////////////////////////////////////////////////////
// Global cleanup.
// 
// This function deletes all internal data structures allocated by
// Yices (including all contexts, models, configuration and parameter
// records). It must be called when the API is no longer used to
// avoid memory leaks.
// 
// [Yices global initialization and cleanup](http://yices.csl.sri.com/doc/global-initialization.html)
// 
// @function exit
static int l_yices_exit(lua_State *L) {
    yices_exit();
    return 0;
}


/////////////////////////////////////////////////////////////////////
// Creates a new context.
// 
// This function allocates and initializes a new context and stores
// it in the registry, using the parameter as location.
// 
// [Yices context creation and configuration](http://yices.csl.sri.com/doc/context-operations.html#creation-and-configuration)
// 
// @function new_context
// @tparam string loc Location to be used as index for storing the
// context in the registry.
// 
// @raise Error if an error occurs while creating the context.
static int l_yices_new_context(lua_State *L) {
    context_t *context = yices_new_context(NULL);
    if(context == NULL) {
        l_throw_error(L);
        return 0;
    }
    
    // get the location where to store the context
    const char *loc = lua_tostring(L, 1);
    
    // store the context in the registry
    lua_pushstring(L, loc);
    lua_pushlightuserdata(L, context);
    lua_settable(L, LUA_REGISTRYINDEX);
    
    return 0;
}


/////////////////////////////////////////////////////////////////////
// Retrieves the context stored in the registry.
// 
// @function l_retrieve_context
// @local here
// @tparam lua_State* L Pointer to lua state.
// @tparam string loc Location where the context is stored.
// 
// @treturn context_t* Pointer to the context.
static context_t * l_retrieve_context(lua_State *L, const char *loc) {
    context_t *context;
    
    // get the context from the registry
    lua_pushstring(L, loc);
    lua_gettable(L, LUA_REGISTRYINDEX);
    context = (context_t *) lua_topointer(L, -1);
    
    return context;
}


/////////////////////////////////////////////////////////////////////
// Delete the context.
// 
// The context is also removed from the registry.
// 
// [Yices context creation and configuration](http://yices.csl.sri.com/doc/context-operations.html#creation-and-configuration)
// 
// @function free_context
// @tparam string loc Location where the context is stored.
static int l_yices_free_context(lua_State *L) {
    // get the location where the context is stored
    const char *loc = lua_tostring(L, 1);
    
    // get the context from the registry
    context_t *context = l_retrieve_context(L, loc);
    
    // remove the context from the registry
    lua_pushstring(L, loc);
    lua_pushnil(L);
    lua_settable(L, LUA_REGISTRYINDEX);
    
    // free the context
    yices_free_context(context);
    
    return 0;
}


/////////////////////////////////////////////////////////////////////
// Marks a backtracking point.
// 
// [Yices push and pop](http://yices.csl.sri.com/doc/context-operations.html#push-and-pop)
// 
// @function mark_backtrack
// @tparam string ctx The context where to mark the backtracking point.
// 
// @raise Error if an error occurs while marking the backtracking point.
static int l_yices_push(lua_State *L) {
    // get the location where the context is stored
    const char *ctx = lua_tostring(L, 1);
    
    // get the context from the registry
    context_t *context = l_retrieve_context(L, ctx);
    
    // mark the backtracking point
    int32_t error = yices_push(context);
    if(error)
        l_throw_error(L);
    
    return 0;
}


/////////////////////////////////////////////////////////////////////
// Backtraks to a previous backtracking point.
// 
// [Yices push and pop](http://yices.csl.sri.com/doc/context-operations.html#push-and-pop)
// 
// @function backtrack
// @tparam string ctx The context where to backtrack.
// 
// @raise Error if an error occurs while backtracking.
static int l_yices_pop(lua_State *L) {
    // get the location where the context is stored
    const char *ctx = lua_tostring(L, 1);
    
    // get the context from the registry
    context_t *context = l_retrieve_context(L, ctx);
    
    // backtracks
    int32_t error = yices_pop(context);
    if(error)
        l_throw_error(L);
    
    return 0;
}


/////////////////////////////////////////////////////////////////////
// Access Yices Integer primitive type.
// 
// [Yices type constructors](http://yices.csl.sri.com/doc/type-operations.html#type-constructors)
// 
// @function int_type
// 
// @treturn number Integer representing the `integer` type.
// 
// @raise Error if an error occurs while accessing the type.
static int l_yices_int_type(lua_State *L) {
    type_t type = yices_int_type();
    
    if (type == NULL_TYPE) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, type);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Access Yices Real primitive type.
// 
// [Yices type constructors](http://yices.csl.sri.com/doc/type-operations.html#type-constructors)
// 
// @function real_type
// 
// @treturn number Integer representing the `real` type.
// 
// @raise Error if an error occurs while accessing the type.
static int l_yices_real_type(lua_State *L) {
    type_t type = yices_real_type();
    
    if (type == NULL_TYPE) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, type);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Access Yices Boolean primitive type.
// 
// [Yices type constructors](http://yices.csl.sri.com/doc/type-operations.html#type-constructors)
// 
// @function bool_type
// 
// @treturn number Integer representing the `boolean` type.
// 
// @raise Error if an error occurs while accessing the type.
static int l_yices_bool_type(lua_State *L) {
    type_t type = yices_bool_type();
    
    if (type == NULL_TYPE) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, type);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Creates an Yices function type.
//     (-> domain[0] ... domain[n-1] type)
// 
// [Yices function type](http://yices.csl.sri.com/doc/type-operations.html#c.yices_function_type)
// 
// @function function_type
// @tparam table domain Table with the types of all arguments.
// @tparam number type The type of the function.
// 
// @treturn number Integer representing the function type.
// 
// @raise Error if an error occurs while creating the type.
static int l_yices_function_type(lua_State *L) {
    // get the parameters for the function
    int d_size = lua_objlen(L, 1);
    int f_dom[d_size];
    lua_pushnil(L);
    int i = 0;
    while (lua_next(L, 1) != 0) {
        f_dom[i] = lua_tonumber(L, -1);
        lua_pop(L, 1);
        i++;
    }
    int f_typ = lua_tonumber(L, 2);
    
    // create the function type
    type_t type = yices_function_type(d_size, f_dom, f_typ);
    
    if (type == NULL_TYPE) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, type);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Creates a type from an expression.
// 
// @function parse_type
// @tparam string expr The expression to be parsed.
// 
// @treturn number Integer representing the type.
// 
// @raise Error if an error occurs while creating the type.
static int l_yices_parse_type(lua_State *L) {
    // get the parameters for the function
    const char *expr = lua_tostring(L, 1);
    
    // parses the expression
    type_t type = yices_parse_type(expr);
    if (type == NULL_TYPE) {
        l_throw_error(L);
        return 0;
    }
    
    lua_pushinteger(L, type);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Returns a new uninterpreted term of type `tau`.
// 
// An uninterpreted term is like a global variable of type tau. If
// tau is a function type, the resulting term is an uninterpreted
// function of type tau. Optionally, you can give a name to new
// uninterpreted terms.
// 
// Equivalent to the expression `(define name :: type)`.
// 
// [Yices term constructor](http://yices.csl.sri.com/doc/term-operations.html#c.yices_new_uninterpreted_term)
// 
// @function new_term
// @tparam number type Integer representing a Yices type.
// @tparam string name Optional name to the term.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_new_uninterpreted_term(lua_State *L) {
    // get the parameters for the function
    int type = lua_tonumber(L, 1);
    
    term_t term = yices_new_uninterpreted_term(type);
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    if (lua_isnil(L, 2) == 1) {
        const char *name = lua_tostring(L, 2);
        yices_set_term_name(term, name);
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Converts `val` to a constant integer term.
// 
// [Yices arithmetic terms](http://yices.csl.sri.com/doc/term-operations.html#arithmetic-terms)
// 
// @function int_term
// @tparam number val Integer to be converted to a term.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_int32(lua_State *L) {
    // get the parameters for the function
    int32_t val = lua_tonumber(L, 1);
    
    term_t term = yices_int32(val);
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Converts `val` to a constant real term.
// 
// [Yices arithmetic terms](http://yices.csl.sri.com/doc/term-operations.html#arithmetic-terms)
// 
// @function real_term
// @tparam string val Float to be converted to a term.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_parse_float(lua_State *L) {
    // get the parameters for the function
    const char *val = lua_tostring(L, 1);
    
    term_t term = yices_parse_float(val);
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Returns the opposite of a term.
// 
// [Yices arithmetic terms](http://yices.csl.sri.com/doc/term-operations.html#arithmetic-terms)
// 
// @function neg_term
// @tparam number t Integer representing the term to be preceded
// with a minus sign.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_neg(lua_State *L) {
    // get the parameters for the function
    int32_t t = lua_tonumber(L, 1);
    
    term_t term = yices_neg(t);
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Constructs the sum `(+ t[0] ... t[n-1])`.
// 
// [Yices arithmetic terms](http://yices.csl.sri.com/doc/term-operations.html#arithmetic-terms)
// 
// @function sum_terms
// @tparam table t Table with the terms to be added.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_sum(lua_State *L) {
    // get the parameters for the function
    int t_size = lua_objlen(L, 1);
    int t[t_size];
    lua_pushnil(L);
    int i = 0;
    while (lua_next(L, 1) != 0) {
        t[i] = lua_tonumber(L, -1);
        lua_pop(L, 1);
        i++;
    }
    
    term_t term = yices_sum(t_size, t);
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Returns the difference `(- t1 t2)`.
// 
// [Yices arithmetic terms](http://yices.csl.sri.com/doc/term-operations.html#arithmetic-terms)
// 
// @function sub_term
// @tparam number t1 Integer representing a term.
// @tparam number t2 Integer representing a term.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_sub(lua_State *L) {
    // get the parameters for the function
    int32_t t1 = lua_tonumber(L, 1);
    int32_t t2 = lua_tonumber(L, 2);
    
    term_t term = yices_sub(t1, t2);
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Returns the product `(* t1 t2)`.
// 
// [Yices arithmetic terms](http://yices.csl.sri.com/doc/term-operations.html#arithmetic-terms)
// 
// @function mul_term
// @tparam number t1 Integer representing a term.
// @tparam number t2 Integer representing a term.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_mul(lua_State *L) {
    // get the parameters for the function
    int32_t t1 = lua_tonumber(L, 1);
    int32_t t2 = lua_tonumber(L, 2);
    
    term_t term = yices_mul(t1, t2);
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Constructs the quotient `(/ t1 t2)`.
// 
// [Yices arithmetic terms](http://yices.csl.sri.com/doc/term-operations.html#arithmetic-terms)
// 
// @function div_term
// @tparam number t1 Integer representing a term.
// @tparam number t2 Integer representing a term.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_division(lua_State *L) {
    // get the parameters for the function
    int32_t t1 = lua_tonumber(L, 1);
    int32_t t2 = lua_tonumber(L, 2);
    
    term_t term = yices_division(t1, t2);
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Raises `t1` to power `d`.
// When `d` is zero, this function returns the constant 1 even if
// `t1` is zero.
// 
// [Yices arithmetic terms](http://yices.csl.sri.com/doc/term-operations.html#arithmetic-terms)
// 
// @function pow_term
// @tparam number t1 Integer representing a term.
// @tparam number d Integer representing the power value.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_power(lua_State *L) {
    // get the parameters for the function
    int32_t t1 = lua_tonumber(L, 1);
    int32_t d = lua_tonumber(L, 2);
    
    term_t term = yices_power(t1, d);
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Creates the arithmetic equality `(= t1 t2)`.
// 
// [Yices arithmetic terms](http://yices.csl.sri.com/doc/term-operations.html#arithmetic-terms)
// 
// @function eq_term
// @tparam number t1 Integer representing a term.
// @tparam number t2 Integer representing a term.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_arith_eq_atom(lua_State *L) {
    // get the parameters for the function
    int32_t t1 = lua_tonumber(L, 1);
    int32_t t2 = lua_tonumber(L, 2);
    
    term_t term = yices_arith_eq_atom(t1, t2);
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Creates the arithmetic disequality `(/= t1 t2)`.
// 
// [Yices arithmetic terms](http://yices.csl.sri.com/doc/term-operations.html#arithmetic-terms)
// 
// @function ne_term
// @tparam number t1 Integer representing a term.
// @tparam number t2 Integer representing a term.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_arith_neq_atom(lua_State *L) {
    // get the parameters for the function
    int32_t t1 = lua_tonumber(L, 1);
    int32_t t2 = lua_tonumber(L, 2);
    
    term_t term = yices_arith_neq_atom(t1, t2);
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Creates the inequality `(>= t1 t2)`.
// 
// [Yices arithmetic terms](http://yices.csl.sri.com/doc/term-operations.html#arithmetic-terms)
// 
// @function ge_term
// @tparam number t1 Integer representing a term.
// @tparam number t2 Integer representing a term.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_arith_geq_atom(lua_State *L) {
    // get the parameters for the function
    int32_t t1 = lua_tonumber(L, 1);
    int32_t t2 = lua_tonumber(L, 2);
    
    term_t term = yices_arith_geq_atom(t1, t2);
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Creates the inequality `(<= t1 t2)`.
// 
// [Yices arithmetic terms](http://yices.csl.sri.com/doc/term-operations.html#arithmetic-terms)
// 
// @function le_term
// @tparam number t1 Integer representing a term.
// @tparam number t2 Integer representing a term.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_arith_leq_atom(lua_State *L) {
    // get the parameters for the function
    int32_t t1 = lua_tonumber(L, 1);
    int32_t t2 = lua_tonumber(L, 2);
    
    term_t term = yices_arith_leq_atom(t1, t2);
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Creates the inequality `(> t1 t2)`.
// 
// [Yices arithmetic terms](http://yices.csl.sri.com/doc/term-operations.html#arithmetic-terms)
// 
// @function gt_term
// @tparam number t1 Integer representing a term.
// @tparam number t2 Integer representing a term.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_arith_gt_atom(lua_State *L) {
    // get the parameters for the function
    int32_t t1 = lua_tonumber(L, 1);
    int32_t t2 = lua_tonumber(L, 2);
    
    term_t term = yices_arith_gt_atom(t1, t2);
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Creates the inequality `(< t1 t2)`.
// 
// [Yices arithmetic terms](http://yices.csl.sri.com/doc/term-operations.html#arithmetic-terms)
// 
// @function lt_term
// @tparam number t1 Integer representing a term.
// @tparam number t2 Integer representing a term.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_arith_lt_atom(lua_State *L) {
    // get the parameters for the function
    int32_t t1 = lua_tonumber(L, 1);
    int32_t t2 = lua_tonumber(L, 2);
    
    term_t term = yices_arith_lt_atom(t1, t2);
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Returns the Boolean constant `true`.
// 
// [Yices boolean terms](http://yices.csl.sri.com/doc/term-operations.html#boolean-terms)
// 
// @function const_true
// 
// @treturn number Integer representing the constant `true`.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_true(lua_State *L) {
    term_t term = yices_true();
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Returns the Boolean constant `false`.
// 
// [Yices boolean terms](http://yices.csl.sri.com/doc/term-operations.html#boolean-terms)
// 
// @function const_false
// 
// @treturn number Integer representing the constant `false`.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_false(lua_State *L) {
    term_t term = yices_false();
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Returns the negation of a term `(not term)`.
// 
// [Yices boolean terms](http://yices.csl.sri.com/doc/term-operations.html#boolean-terms)
// 
// @function not_term
// @tparam number term Integer representing the term to be negated.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_not(lua_State *L) {
    // get the parameters for the function
    int32_t t = lua_tonumber(L, 1);
    
    term_t term = yices_not(t);
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Constructs the conjunction `(and t[0] ... t[n-1])`.
// 
// [Yices boolean terms](http://yices.csl.sri.com/doc/term-operations.html#boolean-terms)
// 
// @function and_terms
// @tparam table t Table with the terms to be in the conjunction.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_and(lua_State *L) {
    // get the parameters for the function
    int t_size = lua_objlen(L, 1);
    int t[t_size];
    lua_pushnil(L);
    int i = 0;
    while (lua_next(L, 1) != 0) {
        t[i] = lua_tonumber(L, -1);
        lua_pop(L, 1);
        i++;
    }
    
    term_t term = yices_and(t_size, t);
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Constructs the disjunction `(or t[0] ... t[n-1])`.
// 
// [Yices boolean terms](http://yices.csl.sri.com/doc/term-operations.html#boolean-terms)
// 
// @function or_terms
// @tparam table t Table with the terms to be in the disjunction.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_or(lua_State *L) {
    // get the parameters for the function
    int t_size = lua_objlen(L, 1);
    int t[t_size];
    lua_pushnil(L);
    int i = 0;
    while (lua_next(L, 1) != 0) {
        t[i] = lua_tonumber(L, -1);
        lua_pop(L, 1);
        i++;
    }
    
    term_t term = yices_or(t_size, t);
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Creates the equivalence `(<=> t1 t2)`.
// 
// [Yices boolean terms](http://yices.csl.sri.com/doc/term-operations.html#boolean-terms)
// 
// @function iff_term
// @tparam number t1 Integer representing a term.
// @tparam number t2 Integer representing a term.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_iff(lua_State *L) {
    // get the parameters for the function
    int32_t t1 = lua_tonumber(L, 1);
    int32_t t2 = lua_tonumber(L, 2);
    
    term_t term = yices_iff(t1, t2);
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Creates the implication `(=> t1 t2)`.
// 
// [Yices boolean terms](http://yices.csl.sri.com/doc/term-operations.html#boolean-terms)
// 
// @function imp_term
// @tparam number t1 Integer representing a term.
// @tparam number t2 Integer representing a term.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_implies(lua_State *L) {
    // get the parameters for the function
    int32_t t1 = lua_tonumber(L, 1);
    int32_t t2 = lua_tonumber(L, 2);
    
    term_t term = yices_implies(t1, t2);
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Returns the term `(ite c t1 t2)` which means if `c` then `t1`
// else `t2`.
// 
// `c` must be a Boolean term; `t1` and `t2` must be two terms of
// compatible types.
// 
// [Yices general constructors](http://yices.csl.sri.com/doc/term-operations.html#general-constructors)
// 
// @function ite_term
// @tparam number c Integer representing a term.
// @tparam number t1 Integer representing a term.
// @tparam number t2 Integer representing a term.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_ite(lua_State *L) {
    // get the parameters for the function
    int32_t c = lua_tonumber(L, 1);
    int32_t t1 = lua_tonumber(L, 2);
    int32_t t2 = lua_tonumber(L, 3);
    
    term_t term = yices_ite(c, t1, t2);
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Returns the term `(distinct t[0] ... t[n-1])`. All elements of `t`
// must have compatible types.
// 
// [Yices general constructors](http://yices.csl.sri.com/doc/term-operations.html#general-constructors)
// 
// @function distinct_terms
// @tparam table t Table with the terms to be in the disjunction.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_distinct(lua_State *L) {
    // get the parameters for the function
    int t_size = lua_objlen(L, 1);
    int t[t_size];
    lua_pushnil(L);
    int i = 0;
    while (lua_next(L, 1) != 0) {
        t[i] = lua_tonumber(L, -1);
        lua_pop(L, 1);
        i++;
    }
    
    term_t term = yices_distinct(t_size, t);
    
    if (term == NULL_TERM) {
         l_throw_error(L);
         return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Constructs the term `(fun t[0] ... t[n-1])`.
// 
// This applies function `fun` to the arguments `t[0] ... t[n-1]`,
// where fun can be any term of function type.
// 
// [Yices general constructors](http://yices.csl.sri.com/doc/term-operations.html#general-constructors)
// 
// @function apply_function
// @tparam number fun Integer representing the function term.
// @tparam table t Table with the terms to be used as arguments.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_application(lua_State *L) {
    // get the parameters for the function
    int fun = lua_tonumber(L, 1);
    int t_size = lua_objlen(L, 2);
    int t[t_size];
    lua_pushnil(L);
    int i = 0;
    while (lua_next(L, 2) != 0) {
        t[i] = lua_tonumber(L, -1);
        lua_pop(L, 1);
        i++;
    }
    
    term_t term = yices_application(fun, t_size, t);
    
    if (term == NULL_TERM) {
        l_throw_error(L);
        return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Creates a term from an expression.
// 
// @function parse_term
// @tparam string expr The expression to be parsed.
// 
// @treturn number Integer representing the term.
// 
// @raise Error if an error occurs while creating the term.
static int l_yices_parse_term(lua_State *L) {
    // get the parameters for the function
    const char *expr = lua_tostring(L, 1);
    
    // parses the expression
    term_t term = yices_parse_term(expr);
    if (term == NULL_TERM) {
        l_throw_error(L);
        return 0;
    }
    
    lua_pushinteger(L, term);
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Gets a term by its name.
// 
// @function get_term_by_name
// @tparam string name The name of the term.
// 
// @treturn number Integer representing the term or `nil` if no term
// with the given name was found.
static int l_yices_get_term_by_name(lua_State *L) {
    // get the parameters for the function
    const char *name = lua_tostring(L, 1);
    
    term_t term = yices_get_term_by_name(name);
    if(term != NULL_TERM)
        lua_pushinteger(L, term);
    else
        lua_pushnil(L);
    
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Asserts a formula.
// 
// This function asserts formula t in context ctx. The term t must
// be Boolean.
// 
// [Yices assertions](http://yices.csl.sri.com/doc/context-operations.html#assertions-and-satisfiability-checks)
// 
// @function assert_formula
// @tparam string ctx The context where to assert the formula.
// @tparam number t Integer representing the term to be asserted.
// 
// @raise Error if an error occurs while asserting the formula.
static int l_yices_assert_formula(lua_State *L) {
    // get the parameters for the function
    const char *ctx = lua_tostring(L, 1);
    int term = lua_tonumber(L, 2);
    
    // get the context from the registry
    context_t *context = l_retrieve_context(L, ctx);
    
    // assert the expression
    int32_t error = yices_assert_formula(context, term);
    if(error)
         l_throw_error(L);
    
    return 0;
}


/////////////////////////////////////////////////////////////////////
// Checks whether a context is satisfiable.
// 
// [Yices check](http://yices.csl.sri.com/doc/context-operations.html#assertions-and-satisfiability-checks)
// 
// @function check_context
// @tparam string ctx The context to check.
// 
// @treturn bool True if the context is satisfiable and false
// otherwise, returns `nil` for any other result.
// 
// @raise Error if an error occurs while checking the context.
static int l_yices_check_context(lua_State *L) {
    // get the parameters for the function
    const char *ctx = lua_tostring(L, 1);
    
    // get the context from the registry
    context_t *context = l_retrieve_context(L, ctx);
    
    // check the context
    switch(yices_check_context(context, NULL)) {
        case STATUS_SAT:
            lua_pushboolean(L, 1); // return true
            break;
        
        case STATUS_UNSAT:
            lua_pushboolean(L, 0); // return false
            break;
        
        case STATUS_ERROR:
            l_throw_error(L);
            return 0;
        
        default:
            lua_pushnil(L); // return nill
    }
    
    return 1;
}


/////////////////////////////////////////////////////////////////////
// Builds a model from a satisfiable context.
// 
// The model created by this function is stored in the registry.
// 
// [Yices model](http://yices.csl.sri.com/doc/model-operations.html)
// 
// @function get_model
// @tparam string ctx The context to check.
// @tparam string loc Location to be used as index for storing the
// model in the registry.
// 
// @raise Error if an error occurs while building the model.
static int l_yices_get_model(lua_State *L) {
    // get the context from the registry
    const char *ctx = lua_tostring(L, 1);
    context_t *context = l_retrieve_context(L, ctx);
    
    // build a model for the context
    model_t *model = yices_get_model(context, true);
    if(model == NULL) {
        l_throw_error(L);
        return 0;
    }
    
    // get the location where to store the context
    const char *loc = lua_tostring(L, 2);
    
    // store the model in the registry
    lua_pushstring(L, loc);
    lua_pushlightuserdata(L, model);
    lua_settable(L, LUA_REGISTRYINDEX);
    
    return 0;
}


/////////////////////////////////////////////////////////////////////
// Retrieves the model stored in the registry.
// 
// @function l_retrieve_model
// @local here
// @tparam lua_State* L Pointer to lua state.
// @tparam string loc Location where the model is stored.
// 
// @treturn model_t* Pointer to the model.
static model_t * l_retrieve_model(lua_State *L, const char *loc) {
    model_t *model;
    
    // get the model from the registry
    lua_pushstring(L, loc);
    lua_gettable(L, LUA_REGISTRYINDEX);
    model = (model_t *) lua_topointer(L, -1);
    
    return model;
}


/////////////////////////////////////////////////////////////////////
// Delete the model.
// 
// The model is also removed from the registry.
// 
// [Yices model](http://yices.csl.sri.com/doc/model-operations.html)
// 
// @function free_model
// @tparam string loc The model to be deleted.
static int l_yices_free_model(lua_State *L) {
    // get the location where the context is stored
    const char *loc = lua_tostring(L, 1);
    
    // get the model from the registry
    model_t *model = l_retrieve_model(L, loc);
    
    // remove the model from the registry
    lua_pushstring(L, loc);
    lua_pushnil(L);
    lua_settable(L, LUA_REGISTRYINDEX);
    
    // free the model
    yices_free_model(model);
    
    return 0;
}


/////////////////////////////////////////////////////////////////////
// Get the value of a boolean term for a satisfiable context.
// 
// [Yices value of term](http://yices.csl.sri.com/doc/model-operations.html#value-of-a-term-in-a-model)
// 
// @function get_bool_value
// @tparam string mdl The model where to evaluate the term.
// @tparam number term Integer representing the term to be evaluated.
// 
// @return The value of the term.
// 
// @raise Error if there is a problem evaluating the term.
static int l_yices_get_bool_value(lua_State *L) {
    // get the parameters for the function
    const char *mdl = lua_tostring(L, 1);
    int term = lua_tonumber(L, 2);
    
    // get the model from the registry
    model_t *model = l_retrieve_model(L, mdl);
    
    // get the value
    int32_t ival;
    if(yices_get_bool_value(model, term, &ival) == 0) {
        lua_pushboolean(L, ival);
        return 1;
    }
    else {
        l_throw_error(L);
        return 0;
    }
}


/////////////////////////////////////////////////////////////////////
// Get the value of a integer term for a satisfiable context.
// 
// [Yices value of term](http://yices.csl.sri.com/doc/model-operations.html#value-of-a-term-in-a-model)
// 
// @function get_int_value
// @tparam string mdl The model where to evaluate the term.
// @tparam number term Integer representing the term to be evaluated.
// 
// @return The value of the term.
// 
// @raise Error if there is a problem evaluating the term.
static int l_yices_get_int_value(lua_State *L) {
    // get the parameters for the function
    const char *mdl = lua_tostring(L, 1);
    int term = lua_tonumber(L, 2);
    
    // get the model from the registry
    model_t *model = l_retrieve_model(L, mdl);
    
    // get the value
    int32_t ival;
    if(yices_get_int32_value(model, term, &ival) == 0) {
        lua_pushinteger(L, ival);
        return 1;
    }
    else {
        l_throw_error(L);
        return 0;
    }
}


/////////////////////////////////////////////////////////////////////
// Get the value of a real term for a satisfiable context.
// 
// [Yices value of term](http://yices.csl.sri.com/doc/model-operations.html#value-of-a-term-in-a-model)
// 
// @function get_real_value
// @tparam string mdl The model where to evaluate the term.
// @tparam number term Integer representing the term to be evaluated.
// 
// @return The value of the term.
// 
// @raise Error if there is a problem evaluating the term.
static int l_yices_get_real_value(lua_State *L) {
    // get the parameters for the function
    const char *mdl = lua_tostring(L, 1);
    int term = lua_tonumber(L, 2);
    
    // get the model from the registry
    model_t *model = l_retrieve_model(L, mdl);
    
    // get the value
    double dval;
    if(yices_get_double_value(model, term, &dval) == 0) {
        lua_pushnumber(L, dval);
        return 1;
    }
    else {
        l_throw_error(L);
        return 0;
    }
}


/////////////////////////////////////////////////////////////////////
// Pretty print a term.
// 
// @function pp_term
// @tparam number term Integer representing the term to be printed.
// @tparam number width Number of columns for presenting the term.
// @tparam number height Number of lines for presenting the term.
static int l_yices_pp_term(lua_State *L) {
    // get the parameters for the function
    int term = lua_tonumber(L, 1);
    double width = lua_tonumber(L, 2);
    double height = lua_tonumber(L, 3);
    
    yices_pp_term(stdout, term, width, height, 0);
    return 0;
}


/////////////////////////////////////////////////////////////////////
// Pretty print the entire model.
// 
// @function pp_model
// @tparam string mdl The model to be printed.
// @tparam number width Number of columns for presenting the model.
// @tparam number height Number of lines for presenting the model.
static int l_yices_pp_model(lua_State *L) {
    // get the parameters for the function
    const char *mdl = lua_tostring(L, 1);
    double width = lua_tonumber(L, 2);
    double height = lua_tonumber(L, 3);
    
    // get the model from the registry
    model_t *model = l_retrieve_model(L, mdl);
    
    yices_pp_model(stdout, model, width, height, 0);
    return 0;
}


static const struct luaL_Reg l_yices_functions[] = {
        {"init", l_yices_init},
        {"exit", l_yices_exit},
        {"new_context", l_yices_new_context},
        {"free_context", l_yices_free_context},
        {"mark_backtrack", l_yices_push},
        {"backtrack", l_yices_pop},
        {"int_type", l_yices_int_type},
        {"real_type", l_yices_real_type},
        {"bool_type", l_yices_bool_type},
        {"function_type", l_yices_function_type},
        {"parse_type", l_yices_parse_type},
        {"new_term", l_yices_new_uninterpreted_term},
        {"int_term", l_yices_int32},
        {"real_term", l_yices_parse_float},
        {"neg_term", l_yices_neg},
        {"sum_terms", l_yices_sum},
        {"sub_term", l_yices_sub},
        {"mul_term", l_yices_mul},
        {"div_term", l_yices_division},
        {"pow_term", l_yices_power},
        {"eq_term", l_yices_arith_eq_atom},
        {"ne_term", l_yices_arith_neq_atom},
        {"ge_term", l_yices_arith_geq_atom},
        {"le_term", l_yices_arith_leq_atom},
        {"gt_term", l_yices_arith_gt_atom},
        {"lt_term", l_yices_arith_lt_atom},
        {"const_true", l_yices_true},
        {"const_false", l_yices_false},
        {"not_term", l_yices_not},
        {"and_terms", l_yices_and},
        {"or_terms", l_yices_or},
        {"iff_term", l_yices_iff},
        {"imp_term", l_yices_implies},
        {"ite_term", l_yices_ite},
        {"distinct_terms", l_yices_distinct},
        {"apply_function", l_yices_application},
        {"parse_term", l_yices_parse_term},
        {"get_term_by_name", l_yices_get_term_by_name},
        {"assert_formula", l_yices_assert_formula},
        {"check_context", l_yices_check_context},
        {"get_model", l_yices_get_model},
        {"free_model", l_yices_free_model},
        {"get_bool_value", l_yices_get_bool_value},
        {"get_int_value", l_yices_get_int_value},
        {"get_real_value", l_yices_get_real_value},
        {"pp_term", l_yices_pp_term},
        {"pp_model", l_yices_pp_model},
        {NULL, NULL}
};


/////////////////////////////////////////////////////////////////////
// Creates module yices for lua with the functions above.
// 
// @function luaopen_yices
// @local here
// @tparam lua_State* L Pointer to lua state.
// 
// @return Table `yices` representing the module.
int luaopen_yices(lua_State *L) {
    // create the module
    luaL_register(L, "solver", l_yices_functions);
    
    return 1;
}