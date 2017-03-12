
resources = require 'resources'
objects   = require 'objects'
local Direction = objects.Direction

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

    if dest_square.teleporter then
      dest_square.teleporter.updated_this_round = true
    end

    -- update block's position
    block.position.x = new_x
    block.position.y = new_y
    return true
  end
  return false
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
  
  local moved_any = false
  table.sort(grid.blocks, sorting_function(direction))
  for _, block in ipairs(grid.blocks) do
    local moved = move(grid, block, direction)
    if moved then
      moved_any = true
    end
  end

  local teleported_before = {}
  for _, teleporter in ipairs(grid.teleporters) do
    if not teleported_before[teleporter] then
      local this_space = grid:get(teleporter.position.x, teleporter.position.y)
      local warp_space = grid:get(teleporter.warp_position.x, teleporter.warp_position.y)
      local matching_teleporter = warp_space.teleporter
      teleported_before[teleporter] = true
      teleported_before[matching_teleporter] = true
      if (not this_space.occupied or teleporter.updated_this_round) and
         (not warp_space.occupied or matching_teleporter.updated_this_round) then
        swap_occupants(
          grid, teleporter.position.x, teleporter.position.y,
          matching_teleporter.position.x, matching_teleporter.position.y
        )
      end
      teleporter.updated_this_round = false
      matching_teleporter.updated_this_round = false
    end
  end

  return moved_any
end

function swap_occupants(grid, x1, y1, x2, y2)
  local sq1 = grid:get(x1, y1)
  local sq2 = grid:get(x2, y2)
  sq1.occupied, sq2.occupied = sq2.occupied, sq1.occupied
  sq1.occupant, sq2.occupant = sq2.occupant, sq1.occupant
  if sq1.occupant then
    sq1.occupant.position = {x=x1, y=y1}
  end
  if sq2.occupant then
    sq2.occupant.position = {x=x2, y=y2}
  end
end

function has_won(grid)
  for _, block in ipairs(grid.blocks) do
    local square = grid:get(block.position.x, block.position.y)
    if square.destination == nil then
      return false
    elseif square.destination.color ~= nil then
      if block.color and block.color ~= square.destination.color then
        return false
      end
    end
  end
  return true
end

function char_to_collision(c)
  local collision
  if c == '0' then
    collision = objects.Collision:new{
      up = true,
      right = true,
      left = true
    }
  elseif c == '1' then
    collision = objects.Collision:new{
      up = true,
      right = true
    }
  elseif c == '2' then
    collision = objects.Collision:new{ 
      up = true,
      down = true,
      right = true
    }
  elseif c == '3' then
    collision = objects.Collision:new{
      right = true,
      down = true
    }
  elseif c == '4' then
    collision = objects.Collision:new{
      right = true,
      down = true,
      left = true
    }
  elseif c == '5' then
    collision = objects.Collision:new{
      left = true,
      down = true
    }
  elseif c == '6' then
    collision = objects.Collision:new{
      left = true,
      down = true,
      up = true
    }
  elseif c == '7' then
    collision = objects.Collision:new{
      left = true,
      up = true
    }
  elseif c == '-' then
    collision = objects.Collision:new{
      up = true,
      down = true
    }  
  elseif c == '|' then
    collision = objects.Collision:new{
      left = true,
      right = true
    }
  end
  return collision
end

function get_body(levels)
 body = ""
  for _, lvl in ipairs(levels) do
    body = body .. string.format("%s - %.2f seconds, %d moves\n", lvl.name, lvl.time, lvl.moves)
  end
  return body
end

exports = {
  move      = move,
  move_all  = move_all,
  has_won   = has_won
}


return exports