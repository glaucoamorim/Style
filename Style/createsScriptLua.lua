dofile("/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/LuaXML/util.lua")

local fileOut = ""
local DestinationFile = "/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/Style/example/foo.lua"

--local layMedia = {video1 = {value = false, prop = "loc1", position = "100,100", ancor = "area1"}, video2 = {value = false, prop = "loc2", position = "200,100", ancor = "area2"}, video3 = {value = false, prop = "loc3", position = "300,100", ancor = "area3"}}
  
--local layProc = {flow = {id = "videos", focusIndex = 1, top = 0, left = 140, bottom = nil, right = nil, width = 860, height = 100, hspace = 20, vspace = nil, align = "center", itens = {[1] = {itemId = "item1", itemWidth = 200, itemHeight = 100}}, medias = {[1] = {_attr = {id="video1", src="video.mp4", xlabel="video", layout="mVideos#videos", item="item1"}}, [2] = {_attr = {id="video2", src="video2.mp4", xlabel="video", layout="mVideos#videos", item="item1"}}, [3] = {_attr = {id="video3", src="video3.mp4", xlabel="video", layout="mVideos#videos", item="item1"}}}}, grid = {id = "menu", focusIndex = 0, top = 0, left = 0, bottom = 0, right = 0, width = 0, height = 0, hspace = 0, vspace = 0, columns = 0, rows = 0, medias = {}}, carousel= {}, stack = {}, untype = {}, itens = {}}

function incText(text, file)
  local f = file
  f = f .. text
  return f
end

function hasMediasLayout(type, table)
  
  if type == "flowLayout" then
    if table.flow.medias then
      return true
    end
  elseif type == "gridLayout" then
    if table.grid.medias then
      return true
    end
  elseif type == "carouselLayout" then
    if table.carousel.medias then
      return true
    end
  elseif type == "stackLayout" then
    if table.stack.medias then
      return true
    end
  end

end

function searchItemSizes(item, model, auxLayP)
  for k,v in pairs(auxLayP) do
    if k == model then
      for i,j in ipairs(v) do
        for l,m in ipairs(j.itens) do
          if m._attr.id == item then
            return m._attr.width, m._attr.height
          end
        end
      end
    end
  end
end

function findElementProc(elm, table)
  local find = false
  for k,v in pairs(table) do
    for l,m in ipairs(v) do
      if m.medias ~= nil then
        for i,j in ipairs(m.medias) do
          if elm == j._attr.id then
            find = true
            return k, l, i, find 
          end
        end
      end
    end
  end
end

function fillTable(layMedia, layProc)
  local proc = layProc
  local medias = layMedia
  local index_media
  local index_model
  local model
  local result
  
  for k,v in pairs(medias) do
    model, index_model, index_media, result = findElementProc(k, proc)
    if result then
      if model == "flow" then
        proc.flow[index_model].medias[index_media].value = v.value
        proc.flow[index_model].medias[index_media].prop = v.prop
        proc.flow[index_model].medias[index_media].position = v.position
        proc.flow[index_model].medias[index_media].ancor = v.ancor
      elseif model == "grid" then
        proc.grid[index_model].medias[index_media].value = v.value
        proc.grid[index_model].medias[index_media].prop = v.prop
        proc.grid[index_model].medias[index_media].position = v.position
        proc.grid[index_model].medias[index_media].ancor = v.ancor
      elseif model == "carousel" then
        proc.carousel[index_model].medias[index_media].value = v.value
        proc.carousel[index_model].medias[index_media].prop = v.prop
        proc.carousel[index_model].medias[index_media].position = v.position
        proc.carousel[index_model].medias[index_media].ancor = v.ancor
      elseif model == "stack" then
        proc.stack[index_model].medias[index_media].value = v.value
        proc.stack[index_model].medias[index_media].prop = v.prop
        proc.stack[index_model].medias[index_media].position = v.position
        proc.stack[index_model].medias[index_media].ancor = v.ancor
      end
    else
      print("Element not found!!!")
      return nil
    end
  end
  return proc
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
              "\t" .. "print('\n\n')" .. "\n" ..
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

