dofile("/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/Style/xml.lua")
dofile("/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/Style/handler.lua")
dofile("/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/Style/tableToXML.lua")
  
  local filename_in = "/Users/glaucoamorim/Documents/DoutoradoUFF/Projetos/Style/ExemploGlauco/Style/TesteTag.ncl"
  local f, e = io.open(filename_in, "r")

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