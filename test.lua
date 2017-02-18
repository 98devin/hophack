
algs = require 'algs'
local Direction = algs.Direction

objects = require 'objects'

test_level = objects.Grid.from_string(
[[##########
#        #
# b      #
#        #
#        #
#        #
#        #
#    b   #
#        #
##########]])

print(test_level:to_string())

algs.move_all(test_level, Direction.UP)

print(test_level:to_string())