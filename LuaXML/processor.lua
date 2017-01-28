local flowLayout = require("flow")
local gridLayout = require("grid")
local carouselLayout = require("carousel")
local stackLayout = require("stack")

flow = nil
grid = nil
carousel = nil
stack = nil

Processor = {flow = {}, grid = {}, carousel= {}, stack = {}}

fucntion Processor:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

fucntion Processor:process(ncl, style)
  local xmlNcl = ncl
  local xmlStyle = style
  local f, g, c, s = 0, 0, 0, 0
  for k,p in ipairs (xmlStyle.root.layout.body.container)
    if p.type == "flowLayout" then
      f = f + 1
      flow = flowLayout:new()
      flow.setId(p.type.id)
      flow.setTop(p.type.top)
      flow.setLeft(p.type.left)
      flow.setBottom(p.type.bottom)
      flow.setRight(p.type.right)
      flow.setWidth(p.type.width)
      flow.setHeight(p.type.height)
      flow.setHspace(p.type.hspace)
      flow.setVspace(p.type.vspace)
      flow.setAlign(p.type.align)
      flow.setItemId(p.type.item.id)
      flow.setItemWidth(p.type.item.width)
      flow.setItemHeight(p.type.item.height)
      tableProcessin.flow[f] = flow
    elseif p.type == "gridLayout" then
      g = g + 1
      grid = gridLayout:new()
      grid.setId(p.type.id)
      grid.setTop(p.type.top)
      grid.setLeft(p.type.left)
      grid.setBottom(p.type.bottom)
      grid.setRight(p.type.right)
      grid.setWidth(p.type.width)
      grid.setHeight(p.type.height)
      grid.setHspace(p.type.hspace)
      grid.setVspace(p.type.vspace)
      grid.setColumns(p.type.columns)
      grid.setRows(p.type.item.rows)
      tableProcessin.grid[g] = grid
    elseif p.type == "carouselLayout" then
      c = c + 1
      carousel = carouselLayout:new()
      carousel.setId(p.type.id)
      carousel.setTop(p.type.top)
      carousel.setLeft(p.type.left)
      carousel.setBottom(p.type.bottom)
      carousel.setRight(p.type.right)
      carousel.setWidth(p.type.width)
      carousel.setHeight(p.type.height)
      carousel.setHspace(p.type.hspace)
      carousel.setVspace(p.type.vspace)
      carousel.setAlign(p.type.align)
      carousel.setItemId(p.type.item.id)
      carousel.setItemWidth(p.type.item.width)
      carousel.setItemHeight(p.type.item.height)
      tableProcessin.carousel[c] = carousel  
    elseif p.type == "stackLayout" then
      s = s + 1
      stack = stackLayout:new()
      stack.setId(p.type.id)
      stack.setTop(p.type.top)
      stack.setLeft(p.type.left)
      stack.setBottom(p.type.bottom)
      stack.setRight(p.type.right)
      stack.setWidth(p.type.width)
      stack.setHeight(p.type.height)
      stack.setHspace(p.type.hspace)
      stack.setVspace(p.type.vspace)
      stack.setAlign(p.type.align)
      stack.setItemId(p.type.item.id)
      stack.setItemWidth(p.type.item.width)
      stack.setItemHeight(p.type.item.height)
      tableProcessin.stack[s] = stack  
    end
  end
end

fucntion Processor:findElement(type, id, table)
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