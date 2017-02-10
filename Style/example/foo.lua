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

function getValues(auxLayP)
	smt.mark_backtrack(m)
if auxLayP.flow[1].medias[1].value then
	smt.assert(m, flow_video1.oc)
else
	smt.assert(m, smt.lnot(fflow_video1.oc))
if auxLayP.flow[2].medias[2].value then
	smt.assert(m, flow_video2.oc)
else
	smt.assert(m, smt.lnot(fflow_video2.oc))
if auxLayP.flow[3].medias[3].value then
	smt.assert(m, flow_video3.oc)
else
	smt.assert(m, smt.lnot(fflow_video3.oc))
	print(m:check())
if auxLayP.flow[1].medias[1].value then
	m:eval(flow_video1)
	auxLayP.flow[1].medias[1].position = tostring(flow_video1.xi.value) .. ',' .. tostring(flow_video1.yi.value)
	print(auxLayP.flow[1].medias[1].position)
	criaEvt(auxLayP.flow[1].medias[1].prop,auxLayP.flow[1].medias[1].position)
end
if auxLayP.flow[2].medias[2].value then
	m:eval(flow_video2)
	auxLayP.flow[2].medias[2].position = tostring(flow_video2.xi.value) .. ',' .. tostring(flow_video2.yi.value)
	print(auxLayP.flow[2].medias[2].position)
	criaEvt(auxLayP.flow[2].medias[2].prop,auxLayP.flow[2].medias[2].position)
end
if auxLayP.flow[3].medias[3].value then
	m:eval(flow_video3)
	auxLayP.flow[3].medias[3].position = tostring(flow_video3.xi.value) .. ',' .. tostring(flow_video3.yi.value)
	print(auxLayP.flow[3].medias[3].position)
	criaEvt(auxLayP.flow[3].medias[3].prop,auxLayP.flow[3].medias[3].position)
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

			flow_video1 = m:new_item{x_size = 200, y_size = 100}
			flow_video2 = m:new_item{x_size = 300, y_size = 200}
			flow_video3 = m:new_item{x_size = 200, y_size = 100}
			local flow_canvas = {
				name = "flow_canvas",
				x_init = 0,
				x_size = 860,
				y_init = 140,
				y_size = 100}
			flow_canvas = m:flow(flow_canvas,
						{flow_video1,flow_video2,flow_video3},
						"20,0,"
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
	print('

')
	print('		class : ' .. tostring(e.class))
	print('		type : ' .. tostring(e.type))
	print('		action : ' .. tostring(e.action))
	print('		label : ' .. tostring(e.label))
	print('		area : ' .. tostring(e.area))
	print('		name : ' .. tostring(e.name))
	print('		value : ' .. tostring(e.value))
	print('

')
end

event.register(printer)
event.register(handler)
