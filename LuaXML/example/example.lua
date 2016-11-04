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

local filename_in = "/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/LuaXML/example/example.xml"
local filename_out = "/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/LuaXML/example/example_out.xml"
local xmltext = ""
local f, e = io.open(filename_in, "r")
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

res = showTable(xmlhandler.root)
print(res)
--Recursivelly prints the table
--printable(xmlhandler.root)

--Manually prints the table (once that the XML structure for this example is previously known)
--for k, p in pairs(xmlhandler.root.pessoas.pessoa) do
--  print("Nome:", p.nome, "Cidade:", p.cidade, "Tipo:", p._attr.tipo)
--end

qtd_list = #(xmlhandler.root.pessoas.pessoa)
print(qtd_list)



table.insert(xmlhandler.root.pessoas.pessoa, {_attr={tipo="F", sangue="B"}, nome = "Myrna", cidade = "Volta Redonda"})

--for k, p in pairs(xmlhandler.root.pessoas.pessoa) do
  --print("Nome:", p.nome, "Cidade:", p.cidade)
  --end

res = showTable(xmlhandler.root)
print(res)

writeToXml(xmlhandler.root, filename_out)


