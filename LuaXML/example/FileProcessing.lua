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

--qtd_list = #(xmlhandler.root.pessoas.pessoa)
--print(qtd_list)

--for k, p in pairs(xmlhandler.root.pessoas.pessoa) do
  --print("Nome:", p.nome, "Cidade:", p.cidade)
  --end

res = showTable(xmlhandler.root)
print(res)

writeToXml(xmlhandler.root, filename_out)