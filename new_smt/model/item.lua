---------------------------------------------------------------------
-- Class to represent media items together with their relations.
--
-- @module model.item
-- @author Joel dos Santos <joel@dossantos.cc>

local smt = require('lib.smt')


--- Class to represent a type. Holds information about the type.
-- @field TYPE_BEG Type begin for the event.
-- @field TYPE_END Type end for the envet.
-- @field __type Class type name.
-- @field new Function to create new type objects.
local event = {
    TYPE_BEG = 'BEG',
    TYPE_END = 'END',
    
    __type = 'event',
    
    new = function (self, o, t, d)
        assert(typeof(o) == 'item', 'Wrong type for argument o.')
        assert(t == self.TYPE_BEG or t == self.TYPE_END, 'Wrong type for argument t.')
        assert(not d or ({typeof(d)})[2] == 'number', 'Wrong type for argument d.')
        
        self.__index = self
        return setmetatable({orig = o, [t] = true, del = d}, self)
    end
}


--- Class table
-- @field name Item's name.
-- @field t_size Duration of the item's interval.
-- @field x_size Width of item's region.
-- @field x_init Left position of item's region.
-- @field x_end Right position of item's region.
-- @field y_size Height of item's region.
-- @field y_init Top position of item's region.
-- @field y_end Bottom position of item's region.
-- @field eval Indicates whether there is a model for the item.
-- @field model Pointer to the item's parent model.
-- @field i_pause Pause intervals related to the item interval.
-- @field i_selec Selection events related to the item interval.
-- @field anchors Items anchored in the item.
local item = {}


---------------------------------------------------------------------
-- Creates a new item with a given name and the information provided.
-- 
-- @tparam model model The model where the item will be created.
-- @tparam string item_name Name of the interval.
-- @tparam table p Table with several values to be used for
-- the attributes. If `nil` default values are used (if available).
-- 
-- @treturn item Object representing an item.
-- 
-- @raise Error if any of the parameters are of wrong type.
function item:new(model, item_name, p)
    assert(typeof(model) == 'model', 'Wrong type for argument model.')
    assert(typeof(item_name) == 'string', 'Wrong type for argument item_name.')
    assert(not p or typeof(p) == 'table', 'Wrong type for argument p.')
    
    local p = p or {}
    
    obj = {}
    obj.name = item_name
    obj.model = model
    if model.scenario == SCENARIO.T or model.scenario == SCENARIO.ST then
        obj.t_size = p.t_size or model.INF
    end
    obj.x_size = p.x_size
    obj.x_init = p.x_init
    obj.x_end = p.x_end
    obj.y_size = p.y_size
    obj.y_init = p.y_init
    obj.y_end = p.y_end
    obj.i_pause = {}
    obj.i_selec = {}
    obj.anchors = {}
    
    return setmetatable(obj, self)
end


---------------------------------------------------------------------
-- Configures the item according to the information provided. It will
-- also create constants for representing the item in the context.
-- 
-- The constants to be created will depend on the model `scenario`.
-- 
-- @tparam boolean cond_end Determines whether or not the item's
-- interval end is given by a conditional.
-- @tparam boolean pausable Determines whether or not the item's
-- interval can be paused. In case it can, the number of pause
-- intervals to be created will depend on the model `num_pause` value.
-- @tparam boolean selectable Determines whether or not the item's
-- interval can be selected. In case it can, the number of selection
-- events to be created will depend on the model `num_selec` value.
-- 
-- @raise Error if one of the following occurs:
--
--  * the type of one of the arguments is not correct;
--  * an error occurs while asserting item info.

