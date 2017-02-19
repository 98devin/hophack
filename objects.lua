
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
 	RED    = {},
  BLUE   = {},
  YELLOW = {},
  GREEN  = {}
}

-- Object representing a grid square.
-- the default collision is empty.
local Square = Object:new {
  collision   = Collision.EMPTY,
  occupied    = false,
  occupant    = nil, -- should contain a Block if occupied = true
  destination = nil, -- { color = ... }
  teleporter  = nil, -- if not nil, should contain a Teleporter
  image       = resources.images.squares.basic_floor,
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

local Destination = Object:new {
  color = nil
}

local Teleporter = Object:new {
  color = nil, -- a Color for use in identifying different pairs of teleporters
  covered = false, -- whether a block is sitting on top and blocking the teleporter
  updated_this_round = false,
  position = { -- the position in the grid which this teleporter is found at
    x = nil, y = nil
  },
  warp_position = { -- the position to which it warps.
    x = nil, y = nil
  }
}

function char_to_teleporter_color(char)
  if char == "t" then
    return Color.BLUE
  elseif char == "T" then
    return Color.RED
  elseif char == "u" then
    return Color.YELLOW
  elseif char == "U" then
    return Color.GREEN
  end
end

function link_teleporters(teleporters)
  local found_match = {} -- keeps track of found matches, ensures we don't match 3+ teleporters
  local by_color = {} -- stores a teleporter of the proper color (which we should match with)
  for _, teleporter in ipairs(teleporters) do
    if by_color[teleporter.color] then
      if found_match[teleporter.color] then
        error("Found three or more teleporters of the same color when parsing a level.")
      end
      local match = by_color[teleporter.color]
      match.warp_position = teleporter.position
      teleporter.warp_position = match.position
      found_match[teleporter.color] = true
    else
      by_color[teleporter.color] = teleporter
    end
  end
end

local Grid = Object:new {
  size = {
    x = 10,
    y = 10
  },
  squares = nil, -- will be initialized in Grid:new
  blocks  = nil, -- same
  teleporters = {},
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

function Grid.from_Level(level)
  local grid = Grid:new{
    size = level.size
  }
  local x = 1
  local y = 1
  local teleporters = {}
  for line in (level.levelstr .. "\n"):gmatch("([^\n]*)\n") do
  	for char in line:gmatch(".") do
      if char == " " then
      	grid.squares[y][x] = Square:new {
          collision = Collision.EMPTY,
          image     = resources.images.squares.basic_empty
        }
      elseif char:match("[a-dx]") then
        local block = Block:new {
        	position = {x = x, y = y},
          image    = resources.images.blocks.basic,
          color = char_to_color(char)
        }
        grid.squares[y][x] = Square:new {
          collision = Collision.EMPTY,
          image     = resources.images.squares.basic_empty,
          occupied  = true,
          occupant  = block
        }
        table.insert(grid.blocks, block)
      elseif char == "#" then   
        grid.squares[y][x] = Square:new {
          collision = Collision.WALL,
          image     = resources.images.squares.basic_wall
        }
      elseif char:match("[A-DX]") then
        grid.squares[y][x] = Square:new {
        	collision = Collision.EMPTY,
          destination = Destination:new{color = char_to_color(char)},
          image = resources.images.squares.basic_empty,
        }
      elseif char:match("[%-%|0-7]") then
        grid.squares[y][x] = Square:new {
          collision = char_to_collision(char),
          image = resources.images.squares.basic_empty
        }
      elseif char:match("[tTuU]") then
        local teleporter = Teleporter:new{
          color = char_to_teleporter_color(char),
          position = {x = x, y = y}
        }
        grid.squares[y][x] = Square:new {
          teleporter = teleporter,
          image = resources.images.squares.basic_empty
        }
        table.insert(teleporters, teleporter)
      end
      x = x + 1
    end
  	y = y + 1
    x = 1
  end
  link_teleporters(teleporters)
  grid.teleporters = teleporters
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
      local xpos, ypos = x * 50, y * 50
      canvas:renderTo(function()
        if square.occupied then
          love.graphics.draw(square.occupant.image, xpos, ypos, 0, 5)
          if square.occupant.color then
            love.graphics.draw(
              resources.images.blocks.modifiers.color[color_to_string(square.occupant.color)], xpos, ypos, 0, 5
            )
          end
        else
          love.graphics.draw(square.image, xpos, ypos, 0, 5)
          if square.teleporter then
            love.graphics.draw(
              resources.images.squares.modifiers.teleporter[color_to_string(square.teleporter.color)], xpos, ypos, 0, 5
            )
          end
          if square.destination then
            love.graphics.draw(
              resources.images.squares.modifiers.destination[color_to_string(square.destination.color)], xpos, ypos, 0, 5
            )
          end
        end
        if square.collision ~= Collision.WALL and
           square.collision ~= Collision.EMPTY then
          if not square.collision.up then
            love.graphics.draw(resources.images.squares.modifiers.collision.up, xpos, ypos, 0, 5)
          end
          if not square.collision.down then
            love.graphics.draw(resources.images.squares.modifiers.collision.down, xpos, ypos, 0, 5)
          end
          if not square.collision.left then
            love.graphics.draw(resources.images.squares.modifiers.collision.left, xpos, ypos, 0, 5)
          end
          if not square.collision.right then
            love.graphics.draw(resources.images.squares.modifiers.collision.right, xpos, ypos, 0, 5)
          end
        end
      end)
    end
  end
  return canvas
end

local Menu = Object:new {
  name  = "",
	items = {},
  selected_item = 1,
  body = ""
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
  str = str .. "\n\n\n" .. self.body
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

function char_to_color(c)
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

function color_to_string(c)
  if c == Color.RED then
    return 'red'
  elseif c == Color.BLUE then
    return 'blue'
  elseif c == Color.GREEN then
    return 'green'
  elseif c == Color.YELLOW then
    return 'yellow'
  elseif c == nil then
    return 'neutral'
  end
end

local Level = Object:new {
  name = "",
  size = {
    x = nil, y = nil
  },
  levelstr = "",
  time = 0,
  moves = 0
}

local Handful = Object:new {
  name = "",
 	levels = {}, -- a list of the levels comprising the handful 
  end_menu = nil, -- a menu to be launched when this is completed
}

function Handful:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o:update_menu_body()
  return o
end

function Handful:update_menu_body()
  if self.end_menu then
    self.end_menu.body = get_body(self.levels)
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
  Direction = Direction,
  Level     = Level,
  Handful   = Handful
}

return exports