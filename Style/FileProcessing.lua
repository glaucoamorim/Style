#!/usr/bin/env lua
---Sample application to read a XML file and print it on the terminal.
--@author Manoel Campos da Silva Filho - http://manoelcampos.com
--require("processor")
dofile("/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/Style/xml.lua")
dofile("/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/Style/handler.lua")
dofile("/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/Style/tableToXML.lua")
dofile("/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/Style/createsScriptLua.lua")

---Recursivelly prints a table
--@param tb The table to be printed
--@param level Only internally used to indent the print.
function printable(tb, level)
  level = level or 1
  local spaces = string.rep(' ', level*2)
  for k,v in pairs(tb) do
      if type(v) ~= "table" then
         print(spaces .. k..'='..v)
      else
         print(spaces .. k)
         level = level + 1
         printable(v, level)
      end
  end  
end

--Manually prints the table (once that the XML structure for this example is previously known)
function createsProperties(xml, count)
  for k, p in pairs(xml.root.ncl.body.media) do
    count = count + 1
    if type(k) == "number" then
      xml.root.ncl.body.media[k].property = {_attr = {name = "location"}}
    else
      xml.root.ncl.body.media.property = {_attr = {name = "location"}}
    end
  end
  return xml, count
end


function createsMediaLua(xml, count)
  local newmedia = {}
  newmedia._attr = {id = "mlua", src="foo.lua"}
  newmedia.area = {}
  newmedia.property = {}
  
  local layout = {}
  
  for i=1,count do
    local nameMedia = xml.root.ncl.body.media[i]._attr.id
    layout[nameMedia] = {}
    local infoMedia = {value = "false", prop = nil, position = "0, 0", ancor = nil}
    newmedia.area[i] = {_attr = {id = "area"..i}}
    infoMedia.ancor = "area"..i
    newmedia.property[i] = {_attr = {name = "loc"..i}}
    infoMedia.prop = "loc"..i
    layout[nameMedia] = infoMedia
  end

  xml.root.ncl.body.media[count+1] = newmedia
  
  return xml, count, layout
end

function createsLinks(xml)
  xml.root.ncl.body.link={}
  local countMedias = 0
  local index = 0
  for k, p in pairs(xml.root.ncl.body.media) do
    if(p._attr.id ~= "mlua") then
      countMedias = countMedias + 1
      index = index + 1
      local newLinkOnBegin = {}
      local newLinkOnStop = {}
    
      newLinkOnBegin._attr = {xconnector = "onBeginStart"}
      newLinkOnBegin.bind = {}
      bindOnBegin = {_attr = {role = "onBegin", component=p._attr.id}}
      newLinkOnBegin.bind[1] = bindOnBegin
      bindOnBegin = {_attr = {role = "start", component="mlua", interface="area"..countMedias}}
      newLinkOnBegin.bind[2] = bindOnBegin
      xml.root.ncl.body.link[index] = newLinkOnBegin
    
      index = index + 1
      newLinkOnStop._attr = {xconnector = "onEndStop"}
      newLinkOnStop.bind = {}
      bindOnBegin = {_attr = {role = "onEnd", component=p._attr.id}}
      newLinkOnStop.bind[1] = bindOnBegin
      bindOnBegin = {_attr = {role = "stop", component="mlua", interface="area"..countMedias}}
      newLinkOnStop.bind[2] = bindOnBegin
      xml.root.ncl.body.link[index] = newLinkOnStop
    else
      tableAux = p.property
      for k, p in pairs(tableAux) do
        index = index + 1
        local newLinkGetSet = {}
        local bindGetSetParam = {}
        newLinkGetSet._attr = {xconnector = "para"}
        newLinkGetSet.bind = {}
        bindGetSet = {_attr = {role = "onEndAttribution", component="mlua", interface=p._attr.name}}
        newLinkGetSet.bind[1] = bindGetSet
        bindGetSet = {_attr = {role = "get", component="mlua", interface=p._attr.name}}
        newLinkGetSet.bind[2] = bindGetSet
        bindGetSet = {_attr = {role = "set", component=xml.root.ncl.body.media[k]._attr.id, interface="location"}, bindParam = {_attr = {name = "var", value = "$get"}}}
        newLinkGetSet.bind[3] = bindGetSet
        xml.root.ncl.body.link[index] = newLinkGetSet
      end
    end
  end
  
  return xml
  
end

function main()
  local filename_in = "/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/Style/example/moveVideos.ncl"
  local filename_out = "/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/Style/example/moveVideos_out.ncl"
  local filename_style = "/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/Style/example/exemploSimpleLayout.xml"
  --local filename_in = arg[1]
  --local filename_out = arg[2]
  local xmltextNCL = ""
  local xmltextStyle = "" 
  local f, e = io.open(filename_in, "r")
  local countMedias = 0
  local layoutTableMedia = nil
  local layoutTableProc = nil

  if f then
    --Gets the entire file content and stores into a string
    xmltextNCL = f:read("*a")
  else
    error(e)
  end

  --Instantiate the object the states the XML file as a Lua table
  local xmlhandlerNCL = simpleTreeHandler()
  --local xmlhandler = domHandler()

  --Instantiate the object that parses the XML to a Lua table
  local xmlparserNCL = xmlParser(xmlhandlerNCL)
  xmlparserNCL:parse(xmltextNCL)
  
  res = showTable(xmlhandlerNCL.root)
  print(res)

  xmlhandlerNCL, countMedias = createsProperties(xmlhandlerNCL, countMedias)
  xmlhandlerNCL, countMedias, layoutTableMedia = createsMediaLua(xmlhandlerNCL, countMedias)
  xmlhandlerNCL = createsLinks(xmlhandlerNCL)

  writeToXml(xmlhandlerNCL.root, filename_out)

  f, e = io.open(filename_style, "r")

  if f then
    --Gets the entire file content and stores into a string
    xmltextStyle = f:read("*a")
  else
    error(e)
  end

  --Instantiate the object the states the XML file as a Lua table
  local xmlhandlerStyle = simpleTreeHandler()
  --local xmlhandler = domHandler()

  --Instantiate the object that parses the XML to a Lua table
  local xmlparserStyle = xmlParser(xmlhandlerStyle)
  xmlparserStyle:parse(xmltextStyle)

  res = showTable(xmlhandlerStyle.root)
  print(res)
  
  proc = Processor:new()
  proc:process(xmlhandlerNCL, xmlhandlerStyle)
  layoutTableProc = proc
  createsScript(layoutTableMedia, layoutTableProc)
end

main()