function incGetValues(file, layoutProc)
  local f = file
  local auxLayP = layoutProc
  local auxT1 = ""
  local auxT2 = ""
  local inc = 0
  local auxName = ""
  local t = "function getValues(auxLayP)".. "\n" ..
            "\t" .. "smt.mark_backtrack(m)".. "\n"
    
  for k,v in pairs(auxLayP) do
    for l,m in ipairs(v) do
      if m.medias ~= nil then
        for i,j in ipairs(m.medias) do
          auxName = k .. "_" .. j._attr.id
          auxT1 = auxT1 .. "if auxLayP."..k.."["..i.."].medias["..i.."].value then".. "\n" ..
                  "\t" .. "smt.assert(m, " .. auxName .. ".oc)".. "\n" ..
                "else".. "\n" ..
                  "\t" .."smt.assert(m, smt.lnot(f" .. auxName .. ".oc))".. "\n"
                  
          auxT2 = auxT2 .. "if auxLayP."..k.."["..i.."].medias["..i.."].value then".. "\n" ..
              "\t" .. "m:eval(" .. auxName .. ")" .. "\n" ..
              "\t" .. "auxLayP."..k.."["..i.."].medias["..i.."].position = tostring(" .. auxName .. ".xi.value) .. ',' .. tostring(" .. auxName .. ".yi.value)" .. "\n" ..
              "\t" .. "print(auxLayP."..k.."["..i.."].medias["..i.."].position)" .. "\n" ..
              "\t" .. "criaEvt(auxLayP."..k.."["..i.."].medias["..i.."].prop,auxLayP."..k.."["..i.."].medias["..i.."].position)" .. "\n" ..
           "end" .. "\n"
        end
      end
    end
  end
  
  t = t .. auxT1 .. "\t" .."print(m:check())".. "\n" .. auxT2 .. "\t" .."smt.backtrack(m)".. "\n" ..
          "end" .. "\n\n"
             
  f = f .. t
  return f
end

function incHandler(file, layout)
  local auxLayP = layout
  local auxTable = {}
  local f = file
  local auxT = ""
  local inc = "{"
  local width, height = 0, 0
  local t = "function handler(evt)" .. "\n" ..
              "\t" .."if (evt.class ~= 'ncl') then return end" .. "\n" ..
              "\t" .."if (evt.type ~= 'presentation') then return end" .. "\n" ..
              "\t" .."if evt.label == '' then" .. "\n" ..
                "\t\t" .."if (evt.action == 'start') then" .. "\n" ..
                  "\t\t\t" .."m = model:new()" .. "\n" ..
                  "\t\t\t" .."m:init_document()" .. "\n\n"
  
  for k,v in pairs(auxLayP) do
    for l,m in ipairs(v) do
      if m.medias ~= nil then
        for i,j in ipairs(m.medias) do
          auxName = k .. "_" .. j._attr.id
          width, height = searchItemSizes(j._attr.item, k, auxLayP)
          auxT = auxT .. "\t\t\t" .. auxName .. " = m:new_item{x_size = " .. width .. ", y_size = " .. height .. "}" .. "\n"
          auxTable[i] = auxName
        end

        auxT = auxT .. "\t\t\t" .."local " .. k .."_canvas = {" .. "\n" ..
                        "\t\t\t\t" .."name = \"".. k .."_canvas\"," .. "\n" ..
                        "\t\t\t\t" .."x_init = "..m.top.."," .. "\n" ..
                        "\t\t\t\t" .."x_size = "..m.width.."," .. "\n" ..
                        "\t\t\t\t" .."y_init = "..m.left.."," .. "\n" ..
                        "\t\t\t\t" .."y_size = "..m.height.."}" .. "\n" ..
                      "\t\t\t" ..k.."_canvas = m:"..k.."("..k.."_canvas," .. "\n"
        for a,b in ipairs(auxTable) do
          if a ~= #auxTable then
            inc = inc .. b .. ","
          else
            inc = inc .. b .. "},"
          end
        end
        
        auxT = auxT .. "\t\t\t\t\t\t" .. inc .. "\n" ..
                        "\t\t\t\t\t\t" .."\"" .. m.hspace .. "," .. m.vspace .. "," .. "\"" .. "\n"
                        
        if k == "flow" then
          auxT = auxT .. "\t\t\t\t\t\t" .."model.FLOW_ALIGN.CENTER," .. "\n" ..
                        "\t\t\t\t\t\t" .."model.FLOW_ALIGN.CENTER," .. "\n" ..
                        "\t\t\t\t\t\t" .."model.FLOW_ALIGN.CENTER)" .. "\n"
        end                
                        
          auxT = auxT .. "\t\t" .."else" .. "\n" ..
                          "\t\t\t" .."m:end_document()" .. "\n" ..
                        "\t\t" .."end" .. "\n" ..
                      "\t" .."else" .. "\n" ..
                        "\t\t" .."info_media = evt.label:split(.)" .. "\n" ..
                        "\t\t" .."id_media = info_media[1]" .. "\n" ..
                        "\t\t" .."layout[id_media].value = (evt.action == 'start')" .. "\n" ..
                    "\t\t" .."getValues()" .. "\n" ..
                "\t" .."end" .. "\n" ..
              "end" .. "\n\n"
      end
    end
  end
  
  t = t .. auxT
  
  f = f .. t
  
  return f
end
  

function createsScript(layoutMedia, layoutProc)
  layProc = fillTable(layoutMedia, layoutProc)
  fileOut = incHead(fileOut)
  fileOut = incSplit(fileOut)
  fileOut = incEVT(fileOut)
  fileOut = incGetValues(fileOut, layProc)
  fileOut = incHandler(fileOut, layProc)
  fileOut = incPrinter(fileOut)
  local t = "event.register(printer)" .. "\n" ..
      "event.register(handler)" .. "\n"
  fileOut = incText(t, fileOut)
  createFile(fileOut, DestinationFile)
end

--createsScript(layMedia, layProc)
