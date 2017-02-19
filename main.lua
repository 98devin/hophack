
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

local GameMode = {
  TIME = {},
  MOVES = {},
  NORMAL = {}
}
function love.load()
  -- set graphics modes
  SCREEN_WIDTH = 500
  SCREEN_HEIGHT = 500
  assert(love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT))
  love.graphics.setDefaultFilter('linear', 'nearest')

  -- initialize levels
  selected_level_no = 1
  seleceted_handful_no = 1
  current_level_grid = nil
	handfuls = {
  	objects.Handful:new {
    	name = "The First Five",
      end_menu = objects.Menu:new {
        name = "Congratulations!\nYou have conquered a handful of simple levels.",
        items = {
          objects.MenuItem:new {
            name="Play again", func=function()
              game_state = GameState.IN_GAME
              selected_level_no = 1
              selected_handful_no = 1
              current_level_grid = objects.Grid.from_Level(handfuls[selected_handful_no].levels[selected_level_no])
              time_elapsed = 0
              moves_made = 0
            end
          },
          objects.MenuItem:new {
            name="Exit to Main Menu", func=function()
              current_menu = main_menu
              current_menu.selected_item = 1
              game_mode = GameMode.NORMAL
            end
          },
          objects.MenuItem:new {
            name="Transcend", func=function() love.event.quit(0) end
          }
        }
      },
      levels = {
      	objects.Level:new {
        	name = "Level 1",
          size = {x = 10, y = 10},
          levelstr =[[
##########
#T      t#
#        #
#   A#   #
#  ###A  #
#  B###  #
#a  #B  b#
#        #
#t      T#
##########]]
        },
        objects.Level:new {
        	name = "Level 2",
          size = {x = 10, y = 10},
          levelstr =[[
##########
# BC A   #
# cb# #  #
#   ##   #
#   ###  #
#  a #   #
#        #
#        #
#        #
##########]]
        },
        objects.Level:new {
        	name = "Level 3",
          size = {x = 10, y = 10},
          levelstr =[[
##########
#     ##B#
# b #### #
#    B   #
#   ######
#        #
#   B#   #
#    b   #
#        #
##########]]
        },
        objects.Level:new {
          name = "Level 4",
        	size = {x = 10, y = 10},
          levelstr =[[
##########
#       B#
#x  ###  #
#    #  A#
#a       #
#   #   D#
#d  ##   #
#    #  X#
#b       #
##########]]
        },
        objects.Level:new {
        	name = "Level 5",
          size = {x = 10, y = 10},
          levelstr =[[
##########
#       B#
#x  123  #
#    4  A#
#a       #
#   5   D#
#d  67   #
#    0  X#
#b       #
##########]]
        }
      }
    }
  }
  

  -- setup input table
  input = {}

  -- setup default font
  love.graphics.setFont(resources.fonts.main_font)

  -- initialize things relating to the menu
  game_state = GameState.IN_MENU
  game_mode = NORMAL
  main_menu = objects.Menu:new {
    name = "Main Menu:",
  	items = {
			objects.MenuItem:new {
    		name="Play", func=function()
          selected_level_no = 1
          selected_handful_no = 1
        	current_menu = selectmode_menu
          current_menu.selected_item = 1
        end
  		},
  		objects.MenuItem:new {
    		name="Quit", func=function() love.event.quit(0) end
  		}
    }
	}
  selectmode_menu = objects.Menu:new {
    name = "Select game mode",
    items = {
      objects.MenuItem:new {
        name = "Normal", func = function()
          game_mode = GameMode.NORMAL
          current_level_grid = objects.Grid.from_Level(handfuls[selected_handful_no].levels[selected_level_no])
          game_state = GameState.IN_GAME
          --time_elapsed = 0
          --moves_made = 0
        end
      },
      objects.MenuItem:new {
        name = "Time Attack", func = function()
          game_mode = GameMode.TIME
          current_level_grid = objects.Grid.from_Level(handfuls[selected_handful_no].levels[selected_level_no])
          game_state = GameState.IN_GAME
          time_elapsed = 0
          --moves_made = 0
        end
      },
      objects.MenuItem:new {
        name = "Move Challenge", func = function()
          game_mode = GameMode.MOVES
          current_level_grid = objects.Grid.from_Level(handfuls[selected_handful_no].levels[selected_level_no])
          game_state = GameState.IN_GAME
          --time_elapsed = 0
          moves_made = 0
        end
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
          game_mode = GameMode.NORMAL
        end
      },
      objects.MenuItem:new {
        name="Restart level", func=function()
        	current_level_grid = objects.Grid.from_Level(handfuls[selected_handful_no].levels[selected_level_no])
          game_state = GameState.IN_GAME
          time_elapsed = 0
          moves_made = 0
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
          
          current_level_grid = objects.Grid.from_Level(handfuls[selected_handful_no].levels[selected_level_no])
        	game_state = GameState.IN_GAME
          time_elapsed = 0
          moves_made = 0
        end
      },
      objects.MenuItem:new {
        name="Exit to Main Menu", func=function()
          current_menu = main_menu
          current_menu.selected_item = 1
          game_mode = GameMode.NORMAL
        end
      },
      objects.MenuItem:new {
        name="Restart level", func=function()
          current_level_grid = objects.Grid.from_Level(handfuls[selected_handful_no].levels[selected_level_no])
          game_state = GameState.IN_GAME
          time_elapsed = 0
          moves_made = 0
        end
      }
    }
  }
  current_menu = main_menu -- start off at the main menu

  -- relating to Timed Mode
  time_elapsed = 0
  
  -- relating to Move Challenge mode
  moves_made = 0

end

function love.keypressed(key)
  love.graphics.print(key, 0, 0)
  --if not isRepeat then
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
  --end
end

function love.update(dt)
  if game_state == GameState.IN_GAME then
    for _, direction in ipairs(input) do
      local moved = algs.move_all(current_level_grid, direction)
      if moved then
        moves_made = moves_made + 1
      end
      if algs.has_won(current_level_grid) then
        game_state = GameState.IN_MENU
        if selected_level_no == #(handfuls[selected_handful_no].levels) then
          current_menu = handfuls[selected_handful_no].end_menu
          current_menu.selected_item = 1
        else
          current_menu = clear_menu
        end
        current_menu.selected_item = 1
      end
    end
  elseif game_state == GameState.IN_MENU then
    for _, direction in ipairs(input) do
      current_menu:change_selection(direction)
    end
  end
  input = {}
  if game_state == GameState.IN_GAME then
  	time_elapsed = time_elapsed + dt
  end
end

function love.draw()
  love.graphics.clear(0, 0, 0)
  if game_state == GameState.IN_GAME then
  	--love.graphics.print(current_level_grid:to_string())
    love.graphics.draw(current_level_grid:to_canvas(), 0, 0)
  elseif game_state == GameState.IN_MENU then
  	love.graphics.print(current_menu:to_string())
  end
  
  if game_mode == GameMode.TIME then
    love.graphics.print(string.format("TIME: %.2f", time_elapsed), 0, SCREEN_HEIGHT - 20)
  elseif game_mode == GameMode.MOVES then
    love.graphics.print(string.format("MOVES MADE: %d", moves_made), 0, SCREEN_HEIGHT - 20)
  end
end




