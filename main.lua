
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

  -- initialize levels
  selected_level_no = 1
  selected_handful_no = 1
  current_level_grid = nil
  handfuls = {
    objects.Handful:new {
      name = "The First Five",
      end_menu = end_menu("Congratulations!\n\n"),
      levels = {
        objects.Level:new {
          name = "Go on...",
          size = {x = 10, y = 9},
          levelstr =[[
##########
#        #
#        #
#        #
# x    X #
#        #
#        #
#        #
##########]]
        },
        objects.Level:new {
          name = "The Divide",
          size = {x = 9, y = 9},
          levelstr =[[
#########
#       #
#       #
#   #   #
# x # X #
#   #   #
#       #
#       #
#########]]
        },
        objects.Level:new {
          name = "Coming Together",
          size = {x = 10, y = 9},
          levelstr =[[
##########
#   XX   #
#        #
#   ##   #
# x ## x #
#   ##   #
#        #
#        #
##########]]
        },
        objects.Level:new {
          name = "Growing Apart",
          size = {x = 10, y = 10},
          levelstr =[[
##########
#        #
#   xx   #
#        #
#  ####  #
#   ##   #
#   ##   #
#   ##   #
# X ## X #
##########]]
        },
        objects.Level:new {
          name = "Three's a Crowd",
          size = {x = 9, y = 9},
          levelstr =[[
#########
#       #
# x   X #
#   #   #
# x # X #
#   #   #
# x   X #
#       #
#########]]
        }
        
      },

    },
    objects.Handful:new {
      name = "The Second Five",
      end_menu = end_menu("Congratulations!\n\n"),
      levels = {
        objects.Level:new {
          name = "Level 6",
          size = {x = 9, y = 10},
          levelstr = [[
#########
#   #   #
#   #   #
# a B   #
#   #   #
#   #   #
# b A   #
#   #   #
#   #   #
#########]]
        },
        objects.Level:new {
          name = "Twins",
          size = {x = 10, y = 9},
          levelstr = [[
##########
#    # # #
#a #   #X#
#  # #   #
##########
#  # #   #
#b #   #X#
#    # # #
##########]]
        },
        objects.Level:new {
          name = "Multiple Choice",
          size = {x = 10, y = 10},
          levelstr = [[
##########
#       A#
# a      #
#   #B   #
#  B###  #
#  ###B  #
#   B#   #
# b      #
#        #
##########]]
        },
        objects.Level:new {
          name = "Corridors",
          size = {x = 9, y = 9},
          levelstr = [[
#########
#X##A##X#
# ## ## #
# ## ## #
#       #
# ## ## #
# ## ## #
#a##b##a#
#########]]
        },
        objects.Level:new {
          name = "Tetris",
          size = {x = 10, y = 10},
          levelstr = [[
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
        }
      }
    },
    objects.Handful:new {
      name = "The Third Five",
      end_menu = end_menu("Congratulations\n\n"),
      levels = {
        objects.Level:new {
          name = "No Entry",
          size = {x = 10, y = 10},
          levelstr = [[
##########
#        #
#        #
##########
####  ####
# x  5 X #
##########
#        #
#        #
##########]]
        },
        objects.Level:new {
          name = "One Way",
          size = {x = 10, y = 9},
          levelstr = [[
##########
#        #
# X      #
#        #
#44440000#
#        #
# x      #
#        #
##########]]
        },
        objects.Level:new {
          name = "",
          size = {x = 9, y = 9},
          levelstr = [[
#########
# a   b #
#   #   #
#       #
#|||||||#
#|||||||#
#|||||||#
#|B|||A|#
#########]]
        },
        objects.Level:new {
          name = "",
          size = {x = 10, y = 10},
          levelstr = [[
##########
#  522   #
#  522   #
#  522   #
#  522   #
#  122   #
# x122   #
###022   #
# X 55   #
##########]]
        },
        objects.Level:new {
          name = "Ruby on Rails",
          size = {x = 10, y = 10},
          levelstr = [[
##########
#5-35a--1#
#|-||517|#     
#33|||||7#
#7- 151||#
#| ||1513#
#5-35 --|#
#|7|7-1-|#
#55-3|A13#
##########]]
        },
      }
    },
    objects.Handful:new{
      name = "The Final Four?",
      end_menu = end_menu("Congratulations! You've defeated quite a few handfuls of these"),
      levels = {
        objects.Level:new {
          name = "A hole in time",
          size = {x = 9, y = 10},
          levelstr = [[
#########
#   #   #
# t # X #
#   #   #
#   #   #
#   #   #
#   #   #
# x # t #
#   #   #
#########]]
        },
        objects.Level:new {
          name = "Zounds",
          size = {x = 9, y = 9},
          levelstr = [[
#########
#a t#u b#
# C # D #
#  U#T  #
#########
#u  #  t#
# B # A #
#d U#T c# 
#########
]]
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

  current_menu = main_menu() -- start off at the main menu

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
        current_menu = pause_menu()
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
        current_level().time = time_elapsed
        current_level().moves = moves_made
        current_handful():update_menu_body()
        game_state = GameState.IN_MENU
        time_elapsed = 0
        moves_made = 0
        if selected_level_no == #(current_handful().levels) then
          current_menu = current_handful().end_menu
          current_menu.selected_item = 1
        else
          current_menu = level_clear_menu()
        end
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
    local level_canvas = current_level_grid:to_canvas()
    love.graphics.draw(level_canvas, math.floor(SCREEN_WIDTH/2 - level_canvas:getWidth()/2), math.floor(SCREEN_HEIGHT/2 - level_canvas:getHeight()/2))
    local level_name = handfuls[selected_handful_no].levels[selected_level_no].name
    love.graphics.print(level_name, math.floor(SCREEN_WIDTH/2 - resources.fonts.main_font:getWidth(level_name)/2), math.floor(SCREEN_HEIGHT/2 - level_canvas:getHeight()/2) + 12)
  elseif game_state == GameState.IN_MENU then
    love.graphics.print(current_menu:to_string())
  end
  
  if game_mode == GameMode.TIME then
    love.graphics.print(string.format("TIME: %.2f", time_elapsed), 0, SCREEN_HEIGHT - 20)
  elseif game_mode == GameMode.MOVES then
    love.graphics.print(string.format("MOVES MADE: %d", moves_made), 0, SCREEN_HEIGHT - 20)
  end
end

function current_handful()
  return handfuls[selected_handful_no]
end

function current_level()
  return current_handful().levels[selected_level_no]
end

function increment_current_handful(n)
  n = n or 1
  selected_handful_no = selected_handful_no + 1
  selected_level_no = 1
end

function increment_current_level(n)
  n = n or 1
  selected_level_no = selected_level_no + 1
end

function main_menu()
  return objects.Menu:new {
    name = "Main Menu:",
    items = {
      objects.MenuItem:new {
        name="Play", func=function()
          selected_level_no = 1
          selected_handful_no = 1
          current_menu = select_mode_menu()
        end
      },
      objects.MenuItem:new {
        name="Level Select", func = function()
          current_menu = handful_select_menu()
        end
      },
      objects.MenuItem:new {
        name="Quit", func=function() love.event.quit(0) end
      }
    }
  }
end

function select_mode_menu()
  return objects.Menu:new {
    name = "Select game mode:",
    items = {
      objects.MenuItem:new {
        name = "Normal", func = function()
          game_mode = GameMode.NORMAL
          current_level_grid = objects.Grid.from_Level(current_level())
          game_state = GameState.IN_GAME
          --time_elapsed = 0
          --moves_made = 0
        end
      },
      objects.MenuItem:new {
        name = "Time Attack", func = function()
          game_mode = GameMode.TIME
          current_level_grid = objects.Grid.from_Level(current_level())
          game_state = GameState.IN_GAME
          time_elapsed = 0
          --moves_made = 0
        end
      },
      objects.MenuItem:new {
        name = "Move Challenge", func = function()
          game_mode = GameMode.MOVES
          current_level_grid = objects.Grid.from_Level(current_level())
          game_state = GameState.IN_GAME
          --time_elapsed = 0
          moves_made = 0
        end
      },
      objects.MenuItem:new {
        name = "Back to Main Menu", func = function()
          current_menu = main_menu()
          current_menu.selected_item = 1
        end
      }
    }  
  }
end

function pause_menu()
  return objects.Menu:new {
    name = "Paused. Current level: '" .. current_level().name .. "'",
    items = {
      objects.MenuItem:new {
        name="Continue", func=function()
          game_state = GameState.IN_GAME
        end
      },
      objects.MenuItem:new {
        name="Reset level", func=function()
          current_level_grid = objects.Grid.from_Level(current_level())
          game_state = GameState.IN_GAME
          time_elapsed = 0
          moves_made = 0
        end
      },
      objects.MenuItem:new {
        name="Exit to Main Menu", func=function()
          current_menu = main_menu()
        end
      }
    }
  }
end

function end_menu(name)
  return objects.Menu:new {
    name = name,
    body = "",
    items = {
      objects.MenuItem:new {
        name="Transcend", func=function()
          increment_current_handful()
          if selected_handful_no == #handfuls + 1 then
            love.event.quit(0)
          end
          current_level_grid = objects.Grid.from_Level(current_level())
          game_state = GameState.IN_GAME
        end
      },
      objects.MenuItem:new {
        name="Play this handful again", func=function()
          selected_level_no = 1
          current_level_grid = objects.Grid.from_Level(current_level())
          game_state = GameState.IN_GAME
        end
      },
      objects.MenuItem:new {
        name="Exit to Main Menu", func=function()
          current_menu = main_menu()
          game_mode = GameMode.NORMAL
        end
      }   
    }
  }
end

function level_clear_menu()
  return objects.Menu:new {
    name = "Cleared level '" .. current_level().name .. "'!",
    items = {
      objects.MenuItem:new {
        name="Advance to next level", func=function()
          increment_current_level()
          current_level_grid = objects.Grid.from_Level(current_level())
          game_state = GameState.IN_GAME
          time_elapsed = 0
          moves_made = 0
        end
      },
      objects.MenuItem:new {
        name="Restart level", func=function()
          current_level_grid = objects.Grid.from_Level(current_level())
          game_state = GameState.IN_GAME
          time_elapsed = 0
          moves_made = 0
        end
      },
      objects.MenuItem:new {
        name="Exit to Main Menu", func=function()
          current_menu = main_menu()
          current_menu.selected_item = 1
          game_mode = GameMode.NORMAL
        end
      }
    }
  }
end

function handful_select_menu()
  menu = objects.Menu:new {
    name = "Select Handful of Levels:",
    items = {},
  }
  for i, handful in ipairs(handfuls) do
    table.insert(menu.items, objects.MenuItem:new {
      name = handful.name,
      func = function()
        current_menu = level_select_menu(handful, i)
      end
    })
  end
  table.insert(menu.items, objects.MenuItem:new {
    name = "Back to Main Menu",
    func = function()
      current_menu = main_menu()
    end
  })
  return menu
end

function level_select_menu(handful, handful_no)
  menu = objects.Menu:new {
    name = "Select level from '" .. handful.name .. "':",
    items = {},
  }
  for i, level in ipairs(handful.levels) do
    table.insert(menu.items, objects.MenuItem:new {
      name = level.name,
      func = function()
        selected_handful_no = handful_no
        selected_level_no = i
        current_level_grid = objects.Grid.from_Level(current_level())
        game_state = GameState.IN_GAME
      end
    })
  end
  table.insert(menu.items, objects.MenuItem:new {
    name = "Back to Handful Select",
    func = function()
      current_menu = handful_select_menu()
    end
  })
  return menu
end