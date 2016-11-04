---------------------------------------------------------------------
-- Represents a multimedia document for its validation.
-- Uses library "SMT" for building the document representation and
-- performing its validation.
-- 
-- @module model
-- @author Joel dos Santos <joel@dossantos.cc>

require('model.scenario')
local smt = require('lib.smt')
local item = require('model.item')
local allen = require('model.allen')
local rcc = require('model.rcc')
local animation = require('model.animation')
local spatial = require('model.spatial')


--- Class table
-- @field INF Constant to represents an infinite value in time.
-- @field scenario Default scenario for document validation (`SCENARIO``.ST`).
-- @field t_size Default values for the canvas duration (`INF`).
-- @field x_size Default values for the canvas width (`1920`).
-- @field y_size Default values for the canvas height (`1080`).
-- @field num_selec Default number of selection events to be created for each item (`2`).
-- @field num_pause Default number of pause intervals to be created for each item (`2`).
-- @field num_item Item name counter. This value is used for creating item
-- names in case it is not provided.
local model = {}
model.INF = -1
model.FLOW_ALIGN = enum{"TOP", "LEFT", "CENTER", "RIGHT", "BOTTOM"}
model.scenario = SCENARIO.ST
model.t_size = model.INF
model.x_size = 1920
model.y_size = 1080
model.num_selec = 2
model.num_pause = 2
model.num_item = 0
model.num_flow = 0


---------------------------------------------------------------------
-- Creates a new model with the information provided. Starts the
-- solver in case it is not running yet.
-- 
-- @tparam table obj Table with several values to be used for the
-- model attributes. If `nil` default values are used.
-- 
-- @treturn model Object representing a model.
-- 
-- @raise Error if *obj* is not a table.
function model:new(obj)
    assert(not obj or typeof(obj) == 'table', 'Wrong type for argument obj.')
    
    if not smt.INIT then
        smt.init()
    end
    
    local obj = obj or {}
    return setmetatable(obj, self)
end


---------------------------------------------------------------------
-- Stop the solver, destroying all contexts and models.
-- 
-- @raise Error if the solver is not running.
function model:destroy()
    assert(smt.INIT, 'There is nothing to destroy.')
    
    smt.exit();
end


---------------------------------------------------------------------
-- Creates assertions to configure the variables representing an
-- interval. The following formulas are asserted.
--    (= c (/ (+ i e) 2))
--    (= e (+ i s))
-- 
-- @tparam term i Constant representing the interval init.
-- @tparam term c Constant representing the interval center.
-- @tparam term e Constant representing the interval end.
-- @tparam term s Constant representing the interval size.
-- @tparam boolean r Determines if the interval end is related to the
-- interval size.
-- 
-- @raise Error if one of the following occurs:
--
--  * one of the arguments does not have the correct type;
--  * an error occurs while creating the term;
--  * an error occurs while asserting.
function model:config_interval(i, c, e, s, r)
    assert(typeof(i) == 'term', 'Wrong type for argument i.')
    assert(typeof(c) == 'term', 'Wrong type for argument c.')
    assert(typeof(e) == 'term', 'Wrong type for argument e.')
    assert(typeof(s) == 'term', 'Wrong type for argument s.')
    
    smt.assert(self, smt.eq(c, smt.div(smt.sum{i, e}, smt.real(2))))
    if r then
        smt.assert(self, smt.lt(i, e))
    else
        smt.assert(self, smt.eq(e, smt.sum{i, s}))
    end
end


---------------------------------------------------------------------
-- Create a context for the document validation and create the
-- constants for representing the document *canvas* and time
-- constants.
-- 
-- The constants to be created will depend on the model `scenario`.
-- 
-- @raise Error if one of the following occurs:
--
--  * there is already a context for the document;
--  * an error occurs while creating the context;
--  * an error occurs while creating the basic document info.
function model:init_document()
    assert(not self.context, 'You must end the previous document first.')
    
    if not smt.CONTEXT[self] then
        smt.create_context(self)
    end
    
    if self.scenario == SCENARIO.T or self.scenario == SCENARIO.ST then
        self.I = smt.constant(smt.REAL, 'I')
        smt.assert(self, smt.gt(self.I, smt.real(0)))
    end
    
    if self.scenario == SCENARIO.ST then
        self.T = smt.constant(smt.REAL, 'T')
        smt.assert(self, smt.ge(self.T, smt.real(0)))
    end
    
    
    local _t = {
        ['t_size'] = self.t_size,
        ['x_size'] = self.x_size,
        ['x_init'] = 0,
        ['x_end'] = self.x_size,
        ['y_size'] = self.y_size,
        ['y_init'] = 0,
        ['y_end'] = self.y_size
    }
    self.canvas = item:new(self, 'canvas', _t)
    
    if self.scenario == SCENARIO.T or self.scenario == SCENARIO.ST then
        self.canvas.ti = smt.constant(smt.REAL, 'canvas.ti')
        self.canvas.tc = smt.constant(smt.REAL, 'canvas.tc')
        self.canvas.te = smt.constant(smt.REAL, 'canvas.te')
        self.canvas.ts = smt.constant(smt.REAL, 'canvas.ts')
        self.canvas.pl = smt.constant(smt.BOOL, 'canvas.pl')
        
        self:config_interval(self.canvas.ti, self.canvas.tc, self.canvas.te, self.canvas.ts)
        
        smt.assert(self, smt.eq(self.canvas.ti, smt.real(0)))
        if self.t_size ~= model.INF then
            smt.assert(self, smt.eq(self.canvas.ts, smt.real(self.t_size)))
        else
            smt.assert(self, smt.gt(self.canvas.ts, smt.real(0)))
        end
        smt.assert(self, smt.le(self.canvas.te, self.I))
        smt.assert(self, self.canvas.pl)
    end
    
    if self.scenario == SCENARIO.ST then
        self.canvas.oc = smt.constant(smt.BOOL, 'canvas.oc')
        
        smt.assert(self, self.canvas.oc)
    end
    
    if self.scenario == SCENARIO.S or self.scenario == SCENARIO.ST then
        self.canvas.xi = smt.constant(smt.REAL, 'canvas.xi')
        self.canvas.xc = smt.constant(smt.REAL, 'canvas.xc')
        self.canvas.xe = smt.constant(smt.REAL, 'canvas.xe')
        self.canvas.xs = smt.constant(smt.REAL, 'canvas.xs')
        self.canvas.yi = smt.constant(smt.REAL, 'canvas.yi')
        self.canvas.yc = smt.constant(smt.REAL, 'canvas.yc')
        self.canvas.ye = smt.constant(smt.REAL, 'canvas.ye')
        self.canvas.ys = smt.constant(smt.REAL, 'canvas.ys')
        
        self:config_interval(self.canvas.xi, self.canvas.xc, self.canvas.xe, self.canvas.xs)
        self:config_interval(self.canvas.yi, self.canvas.yc, self.canvas.ye, self.canvas.ys)
        
        smt.assert(self, smt.eq(self.canvas.xi, smt.real(0)))
        smt.assert(self, smt.eq(self.canvas.yi, smt.real(0)))
        smt.assert(self, smt.eq(self.canvas.xs, smt.real(self.x_size)))
        smt.assert(self, smt.eq(self.canvas.ys, smt.real(self.y_size)))
    end
    
    self.context = true
