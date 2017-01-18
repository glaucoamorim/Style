require 'event'
local model = require('model')
local smt = require('lib.smt')
m = nil
f1 = nil
f2 = nil
f3 = nil

function string:split(separator)
	local init = 1
	return function()
		if init == nil then return nil end
		local i, j = self:find(separator, init)
		local result
		if i ~= nil then
			result = self:sub(init, i – 1)
			init = j + 1
		else
			result = self:sub(init)
			init = nil
		end
		return result
	end
end

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
	if layout.video1.value then
		smt.assert(m, f1.oc)
	else
		smt.assert(m, smt.lnot(f1.oc))
	end

	if layout.video2.value then
		smt.assert(m, f2.oc)
	else
		smt.assert(m, smt.lnot(f2.oc))
	end

	if layout.video3.value then
		smt.assert(m, f3.oc)
	else
		smt.assert(m, smt.lnot(f3.oc))
	end

	print(m:check())

	if layout.video1.value then
		m:eval(f1)
		layout.video1.position = tostring(f1.xi.value) .. ',' .. tostring(f1.yi.value)
		print(layout.video1.position)
		criaEvt(layout.video1.prop,layout.video1.position)
	end

	if layout.video2.value then
		m:eval(f2)
		layout.video2.position = tostring(f2.xi.value) .. ',' .. tostring(f2.yi.value)
		print(layout.video2.position)
		criaEvt(layout.video2.prop,layout.video2.position)
	end

	if layout.video3.value then
		m:eval(f3)
		layout.video3.position = tostring(f3.xi.value) .. ',' .. tostring(f3.yi.value)
		print(layout.video3.position)
		criaEvt(layout.video3.prop,layout.video3.position)
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
		info_media = evt.label:split(.)
		id_media = info_media[1]
		layout[id_media].value = (evt.action == 'start')
		getValues()
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
