Grid = {  id = " ",
          focusIndex = 0,
          top = 0,
          left = 0,
          bottom = 0,
          right = 0,
          width = 0,
          height = 0,
          hspace = 0,
          vspace = 0,
          columns = 0,
          rows = 0}
        
function Grid:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Grid:setId(newId)
  self.id = newId
end

function Grid:setTop(newTop)
  self.top = newTop
end

function Grid:setLeft(newLeft)
  self.left = newLeft
end

function Grid:setBottom(newBottom)
  self.bottom = newBottom
end

function Grid:setRight(newRight)
  self.right = newRight
end

function Grid:setWidth(newWidth)
  self.width = newWidth
end

function Grid:setHeight(newHeight)
  self.height = newHeight
end

function Grid:setHspace(newHspace)
  self.hspace = newHspace
end

function Grid:setVspace(newVspace)
  self.vspace = newVspace
end

function Grid:setColumns(newColumns)
  self.columns = newColumns
end

function Grid:setRows(newRows)
  self.rows = newRows
end

function Grid:getId()
  return self.id
end

function Grid:getTop()
  return self.top
end

function Grid:getLeft()
  return self.left
end

function Grid:getBottom()
  return self.bottom
end

function Grid:getRight()
  return self.right
end

function Grid:getWidth()
  return self.width
end

function Grid:getHeight()
  return self.height
end

function Grid:getHspace()
  return self.hspace
end

function Grid:getVspace()
  return self.vspace
end

function Grid:getColumns()
  return self.columns
end

function Grid:getRows()
  return self.rows
end