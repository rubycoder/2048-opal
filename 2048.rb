# frozen_string_literal: true

require 'opal'  # a
require 'opal-jquery'
require 'forwardable'
require 'ostruct'
require_relative 'tile'
require_relative 'interval'
require_relative 'canvas'

puts '$global $gvars'
p $global
p $gvars

class Board
  attr_reader :height, :width, :canvas, :context, :max_x, :max_y
  attr_accessor :state, :seed

  CELL_HEIGHT = 15
  CELL_WIDTH  = 15

  COLUMNS = 4
  ROWS    = 4
  SQUARE_EDGE  = 40
  BORDER_SIZE  =  5

  def initialize
    @height  = `$(window).height()`
    @width   = `$(window).width()`
    @canvas  = `document.getElementById(#{canvas_id})`
    @context = `#{canvas}.getContext('2d')`
    @max_x   = (height / CELL_HEIGHT).floor
    @max_y   = (width / CELL_WIDTH).floor
    @state   = blank_state
    @seed    = []
    @tiles   = []

    tile_max_height = (0.9 * @height / ROWS).floor
    tile_max_width  = (0.9 * @width  / COLUMNS).floor
    @tile_height = [tile_max_height, tile_max_width].min
    @tile_width  = @tile_height

    #draw_grid
    add_mouse_event_listener
    add_demo_event_listener
    add_enter_event_listener
  end

  def draw_tileOLD(tile)
    `#{canvas}.width  = #{width}`
    `#{canvas}.height = #{height}`

    `#{context}.moveTo(#{ tile.x      * @tile_width}, #{tile.y * @tile_height})`
    `#{context}.lineTo(#{(tile.x + 1) * @tile_width}, #{tile.y * @tile_height})`

    `#{context}.strokeStyle = "#eee"`
    `#{context}.stroke()`
  end

  def draw_tile(tile)
    `#{context}.rect(400, 400,
                 200, 100)`
    `#{context}.rect(0, 0,
                 200, 100)`
    `#{context}.fillStyle = "#8ED6FF"`
    `#{context}.fill()`
    `#{context}.lineWidth = 5`
    `#{context}.strokeStyle = "black"`
    `#{context}.stroke()`
  end

  def draw_tile2(left, top, width, height, fill_style, line_width, stroke_style)
    `#{context}.rect(#{left}, #{top}, #{width}, #{height})`
    `#{context}.fillStyle = #{fill_style}`
    `#{context}.fill()`
    `#{context}.lineWidth = #{line_width}`
    `#{context}.strokeStyle = #{stroke_style}`
    `#{context}.stroke()`
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


  def draw_grid
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

  def redraw_grid
    draw_grid
    state.each do |cell, liveness|
      fill_cell(cell[0], cell[1]) if liveness == 1
    end
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

  def add_demo_event_listener
    Document.on :keypress do |event|
      if ctrl_b_pressed?(event)
        [
            [25, 1],
            [23, 2], [25, 2],
            [13, 3], [14, 3], [21, 3], [22, 3],
            [12, 4], [16, 4], [21, 4], [22, 4], [35, 4], [36, 4],
            [1, 5],  [2, 5],  [11, 5], [17, 5], [21, 5], [22, 5], [35, 5], [36, 5],
            [1, 6],  [2, 6],  [11, 6], [15, 6], [17, 6], [18, 6], [23, 6], [25, 6],
            [11, 7], [17, 7], [25, 7],
            [12, 8], [16, 8],
            [13, 9], [14, 9]
        ].each do |x, y|
          fill_cell(x, y)
          seed << [x, y]
        end
      end
    end
  end

  # Original source used ctrl-D, but Brave uses that to add a bookmark, so we changed it to ctrl-B
  def ctrl_b_pressed?(event)
    event.ctrl_key == true && event.which == 2
  end

  # following methods from conway.rb

  def add_enter_event_listener
    Document.on :keypress do |event|
      seed.each do |x, y|
        state[[x, y]] = 1
      end
      run if enter_pressed?(event)
    end
  end

  def enter_pressed?(event)
    event.which == 13
  end

  def run
    Interval.new do
      tick
    end
  end

  def tick
    self.state = new_state
    #redraw_grid
  end

  # below methods added en masse, probably not all needed

  def new_state
    #console.log 'in new_state'
    new_state = Hash.new
    state.each do |cell, _|
      new_state[cell] = get_state_at(cell[0], cell[1])
    end
    new_state
  end

  def get_state_at(x, y)
    if is_underpopulated?(x, y)
      0
    elsif is_living_happily?(x, y)
      1
    elsif is_overpopulated?(x, y)
      0
    elsif can_reproduce?(x, y)
      1
    end
  end

  # Any live cell with fewer than two live neighbours dies,
  # as if caused by under-population.
  def is_underpopulated?(x, y)
    is_alive?(x, y) && population_at(x, y) < 2
  end

  # Any live cell with two or three live neighbours lives
  # on to the next generation.
  def is_living_happily?(x, y)
    is_alive?(x, y) && ([2, 3].include? population_at(x, y))
  end

  # Any live cell with more than three live neighbours dies,
  # as if by overcrowding.
  def is_overpopulated?(x, y)
    is_alive?(x, y) && population_at(x, y) > 3
  end

  # Any dead cell with exactly three live neighbours becomes a live cell,
  # as if by reproduction.
  def can_reproduce?(x, y)
    is_dead?(x, y) && population_at(x, y) == 3
  end

  def population_at(x, y)
    [
        state[[x-1, y-1]],
        state[[x-1, y  ]],
        state[[x-1, y+1]],
        state[[x,   y-1]],
        state[[x,   y+1]],
        state[[x+1, y-1]],
        state[[x+1, y  ]],
        state[[x+1, y+1]]
    ].map(&:to_i).reduce(:+)
  end

  def is_alive?(x, y)
    state[[x, y]] == 1
  end

  def is_dead?(x, y)
    !is_alive?(x, y)
  end

end

class Coordinates < OpenStruct; end

puts '$global'
p $global

board = Board.new
# board.draw_grid
tile = Tile.new(1,1)
#board.draw_tile(tile)
canvas = Canvas.new('board')
canvas.draw_rectangle(50, 50, 100, 100, 'blue', 1, 'black')
