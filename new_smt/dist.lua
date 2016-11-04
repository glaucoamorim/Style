local model = require('model')
local spatial = require('model.spatial')

local item_size = {{20,20}, {30,30}, {40,40}, {50,50}, {20,20}}


m = model:new{scenario = SCENARIO.S, x_size = 300, y_size = 100}
m:init_document()

-- create the items to be inside the flow
local test_items = {}
for i = 1, #item_size do
    test_items[i] = m:new_item{x_size = item_size[i][1], y_size = item_size[i][2]}
end

local canvas = m:distribute(test_items, spatial.AXIS.X, spatial.BORD.OUT)
m:inside(canvas, m.canvas)
m:relate(canvas, {{spatial.same_size, spatial.AXIS.X}}, m.canvas)

local sat = m:check()

-- pretty print
if sat then
    m:eval(canvas)
    print('Canvas x:[' .. canvas.xi.value .. ', ' .. canvas.xe.value .. ']  y:[' .. canvas.yi.value .. ', ' .. canvas.ye.value .. ']')
    
    for i,item in ipairs(test_items) do
        m:eval(item)
        print('Item' .. i .. ' x:[' .. item.xi.value .. ', ' .. item.xe.value .. ']  y:[' .. item.yi.value .. ', ' .. item.ye.value .. ']')
    end
else
    print('Not SAT')
end

m:end_document()