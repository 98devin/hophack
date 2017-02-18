
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