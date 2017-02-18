

algs = require 'algs'
local Direction = algs.Direction

objects = require 'objects'

function love.load()
	test_level = objects.Grid.from_string(
[[
##########
#        #
# b      #
#        #
#        #
#        #
#        #
#    b   #
#        #
##########
]])
  input = {}
end

function love.keyPressed(key, isRepeat)
  if not isRepeat then
    if key == 'up' then
      table.insert(input, Direction.UP)
    elseif key == 'down' then
      table.insert(input, Direction.DOWN)
    elseif key == 'left' then
      table.insert(input, Direction.LEFT)
    elseif key == 'right' then
      table.insert(input, Direction.RIGHT)
    end
  end
end

function love.update()
  for _, direction in ipairs(input) do
  	algs.move_all(test_level, direction)
  end
  input = {}
end

function love.draw()
  love.graphics.print(test_level:to_string())
end








