
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
      },
      movement = {
        up     = love.graphics.newImage("/resources/images/blocks/modifiers/movement-up.png"),
        down   = love.graphics.newImage("/resources/images/blocks/modifiers/movement-down.png"),
        left   = love.graphics.newImage("/resources/images/blocks/modifiers/movement-left.png"),
        right  = love.graphics.newImage("/resources/images/blocks/modifiers/movement-right.png")
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
      },
      collision = {
        up      = love.graphics.newImage("/resources/images/squares/modifiers/collision-up.png"),
        down    = love.graphics.newImage("/resources/images/squares/modifiers/collision-down.png"),
        left    = love.graphics.newImage("/resources/images/squares/modifiers/collision-left.png"),
        right   = love.graphics.newImage("/resources/images/squares/modifiers/collision-right.png")
      },
      teleporter = {
        blue   = love.graphics.newImage("/resources/images/squares/modifiers/teleporter-blue.png"),
        green  = love.graphics.newImage("/resources/images/squares/modifiers/teleporter-green.png"),
        red    = love.graphics.newImage("/resources/images/squares/modifiers/teleporter-red.png"),
        yellow = love.graphics.newImage("/resources/images/squares/modifiers/teleporter-yellow.png")
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
