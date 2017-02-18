
module = {}

-- initialize images
module.images = {
  basic_block = love.graphics.newImage("/resources/images/block/basic.png"),
  basic_wall  = love.graphics.newImage("/resources/images/walls/basic.png"),
  basic_floor = love.graphics.newImage("/resources/images/walls/basic-floor.png")
}

-- initialize fonts
module.fonts = {
  main_font = love.graphics.newFont("/resources/fonts/Inconsolata.otf", 20)
}

return module
