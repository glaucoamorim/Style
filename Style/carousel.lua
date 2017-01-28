Carousel = {  id = "",
          focusIndex = "",
          top = "",
          left = "",
          bottom = "",
          right = "",
          width = "",
          height = "",
          itemId = "",
          itemWidth = "",
          itemHeight = ""}
        
function Carousel:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Carousel:setId(newId)
  self.id = newId
end

function Carousel:setTop(newTop)
  self.top = newTop
end

function Carousel:setLeft(newLeft)
  self.left = newLeft
end

function Carousel:setBottom(newBottom)
  self.bottom = newBottom
end

function Carousel:setRight(newRight)
  self.right = newRight
end

function Carousel:setWidth(newWidth)
  self.width = newWidth
end

function Carousel:setHeight(newHeight)
  self.height = newHeight
end

function Carousel:setItemId(newItemId)
  self.itemId = newItemId
end

function Carousel:setItemWidth(newItemWidth)
  self.itemWidth = newItemWidth
end

function Carousel:setItemHeight(newItemHeight)
  self.itemHeight = newItemHeight
end

function Carousel:getId()
  return self.id
end

function Carousel:getTop()
  return self.top
end

function Carousel:getLeft()
  return self.left
end

function Carousel:getBottom()
  return self.bottom
end

function Carousel:getRight()
  return self.right
end

function Carousel:getWidth()
  return self.width
end

function Carousel:getHeight()
  return self.height
end

function Carousel:getItemId()
  return self.itemId
end

function Carousel:getItemWidth()
  return self.itemWidth
end

function Carousel:getItemHeight()
  return self.itemHeight
end