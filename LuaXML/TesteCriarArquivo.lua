
dofile("/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/LuaXML/util.lua")

local fileOut = ""
local DestinationFile = "/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/LuaXML/example/foo.lua"
local layout = {[1] = {id = "video1", attributes = {value = "false", prop = "loc1", position = "100, 100", ancor = "area1"}}, [2] = {id = "video2", attributes = {value = "false", prop = "loc2", position = "200, 100", ancor = "area2"}}, [3] = {id = "video3", attributes = {value = "false", prop = "loc3", position = "300, 100", ancor = "area3"}}}

print(layout[1].id)
 
function incText(text, file)
  local f = file
  f = f .. text
  return f
end

function incHead(file)
  local f = file
  local t = "require 'event'" .. "\n" .."local model = require('model')" .. "\n" .. "local smt = require('lib.smt')" .. "\n" ..
      "m = nil" .. "\n" ..
      "f1 = nil" .. "\n" ..
      "f2 = nil" .. "\n" ..
      "f3 = nil" .. "\n\n"
  f = f .. t
  return f
end

function incSplit(file)
  local f = file
  local t = "function string:split(separator)" .. "\n" ..
              "\t" .. "local init = 1" .. "\n" ..
              "\t" .. "return function()" .. "\n" ..
                "\t\t" .. "if init == nil then return nil end" .. "\n" ..
                "\t\t" .. "local i, j = self:find(separator, init)" .. "\n" ..
                "\t\t" .. "local result" .. "\n" ..
                "\t\t" .. "if i ~= nil then" .. "\n" ..
                  "\t\t\t" .. "result = self:sub(init, i – 1)" .. "\n" ..
                  "\t\t\t" .. "init = j + 1" .. "\n" ..
                "\t\t" .. "else" .. "\n" ..
                  "\t\t\t" .. "result = self:sub(init)" .. "\n" ..
                  "\t\t\t" .. "init = nil" .. "\n" ..
                "\t\t" .. "end" .. "\n" ..
                "\t\t" .. "return result" .. "\n" ..
              "\t" .. "end" .. "\n" ..
            "end" .. "\n\n"
  
  f = f .. t
  return f
end

function incEVT(file)
  local f = file
  local t = "function criaEvt(p, v)" .. "\n" ..
              "\t" .. "e1 = {}" .. "\n" ..
              "\t" .. "e1.class = 'ncl'" .. "\n" ..
              "\t" .. "e1.type = 'attribution'" .. "\n" ..
              "\t" .. "e1.action = 'start'" .. "\n" ..
              "\t" .. "e1.name = p" .. "\n" ..
              "\t" .. "e1.value = v" .. "\n" ..
              "\t" .. "event.post(e1)" .. "\n\n" ..
    
              "\t" .. "e2 = {}" .. "\n" ..
              "\t" .. "e2.class = 'ncl'" .. "\n" ..
              "\t" .. "e2.type = 'attribution'" .. "\n" ..
              "\t" .. "e2.action = 'stop'" .. "\n" ..
              "\t" .. "e2.name = p" .. "\n" ..
              "\t" .. "e2.value = v" .. "\n" ..
              "\t" .. "event.post(e2)" .. "\n" ..
            "end" .. "\n\n"
            
  f = f .. t
  return f
end

function incPrinter(file)
  local f = file
  local t = "function printer(e)" .. "\n" ..
              "\t" .. "print('\\n\\n')" .. "\n" ..
              "\t" .. "print('\\t\\tclass : ' .. tostring(e.class))".. "\n" ..
              "\t" .. "print('\\t\\ttype : ' .. tostring(e.type))".. "\n" ..
              "\t" .. "print('\\t\\taction : ' .. tostring(e.action))".. "\n" ..
              "\t" .. "print('\\t\\tlabel : ' .. tostring(e.label))".. "\n" ..
              "\t" .. "print('\\t\\tarea : ' .. tostring(e.area))".. "\n" ..
              "\t" .. "print('\\t\\tname : ' .. tostring(e.name))".. "\n" ..
              "\t" .. "print('\\t\\tvalue : ' .. tostring(e.value))".. "\n" ..
              "\t" .. "print('\\n\\n')".. "\n" ..
            "end".. "\n\n"
            
  f = f .. t
  return f
end