function item:configure(cond_end, pausable, selectable)
    local _t = typeof(cond_end)
    assert(_t == 'nil' or _t == 'boolean', 'Wrong type for argument cond_end.')
    _t = typeof(pausable)
    assert(_t == 'nil' or _t == 'boolean', 'Wrong type for argument pausable.')
    _t = typeof(selectable)
    assert(_t == 'nil' or _t == 'boolean', 'Wrong type for argument selectable.')
    
    
    if self.model.scenario == SCENARIO.T or self.model.scenario == SCENARIO.ST then
        self.ti = smt.constant(smt.REAL, self.name .. '.ti')
        self.tc = smt.constant(smt.REAL, self.name .. '.tc')
        self.te = smt.constant(smt.REAL, self.name .. '.te')
        self.ts = smt.constant(smt.REAL, self.name .. '.ts')
        self.pl = smt.constant(smt.BOOL, self.name .. '.pl')
        
        self.model:config_interval(self.ti, self.tc, self.te, self.ts, cond_end and self.t_size ~= self.model.INF)
        smt.assert(self.model, smt.ge(self.ti, self.model.canvas.ti))
        smt.assert(self.model, smt.le(self.te, self.model.canvas.te))
        
        if self.t_init then
            smt.assert(self.model, smt.eq(self.ti, smt.real(self.t_init)))
        end
        if self.t_end then
            smt.assert(self.model, smt.eq(self.te, smt.real(self.t_end)))
        end
    end
    
    if self.model.scenario == SCENARIO.ST then
        self.oc = smt.constant(smt.BOOL, self.name .. '.oc')
        
        smt.assert(self.model,
            smt.lor{
                smt.land{
                    self.pl,
                    smt.ge(self.model.T, self.ti),
                    smt.le(self.model.T, self.te),
                    self.oc
                },
                smt.land{
                    smt.lor{
                        smt.lnot(self.pl),
                        smt.lt(self.model.T, self.ti),
                        smt.gt(self.model.T, self.te)
                    },
                    smt.lnot(self.oc)
                }
            })
    end
    
    if self.model.scenario == SCENARIO.S or self.model.scenario == SCENARIO.ST then
        self.xi = smt.constant(smt.REAL, self.name .. '.xi')
        self.xc = smt.constant(smt.REAL, self.name .. '.xc')
        self.xe = smt.constant(smt.REAL, self.name .. '.xe')
        self.xs = smt.constant(smt.REAL, self.name .. '.xs')
        self.yi = smt.constant(smt.REAL, self.name .. '.yi')
        self.yc = smt.constant(smt.REAL, self.name .. '.yc')
        self.ye = smt.constant(smt.REAL, self.name .. '.ye')
        self.ys = smt.constant(smt.REAL, self.name .. '.ys')
        
        self.model:config_interval(self.xi, self.xc, self.xe, self.xs)
        self.model:config_interval(self.yi, self.yc, self.ye, self.ys)
        
        if self.x_size then
            smt.assert(self.model, smt.eq(self.xs, smt.real(self.x_size)))
        end
        if self.x_init then
            smt.assert(self.model, smt.eq(self.xi, smt.real(self.x_init)))
        end
        if self.x_end then
            smt.assert(self.model, smt.eq(self.xe, smt.real(self.x_end)))
        end
        if self.y_size then
            smt.assert(self.model, smt.eq(self.ys, smt.real(self.y_size)))
        end
        if self.y_init then
            smt.assert(self.model, smt.eq(self.yi, smt.real(self.y_init)))
        end
        if self.y_end then
            smt.assert(self.model, smt.eq(self.ye, smt.real(self.y_end)))
        end
    end
    
    
    if self.model.scenario == SCENARIO.T or self.model.scenario == SCENARIO.ST then
        -- create pause intervals for item, if applicable
        if pausable then
            local d = {}
            for i = 1, self.model.num_pause do
                local ip = item:new(self.model, self.name .. '_p' .. tostring(#self.i_pause + 1), {type = 'pause', t_size = self.model.INF})
                self.i_pause[#self.i_pause + 1] = ip
                
                ip.ti = smt.constant(smt.REAL, ip.name .. '.ti')
                ip.tc = smt.constant(smt.REAL, ip.name .. '.tc')
                ip.te = smt.constant(smt.REAL, ip.name .. '.te')
                ip.ts = smt.constant(smt.REAL, ip.name .. '.ts')
                ip.pl = smt.constant(smt.BOOL, ip.name .. '.pl')
                
                self.model:config_interval(ip.ti, ip.tc, ip.te, ip.ts)
                smt.assert(self.model, smt.ge(ip.ti, self.ti))
                smt.assert(self.model, smt.le(ip.te, self.te))
                smt.assert(self.model,
                    smt.lor{
                        smt.land{ip.pl, smt.gt(ip.ts, smt.real(0))},
                        smt.land{smt.lnot(ip.pl), smt.eq(ip.ts, smt.real(0))}
                    })
                
                if i > 1 then
                    smt.assert(self.model,
                        smt.imp{
                            ip.pl,
                            smt.land{self.i_pause[i - 1].pl, allen.before(self.i_pause[i - 1], ip)}
                        })
                end
                
                d[#d + 1] = ip.ts
            end
            
            if self.t_size ~= self.model.INF then
                d[#d + 1] = smt.real(self.t_size)
                
                smt.assert(self.model, smt.eq(self.ts, smt.sum(d)))
            else
                smt.assert(self.model, smt.gt(self.ts, smt.sum(d)))
            end
        else
            if self.t_size ~= self.model.INF then
                smt.assert(self.model, smt.eq(self.ts, smt.real(self.t_size)))
            else
                smt.assert(self.model, smt.gt(self.ts, smt.real(0)))
            end
        end
        
        -- create selection events for item, if applicable
        if selectable then
            for i = 1, self.model.num_selec do
                local is = item:new(self.model, self.name .. '_s' .. tostring(#self.i_selec + 1), {type = 'selec'})
                self.i_selec[#self.i_selec + 1] = is
                
                is.ti = smt.constant(smt.REAL, is.name .. '.ti')
                is.pl = smt.constant(smt.BOOL, is.name .. '.pl')
                
                smt.assert(self.model, smt.imp(is.pl, smt.between(self.ti, is.ti, self.te, true)))
                if i > 1 then
                    smt.assert(self.model,
                        smt.imp{
                            is.pl,
                            smt.land{self.i_selec[i - 1].pl, smt.lt(self.i_selec[i - 1].ti, is.ti)}
                        })
                end
            end
        end
    end
end


---------------------------------------------------------------------
-- Anchors an item in the "main" item. Optionaly, for an anchor it
-- indicates the initial (`t_init`) and final (`t_end`) times in
-- relation to the "main" item. This method can only be usedin a `T`
-- or `ST` `scenario`.
-- 
-- Initial and final times are considered in relation to the main
-- item initial time. If the initial time is not provided, the initial
-- time of the main item is considered. If the final time is not
-- provided, the final time of the main item is considered.
-- 
-- @tparam item anchor Item object to be anchored.
-- @tparam number t_init Initial time for the anchor.
-- @tparam number t_end Final time for the anchor.
-- 
-- @raise Error if one of the following occurs:
--
--  * there is not a context;
--  * the `scenario` is not `T` or `ST`
--  * the type of one of the arguments is not correct;
--  * an error occurs while asserting item info.
-- 
-- @usage 
-- m:anchor(animation, {{segIcon, t_init = 45000, t_end = 51000},
--                      {segPhoto, t_init = 41000},
--                      {segDrible, t_init = 12000}})
function item:anchor(anchor, t_init, t_end)
    assert(self.model.context, 'You must initiate the document first.')
    assert(self.model.scenario ~= SCENARIO.S, "The model scenario must be either T or ST.")
    assert(typeof(anchor) == 'item', 'Wrong type for argument anchor.')
    assert(not t_init or type(t_init) == 'number', 'Wrong type for argument t_init.')
    assert(not t_end or type(t_end) == 'number', 'Wrong type for argument t_end.')
    
    if t_init then
        smt.assert(self.model, smt.eq(anchor.ti, smt.sum{self.ti, smt.real(t_init)}))
    else
        smt.assert(self.model, smt.eq(anchor.ti, self.ti))
    end
    if t_end then
        smt.assert(self.model, smt.eq(anchor.te, smt.sum{self.ti, smt.real(t_end)}))
    else
        smt.assert(self.model, smt.eq(anchor.te, self.te))
    end
    
    self.anchors[#self.anchors + 1] = anchor
end


---------------------------------------------------------------------
-- States that an item exists when its anchors exist and vice-versa.
-- 
-- @raise Error if an error occur while asserting the item relation
-- with its anchors.
function item:place_anchors()
    local p = {self.pl}
    local np = {smt.lnot(self.pl)}
    for _,a in ipairs(self.anchors) do
        p[#p + 1] = a.pl
        np[#np + 1] = smt.lnot(a.pl)
    end
    
    smt.assert(self.model, smt.lor{smt.land(p),smt.land(np)})
end


---------------------------------------------------------------------
-- Gets the event representing the item *begin*.
-- 
-- @tparam number d Delay from the item begin. If `nil`, no delay is
-- considered.
-- 
-- @treturn event Event Object representing the item begin.
-- 
-- @raise Error if any of the parameters are of wrong type.
function item:BEG(d)
    assert(not d or ({typeof(d)})[2] == 'number', 'Wrong type for argument d.')
    
    return event:new(self, event.TYPE_BEG, d)
end


---------------------------------------------------------------------
-- Gets the event representing the item *end*.
-- 
-- @tparam number d Delay from the item end. If `nil`, no delay is
-- considered.
-- 
-- @treturn event Event Object representing the item end.
-- 
-- @raise Error if any of the parameters are of wrong type.
function item:END(d)
    assert(not d or ({typeof(d)})[2] == 'number', 'Wrong type for argument d.')
    
    return event:new(self, event.TYPE_END, d)
end


---------------------------------------------------------------------
-- Gets the variable representing the item *left* value.
-- 
-- @treturn term Term representing the item left.
function item:LEFT()
    return self.xi
end


---------------------------------------------------------------------
-- Gets the variable representing the item *top* value.
-- 
-- @treturn term Term representing the item top.
function item:TOP()
    return self.yi
end


---------------------------------------------------------------------
-- Gets the variable representing the item *width* value.
-- 
-- @treturn term Term representing the item width.
function item:WIDTH()
    return self.xs
end


---------------------------------------------------------------------
-- Gets the variable representing the item *height* value.
-- 
-- @treturn term Term representing the item height.
function item:HEIGHT()
    return self.ys
end


---------------------------------------------------------------------
-- Gets a string representing the item.
-- 
-- @treturn string String representing the item.
local function item_string(self)
    str = {}
    
    str[#str + 1] = "\nMedia item: " .. self.name
    str[#str + 1] = "\nattributes:"
    str[#str + 1] = "\n\tt_size = " .. tostring(self.t_size)
    str[#str + 1] = "\n\tx_size = " .. tostring(self.x_size)
    str[#str + 1] = "\n\tx_init = " .. tostring(self.x_init)
    str[#str + 1] = "\n\tx_init = " .. tostring(self.x_end)
    str[#str + 1] = "\n\ty_size = " .. tostring(self.y_size)
    str[#str + 1] = "\n\ty_init = " .. tostring(self.y_init)
    str[#str + 1] = "\n\ty_init = " .. tostring(self.y_end)
    
    if self.eval then
        str[#str + 1] = "\nmodel:"
        str[#str + 1] = "\n\tt: " .. table.concat({self.ti.value, self.te.value, self.ts.value}, ",")
        str[#str + 1] = "\n\tx: " .. table.concat({self.xi.value, self.xe.value, self.xs.value}, ",")
        str[#str + 1] = "\n\ty: " .. table.concat({self.yi.value, self.ye.value, self.ys.value}, ",")
    end
    
    return table.concat(str)
end


item.__type = 'item'
item.__index = item
item.__tostring = item_string
return item