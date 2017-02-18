
resources = require 'resources'
algs      = require 'algs'
objects   = require 'objects'
local Direction = objects.Direction

-- enum to keep track of our current state,
-- e.g. in a menu, in a level, etc.
local GameState = {
  IN_MENU = {},
  IN_GAME = {},
}

function love.load()
  -- set window mode
  assert(love.window.setMode(500, 500))

  -- initialize levels
  selected_level_no = 1
  current_level_grid = nil
	levels = {
[[
##########
#        #
# b      #
#   #    #
#   ###  #
#  ###   #
#    #   #
#    b   #
#        #
##########]],
  }
  -- setup input table
  input = {}

  -- setup default font
  love.graphics.setFont(resources.fonts.main_font)

  -- initialize things relating to the menu
  game_state = GameState.IN_MENU
  menu = objects.Menu:new {
    selected_item = 1,
  	items = {
			objects.MenuItem:new {
    		name="Play", func=function()
        	current_level_grid = objects.Grid.from_string(levels[selected_level_no])
          game_state = GameState.IN_GAME
        end
  		},
  		objects.MenuItem:new {
    		name="Quit", func=function() love.event.quit(0) end
  		}
    }
	}
end

function love.keypressed(key, scancode, isRepeat)
  love.graphics.print(key, 0, 0)
  if not isRepeat then
    if key == 'up' then
      table.insert(input, Direction.UP)
    elseif key == 'down' then
      table.insert(input, Direction.DOWN)
    elseif key == 'left' then
      table.insert(input, Direction.LEFT)
    elseif key == 'right' then
      table.insert(input, Direction.RIGHT)
    elseif key == 'escape' then
      -- maybe we want escape to close a pause menu?
      --if game_state == GameState.IN_MENU then
      --  game_state = GameState.IN_GAME
    	if game_state == GameState.IN_GAME then
        game_state = GameState.IN_MENU
      end
    elseif key == 'return' then
			if game_state == GameState.IN_MENU then
        menu:activate_selection()
      end
    end
  end
end

function love.update()
  if game_state == GameState.IN_GAME then
    for _, direction in ipairs(input) do
      algs.move_all(current_level_grid, direction)
    end
  elseif game_state == GameState.IN_MENU then
    for _, direction in ipairs(input) do
      menu:change_selection(direction)
    end
  end
  input = {}
end

function love.draw()
  love.graphics.clear(0, 0, 0)
  if game_state == GameState.IN_GAME then
  	--love.graphics.print(current_level_grid:to_string())
    love.graphics.draw(current_level_grid:to_canvas(), 0, 0)
  elseif game_state == GameState.IN_MENU then
  	love.graphics.print(menu:to_string())
  end
end




