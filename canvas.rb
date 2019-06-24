class Canvas
  # attr_reader :canvas, :context

  def initialize(canvas_id)
    @canvas  = `document.getElementById(#{canvas_id})`
    @context = `#{@canvas}.getContext('2d')`
  end

  def draw_rectangle(left, top, width, height, fill_style, line_width, stroke_style)
    `#{@context}.rect(#{left}, #{top}, #{width}, #{height})`
    `#{@context}.fillStyle = #{fill_style}`
    `#{@context}.fill()`
    `#{@context}.lineWidth = #{line_width}`
    `#{@context}.strokeStyle = #{stroke_style}`
    `#{@context}.stroke()`
  end

end
