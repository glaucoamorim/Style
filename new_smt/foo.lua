require 'event'
local model = require('model')
local smt = require('lib.smt')

m = nil
f1 = nil
f2 = nil
f3 = nil
layout = {
    arj = {
        value = false,
        prop = 'locrj',
        position = '100,100'
    },
    apr = {
        value = false,
        prop = 'locpr',
        position = '200,100'
    },
    atr = {
        value = false,
        prop = 'loctr',
        position = '300,100'
    }
}


function criaEvt(p, v)
    e1 = {}
    e1.class = 'ncl'
    e1.type = 'attribution'
    e1.action = 'start'
    e1.name = p
    e1.value = v
    event.post(e1)
    
    e2 = {}
    e2.class = 'ncl'
    e2.type = 'attribution'
    e2.action = 'stop'
    e2.name = p
    e2.value = v
    event.post(e2)
end


function getValues()
    smt.mark_backtrack(m)
    
    -- create assertions
    if layout.arj.value then
        smt.assert(m, f1.oc)
    else
        smt.assert(m, smt.lnot(f1.oc))
    end
    if layout.apr.value then
        smt.assert(m, f2.oc)
    else
        smt.assert(m, smt.lnot(f2.oc))
    end
    if layout.atr.value then
        smt.assert(m, f3.oc)
    else
        smt.assert(m, smt.lnot(f3.oc))
    end
    
    -- check the model
    print(m:check())
    
    -- evaluate and get value
    if layout.arj.value then
        m:eval(f1)
        layout.arj.position = tostring(f1.xi.value) .. ',' .. tostring(f1.yi.value)
        print(layout.arj.position)
        criaEvt(layout.arj.prop,layout.arj.position)
    end
    if layout.apr.value then
        m:eval(f2)
        layout.apr.position = tostring(f2.xi.value) .. ',' .. tostring(f2.yi.value)
        print(layout.apr.position)
        criaEvt(layout.apr.prop,layout.apr.position)
    end
    if layout.atr.value then
        m:eval(f3)
        layout.atr.position = tostring(f3.xi.value) .. ',' .. tostring(f3.yi.value)
        print(layout.atr.position)
        criaEvt(layout.atr.prop,layout.atr.position)
    end
    
    smt.backtrack(m)
end


function handler(evt)
    if (evt.class ~= 'ncl') then return end
    if (evt.type ~= 'presentation') then return end
    if evt.label == '' then
        if (evt.action == 'start') then
            m = model:new()
            m:init_document()

            f1 = m:new_item{x_size = 240, y_size = 135}
            f2 = m:new_item{x_size = 160, y_size = 90}
            f3 = m:new_item{x_size = 80, y_size = 53}

            local flow_canvas = {
                name = "flow_canvas",
                x_init = 0,
                x_size = 600,
                y_init = 0,
                y_size = 400}
            flow_canvas = m:flow(flow_canvas,
                                 {f1,f2,f3},
                                 10, 10,
                                 model.FLOW_ALIGN.CENTER,
                                 model.FLOW_ALIGN.CENTER,
                                 model.FLOW_ALIGN.CENTER)
        else
            m:end_document()
        end
    else
		-- criarStateTable
        layout[evt.label].value = (evt.action == 'start')
        getValues()
        -- criaEvt(layout[evt.label].prop,layout[evt.label].position)
    end
end

function printer(e)
    print('\n\n')
    print('\t\tclass : ' .. tostring(e.class))
    print('\t\ttype : ' .. tostring(e.type))
    print('\t\taction : ' .. tostring(e.action))
    print('\t\tlabel : ' .. tostring(e.label))
    print('\t\tarea : ' .. tostring(e.area))
    print('\t\tname : ' .. tostring(e.name))
    print('\t\tvalue : ' .. tostring(e.value))
    print('\n\n')
end

event.register(printer)
event.register(handler)