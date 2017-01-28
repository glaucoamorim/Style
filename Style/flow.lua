Flow = {  id = "",
          focusIndex = "",
          top = "",
          left = "",
          bottom = "",
          right = "",
          width = "",
          height = "",
          hspace = "",
          vspace = "",
          align = "", 
          itemId = "",
          itemWidth = "",
          itemHeight = "",
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

function Flow:setItemId(newItemId)
  self.itemId = newItemId
end

function Flow:setItemWidth(newItemWidth)
  self.itemWidth = newItemWidth
end

function Flow:setItemHeight(newItemHeight)
  self.itemHeight = newItemHeight
end

function Flow:setMedia(newMedia, index)
  self.medias[index] = newMedia
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

function Flow:getItemId()
  return self.itemId
end

function Flow:getItemWidth()
  return self.itemWidth
end

function Flow:getItemHeight()
  return self.itemHeight
end