# frozen_string_literal: true

require 'opal'
# require 'opal-jquery'
require 'forwardable'
require 'ostruct'
# require_relative 'board'

class Board
  attr_reader :height, :width, :canvas, :context, :max_x, :max_y

  CELL_HEIGHT = 15
  CELL_WIDTH  = 15

  def initialize
    @height  = `$(window).height()`
    @width   = `$(window).width()`
    @canvas  = `document.getElementById(#{canvas_id})`
    @context = `#{canvas}.getContext('2d')`
    @max_x   = (height / CELL_HEIGHT).floor
    @max_y   = (width / CELL_WIDTH).floor
    @state   = blank_state
    @seed    = []
    draw_canvas
    # add_mouse_event_listener
    # add_demo_event_listener
  end

  def canvas_id
    'board'
  end

  def draw_canvas
    `#{canvas}.width  = #{width}`
    `#{canvas}.height = #{height}`

    x = 0.5
    until x >= width do
      `#{context}.moveTo(#{x}, 0)`
      `#{context}.lineTo(#{x}, #{height})`
      x += CELL_WIDTH
    end

    y = 0.5
    until y >= height do
      `#{context}.moveTo(0, #{y})`
      `#{context}.lineTo(#{width}, #{y})`
      y += CELL_HEIGHT
    end

    `#{context}.strokeStyle = "#eee"`
    `#{context}.stroke()`
  end

  def blank_state
    h = {}
    (0..max_x).each do |x|
      (0..max_y).each do |y|
        h[[x, y]] = 0
      end
    end
    h
  end
end

board = Board.new
board.draw_canvas
