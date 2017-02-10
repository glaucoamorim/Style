Stack = {  id = "",
          focusIndex = 0,
          top = 0,
          left = 0,
          bottom = 0,
          right = 0,
          width = 0,
          height = 0,
          zIndex = 0,
          orientation = "",
          align = "center",
          step = 0,
          itens = {},
          medias = {}}
        
function Stack:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Stack:setId(newId)
  self.id = newId
end

function Stack:setTop(newTop)
  self.top = newTop
end

function Stack:setLeft(newLeft)
  self.left = newLeft
end

function Stack:setBottom(newBottom)
  self.bottom = newBottom
end

function Stack:setRight(newRight)
  self.right = newRight
end

function Stack:setWidth(newWidth)
  self.width = newWidth
end

function Stack:setHeight(newHeight)
  self.height = newHeight
end

function Stack:setZindex(newZindex)
  self.zIndex = newZindex
end

function Stack:setOrientation(newOrientation)
  self.orientation = newOrientation
end

function Stack:setAlign(newAlign)
  self.align = newAlign
end

function Stack:setStep(newStep)
  self.step = newStep
end

function Stack:setItem(newItem)
  self.itens = newItem
end

function Stack:setMedia(newMedia, index)
  self.medias[index] = newMedia
end

function Stack:getId()
  return self.id
end

function Stack:getTop()
  return self.top
end

function Stack:getLeft()
  return self.left
end

function Stack:getBottom()
  return self.bottom
end

function Stack:getRight()
  return self.right
end

function Stack:getWidth()
  return self.width
end

function Stack:getHeight()
  return self.height
end

function Stack:getZindex()
  return self.zIndex
end

function Stack:getOrientation()
  return self.orientation
end

function Stack:getAlign()
  return self.align
end

function Stack:getStep()
  return self.step
end

function Stack:getItemId(index)
  return self.itens[index].id
end

function Stack:getItemWidth(index)
  return self.itens[index].width
end

function Stack:getItemHeight(index)
  return self.itens[index].height
end