end


---------------------------------------------------------------------
-- Destroys a context and a model (if existent) after document
-- validation is performed.
-- 
-- @raise Error if one of the following occurs:
--
--  * there is not a context for the model;
--  * an error occurs while destroying the context and/or the model.
function model:end_document()
    assert(self.context, 'You must initiate the document first.')
    
    if self.model then
        smt.destroy_model(self);
    end
    smt.destroy_context(self);
end


---------------------------------------------------------------------
-- Checks whether the context is sat or not. In case it is, creates
-- a model with possible values for each constant.
-- 
-- @treturn bool True if the context is sat and a model was created.
-- 
-- @raise Error if one of the following occurs:
--
--  * there is not a context;
--  * an error occurs while checking the context or building the model.
function model:check()
    assert(self.context, 'You must initiate the document first.')
    
    self.model = smt.check(self)
    if self.model then
        smt.create_model(self)
    end
    return self.model
end


---------------------------------------------------------------------
-- Returns the values for each constant related to a given item.
-- Changes the value of attribute *eval* to true after evaluation.
-- 
-- The constants to be created will depend on the model `scenario`.
-- If the `scenario` is `T` or `ST`, values are evalueted only if
-- the item is part of the temporal scenario (`item.pl == true`).
-- 
-- @tparam item item Item object to have its value evaluated.
-- 
-- @raise Error if one of the following occurs:
--
--  * there is not a model for the context;
--  * item is not an item object;
--  * an error occurs while checking the context or building the model.
function model:eval(item)
    assert(self.model, 'There is no model for the document.')
    assert(typeof(item) == 'item', 'Wrong type for argument item.')
    
    local pl
    if self.scenario == SCENARIO.T or self.scenario == SCENARIO.ST then
        pl = smt.eval(self, item.pl, smt.BOOL)
    end
    if pl then
        item.eval = true
        smt.eval(self, item.ti, smt.REAL)
        smt.eval(self, item.tc, smt.REAL)
        smt.eval(self, item.te, smt.REAL)
        smt.eval(self, item.ts, smt.REAL)
        
        for _,i in ipairs(item.i_selec) do
            local p = smt.eval(self, i.pl, smt.BOOL)
            if p then
                i.eval = true
                smt.eval(self, i.ti, smt.REAL)
            end
        end
        for _,i in ipairs(item.i_pause) do
            local p = smt.eval(self, i.pl, smt.BOOL)
            if p then
                i.eval = true
                smt.eval(self, i.ti, smt.REAL)
                smt.eval(self, i.tc, smt.REAL)
                smt.eval(self, i.te, smt.REAL)
                smt.eval(self, i.ts, smt.REAL)
            end
        end
    end
    local oc
    if pl and self.scenario == SCENARIO.ST then
        oc = smt.eval(self, item.oc, smt.BOOL)
    end
    if self.scenario == SCENARIO.S or (oc and self.scenario == SCENARIO.ST) then
        item.eval = true
        smt.eval(self, item.xi, smt.REAL)
        smt.eval(self, item.xc, smt.REAL)
        smt.eval(self, item.xe, smt.REAL)
        smt.eval(self, item.xs, smt.REAL)
        smt.eval(self, item.yi, smt.REAL)
        smt.eval(self, item.yc, smt.REAL)
        smt.eval(self, item.ye, smt.REAL)
        smt.eval(self, item.ys, smt.REAL)
    end
end


---------------------------------------------------------------------
-- Creates a new item according to the information provided. It will
-- also create constants for representing the item in the context.
-- 
-- The constants to be created will depend on the model `scenario`.
-- 
-- Prototype information for the item follows considers the following
-- fields: name, t_size, x_size, x_init, x_end, y_size, y_init, y_end
-- described in the `item` class. Moreover, the following fields are
-- considered for prototype information:
-- 
--  * cond_end: determines whether or not the item's interval end is
--  given by a conditional.
--  * pausable: determines whether or not the item's interval can be
--  paused. In case it can, the number of pause intervals to be
--  created will depend on the model `num_pause` value.
--  * selectable: determines whether or not the item's interval can
--  be selected. In case it can, the number of selection events to
--  be created will depend on the model `num_selec` value.
-- 
-- @tparam table p Prototype information for the item.
-- @see model.item
-- 
-- @treturn item New item object.
-- 
-- @raise Error if one of the following occurs:
--
--  * there is not a context;
--  * the type of one of the arguments is not correct;
--  * an error occurs while asserting item info.
function model:new_item(p)
    assert(self.context, 'You must initiate the document first.')
    assert(not p or type(p) == 'table', 'Wrong type for argument p.')
    
    local p = p or {}
    if not p.name then
        self.num_item = self.num_item + 1
        p.name = 'item' .. tostring(self.num_item)
    end
    
    local i = item:new(self, p.name, p)
    i:configure(p.cond_end, p.pausable, p.selectable)
    
    return i
end


---------------------------------------------------------------------
-- Indicates the items to be executed as the document execution
-- begins. This method can only be usedin a `T` or `ST` `scenario`.
-- 
-- @tparam table items List of items to be executed as the document
-- execution begins.
-- 
-- @raise Error if one of the following occurs:
--
--  * there is not a context;
--  * the `scenario` is not `T` or `ST`
--  * `item` type is not correct;
--  * an error occurs while asserting item info.
function model:init(items)
    assert(self.context, 'You must initiate the document first.')
    assert(self.scenario ~= SCENARIO.S, "The model scenario must be either T or ST.")
    assert(type(items) == 'table', 'Wrong type for argument items.')
    
    for i, item in ipairs(items) do
        assert(typeof(item) == 'item', 'Element at index ' .. i .. ' must be an item')
        
        smt.assert(self, smt.land{item.pl, smt.eq(item.ti, self.canvas.ti)})
        item.t_init = 0
    end
end


