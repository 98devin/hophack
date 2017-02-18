
module = {}

-- initialize images
module.images = {
  blocks = {
    basic = love.graphics.newImage("/resources/images/blocks/basic.png"),
  },
  squares = {
    basic_wall  = love.graphics.newImage("/resources/images/squares/basic-wall.png"),
    basic_floor = love.graphics.newImage("/resources/images/squares/basic-floor.png"),
    destination_floor = love.graphics.newImage("/resources/images/squares/destination-floor.png")
  }
}

-- initialize fonts
module.fonts = {
  main_font = love.graphics.newFont("/resources/fonts/Inconsolata.otf", 20)
}

return module
