
resources = require 'resources'

-- Object, the root of our inheritance tree
local Object = {}

-- all Object is good for is letting things
-- know how to be instantiated.
function Object:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end


-- Collision represents the solidity of a grid square
local Collision = Object:new {
  up = false,      -- whether collision is enabled from above
  down = false,    -- etc.
  left = false,    -- etc.
  right = false
}

-- A type of Collision which will be used pretty often,
-- so we just give it a convenient name.
Collision.WALL = Collision:new {
  up = true,
  down = true,
  left = true,
  right = true
}

-- same for EMPTY spaces
Collision.EMPTY = Collision:new{}

-- enum of possible directions
local Direction = {
	UP    = {},
  DOWN  = {},
  LEFT  = {},
  RIGHT = {}
}

local Color = {
 	RED = {},
  BLUE = {},
  YELLOW = {},
  GREEN = {}
}

-- Object representing a grid square.
-- the default collision is empty.
local Square = Object:new {
  collision   = Collision.EMPTY,
  occupied    = false,
  destination = nil, -- { color = ... }
  image       = resources.images.squares.basic_floor,
  occupant    = nil -- should contain a Block if occupied = true
}

local Block = Object:new {
	collision = Collision.WALL,
  image     = resources.images.blocks.basic,
  position = {
    x = nil,
    y = nil
  },
  color = nil
}

local Grid = Object:new {
  size = {
    x = 10,
    y = 10
  },
  squares = nil, -- will be initialized in Grid:new
  blocks  = nil  -- same
}

function Grid:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  -- initialize the `squares` matrix
  o.squares = {}
  o.blocks  = {}
  for y = 1, o.size.y do
    table.insert(o.squares, {})
  end
  return o
end

function Grid:get(x, y)
	return self.squares[y][x]
end

function Grid.from_string(levelstr)
  local grid = Grid:new()
  local x = 1
  local y = 1
  for line in (levelstr .. "\n"):gmatch("([^\n]*)\n") do
  	for char in line:gmatch(".") do
      if char == " " then
      	grid.squares[y][x] = Square:new {
          collision = Collision.EMPTY,
          image     = resources.images.squares.basic_floor
        }
      elseif char:match("[a-d]") then
        local block = Block:new {
        	position = {x = x, y = y},
          image    = resources.images.blocks.basic,
          color = charToColor(char)
        }
        grid.squares[y][x] = Square:new {
          collision = Collision.EMPTY,
          image     = resources.images.squares.basic_floor,
          occupied  = true,
          occupant  = block
        }
        table.insert(grid.blocks, block)
      elseif char == "#" then   
        grid.squares[y][x] = Square:new {
          collision = Collision.WALL,
          image     = resources.images.squares.basic_wall
        }
      elseif char:match("[A-D]") then
        grid.squares[y][x] = Square:new {
        	collision = Collision.EMPTY,
          destination = {color = charToColor(char)},
          image = resources.images.squares.destination_floor
        }
      end
      x = x + 1
    end
  	y = y + 1
    x = 1
  end
  return grid
end

function Grid:to_string()
  local str = ""
  for y = 1, self.size.y do
    for x = 1, self.size.x do
    	local square = self:get(x, y)
      if not square.occupied then
        if square.collision == Collision.WALL then
          str = str .. "#"
        else
          str = str .. " "
        end
      else
        str = str .. "b"
      end
    end
    str = str .. "\n"
  end
  return str
end

function Grid:to_canvas()
  local canvas = love.graphics.newCanvas(self.size.x * 50, self.size.y * 50)
  for y = 0, self.size.y - 1 do
    for x = 0, self.size.x - 1 do
      local square = self:get(x + 1, y + 1)
      if square.occupied then
        canvas:renderTo(function()
          love.graphics.draw(square.occupant.image, x * 50, y * 50, 0, 5)
        end)
      else
        canvas:renderTo(function()
          love.graphics.draw(square.image, x * 50, y * 50, 0, 5)
        end)
      end
    end
  end
  return canvas
end

local Menu = Object:new {
  name  = "",
	items = {},
  selected_item = 1
}

function Menu:to_string()
  local str = self.name .. "\n"
  for item_no, menu_item in ipairs(self.items) do
    if item_no == self.selected_item then
      str = str .. " * "
    else
      str = str .. "   "
    end
    str = str .. menu_item.name .. "\n"
  end
  return str
end

function Menu:change_selection(direction)
  
  if direction == Direction.UP then
    self.selected_item = self.selected_item - 1
  elseif direction == Direction.DOWN then
    self.selected_item = self.selected_item + 1
  end
  
  if self.selected_item < 1 then
    self.selected_item = #self.items
  elseif self.selected_item > #self.items then
    self.selected_item = 1
  end

end

function Menu:activate_selection()
  self.items[self.selected_item].func()
end


local MenuItem = Object:new {
  name = "",
  func = nil, -- function which will be called when the menu item is chosen
}

local Desitnation = Object:new {
  color = nil
}

function charToColor(c)
  local c = string.lower(c)
  if c == 'a' then
    return Color.RED
  elseif c == 'b' then
    return Color.BLUE
  elseif c == 'c' then
    return Color.GREEN
  elseif c == 'd' then
    return Color.YELLOW
  end
end
exports = {
  Object    = Object,
	Collision = Collision,
  Square    = Square,
  Grid      = Grid,
  Block     = Block,
  MenuItem  = MenuItem,
  Menu      = Menu,
  Direction = Direction
}

return exports