# frozen_string_literal: true

require 'opal'
require 'opal-jquery'
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
    add_mouse_event_listener
    # add_demo_event_listener
  end

  def fill_cell(x, y)
    x *= CELL_WIDTH
    y *= CELL_HEIGHT
    `#{context}.fillStyle = "#000"`
    `#{context}.fillRect(#{x.floor+1}, #{y.floor+1}, #{CELL_WIDTH-1}, #{CELL_HEIGHT-1})`
  end

  def unfill_cell(x, y)
    x *= CELL_WIDTH
    y *= CELL_HEIGHT
    `#{context}.clearRect(#{x.floor+1}, #{y.floor+1}, #{CELL_WIDTH-1}, #{CELL_HEIGHT-1})`
  end

  def canvas_id
    'board'
  end

  def add_mouse_event_listener
    Element.find("##{canvas_id}").on :click do |event|
      coords = get_cursor_position(event)
      x, y   = coords.x, coords.y
      fill_cell(x, y)
      seed << [x, y]
    end

    Element.find("##{canvas_id}").on :dblclick do |event|
      coords = get_cursor_position(event)
      x, y   = coords.x, coords.y
      unfill_cell(x, y)
      seed.delete([x, y])
    end
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

  def get_cursor_position(event)
    if event.page_x && event.page_y
      x = event.page_x
      y = event.page_y
    else
      doc = Opal.Document[0]
      x = event[:clientX] + doc.scrollLeft + doc.documentElement.scrollLeft
      y = event[:clientY] + doc.body.scrollTop + doc.documentElement.scrollTop
    end

    x -= `#{canvas}.offsetLeft`
    y -= `#{canvas}.offsetTop`

    x = (x / CELL_WIDTH).floor
    y = (y / CELL_HEIGHT).floor

    Coordinates.new(x: x, y: y)
  end
end

class Coordinates < OpenStruct; end

board = Board.new
board.draw_canvas
