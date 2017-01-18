dofile("/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/LuaXML/util.lua")

local fileOut

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
  local t = "function printer(e)"
              "\t" .. "print('\n\n')"
              "\t" .. "print('\t\tclass : ' .. tostring(e.class))".. "\n" ..
              "\t" .. "print('\t\ttype : ' .. tostring(e.type))".. "\n" ..
              "\t" .. "print('\t\taction : ' .. tostring(e.action))".. "\n" ..
              "\t" .. "print('\t\tlabel : ' .. tostring(e.label))".. "\n" ..
              "\t" .. "print('\t\tarea : ' .. tostring(e.area))".. "\n" ..
              "\t" .. "print('\t\tname : ' .. tostring(e.name))".. "\n" ..
              "\t" .. "print('\t\tvalue : ' .. tostring(e.value))".. "\n" ..
              "\t" .. "print('\n\n')".. "\n" ..
            "end".. "\n\n"
            
  f = f .. t
  return f
end

function incGetValues(file, layout)
  local f = file
  local auxLay = layout
  local auxT = ""
  local inc = 0
  local t = "function getValues()".. "\n" ..
            "\t" .. "smt.mark_backtrack(m)".. "\n"
            
  for k, p in pairs(auxLay) do
    inc = inc + 1
    auxT = "if layout."..k.."value then".. "\n" ..
              "\t" .. "smt.assert(m, f" .. inc .. ".oc)".. "\n" ..
           "else".. "\n" ..
              "\t" .."smt.assert(m, smt.lnot(f" .. inc .. ".oc))".. "\n"
              
    t = t .. auxT
  end
  
  inc = 0
  auxT = ""
  
  t = t .. "\t" .."print(m:check())".. "\n"
  
  for k, p in pairs(auxLay) do
    inc = inc + 1
    auxT = "if layout."..k.."value then".. "\n" ..
              "\t" .. "m:eval(f" .. inc .. ")" .. "\n" ..
              "\t" .. "layout."..k..".position = tostring(f" .. inc .. ".xi.value) .. ',' .. tostring(f" .. inc .. ".yi.value)" .. "\n" ..
              "\t" .. "print(layout."..k..".position)" .. "\n" ..
              "\t" .. "criaEvt(layout."..k..".prop,layout."..k..".position)" .. "\n" ..
           "end" .. "\n"
              
    t = t .. auxT
  end
  
  t = t .. "\t" .."smt.backtrack(m)".. "\n" ..
            "end" .. "\n\n"
            
  f = f .. t
  return f
end

function createsScript(layout)
  local lay = layout
  fileOut = incHead(fileOut)
  fileOut = incSplit(fileOut)
  fileOut = incEVT(fileOut)
  fileOut = incGetValues(fileOut, lay)
  fileOut = incPrinter(fileOut)
end
