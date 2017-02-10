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

function split_tag(str, pat)
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
  local first = true
  local auxTable = {}
  
  for k,p in pairs(xmlStyle.layout.body.container) do
    if type(k) == "number" then
      if p._attr.type == "flowLayout" then
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
        flowLayout:setItem(p.item)
        
        for i,j in ipairs(xmlNcl.ncl.body.media) do
          if(j._attr.layout ~= nil) then
            auxID = split_tag(j._attr.layout, "#")
            if auxID[2] == p._attr.id then
              auxTable[i] = j
            end
          end
        end
        
        flowLayout:setMedia(auxTable)
        
        self.flow[f] = flowLayout
      elseif p._attr.type == "gridLayout" then
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
          if(j._attr.layout ~= nil) then
            auxID = split_tag(j._attr.layout, "#")
            if auxID[2] == p._attr.id then
              gridLayout:setMedia(j, i)
            end
          end 
        end
        
        self.grid[g] = gridLayout
      elseif p._attr.type == "carouselLayout" then
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
        carouselLayout:setItem(p.item)
        
        for i,j in ipairs(xmlNcl.root.ncl.body.media) do
          auxID[2] = split_tag(j._attr.layout, "#")
          if(j._attr.layout ~= nil) then
            if auxID == p._attr.id then
              carouselLayout:setMedia(j, i)
            end
          end
        end
        
        self.carousel[c] = carouselLayout  
      elseif p._attr.type == "stackLayout" then
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
        stackLayout:setItemId(p.item)
        
        for i,j in ipairs(xmlNcl.root.ncl.body.media) do
          if(j._attr.layout ~= nil) then
            auxID[2] = split_tag(j._attr.layout, "#")
            if auxID == p._attr.id then
              stackLayout:setMedia(j, i)
            end
          end
        end
        
        self.stack[s] = stackLayout  
      end
    else
      if xmlStyle.layout.body.container._attr.type == "flowLayout" and first then
        f = f + 1
        first = false
        flowLayout = Flow:new()
        flowLayout:setId(xmlStyle.layout.body.container._attr.id)
        flowLayout:setTop(xmlStyle.layout.body.container.format._attr.top)
        flowLayout:setLeft(xmlStyle.layout.body.container.format._attr.left)
        flowLayout:setBottom(xmlStyle.layout.body.container.format._attr.bottom)
        flowLayout:setRight(xmlStyle.layout.body.container.format._attr.right)
        flowLayout:setWidth(xmlStyle.layout.body.container.format._attr.width)
        flowLayout:setHeight(xmlStyle.layout.body.container.format._attr.height)
        flowLayout:setHspace(xmlStyle.layout.body.container.format._attr.hspace)
        flowLayout:setVspace(xmlStyle.layout.body.container.format._attr.vspace)
        flowLayout:setAlign(xmlStyle.layout.body.container.format._attr.align)
        flowLayout:setItem(xmlStyle.layout.body.container.item)
        
        for i,j in ipairs(xmlNcl.ncl.body.media) do
          if(j._attr.layout ~= nil) then
            auxID = split_tag(j._attr.layout, "#")
            if auxID[2] == xmlStyle.layout.body.container._attr.id then
              auxTable[i] = j
            end
          end
        end
        
        flowLayout:setMedia(auxTable)
        
        self.flow[f] = flowLayout
      elseif xmlStyle.layout.body.container._attr.type == "gridLayout" and first then
        g = g + 1
        first = false
        gridLayout = Grid:new()
        gridLayout:setId(xmlStyle.layout.body.container._attr.id)
        gridLayout:setTop(xmlStyle.layout.body.container.format._attr.top)
        gridLayout:setLeft(xmlStyle.layout.body.container.format._attr.left)
        gridLayout:setBottom(xmlStyle.layout.body.container.format._attr.bottom)
        gridLayout:setRight(xmlStyle.layout.body.container.format._attr.right)
        gridLayout:setWidth(xmlStyle.layout.body.container.format._attr.width)
        gridLayout:setHeight(xmlStyle.layout.body.container.format._attr.height)
        gridLayout:setHspace(xmlStyle.layout.body.container.format._attr.hspace)
        gridLayout:setVspace(xmlStyle.layout.body.container.format._attr.vspace)
        gridLayout:setColumns(xmlStyle.layout.body.container.format._attr.columns)
        gridLayout:setRows(xmlStyle.layout.body.container.format._attr.rows)
        
        for i,j in ipairs(xmlNcl.ncl.body.media) do
          if(j._attr.layout ~= nil) then
            auxID = split_tag(j._attr.layout, "#")
            if auxID[2] == xmlStyle.layout.body.container._attr.id then
              gridLayout:setMedia(j, i)
            end
          end 
        end
        
        self.grid[g] = gridLayout
      elseif xmlStyle.layout.body.container._attr.type == "carouselLayout" and first then
        c = c + 1
        first = false
        carouselLayout = Carousel:new()
        carouselLayout:setId(xmlStyle.layout.body.container._attr.id)
        carouselLayout:setTop(xmlStyle.layout.body.container.format._attr.top)
        carouselLayout:setLeft(xmlStyle.layout.body.container.format._attr.left)
        carouselLayout:setBottom(xmlStyle.layout.body.container.format._attr.bottom)
        carouselLayout:setRight(xmlStyle.layout.body.container.format._attr.right)
        carouselLayout:setWidth(xmlStyle.layout.body.container.format._attr.width)
        carouselLayout:setHeight(xmlStyle.layout.body.container.format._attr.height)
        carouselLayout:setHspace(xmlStyle.layout.body.container.format._attr.hspace)
        carouselLayout:setVspace(xmlStyle.layout.body.container.format._attr.vspace)
        carouselLayout:setAlign(xmlStyle.layout.body.container.format._attr.align)
        carouselLayout:setItem(xmlStyle.layout.body.container.item)
        
        for i,j in ipairs(xmlNcl.root.ncl.body.media) do
          auxID[2] = split_tag(j._attr.layout, "#")
          if(j._attr.layout ~= nil) then
            if auxID == xmlStyle.layout.body.container._attr.id then
              carouselLayout:setMedia(j, i)
            end
          end
        end
        
        self.carousel[c] = carouselLayout  
      elseif xmlStyle.layout.body.container._attr.type == "stackLayout" and first then
        s = s + 1
        first = false
        stackLayout = Stack:new()
        stackLayout:setId(xmlStyle.layout.body.container._attr.id)
        stackLayout:setTop(xmlStyle.layout.body.container.format._attr.top)
        stackLayout:setLeft(xmlStyle.layout.body.container.format._attr.left)
        stackLayout:setBottom(xmlStyle.layout.body.container.format._attr.bottom)
        stackLayout:setRight(xmlStyle.layout.body.container.format._attr.right)
        stackLayout:setWidth(xmlStyle.layout.body.container.format._attr.width)
        stackLayout:setHeight(xmlStyle.layout.body.container.format._attr.height)
        stackLayout:setHspace(xmlStyle.layout.body.container.format._attr.hspace)
        stackLayout:setVspace(xmlStyle.layout.body.container.format._attr.vspace)
        stackLayout:setAlign(xmlStyle.layout.body.container.format._attr.align)
        stackLayout:setItemId(xmlStyle.layout.body.container.item)
        
        for i,j in ipairs(xmlNcl.root.ncl.body.media) do
          if(j._attr.layout ~= nil) then
            auxID[2] = split_tag(j._attr.layout, "#")
            if auxID == xmlStyle.layout.body.container._attr.id then
              stackLayout:setMedia(j, i)
            end
          end
        end
        
        self.stack[s] = stackLayout  
      end
    end
  end
  local auxP = {}
  auxP.flow = self.flow
  auxP.grid = self.grid
  auxP.stack = self.stack
  auxP.carousel = self.carousel
  auxP.untype = self.untype
  auxP.itens = self.itens
  return auxP
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
