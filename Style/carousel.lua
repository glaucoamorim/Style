Carousel = {  id = "",
          focusIndex = 0,
          top = 0,
          left = 0,
          bottom = 0,
          right = 0,
          width = 0,
          height = 0,
          itens = {},
          medias = {}}
        
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

function Carousel:setItem(newItem)
  self.itens = newItem
end

function Carousel:setMedia(newMedia, index)
  self.medias[index] = newMedia
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

function Carousel:getItemId(index)
  return self.itens[index].id
end

function Carousel:getItemWidth(index)
  return self.itens[index].width
end

function Carousel:getItemHeight(index)
  return self.itens[index].height
end