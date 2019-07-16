# frozen_string_literal: true

require 'opal'
#require 'opal-jquery'
require 'opal-browser'
#require_relative 'canvas'

puts '$global $gvars'
p $global
p $gvars


#canvas = Canvas.new('board')
#canvas.draw_rectangle(50, 50, 100, 100, 'blue', 1, 'black')

p Opal.ancestors

foo = Opal.new
p foo
#canvas = Opal::Browser::Canvas.new('board')
#p canvas