function incGetValues(file, layout)
  local f = file
  local auxLay = layout
  local auxT = ""
  --local inc = 0
  local t = "function getValues()".. "\n" ..
            "\t" .. "smt.mark_backtrack(m)".. "\n"
            
  for k, p in ipairs(auxLay) do
    --inc = inc + 1
    auxT = "\t" .. "if layout."..p.id..".value then".. "\n" ..
              "\t\t" .. "smt.assert(m, f" .. k .. ".oc)".. "\n" ..
           "\t" .. "else".. "\n" ..
              "\t\t" .."smt.assert(m, smt.lnot(f" .. k .. ".oc))".. "\n" ..
            "\t" .. "end" .. "\n\n"   
              
    t = t .. auxT
  end
  
  --inc = 0
  auxT = ""
  
  t = t .. "\t" .."print(m:check())".. "\n\n"
  
  for k, p in ipairs(auxLay) do
    --inc = inc + 1
    auxT = "\t" .. "if layout."..p.id..".value then".. "\n" ..
              "\t\t" .. "m:eval(f" .. k .. ")" .. "\n" ..
              "\t\t" .. "layout."..p.id..".position = tostring(f" .. k .. ".xi.value) .. ',' .. tostring(f" .. k .. ".yi.value)" .. "\n" ..
              "\t\t" .. "print(layout."..p.id..".position)" .. "\n" ..
              "\t\t" .. "criaEvt(layout."..p.id..".prop,layout."..p.id..".position)" .. "\n" ..
           "\t" .. "end" .. "\n\n"
              
    t = t .. auxT
  end
  
  t = t .. "\t" .."smt.backtrack(m)".. "\n" ..
            "end" .. "\n\n"
            
  f = f .. t
  return f
end

function incHandler(file, layout)
  local lay = layout
  local f = file
  local auxT = ""
  local inc = 0
  local t = "function handler(evt)" .. "\n" ..
              "\t" .."if (evt.class ~= 'ncl') then return end" .. "\n" ..
              "\t" .."if (evt.type ~= 'presentation') then return end" .. "\n" ..
              "\t" .."if evt.label == '' then" .. "\n" ..
                "\t\t" .."if (evt.action == 'start') then" .. "\n" ..
                  "\t\t\t" .."m = model:new()" .. "\n" ..
                  "\t\t\t" .."m:init_document()" .. "\n\n" ..

                  "\t\t\t" .."f1 = m:new_item{x_size = 240, y_size = 135}" .. "\n" ..
                  "\t\t\t" .."f2 = m:new_item{x_size = 160, y_size = 90}" .. "\n" ..
                  "\t\t\t" .."f3 = m:new_item{x_size = 80, y_size = 53}" .. "\n\n" ..

                    "\t\t\t" .."local flow_canvas = {" .. "\n" ..
                    "\t\t\t\t" .."name = \"flow_canvas\"," .. "\n" ..
                    "\t\t\t\t" .."x_init = 0," .. "\n" ..
                    "\t\t\t\t" .."x_size = 600," .. "\n" ..
                    "\t\t\t\t" .."y_init = 0," .. "\n" ..
                    "\t\t\t\t" .."y_size = 400}" .. "\n" ..
                  "\t\t\t" .."flow_canvas = m:flow(flow_canvas," .. "\n" ..
                                 "\t\t\t\t\t\t" .."{f1,f2,f3}," .. "\n" ..
                                 "\t\t\t\t\t\t" .."10, 10," .. "\n" ..
                                 "\t\t\t\t\t\t" .."model.FLOW_ALIGN.CENTER," .. "\n" ..
                                 "\t\t\t\t\t\t" .."model.FLOW_ALIGN.CENTER," .. "\n" ..
                                 "\t\t\t\t\t\t" .."model.FLOW_ALIGN.CENTER)" .. "\n" ..
                "\t\t" .."else" .. "\n" ..
                  "\t\t\t" .."m:end_document()" .. "\n" ..
                "\t\t" .."end" .. "\n" ..
              "\t" .."else" .. "\n" ..
                "\t\t" .."info_media = evt.label:split(.)" .. "\n" ..
                "\t\t" .."id_media = info_media[1]" .. "\n" ..
                "\t\t" .."layout[id_media].value = (evt.action == 'start')" .. "\n" ..
                "\t\t" .."getValues()" .. "\n" ..
              "\t" .."end" .. "\n" ..
            "end" .. "\n\n"
    
    f = f .. t
    return f
end 

function createsScript(layout)
  local lay = layout
  local t
  fileOut = incHead(fileOut)
  fileOut = incSplit(fileOut)
  fileOut = incEVT(fileOut)
  fileOut = incGetValues(fileOut, lay)
  fileOut = incHandler(fileOut, lay)
  fileOut = incPrinter(fileOut)
  t = "event.register(printer)" .. "\n" ..
      "event.register(handler)" .. "\n"
  fileOut = incText(t, fileOut)
  createFile(fileOut, DestinationFile)
end

createsScript(layout)