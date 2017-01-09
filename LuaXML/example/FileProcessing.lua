#!/usr/bin/env lua
---Sample application to read a XML file and print it on the terminal.
--@author Manoel Campos da Silva Filho - http://manoelcampos.com

dofile("/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/LuaXML/xml.lua")
dofile("/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/LuaXML/handler.lua")
dofile("/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/LuaXML/tableToXML.lua")

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

local filename_in = "/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/LuaXML/example/moveVideos.ncl"
local filename_out = "/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/LuaXML/example/moveVideos_out.ncl"
local xmltext = ""
local f, e = io.open(filename_in, "r")
local countMedias = 0
if f then
  --Gets the entire file content and stores into a string
  xmltext = f:read("*a")
else
  error(e)
end

--Instantiate the object the states the XML file as a Lua table
local xmlhandler = simpleTreeHandler()
--local xmlhandler = domHandler()

--Instantiate the object that parses the XML to a Lua table
local xmlparser = xmlParser(xmlhandler)
xmlparser:parse(xmltext)

--res = showTable(xmlhandler.root)
--print(res)
--Recursivelly prints the table
--printable(xmlhandler.root)

--local aux = {["property"] = {_attr = {name = "location"}}}
--table.insert(xmlhandler.root.ncl.body.media[1], {["property"] = {_attr = {name = "location"}}})

--Manually prints the table (once that the XML structure for this example is previously known)
for k, p in pairs(xmlhandler.root.ncl.body.media) do
	--print("Nome:", p.nome, "Cidade:", p.cidade, "Tipo:", p._attr.tipo)
  countMedias = countMedias + 1
	if type(k) == "number" then
	 xmlhandler.root.ncl.body.media[k].property = {_attr = {name = "location"}}
	else
	 xmlhandler.root.ncl.body.media.property = {_attr = {name = "location"}}
	end
end

local newmedia = {}
newmedia._attr = {id = "mlua", src="foo.lua"}
newmedia.area = {}
newmedia.property = {}
for i=1,countMedias do
  newmedia.area[i] = {_attr = {id = "arj"..i}}
  newmedia.property[i] = {_attr = {name = "loc"..i}}
end

xmlhandler.root.ncl.body.media[countMedias+1] = newmedia


xmlhandler.root.ncl.body.link={}
countMedias = 0
index = 0
for k, p in pairs(xmlhandler.root.ncl.body.media) do
  if(p._attr.id ~= "mlua") then
    countMedias = countMedias + 1
    index = index + 1
    local newLinkOnBegin = {}
    local newLinkOnStop = {}
    
    newLinkOnBegin._attr = {xconnector = "onBeginStart"}
    newLinkOnBegin.bind = {}
    bindOnBegin = {_attr = {role = "onBegin", component=p._attr.id}}
    newLinkOnBegin.bind[1] = bindOnBegin
    bindOnBegin = {_attr = {role = "start", component="mlua", interface="arj"..countMedias}}
    newLinkOnBegin.bind[2] = bindOnBegin
    xmlhandler.root.ncl.body.link[index] = newLinkOnBegin
    
    index = index + 1
    newLinkOnStop._attr = {xconnector = "onEndStop"}
    newLinkOnStop.bind = {}
    bindOnBegin = {_attr = {role = "onEnd", component=p._attr.id}}
    newLinkOnStop.bind[1] = bindOnBegin
    bindOnBegin = {_attr = {role = "stop", component="mlua", interface="arj"..countMedias}}
    newLinkOnStop.bind[2] = bindOnBegin
    xmlhandler.root.ncl.body.link[index] = newLinkOnStop
  else
    tableAux = p.property
    res = showTable(p.property)
    print(res)
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
      bindGetSet = {_attr = {role = "set", component=xmlhandler.root.ncl.body.media[k]._attr.id, interface="location"}, bindParam = {_attr = {name = "var", value = "$get"}}}
      newLinkGetSet.bind[3] = bindGetSet
      xmlhandler.root.ncl.body.link[index] = newLinkGetSet
      res = showTable(newLinkGetSet)  
      print(res)
    end
  end
end


-------------------Definicao dos links-----------------------------------------
--xmlhandler.root.ncl.body.link={}
--countMedias = 0
--local newLink = {}
--newLink._attr = {xconnector = "onBeginStart"}
--newLink.bind = {}
--for k, p in pairs(xmlhandler.root.ncl.body.media) do
  --countMedias = countMedias + 1
  --newLink.bind[1] = {_attr = {role = "onBegin", component=p._attr.id}}
  --newLink.bind[2] = {_attr = {role = "start", component="mlua", interface="arj"..countMedias}}
  --xmlhandler.root.ncl.body.link[countMedias] = newLink
--end

-------------------------------------------------------------------------------

--qtd_list = #(xmlhandler.root.pessoas.pessoa)
--print(qtd_list)

--for k, p in pairs(xmlhandler.root.pessoas.pessoa) do
  --print("Nome:", p.nome, "Cidade:", p.cidade)
  --end

res = showTable(xmlhandler.root)
print(res)

writeToXml(xmlhandler.root, filename_out)