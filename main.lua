
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
  -- set graphics modes
  assert(love.window.setMode(500, 500))
  love.graphics.setDefaultFilter('linear', 'nearest')

  -- initialize levels
  selected_level_no = 1
  current_level_grid = nil
	levels = {
[[
##########
#       x#
# b      #
#   #x   #
#   ###  #
#  ###x  #
#   x#   #
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
  main_menu = objects.Menu:new {
    name = "Main Menu:",
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
  pause_menu = objects.Menu:new {
    name = "Game paused.",
  	items = {
      objects.MenuItem:new {
    		name="Continue", func=function()
        	game_state = GameState.IN_GAME
      	end
      },
    	objects.MenuItem:new {
    		name="Exit to Main Menu", func=function()
          current_menu = main_menu
          current_menu.selected_item = 1
        end
      },
      objects.MenuItem:new {
        name="Restart level", func=function()
        	current_level_grid = objects.Grid.from_string(levels[selected_level_no])
          game_state = GameState.IN_GAME
        end
      }
    }
  }
  clear_menu = objects.Menu:new {
    name = "Level Cleared!",
    items = {
    	objects.MenuItem:new {
      	name="Advance to next level", func=function()
          selected_level_no = selected_level_no + 1
          current_level_grid = objects.Grid.from_string(levels[selected_level_no])
        	game_state = GameState.IN_GAME
        end
      },
      objects.MenuItem:new {
        name="Exit to Main Menu", func=function()
          current_menu = main_menu
          current_menu.selected_item = 1
        end
      },
      objects.MenuItem:new {
        name="Restart level", func=function()
          current_level_grid = objects.Grid.from_string(levels[selected_level_no])
          game_state = GameState.IN_GAME
        end
      }
    }
  }

  current_menu = main_menu -- start off at the main menu

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
    	if game_state == GameState.IN_GAME then
        current_menu = pause_menu
        game_state = GameState.IN_MENU
      end
    elseif key == 'return' then
			if game_state == GameState.IN_MENU then
        current_menu:activate_selection()
      end
    end
  end
end

function love.update()
  if game_state == GameState.IN_GAME then
    for _, direction in ipairs(input) do
      algs.move_all(current_level_grid, direction)
      if algs.has_won(current_level_grid) then
        game_state = GameState.IN_MENU
        current_menu = clear_menu
        current_menu.selected_item = 1
      end
    end
  elseif game_state == GameState.IN_MENU then
    for _, direction in ipairs(input) do
      current_menu:change_selection(direction)
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
  	love.graphics.print(current_menu:to_string())
  end
end




