
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

-- Object representing a grid square.
-- the default collision is empty.
local Square = Object:new {
  collision = Collision.EMPTY,
  occupied = false,
  occupant = nil -- should contain a Block if occupied = true
}

local Block = Object:new {
	collision = Collision.WALL,
  position = {
    x = nil,
    y = nil
  }
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
      	grid.squares[y][x] = Square:new{collision = Collision.EMPTY}
      elseif char == "b" then
        local block = Block:new {
        	position = {x = x, y = y}
        }
        grid.squares[y][x] = Square:new {
          collision=Collision.EMPTY, occupied=true, occupant=block
        }
        table.insert(grid.blocks, block)
      elseif char == "#" then   
        grid.squares[y][x] = Square:new{collision = Collision.WALL}
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

local Menu = Object:new {
	items = {},
  selected_item = 1
}

function Menu:to_string()
  local str = ""
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

