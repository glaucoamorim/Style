#!/usr/bin/env lua

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

local filename = "/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/LuaXML/example/exemploLayout.xml"
local xmltext = ""
local f, e = io.open(filename, "r")
if f then
  --Gets the entire file content and stores into a string
  xmltext = f:read("*a")
else
  error(e)
end

--Instantiate the object the states the XML file as a Lua table
local xmlhandler = simpleTreeHandler()

--Instantiate the object that parses the XML to a Lua table
local xmlparser = xmlParser(xmlhandler)
xmlparser:parse(xmltext)

--Recursivelly prints the table
--printable(xmlhandler.root)
res = showTable(xmlhandler.root.layout.body.container)
print(res)

--Manually prints the table (once that the XML structure for this example is previously known)
for k, p in pairs(xmlhandler.root.layout.body.container) do
  print("Container id:", p._attr.id, "tipo:", p._attr.type)
end

for k, p in pairs(xmlhandler.root.layout.body.spatialConstraint) do
  print("spatialConstraint:", p._attr.id, "tipo:", p._attr.type, "xconnector:", p._attr.xconnector)
  for i, j in pairs(p.bind) do
	  if j._attr.interface then
		  print("bind component:", j._attr.component, "interface:", j._attr.interface)
	  else
		  print("bind component:", j._attr.component)
	  end
  end  
end