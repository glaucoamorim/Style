Flow = {  id = "",
          focusIndex = 0,
          top = 0,
          left = 0,
          bottom = 0,
          right = 0,
          width = 0,
          height = 0,
          hspace = 0,
          vspace = 0,
          align = "center",
          itens = {},
          medias = {}}
        
function Flow:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Flow:setId(newId)
  self.id = newId
end

function Flow:setTop(newTop)
  self.top = newTop
end

function Flow:setLeft(newLeft)
  self.left = newLeft
end

function Flow:setBottom(newBottom)
  self.bottom = newBottom
end

function Flow:setRight(newRight)
  self.right = newRight
end

function Flow:setWidth(newWidth)
  self.width = newWidth
end

function Flow:setHeight(newHeight)
  self.height = newHeight
end

function Flow:setHspace(newHspace)
  self.hspace = newHspace
end

function Flow:setVspace(newVspace)
  self.vspace = newVspace
end

function Flow:setAlign(newAlign)
  self.align = newAlign
end

function Flow:setItem(newItem)
  self.itens = newItem
end

function Flow:setMedia(newMedia)
  self.medias = newMedia
end

function Flow:getId()
  return self.id
end

function Flow:getTop()
  return self.top
end

function Flow:getLeft()
  return self.left
end

function Flow:getBottom()
  return self.bottom
end

function Flow:getRight()
  return self.right
end

function Flow:getWidth()
  return self.width
end

function Flow:getHeight()
  return self.height
end

function Flow:getHspace()
  return self.hspace
end

function Flow:getVspace()
  return self.vspace
end

function Flow:getAlign()
  return self.align
end

function Flow:getItemId(index)
  return self.itens[index].id
end

function Flow:getItemWidth(index)
  return self.itens[index].width
end

function Flow:getItemHeight(index)
  return self.itens[index].height
end