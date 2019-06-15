# frozen_string_literal: true

require 'opal'
#require 'opal-jquery'
require 'forwardable'
require 'ostruct'
#require_relative 'board'

class Board
  attr_reader :height, :width, :canvas, :context, :max_x, :max_y

  CELL_HEIGHT = 1513
  CELL_WIDTH  = 15

  def initialize
    @height  = `$(window).height()`
    @width   = `$(window).width()`
    @canvas  = `document.getElementById(#{canvas_id})`
    @context = `#{canvas}.getContext('2d')`
    @max_x   = (height / CELL_HEIGHT).floor
    @max_y   = (width / CELL_WIDTH).floor
    # @state   = blank_state
    # @seed    = []
    # draw_canvas
    # add_mouse_event_listener
    # add_demo_event_listener
  end

  def canvas_id
    'board'
  end

  def draw
  end
end

board = Board.new
board.draw
