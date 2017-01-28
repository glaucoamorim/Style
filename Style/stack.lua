Stack = {  id = "",
          focusIndex = "",
          top = "",
          left = "",
          bottom = "",
          right = "",
          width = "",
          height = "",
          zIndex = "",
          orientation = "",
          align = "",
          step = "",
          itemId = "",
          itemWidth = "",
          itemHeight = ""}
        
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

function Stack:setItemId(newItemId)
  self.itemId = newItemId
end

function Stack:setItemWidth(newItemWidth)
  self.itemWidth = newItemWidth
end

function Stack:setItemHeight(newItemHeight)
  self.itemHeight = newItemHeight
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

function Stack:getItemId()
  return self.itemId
end

function Stack:getItemWidth()
  return self.itemWidth
end

function Stack:getItemHeight()
  return self.itemHeight
end