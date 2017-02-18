
objects = require 'objects'

local Direction = {
	UP = {},
  DOWN = {},
  LEFT = {},
  RIGHT = {}
}


function move(grid, block, direction)
  local init_x, init_y = block.position.x, block.position.y
  local init_square = grid:get(init_x, init_y)
  local new_x, new_y
  if direction == Direction.UP then
  	new_x = init_x
    new_y = init_y - 1
  elseif direction == Direction.DOWN then
  	new_x = init_x
    new_y = init_y + 1
  elseif direction == Direction.LEFT then
    new_x = init_x - 1
    new_y = init_y
  elseif direction == Direction.RIGHT then
    new_x = init_x + 1
    new_y = init_y
  end
  local dest_square = grid:get(new_x, new_y)
  if not dest_square.occupied and not collides(dest_square, direction) then
    init_square.occupied = false
    init_square.occupant = nil
    dest_square.occupied = true
    dest_square.occupant = block
    -- update block's position
    block.position.x = new_x
    block.position.y = new_y
  end
end


function collides(square, direction)
  if direction == Direction.UP then
    return square.collision.down
  elseif direction == Direction.DOWN then
    return square.collision.up
  elseif direction == Direction.LEFT then
    return square.collision.right
  elseif direction == Direction.RIGHT then
  	return square.collision.left
  end
end


function move_all(grid, direction)
  function sorting_function(direction)
  	if direction == Direction.UP then
      return (function(a, b) return a.position.y < b.position.y end)
    elseif direction == Direction.DOWN then
      return (function(a, b) return a.position.y > b.position.y end)
    elseif direction == Direction.LEFT then
      return (function(a, b) return a.position.x < b.position.x end)
    elseif direction == Direction.RIGHT then
      return (function(a, b) return a.position.x > b.position.x end)
    end
  end
  
  table.sort(grid.blocks, sorting_function(direction))
	for _, block in ipairs(grid.blocks) do
    move(grid, block, direction)
  end
end

exports = {
	move      = move,
  move_all  = move_all,
  Direction = Direction
}

return exports
  
  
  
  
  
  