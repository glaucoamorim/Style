require('flow')
require('grid')
require('carousel')
require('stack')

Processor = {flow = {}, grid = {}, carousel= {}, stack = {}, untype = {}, itens = {}}

function Processor:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function Processor:process(ncl, style)
  local xmlNcl = ncl
  local xmlStyle = style
  local f, g, c, s = 0, 0, 0, 0
  local auxID
  for k,p in ipairs(xmlStyle.layout.body.container) do
    if p._attr.type == "flowLayout" then
      local index_medias_f = 0
      f = f + 1
      flowLayout = Flow:new()
      flowLayout:setId(p._attr.id)
      flowLayout:setTop(p.format._attr.top)
      flowLayout:setLeft(p.format._attr.left)
      flowLayout:setBottom(p.format._attr.bottom)
      flowLayout:setRight(p.format._attr.right)
      flowLayout:setWidth(p.format._attr.width)
      flowLayout:setHeight(p.format._attr.height)
      flowLayout:setHspace(p.format._attr.hspace)
      flowLayout:setVspace(p.format._attr.vspace)
      flowLayout:setAlign(p.format._attr.align)
      flowLayout:setItemId(p.item._attr.id)
      flowLayout:setItemWidth(p.item._attr.width)
      flowLayout:setItemHeight(p.item._attr.height)
      
      for i,j in ipairs(xmlNcl.ncl.body.media) do
        auxID = split(j._attr.layout, "#")
        if auxID[2] == p._attr.id then
          index_medias_f = index_medias_f + 1
          flowLayout:setMedia(j, index_medias_f)
        end
      end
      
      Processor.flow[f] = flowLayout
    elseif p._attr.type == "gridLayout" then
      local index_medias_g = 0
      g = g + 1
      gridLayout = Grid:new()
      gridLayout:setId(p._attr.id)
      gridLayout:setTop(p.format._attr.top)
      gridLayout:setLeft(p.format._attr.left)
      gridLayout:setBottom(p.format._attr.bottom)
      gridLayout:setRight(p.format._attr.right)
      gridLayout:setWidth(p.format._attr.width)
      gridLayout:setHeight(p.format._attr.height)
      gridLayout:setHspace(p.format._attr.hspace)
      gridLayout:setVspace(p.format._attr.vspace)
      gridLayout:setColumns(p.format._attr.columns)
      gridLayout:setRows(p.format._attr.rows)
      
      for i,j in ipairs(xmlNcl.ncl.body.media) do
        auxID = split(j._attr.layout, "#")
        if auxID[2] == p._attr.id then
          index_medias_g = index_medias_g + 1
          gridLayout:setMedia(j, index_medias_g)
        end
      end
      
      Processor.grid[g] = gridLayout
    elseif p._attr.type == "carouselLayout" then
      local index_medias_c = 0
      c = c + 1
      carouselLayout = Carousel:new()
      carouselLayout:setId(p._attr.id)
      carouselLayout:setTop(p.format._attr.top)
      carouselLayout:setLeft(p.format._attr.left)
      carouselLayout:setBottom(p.format._attr.bottom)
      carouselLayout:setRight(p.format._attr.right)
      carouselLayout:setWidth(p.format._attr.width)
      carouselLayout:setHeight(p.format._attr.height)
      carouselLayout:setHspace(p.format._attr.hspace)
      carouselLayout:setVspace(p.format._attr.vspace)
      carouselLayout:setAlign(p.format._attr.align)
      carouselLayout:setItemId(p.item._attr.id)
      carouselLayout:setItemWidth(p.item._attr.width)
      carouselLayout:setItemHeight(p.item._attr.height)
      
      for i,j in ipairs(xmlNcl.root.ncl.body.media) do
        auxID[2] = split(j._attr.layout, "#")
        if auxID == p._attr.id then
          index_medias_c = index_medias_c + 1
          carouselLayout:setMedia(j, index_medias_c)
        end
      end
      
      Processor.carousel[c] = carouselLayout  
    elseif p._attr.type == "stackLayout" then
      local index_medias_s = 0
      s = s + 1
      stackLayout = Stack:new()
      stackLayout:setId(p._attr.id)
      stackLayout:setTop(p.format._attr.top)
      stackLayout:setLeft(p.format._attr.left)
      stackLayout:setBottom(p.format._attr.bottom)
      stackLayout:setRight(p.format._attr.right)
      stackLayout:setWidth(p.format._attr.width)
      stackLayout:setHeight(p.format._attr.height)
      stackLayout:setHspace(p.format._attr.hspace)
      stackLayout:setVspace(p.format._attr.vspace)
      stackLayout:setAlign(p.format._attr.align)
      stackLayout:setItemId(p.item._attr.id)
      stackLayout:setItemWidth(p.item._attr.width)
      stackLayout:setItemHeight(p.item._attr.height)
      
      for i,j in ipairs(xmlNcl.root.ncl.body.media) do
        auxID[2] = split(j._attr.layout, "#")
        if auxID == p._attr.id then
          index_medias_s = index_medias_s + 1
          stackLayout:setMedia(j, index_medias_s)
        end
      end
      
      Processor.stack[s] = stackLayout  
    end
  end
end

function Processor:findElement(type, id, table)
  local find = false
  local index = 1
  local auxTabel
  
  if type == "flowLayout" then
    while table.flow and find == false do
      if table.flow.id ~= id then
        index = index + 1
      else
        find = true
        auxTabel = table.flow
      end
    end
    
    if find == true then
      return auxTabel
    end
  elseif type == "gridLayout" then
    while table.grid and find == false do
      if table.grid.id ~= id then
        index = index + 1
      else
        find = true
        auxTabel = table.grid
      end
    end
    
    if find == true then
      return auxTabel
    end
  elseif type == "carouselLayout" then
    while table.carousel and find == false do
      if table.carousel.id ~= id then
        index = index + 1
      else
        find = true
        auxTabel = table.carousel
      end
    end
    
    if find == true then
      return auxTabel
    end
  elseif type == "stackLayout" then
    while table.stack and find == false do
      if table.stack.id ~= id then
        index = index + 1
      else
        find = true
        auxTabel = table.stack
      end
    end
    
    if find == true then
      return auxTabel
    end
  end
end
