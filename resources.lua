
module = {}

-- initialize images
module.images = {
  blocks = {
    modifiers = {
      color = {
        blue   = love.graphics.newImage("/resources/images/blocks/modifiers/color-blue.png"),
        green  = love.graphics.newImage("/resources/images/blocks/modifiers/color-green.png"),
        red    = love.graphics.newImage("/resources/images/blocks/modifiers/color-red.png"),
        yellow = love.graphics.newImage("/resources/images/blocks/modifiers/color-yellow.png")
      }
    },
    basic = love.graphics.newImage("/resources/images/blocks/basic.png"),
  },
  squares = {
    modifiers = {
      destination = {
        neutral = love.graphics.newImage("/resources/images/squares/modifiers/destination-neutral.png"),
        blue    = love.graphics.newImage("/resources/images/squares/modifiers/destination-blue.png"),
        green   = love.graphics.newImage("/resources/images/squares/modifiers/destination-green.png"),
        red     = love.graphics.newImage("/resources/images/squares/modifiers/destination-red.png"),
        yellow  = love.graphics.newImage("/resources/images/squares/modifiers/destination-yellow.png")
      }
    },
    basic_wall  = love.graphics.newImage("/resources/images/squares/basic-wall.png"),
    basic_empty = love.graphics.newImage("/resources/images/squares/basic-floor.png")
  }
}

-- initialize fonts
module.fonts = {
  main_font = love.graphics.newFont("/resources/fonts/Inconsolata.otf", 20)
}

return module
