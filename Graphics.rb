require 'tk'
require_relative 'Model.rb'


class BattleshipGUI
  def initialize(grid1, grid2)
    @player_grid = grid1
    @ai_grid = grid2
    @root = TkRoot.new { title 'Battleship' }
    @cell_size = 30
    draw_grids
  end



  def draw_grid_lines(canvas, sizex, sizey, cell_size)
    (1..sizex).each do |i|
      TkcLine.new(canvas, i * cell_size, 0, i * cell_size, sizey * cell_size, fill: '#D3D3D3')
    end

    (1..sizey).each do |j|
      TkcLine.new(canvas, 0, j * cell_size, sizex * cell_size, j * cell_size, fill: '#D3D3D3')
    end
  end
  def draw_player_grid(canvas)
      draw_grid_lines(canvas, @player_grid.size_x, @player_grid.size_y, @cell_size)
    render_player_ships(@player_grid)
  end

  def draw_ai_grid(canvas)
        draw_grid_lines(canvas, ai_grid.size_x, ai_grid.size_y, @cell_size)
  end

  def draw_grids
    player_canvas = TkCanvas.new(@root) { width 400; height 400; background 'white' }.pack
    ai_canvas = TkCanvas.new(@root) { width 400; height 400; background 'white' }.pack

    draw_player_grid(player_canvas)
    draw_ai_grid(ai_canvas)
    player_canvas.bind('Button-1', proc { |event| on_player_click(event.x, event.y) })
  end

  def on_player_click(x, y)
    result, _ = @ai_grid.shoot_at_position([x / @cell_size, y / @cell_size])
    puts "Player shot at #{x / @cell_size}, #{y / @cell_size}. Result: #{result}"

    fill_color = if result[0] == 'HIT'
                   'yellow'
                 elsif result[0] == 'MISS'
                   'gray'
                 end

    fill(fill_color)
    oval(x, y, x + @cell_size, y + @cell_size)
    render_sunk_ships(@ai_grid) if result[0] == 'DESTROYED'
  end

  def render_player_ships(grid)
    grid.ships.each do |ship|
      ship.positions.each do |position|
        fill('blue')  # You can change the color or style as needed
        rect(position[0] * @cell_size, position[1] * @cell_size, @cell_size, @cell_size)
      end
    end
  end

  def redraw_grids
    Tk.root.children.each(&:destroy)
    draw_grids
  end

  def render_sunk_ships(grid)
    grid.sunken_ships.each do |ship|
      ship.positions.each do |position|
        fill('red')  # You can change the color or style as needed
        rect(position[0] * @cell_size, position[1] * @cell_size, @cell_size, @cell_size)
      end
    end
  end

  def run
    Tk.mainloop
  end
end
