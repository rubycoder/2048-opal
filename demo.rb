# frozen_string_literal: true

require 'opal'  # a
require 'opal-jquery'
# require 'forwardable'
# require 'ostruct'
# require_relative 'tile'
# require_relative 'interval'
require_relative 'canvas'

puts '$global $gvars'
p $global
p $gvars


canvas = Canvas.new('board')
canvas.draw_rectangle(50, 50, 100, 100, 'blue', 1, 'black')