---------------------------------------------------------------------
-- Relates two items according to one or more relations. Relations can
-- be either Allen relations or RCC relations.
-- 
-- Issuing more than one relation at the same time, using the relate
-- function means that relations are alternatives to each other. For
-- example:
--    m:relate(animation, {{allen.during,10}, allen.starts}, background)
-- means that either relation **during** or **starts** will be issued.
-- Furthermore, the item
--    {allen.during,10}
-- means that relation **during** will be parameterized with a delay
-- of 10 time units.
-- 
-- @tparam item item1 Item to participate in the relation.
-- @tparam table relation Relation(s) to be issued between `item1` and `item2`.
-- @tparam item item2 Item to participate in the relation.
-- 
-- @raise Error if one of the following occurs:
--
--  * there is not a context;
--  * the `scenario` is not `T` or `ST`
--  * one of the argument's type is not correct;
--  * an error occurs while asserting realtion info.
-- 
-- @see model.allen
-- @see model.rcc
-- 
-- @usage 
-- m:relate(animation, {{allen.during,10}, allen.during}, background)
function model:relate(item1, relation, item2)
    assert(self.context, 'You must initiate the document first.')
    assert(typeof(item1) == 'item', 'Wrong type for argument item1.')
    assert(type(relation) == 'table', 'Wrong type for argument relation.')
    assert(typeof(item2) == 'item', 'Wrong type for argument item2.')
    
    local exp = {}
    for _, rel in pairs(relation) do
        if type(rel) == "table" then
            exp[#exp + 1], exp_type = rel[1](item1, item2, unpack(rel, 2))
        else
            exp[#exp + 1], exp_type = rel(item1, item2)
        end
        assert(self.scenario == SCENARIO.ST or exp_type == self.scenario, 'This relation can not be asserted in the current scenario.')
    end
    
    local ext_var
    if exp_type == SCENARIO.S then
        if item1.oc and item2.oc then
            ext_var = smt.land{item1.oc, item2.oc}
        end
    else
        ext_var = smt.land{item1.pl, item2.pl}
    end
    
    if #exp == 1 then
        exp = exp[1]
    else
        exp = smt.lor(exp)
    end
    
    if ext_var then
        smt.assert(self, smt.imp(ext_var, exp))
    else
        smt.assert(self, exp)
    end
end


---------------------------------------------------------------------
-- Creates a relation indicating that if some items (`left`) are
-- present at the temporal scenario, then it also means that other
-- items (`right`) are also present at the temporal scenario.
-- 
-- Either `left` and `right` can indicate one or more items. The
-- equivalent to this is:
--    l1 /\ l2 /\ .. /\ ln <=> r1 /\ r2 /\ ... /\ rm
-- 
-- @tparam table left List of items to be placed at the left side.
-- @tparam table right List of items to be placed at the right side.
-- 
-- @raise Error if one of the following occurs:
--
--  * there is not a context;
--  * the `scenario` is not `T` or `ST`;
--  * one of the argument's type is not correct;
--  * an error occurs while asserting realtion info.
function model:place(left, right)
    assert(self.context, 'You must initiate the document first.')
    assert(self.scenario ~= SCENARIO.S, "The model scenario must be either T or ST.")
    assert(type(left) == 'table', 'Wrong type for argument left.')
    assert(type(right) == 'table', 'Wrong type for argument right.')
    
    local pl
    if #left > 1 then
        p = {}
        for _, i in ipairs(left) do
            p[#p + 1] = i.pl
        end
        pl = smt.land(p)
    else
        pl = left[1].pl
    end
    
    local pr
    if #right > 1 then
        p = {}
        for _, i in ipairs(right) do
            p[#p + 1] = i.pl
        end
        pr = smt.land(p)
    else
        pr = right[1].pl
    end
    
    smt.assert(self, smt.iff(pl, pr))
end


---------------------------------------------------------------------
-- Creates an expression that associates a variable to the smaller
-- variable from a list of pairs (variable, property), given that
-- property is true.
-- 
-- @tparam string var String representing the variable to have its
-- value set.
-- @tparam table props List of pairs (variable, property).
-- 
-- @treturn term An expression giving the possible values of `var`,
-- given that one of the properties in `props` is true.
local function first(var, props)
    local forms = {}
    for i, p in ipairs(props) do
        local f = {p[2]}
        for j,q in ipairs(props) do
            if j < i then
                if q[2] then
                    f[#f + 1] = smt.lor{smt.le(p[1], q[1]), smt.lnot(q[2])}
                else
                    f[#f + 1] = smt.le(p[1], q[1])
                end
            elseif j > i then
                if q[2] then
                    f[#f + 1] = smt.lor{smt.lt(p[1], q[1]), smt.lnot(q[2])}
                else
                    f[#f + 1] = smt.lt(p[1], q[1])
                end
            end
        end
        f[#f + 1] = smt.eq(var, p[1])
        forms[#forms + 1] = smt.land(f)
    end
    
    return smt.lor(forms)
end


---------------------------------------------------------------------
-- Creates an expression that associates a variable to the biggest
-- variable from a list of pairs (variable, property), given that
-- property is true.
-- 
-- @tparam string var String representing the variable to have its
-- value set.
-- @tparam table props List of pairs (variable, property).
-- 
-- @treturn term An expression giving the possible values of `var`,
-- given that one of the properties in `props` is true.
local function last(var, props)
    -- create formulas relating propositions
    local forms = {}
    for i, p in ipairs(props) do
        local f = {p[2]}
        for j,q in ipairs(props) do
            if j < i then
                if q[2] then
                    f[#f + 1] = smt.lor{smt.ge(p[1], q[1]), smt.lnot(q[2])}
                else
                    f[#f + 1] = smt.ge(p[1], q[1])
                end
            elseif j > i then
                if q[2] then
                    f[#f + 1] = smt.lor{smt.gt(p[1], q[1]), smt.lnot(q[2])}
                else
                    f[#f + 1] = smt.gt(p[1], q[1])
                end
            end
        end
        f[#f + 1] = smt.eq(var, p[1])
        forms[#forms + 1] = smt.land(f)
    end
    
    return smt.lor(forms)
end


---------------------------------------------------------------------
-- Creates a conditional relation among events. The event expressed
-- in `evt` will be determined by one of the events in `events`. The
-- first event in `events` to occurs will be the one used.
-- 
-- @tparam table evt An event occurrence in an item.
-- @tparam table events List of events occurrences.
-- 
-- @raise Error if one of the following occurs:
--
--  * there is not a context;
--  * one of the argument's type is not correct;
--  * an error occurs while asserting realtion info.
-- 
-- @see model.item.BEG
-- @see model.item.END
function model:conditional(evt, events)
    assert(self.context, 'You must initiate the document first.')
    assert(typeof(evt) == 'event', 'Wrong type for argument evt.')
    assert(type(events) == 'table', 'Wrong type for argument events.')
    
    local var
    local val
    
    
    if evt.BEG then
        var = evt.orig.ti
    elseif evt.END then
        var = evt.orig.te
    end
    
    
    if #events == 1 and evt.BEG then
        if events[1].del then
            if events[1].BEG then
                val = smt.eq(var, smt.sum{events[1].orig.ti, smt.real(events[1].del)})
            elseif events[1].END then
                val = smt.eq(var, smt.sum{events[1].orig.te, smt.real(events[1].del)})
            end
        else
            if events[1].BEG then
                val = smt.eq(var, events[1].orig.ti)
            elseif events[1].END then
                val = smt.eq(var, events[1].orig.te)
            end
        end
    else
        -- get the atomic propositions from the events
        local props = {}
        for _,e in ipairs(events) do
            local p = {}
            if e.del then
                if e.BEG then
                    p[1] = smt.sum{e[1].orig.ti, smt.real(e.del)}
                elseif e.END then
                    p[1] = smt.sum{e[1].orig.te, smt.real(e.del)}
                end
            else
                if e.BEG then
                    p[1] = e.orig.ti
                elseif e.END then
                    p[1] = e.orig.te
                end
            end
            p[2] = e.orig.pl
            props[#props + 1] = p
        end
        
        -- add aditional propositions if necessary
        if evt.END then
            if evt.orig.t_size == model.INF then
                -- t_end is already related to t_size. Item terminates with INF or some event
                props[#props + 1] = {self.I}
            else
                -- t_end is not related to t_size. Item terminated with t_size or some event
                props[#props + 1] = {smt.sum{evt.orig.ti, evt.orig.ts}}
                -- if item can be paused it might also terminates with INF
                if #evt.orig.i_pause > 0 then
                    props[#props + 1] = {self.I}
                    --TODO: pode um item estar pausado sendo infinito?
                end
            end
        end
        val = first(var, props)
    end
    
    smt.assert(self, smt.imp(evt.orig.pl, val))
end


---------------------------------------------------------------------
-- Creates a composition grouping a set of items. A set of relations
-- is issues among intems inside the composition. Relations are
-- created following the order they are listed in `items`.
-- 
-- According to the model `scenario` the composition can group items
-- in time, space or both.
-- 
-- @tparam table relation Relation(s) to be issued between items
-- inside the composition.
-- @tparam table items List of items to be grouped inside the
-- composition.
-- 
-- @treturn item Composition grouping items.
-- 
-- @raise Error if one of the following occurs:
--
--  * there is not a context;
--  * one of the argument's type is not correct;
--  * an error occurs while asserting realtion info.
-- 
-- @see model.relate
function model:composition(relation, items)
    assert(self.context, 'You must initiate the document first.')
    assert(type(relation) == 'table', 'Wrong type for argument relation.')
    assert(type(items) == 'table', 'Wrong type for argument items.')
    
    local comp = self:new_item{t_size = model.INF, cond_end = true}
    
    if self.scenario == SCENARIO.T or self.scenario == SCENARIO.ST then
        local ti = {}
        local te = {}
        local pl = {}
        for _,it in ipairs(items) do
            ti[#ti + 1] = {it.ti, it.pl}
            te[#te + 1] = {it.te, it.pl}
            pl[#pl + 1] = it.pl
        end
    
        -- comp exists only if some internal item exists
        smt.assert(self, smt.iff(comp.pl, smt.lor(pl)))
    
        -- comp begins with the first and ends with the last internal
        smt.assert(self, smt.imp(comp.pl, first(comp.ti, ti)))
        smt.assert(self, smt.imp(comp.pl, last(comp.te, te)))
    end
    
    if self.scenario == SCENARIO.S or self.scenario == SCENARIO.ST then
        local xi = {}
        local xe = {}
        local yi = {}
        local ye = {}
        local oc = {}
        for _,it in ipairs(items) do
            xi[#xi + 1] = {it.xi, it.oc}
            xe[#xe + 1] = {it.xe, it.oc}
            yi[#yi + 1] = {it.yi, it.oc}
            ye[#ye + 1] = {it.ye, it.oc}
            oc[#oc + 1] = it.oc
        end
        
        -- comp exists only if some internal item exists
        smt.assert(self, smt.iff(comp.oc, smt.lor(oc)))
        
        -- comp begins with the first and ends with the last internal in eaxh axis
        smt.assert(self, smt.imp(comp.oc, first(comp.xi, xi)))
        smt.assert(self, smt.imp(comp.oc, last(comp.xe, xe)))
        
        smt.assert(self, smt.imp(comp.oc, first(comp.yi, yi)))
        smt.assert(self, smt.imp(comp.oc, last(comp.ye, ye)))
    end
    
    -- issue the relations among all internal
    for i = 1, #items - 1 do
        self:relate(items[i], relation, items[i + 1])
    end
    
    return comp
end


---------------------------------------------------------------------
-- Creates an animation, defining a position variable as function of
-- time.
-- 
-- @tparam term anim_var Variable of the item to be animated.
-- @see model.item.LEFT
-- @see model.item.TOP
-- @see model.item.WIDTH
-- @see model.item.HEIGHT
-- @tparam function animation Function defining how the variable
-- `anim_var` will change with time.
-- @tparam table p Eventual parameters related to the animation.
-- @see model.animation
-- @tparam term/table t_init Term representing the initial time for
-- the animation or a Table with a point in time plus a delay.
-- @tparam term/table t_end Term representing the final time for
-- the animation or a Table with a point in time plus a delay.
-- @tparam bool anim_bef Indicates if the animation have to set the
-- value of the attribute before the animation begins.
-- @tparam bool anim_aft Indicates if the animation have to set the
-- value of the attribute before the animation ends.
-- 
-- @raise Error if one of the following occurs:
--
--  * there is not a context;
--  * one of the argument's type is not correct;
--  * an error occurs while asserting realtion info.
-- 
-- @usage 
-- m:animate(video.LEFT,
--           animation.polynomial, {0, 0.1, 0},
--           {video.ti, 45},
--           {video.ti, 51},
--           true, true)
-- m:animate(video.WIDTH,
--           animation.polynomial, {2, 0, 10},
--           video.ti,
--           video.te)
function model:animate(anim_var, animation, p, t_init, t_end, anim_bef, anim_aft)
    assert(self.context, 'You must initiate the document first.')
    assert(typeof(anim_var) == 'term', 'Wrong type for argument anim_var.')
    assert(type(animation) == 'function', 'Wrong type for argument animation.')
    assert(not p or type(p) == 'table', 'Wrong type for argument p.')
    local _t = typeof(t_init)
    assert(_t == 'term' or _t == 'table', 'Wrong type for argument t_init.')
    _t = typeof(t_end)
    assert(_t == 'term' or _t == 'table', 'Wrong type for argument t_end.')
    assert(anim_bef == nil or type(anim_bef) == 'boolean', 'Wrong type for argument anim_bef.')
    assert(anim_aft == nil or type(anim_aft) == 'boolean', 'Wrong type for argument anim_aft.')
    
    -- calculate the initial time
    local t_ai
    if type(t_init) == 'table' then
        assert(typeof(t_init[1]) == 'term', 'Wrong type for t_init begin point.')
        assert(type(t_init[2]) == 'number', 'Wrong type for t_init delay.')
        
        t_ai = smt.sum{t_init[1], smt.real(t_init[2])}
    else
        assert(typeof(t_init) == 'term', 'Wrong type for t_init.')
        
        t_ai = t_init
    end
    
    -- calculate the final time
    local t_ae
    if type(t_end) == 'table' then
        assert(typeof(t_end[1]) == 'term', 'Wrong type for t_end begin point.')
        assert(type(t_end[2]) == 'number', 'Wrong type for t_end delay.')
        
        t_ae = smt.sum{t_end[1], smt.real(t_end[2])}
    else
        assert(typeof(t_end) == 'term', 'Wrong type for t_end.')
        
        t_ae = t_end
    end
    
    -- time variable
    local t_var = smt.sub(self.T, t_ai)
    
    -- get animation functions
    local v_bef
    local v_dur
    local v_aft
    v_bef, v_dur, v_aft = animation(t_var, t_ae, p)
    
    if anim_bef then
        smt.assert(self, smt.imp(smt.lt(self.T, t_ai), smt.eq(anim_var, v_bef)))
    end
    
    smt.assert(self, smt.imp(smt.between(t_ai, self.T, t_ae), v_dur))
    
    if anim_aft then
        smt.assert(self, smt.imp(smt.gt(self.T, t_ae), smt.eq(anim_var, v_aft)))
    end
end


---------------------------------------------------------------------
-- Changes the value of a variable inside a given interval.
-- The function returns the interval for each the value is the one
-- indicated.
-- 
-- @tparam term anim_var Variable of the item to be animated.
-- @see model.item.LEFT
-- @see model.item.TOP
-- @see model.item.WIDTH
-- @see model.item.HEIGHT
-- @tparam number value The value for the variable.
-- @tparam item interval An interval to be used. In this case the
-- function will not create a new interval for controling the
-- variable value.
-- 
-- @treturn item Item representing the interval for each the value
-- is the one indicated.
-- 
-- @raise Error if one of the following occurs:
--
--  * there is not a context;
--  * one of the argument's type is not correct;
--  * an error occurs while asserting realtion info.
function model:set(anim_var, value, interval)
    assert(self.context, 'You must initiate the document first.')
    assert(typeof(anim_var) == 'term', 'Wrong type for argument anim_var.')
    assert(type(value) == 'number', 'Wrong type for argument value.')
    assert(not interval or typeof(interval) == 'item', 'Wrong type for argument interval.')
        
    local interval = interval or self:new_item()
    smt.assert(self, smt.imp(smt.between(interval.ti, self.T, interval.te), smt.eq(anim_var, smt.real(value))))
    
    return interval
end


---------------------------------------------------------------------
-- Creates a canvas where internal items are arrenged in a flow.
-- The function returns the canvas item.
-- 
-- @tparam table p Prototype information for the canvas item.
-- @tparam table items An ordered list of items to be in the flow.
-- @tparam number hspace Horizontal spacing among items.
-- @tparam number vspace Vertical spacing among items.
-- @tparam model.FLOW_ALIGN l_align Vertical alignment among items in
-- a line. The default value is `model.FLOW_ALIGN.CENTER`.
-- @tparam model.FLOW_ALIGN h_align Horizontal alignment inside the
-- flow. The default value is `model.FLOW_ALIGN.CENTER`.
-- @tparam model.FLOW_ALIGN v_align Vertical alignment inside the
-- flow. The default value is `model.FLOW_ALIGN.CENTER`.
-- 
-- @treturn item Item representing the canvas.
-- 
-- @raise Error if one of the following occurs:
--
--  * there is not a context;
--  * one of the argument's type is not correct;
--  * an error occurs while asserting realtion info.
function model:flow(p, items, hspace, vspace, l_align, h_align, v_align)
    assert(self.context, 'You must initiate the document first.')
    assert(not p or type(p) == 'table', 'Wrong type for argument p.')
    assert(type(items) == 'table', 'Wrong type for argument items.')
    assert(type(hspace) == 'number', 'Wrong type for argument hspace.')
    assert(type(vspace) == 'number', 'Wrong type for argument vspace.')
    assert(not l_align or type(l_align) == 'number', 'Wrong type for argument l_align.')
    assert(not h_align or type(h_align) == 'number', 'Wrong type for argument h_align.')
    assert(not v_align or type(v_align) == 'number', 'Wrong type for argument v_align.')
    
    if l_align == nil or l_align == model.FLOW_ALIGN.LEFT or l_align == model.FLOW_ALIGN.RIGHT then
        l_align = model.FLOW_ALIGN.CENTER
    end
    if h_align == nil or h_align == model.FLOW_ALIGN.TOP or h_align == model.FLOW_ALIGN.BOTTOM then
        h_align = model.FLOW_ALIGN.CENTER
    end
    if v_align == nil or v_align == model.FLOW_ALIGN.LEFT or v_align == model.FLOW_ALIGN.RIGHT then
        v_align = model.FLOW_ALIGN.CENTER
    end
    
    local flow_canvas = self:new_item(p)
    
    -- flow exists only if some internal item exists
    local p = {}
    for _,it in ipairs(items) do
        p[#p + 1] = it.oc
    end
    smt.assert(self, smt.iff(flow_canvas.oc, smt.lor(p)))
    
    -- create flow auxiliary functions if they do not exist
    if not self.flow_funcs then
        self.flow_funcs = {
            lin = smt.create_function({smt.INT, smt.INT}, smt.INT, 'lin'),
            top = smt.create_function({smt.INT, smt.INT}, smt.REAL, 'top'),
            bot = smt.create_function({smt.INT, smt.INT}, smt.REAL, 'bot'),
            first = smt.create_function({smt.INT, smt.INT}, smt.BOOL, 'first'),
            lxi = smt.create_function({smt.INT, smt.INT}, smt.REAL, 'l.xi'),
            lxc = smt.create_function({smt.INT, smt.INT}, smt.REAL, 'l.xc'),
            lxe = smt.create_function({smt.INT, smt.INT}, smt.REAL, 'l.xe'),
            lxs = smt.create_function({smt.INT, smt.INT}, smt.REAL, 'l.xs'),
            lyi = smt.create_function({smt.INT, smt.INT}, smt.REAL, 'l.yi'),
            lyc = smt.create_function({smt.INT, smt.INT}, smt.REAL, 'l.yc'),
            lye = smt.create_function({smt.INT, smt.INT}, smt.REAL, 'l.ye'),
            lys = smt.create_function({smt.INT, smt.INT}, smt.REAL, 'l.ys')
        }
    end
    
    -- flow info
    self.num_flow = self.num_flow + 1
    local nf = smt.int(self.num_flow)
    local lin = self.flow_funcs.lin
    local top = self.flow_funcs.top
    local bot = self.flow_funcs.bot
    local first = self.flow_funcs.first
    local lxi = self.flow_funcs.lxi
    local lxc = self.flow_funcs.lxc
    local lxe = self.flow_funcs.lxe
    local lxs = self.flow_funcs.lxs
    local lyi = self.flow_funcs.lyi
    local lyc = self.flow_funcs.lyc
    local lye = self.flow_funcs.lye
    local lys = self.flow_funcs.lys
    
    -- create hspace and vspace constants
    local vs = smt.constant(smt.REAL, 'vspace')
    local hs = smt.constant(smt.REAL, 'hspace')
    smt.assert(self, smt.eq(hs, smt.real(hspace)))
    smt.assert(self, smt.eq(vs, smt.real(vspace)))
    
    -- flow relation among items
    for i = 1, #items - 1 do
        local item_a = items[i]
        local item_b = items[i+1]
        local pos_a = smt.int(i)
        local pos_b = smt.int(i+1)
        
        
        local l_align_exp
        if l_align == model.FLOW_ALIGN.TOP then
            l_align_exp = smt.eq(item_b.yi, item_a.yi)
        elseif l_align == model.FLOW_ALIGN.CENTER then
            l_align_exp = smt.eq(item_b.yc, item_a.yc)
        elseif l_align == model.FLOW_ALIGN.BOTTOM then
            l_align_exp = smt.eq(item_b.ye, item_a.ye)
        end
        
        local h_align_exp
        if h_align == model.FLOW_ALIGN.LEFT then
            h_align_exp = smt.eq(smt.apply(lxi, {nf, smt.apply(lin, {nf, pos_b})}), flow_canvas.xi)
        elseif h_align == model.FLOW_ALIGN.CENTER then
            h_align_exp = smt.eq(smt.apply(lxc, {nf, smt.apply(lin, {nf, pos_b})}), flow_canvas.xc)
        elseif h_align == model.FLOW_ALIGN.RIGHT then
            h_align_exp = smt.eq(smt.apply(lxe, {nf, smt.apply(lin, {nf, pos_b})}), flow_canvas.xe)
        end
        
        local h_align_exp
        if h_align == model.FLOW_ALIGN.LEFT then
            h_align_exp = smt.eq(smt.apply(lxi, {nf, smt.apply(lin, {nf, pos_b})}), flow_canvas.xi)
        elseif h_align == model.FLOW_ALIGN.CENTER then
            h_align_exp = smt.eq(smt.apply(lxc, {nf, smt.apply(lin, {nf, pos_b})}), flow_canvas.xc)
        elseif h_align == model.FLOW_ALIGN.RIGHT then
            h_align_exp = smt.eq(smt.apply(lxe, {nf, smt.apply(lin, {nf, pos_b})}), flow_canvas.xe)
        end
        
        
        smt.assert(self, 
            smt.ite(smt.lnot(item_b.oc),
                    smt.land{
                        smt.eq(smt.apply(lin, {nf, pos_b}), smt.apply(lin, {nf, pos_a})),
                        smt.eq(smt.apply(top, {nf, pos_b}), smt.apply(top, {nf, pos_a})),
                        smt.eq(smt.apply(bot, {nf, pos_b}), smt.apply(bot, {nf, pos_a})),
                        l_align_exp,
                        smt.ite(item_a.oc,
                                smt.land{
                                    smt.eq(item_b.xi, item_a.xe),
                                    smt.lnot(smt.apply(first, {nf, pos_b}))
                                },
                                smt.land{
                                    smt.eq(item_b.xi, item_a.xi),
                                    smt.iff(smt.apply(first, {nf, pos_b}), smt.apply(first, {nf, pos_a}))
                                })
                    },
                    smt.ite(item_a.oc,
                            smt.ite(smt.le(smt.sum{smt.sub(item_a.xe, smt.apply(lxi, {nf, smt.apply(lin, {nf, pos_a})})),hs, item_b.xs}, flow_canvas.xs),
                                    smt.land{
                                        smt.eq(smt.apply(lin, {nf, pos_b}), smt.apply(lin, {nf, pos_a})),
                                        smt.ite(smt.lt(item_b.yi, smt.apply(top, {nf, pos_a})),
                                                smt.eq(smt.apply(top, {nf, pos_b}), item_b.yi),
                                                smt.eq(smt.apply(top, {nf, pos_b}), smt.apply(top, {nf, pos_a}))
                                        ),
                                        smt.ite(smt.gt(item_b.ye, smt.apply(bot, {nf, pos_a})),
                                                smt.eq(smt.apply(bot, {nf, pos_b}), item_b.ye),
                                                smt.eq(smt.apply(bot, {nf, pos_b}), smt.apply(bot, {nf, pos_a}))
                                        ),
                                        smt.lnot(smt.apply(first, {nf, pos_b})),
                                        smt.eq(item_b.xi, smt.sum{item_a.xe, hs}),
                                        l_align_exp
                                    },
                                    smt.land{
                                        smt.eq(smt.apply(lin, {nf, pos_b}), smt.sum{smt.apply(lin, {nf, pos_a}), smt.int(1)}),
                                        smt.eq(smt.apply(top, {nf, pos_b}), item_b.yi),
                                        smt.eq(smt.apply(bot, {nf, pos_b}), item_b.ye),
                                        smt.apply(first, {nf, pos_b}),
                                        smt.eq(smt.apply(lxe, {nf, smt.apply(lin, {nf, pos_a})}), item_a.xe),
                                        smt.eq(smt.apply(lyi, {nf, smt.apply(lin, {nf, pos_a})}), smt.apply(top, {nf, pos_a})),
                                        smt.eq(smt.apply(lye, {nf, smt.apply(lin, {nf, pos_a})}), smt.apply(bot, {nf, pos_a})),
                                        smt.eq(smt.apply(lxc, {nf, smt.apply(lin, {nf, pos_b})}), smt.sum{smt.apply(lxi, {nf, smt.apply(lin, {nf, pos_b})}), smt.div(smt.apply(lxs, {nf, smt.apply(lin, {nf, pos_b})}), smt.real(2))}),
                                        smt.eq(smt.apply(lxe, {nf, smt.apply(lin, {nf, pos_b})}), smt.sum{smt.apply(lxi, {nf, smt.apply(lin, {nf, pos_b})}), smt.apply(lxs, {nf, smt.apply(lin, {nf, pos_b})})}),
                                        smt.eq(smt.apply(lyc, {nf, smt.apply(lin, {nf, pos_b})}), smt.sum{smt.apply(lyi, {nf, smt.apply(lin, {nf, pos_b})}), smt.div(smt.apply(lys, {nf, smt.apply(lin, {nf, pos_b})}), smt.real(2))}),
                                        smt.eq(smt.apply(lye, {nf, smt.apply(lin, {nf, pos_b})}), smt.sum{smt.apply(lyi, {nf, smt.apply(lin, {nf, pos_b})}), smt.apply(lys, {nf, smt.apply(lin, {nf, pos_b})})}),
                                        h_align_exp,
                                        smt.eq(smt.apply(lxi, {nf, smt.apply(lin, {nf, pos_b})}), item_b.xi),
                                        smt.eq(smt.apply(lyi, {nf, smt.apply(lin, {nf, pos_b})}), smt.sum{smt.apply(lye, {nf, smt.apply(lin, {nf, pos_a})}), vs})
                                    }
                            ),
                            smt.ite(smt.apply(first, {nf, pos_a}),
                                    smt.land{
                                        smt.eq(smt.apply(lin, {nf, pos_b}), smt.apply(lin, {nf, pos_a})),
                                        smt.eq(smt.apply(top, {nf, pos_b}), item_b.yi),
                                        smt.eq(smt.apply(bot, {nf, pos_b}), item_b.ye),
                                        smt.eq(item_b.xi, item_a.xi)
                                    },
                                    smt.ite(smt.le(smt.sum{smt.sub(item_a.xi, smt.apply(lxi, {nf, smt.apply(lin, {nf, pos_a})})), hs, item_b.xs}, flow_canvas.xs),
                                            smt.land{
                                                smt.eq(smt.apply(lin, {nf, pos_b}), smt.apply(lin, {nf, pos_a})),
                                                smt.ite(smt.lt(item_b.yi, smt.apply(top, {nf, pos_a})),
                                                    smt.eq(smt.apply(top, {nf, pos_b}), item_b.yi),
                                                    smt.eq(smt.apply(top, {nf, pos_b}), smt.apply(top, {nf, pos_a}))
                                                ),
                                                smt.ite(smt.gt(item_b.ye, smt.apply(bot, {nf, pos_a})),
                                                    smt.eq(smt.apply(bot, {nf, pos_b}), item_b.ye),
                                                    smt.eq(smt.apply(bot, {nf, pos_b}), smt.apply(bot, {nf, pos_a}))
                                                ),
                                                smt.lnot(smt.apply(first, {nf, pos_b})),
                                                smt.eq(item_b.xi, smt.sum{item_a.xi, hs}),
                                                l_align_exp
                                            },
                                            smt.land{
                                                smt.eq(smt.apply(lin, {nf, pos_b}), smt.sum{smt.apply(lin, {nf, pos_a}), smt.int(1)}),
                                                smt.eq(smt.apply(top, {nf, pos_b}), item_b.yi),
                                                smt.eq(smt.apply(bot, {nf, pos_b}), item_b.ye),
                                                smt.apply(first, {nf, pos_b}),
                                                smt.eq(smt.apply(lxe, {nf, smt.apply(lin, {nf, pos_a})}), item_a.xi),
                                                smt.eq(smt.apply(lyi, {nf, smt.apply(lin, {nf, pos_a})}), smt.apply(top, {nf, pos_a})),
                                                smt.eq(smt.apply(lye, {nf, smt.apply(lin, {nf, pos_a})}), smt.apply(bot, {nf, pos_a})),
                                                smt.eq(smt.apply(lxc, {nf, smt.apply(lin, {nf, pos_b})}), smt.sum{smt.apply(lxi, {nf, smt.apply(lin, {nf, pos_b})}), smt.div(smt.apply(lxs, {nf, smt.apply(lin, {nf, pos_b})}), smt.real(2))}),
                                                smt.eq(smt.apply(lxe, {nf, smt.apply(lin, {nf, pos_b})}), smt.sum{smt.apply(lxi, {nf, smt.apply(lin, {nf, pos_b})}), smt.apply(lxs, {nf, smt.apply(lin, {nf, pos_b})})}),
                                                smt.eq(smt.apply(lyc, {nf, smt.apply(lin, {nf, pos_b})}), smt.sum{smt.apply(lyi, {nf, smt.apply(lin, {nf, pos_b})}), smt.div(smt.apply(lys, {nf, smt.apply(lin, {nf, pos_b})}), smt.real(2))}),
                                                smt.eq(smt.apply(lye, {nf, smt.apply(lin, {nf, pos_b})}), smt.sum{smt.apply(lyi, {nf, smt.apply(lin, {nf, pos_b})}), smt.apply(lys, {nf, smt.apply(lin, {nf, pos_b})})}),
                                                h_align_exp,
                                                smt.eq(smt.apply(lxi, {nf, smt.apply(lin, {nf, pos_b})}), item_b.xi),
                                                smt.eq(smt.apply(lyi, {nf, smt.apply(lin, {nf, pos_b})}), smt.sum{smt.apply(lye, {nf, smt.apply(lin, {nf, pos_a})}), vs})
                                            })))))
    end
    
    local n = smt.int(#items)
    
    smt.assert(self, smt.eq(smt.apply(lin, {nf, smt.int(1)}), smt.int(1)))
    smt.assert(self, smt.eq(smt.apply(top, {nf, smt.int(1)}), items[1].yi))
    smt.assert(self, smt.eq(smt.apply(bot, {nf, smt.int(1)}), items[1].ye))
    smt.assert(self, smt.apply(first, {nf, smt.int(1)}))
    smt.assert(self, smt.eq(smt.apply(lxc, {nf, smt.apply(lin, {nf, smt.int(1)})}), smt.sum{smt.apply(lxi, {nf, smt.apply(lin, {nf, smt.int(1)})}), smt.div(smt.apply(lxs, {nf, smt.apply(lin, {nf, smt.int(1)})}), smt.real(2))}))
    smt.assert(self, smt.eq(smt.apply(lxe, {nf, smt.apply(lin, {nf, smt.int(1)})}), smt.sum{smt.apply(lxi, {nf, smt.apply(lin, {nf, smt.int(1)})}), smt.apply(lxs, {nf, smt.apply(lin, {nf, smt.int(1)})})}))
    smt.assert(self, smt.eq(smt.apply(lyc, {nf, smt.apply(lin, {nf, smt.int(1)})}), smt.sum{smt.apply(lyi, {nf, smt.apply(lin, {nf, smt.int(1)})}), smt.div(smt.apply(lys, {nf, smt.apply(lin, {nf, smt.int(1)})}), smt.real(2))}))
    smt.assert(self, smt.eq(smt.apply(lye, {nf, smt.apply(lin, {nf, smt.int(1)})}), smt.sum{smt.apply(lyi, {nf, smt.apply(lin, {nf, smt.int(1)})}), smt.apply(lys, {nf, smt.apply(lin, {nf, smt.int(1)})})}))
    if h_align == model.FLOW_ALIGN.LEFT then
        smt.assert(self, smt.eq(smt.apply(lxi, {nf, smt.apply(lin, {nf, smt.int(1)})}), flow_canvas.xi))
    elseif h_align == model.FLOW_ALIGN.CENTER then
        smt.assert(self, smt.eq(smt.apply(lxc, {nf, smt.apply(lin, {nf, smt.int(1)})}), flow_canvas.xc))
    elseif h_align == model.FLOW_ALIGN.RIGHT then
        smt.assert(self, smt.eq(smt.apply(lxe, {nf, smt.apply(lin, {nf, smt.int(1)})}), flow_canvas.xe))
    end
    smt.assert(self, smt.eq(smt.apply(lxi, {nf, smt.apply(lin, {nf, smt.int(1)})}), items[1].xi))
    
    smt.assert(self, smt.ite(items[#items].oc,
                            smt.eq(smt.apply(lxe, {nf, smt.apply(lin, {nf, n})}), items[#items].xe),
                            smt.eq(smt.apply(lxe, {nf, smt.apply(lin, {nf, n})}), items[#items].xi)))
    smt.assert(self, smt.eq(smt.apply(lyi, {nf, smt.apply(lin, {nf, n})}), smt.apply(top, {nf, n})))
    smt.assert(self, smt.eq(smt.apply(lye, {nf, smt.apply(lin, {nf, n})}), smt.apply(bot, {nf, n})))
    
    smt.assert(self, smt.eq(smt.apply(lyc, {nf, smt.int(0)}), smt.sum{smt.apply(lyi, {nf, smt.int(0)}), smt.div(smt.apply(lys, {nf, smt.int(0)}), smt.real(2))}))
    smt.assert(self, smt.eq(smt.apply(lye, {nf, smt.int(0)}), smt.sum{smt.apply(lyi, {nf, smt.int(0)}), smt.apply(lys, {nf, smt.int(0)})}))
    if v_align == model.FLOW_ALIGN.TOP then
        smt.assert(self, smt.eq(smt.apply(lyi, {nf, smt.int(0)}), flow_canvas.yi))
    elseif v_align == model.FLOW_ALIGN.CENTER then
        smt.assert(self, smt.eq(smt.apply(lyc, {nf, smt.int(0)}), flow_canvas.yc))
    elseif v_align == model.FLOW_ALIGN.BOTTOM then
        smt.assert(self, smt.eq(smt.apply(lye, {nf, smt.int(0)}), flow_canvas.ye))
    end
    smt.assert(self, smt.eq(smt.apply(lyi, {nf, smt.int(0)}), smt.apply(lyi, {nf, smt.apply(lin, {nf, smt.int(1)})})))
    smt.assert(self, smt.eq(smt.apply(lye, {nf, smt.int(0)}), smt.apply(lye, {nf, smt.apply(lin, {nf, n})})))
    
    return flow_canvas
end


---------------------------------------------------------------------
-- Creates a composition grouping a set of items. All items inside
-- the composition are distributed according one of the following
-- options in `spatial.BORD`.
-- INIT:
--    [ item1 ]     [ item2     ] [ item3   ]
--    |------d------|------d------|
-- 
-- CENTER:
--    [ item1 ]   [ item2     ]  [ item3   ]
--        |------d------|------d------|
-- 
-- END:
--    [ item1 ] [ item2     ]   [ item3   ]
--            |------d------|------d------|
-- 
-- OUT:
--    [ item1 ]   [ item2     ]   [ item3   ]
--            |-d-|           |-d-|
-- 
-- @tparam table items Regions to be distributed.
-- @tparam spatial.AXIS axis The axis where to define the constraint.
-- @tparam spatial.BORD bord Bord to use for distributing regions.
-- @tparam string var Variable to use as the space among regions.
-- 
-- @treturn term Term representing the composition.
-- 
-- @raise Error if one of the following occurs:
--
--  * there is not a context;
--  * the `scenario` is not `S` or `ST`;
--  * one of the argument's type is not correct;
--  * an error occurs while building realtion info.
function model:distribute(items, axis, bord)
    assert(self.context, 'You must initiate the document first.')
    assert(self.scenario ~= SCENARIO.T, "The model scenario must be either T or ST.")
    assert(type(items) == 'table', 'Wrong type for argument items.')
    assert(type(axis) == 'number', 'Wrong type for argument axis.')
    assert(type(bord) == 'number', 'Wrong type for argument bord.')
    
    local field
    if axis == spatial.AXIS.X then
        field = 'x'
    elseif axis == spatial.AXIS.Y then
        field = 'y'
    end
    
    if bord == spatial.BORD.INIT then
        field = field .. 'i'
    elseif bord == spatial.BORD.CENTER then
        field = field .. 'c'
    elseif bord == spatial.BORD.END then
        field = field .. 'e'
    elseif bord ~= spatial.BORD.OUT then
        error('spatial.BORD option not supported', 2)
    end
    
    local comp = self:new_item()
    
    local yi = {}
    local ye = {}
    local oc = {}
    for _,it in ipairs(items) do
        yi[#yi + 1] = {it.yi}
        ye[#ye + 1] = {it.ye}
        oc[#oc + 1] = it.oc
    end
    
    -- comp begins with the first and ends with the last internal in eaxh axis
    local exp = smt.land{
                             smt.eq(comp.xi, items[1].xi),
                             smt.eq(comp.xe, items[#items].xe),
                             first(comp.yi, yi),
                             last(comp.ye, ye)
                        }
    
    if self.scenario == SCENARIO.ST then
        smt.assert(self, smt.imp(comp.oc, exp))
        
        -- comp exists only if some internal item exists
        smt.assert(self, smt.iff(comp.oc, smt.land(oc)))
    else
        smt.assert(self, exp)
    end
    
    
    -- create the distribute expression
    local var = smt.constant(smt.REAL)
    smt.assert(self, smt.gt(var, smt.real(0)))
    
    local exp = {}
    if bord ~= spatial.BORD.OUT then
        for i = 1, #items-1 do
            exp[#exp + 1] = smt.gt(items[i+1].xi, items[i].xe)
            exp[#exp + 1] = smt.eq(items[i+1][field], smt.sum{items[i][field], var})
        end
    else
        for i = 1, #items-1 do
            exp[#exp + 1] = smt.gt(items[i+1].xi, items[i].xe)
            exp[#exp + 1] = smt.eq(items[i+1][field .. 'i'], smt.sum{items[i][field .. 'e'], var})
        end
    end
    
    smt.assert(self, smt.land(exp))
    
    return comp, var
end


---------------------------------------------------------------------
-- Indicates the items to be executed as the document execution
-- begins. This method can only be usedin a `T` or `ST` `scenario`.
-- 
-- @tparam table items List of items to be executed as the document
-- execution begins.
-- 
-- @raise Error if one of the following occurs:
--
--  * there is not a context;
--  * the `scenario` is not `T` or `ST`
--  * `item` type is not correct;
--  * an error occurs while asserting item info.
function model:inside(item1, item2)
    assert(self.context, 'You must initiate the document first.')
    assert(typeof(item1) == 'item', 'Wrong type for argument item1.')
    assert(typeof(item2) == 'item', 'Wrong type for argument item2.')
    
    if self.scenario == SCENARIO.T or self.scenario == SCENARIO.ST then
        smt.assert(self, smt.ge(item1.ti, item2.ti))
        smt.assert(self, smt.le(item1.te, item2.te))
    end
    
    if self.scenario == SCENARIO.S or self.scenario == SCENARIO.ST then
        smt.assert(self, smt.ge(item1.xi, item2.xi))
        smt.assert(self, smt.le(item1.xe, item2.xe))
        smt.assert(self, smt.ge(item1.yi, item2.yi))
        smt.assert(self, smt.le(item1.ye, item2.ye))
    end
end


---------------------------------------------------------------------
-- Sets the value of variable T for checking the context.
-- 
-- @tparam number value The value for T.
-- 
-- @raise Error if one of the following occurs:
--
--  * there is not a context;
--  * the `scenario` is not `T` or `ST`;
--  * argument value is not a number;
--  * an error occurs while asserting realtion info.
function model:setTime(value)
    assert(self.context, 'You must initiate the document first.')
    assert(self.scenario ~= SCENARIO.S, "The model scenario must be either T or ST.")
    assert(type(value) == 'number', 'Wrong type for argument value.')
    
    smt.assert(self, smt.eq(self.T, smt.real(value)))
end


---------------------------------------------------------------------
-- Sets the value of variable T and checking the context. The value
-- of T is asserted inside a backtracking point, so that other values
-- of T can be used in sequential calls to this function. It also
-- evaluates the positioning attrubutes for each item that is being
-- presented in time T.
-- 
-- @tparam number value The value for T.
-- @tparam table items Items to have its position evaluated.
-- 
-- @raise Error if one of the following occurs:
--
--  * there is not a context;
--  * the `scenario` is not `T` or `ST`;
--  * one of the argument's type is not correct;
--  * an error occurs while asserting realtion info.
function model:checkInTime(value, items)
    assert(self.context, 'You must initiate the document first.')
    assert(self.scenario ~= SCENARIO.S, "The model scenario must be either T or ST.")
    assert(type(value) == 'number', 'Wrong type for argument value.')
    assert(type(items) == 'table', 'Wrong type for argument items.')
    
    smt.mark_backtrack(self)
    smt.assert(self, smt.eq(self.T, smt.real(value)))
    self:check()
    for _,item in ipairs(items) do
        if smt.eval(self, item.oc, smt.BOOL) then
            item.eval = true
            smt.eval(self, item.xi, smt.REAL)
            smt.eval(self, item.xe, smt.REAL)
            smt.eval(self, item.xs, smt.REAL)
            smt.eval(self, item.yi, smt.REAL)
            smt.eval(self, item.ye, smt.REAL)
            smt.eval(self, item.ys, smt.REAL)
        else
            item.eval = false
            item.xi.value = nil
            item.xe.value = nil
            item.xs.value = nil
            item.yi.value = nil
            item.ye.value = nil
            item.ys.value = nil
        end
    end
    smt.backtrack(self)
end


model.__type = 'model'
model.__index = model
return model