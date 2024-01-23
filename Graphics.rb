require 'tk'
require_relative 'Model.rb'
require_relative 'Random_ship_generator.rb'


class BattleshipGUI
  def initialize(grid1, grid2)
    @player_grid = grid1
    @ai_grid = grid2
    @game_over = false  # Initialize game_over to false
    @root = TkRoot.new { title 'Battleship' }
    @cell_size = 40
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
      render_player_ships(@player_grid, canvas)
 
  end

  def draw_ai_grid(canvas)
        draw_grid_lines(canvas, @ai_grid.size_x, @ai_grid.size_y, @cell_size)
  end

  def draw_grids
    player_canvas = TkCanvas.new(@root) { width 400; height 400; background 'white' }.pack
    ai_canvas = TkCanvas.new(@root) { width 400; height 400; background 'white' }.pack

    draw_player_grid(player_canvas)
    draw_ai_grid(ai_canvas)
    ai_canvas.bind('Button-1', proc { |event| on_player_click(event.x, event.y, ai_canvas, player_canvas) })
  end

  def on_player_click(x, y, ai_canvas, player_canvas)
    return if @game_over
    result = @ai_grid.shoot_at_position([x / @cell_size, y / @cell_size])
    puts "Player shot at #{x / @cell_size}, #{y / @cell_size}. Result: #{result}" unless result[0] == 'DESTROYED'
    render_hit_or_miss(ai_canvas, (x / @cell_size), (y / @cell_size),  result[0])
    if result[0] == 'DESTROYED'
      render_sunk_ships(@ai_grid, ai_canvas)
      puts "#{result}"
      return  if check_win_condition(@ai_grid)
    end
    opponent_shoots(@player_grid, player_canvas)
  end



  def render_hit_or_miss(canvas, grid_x, grid_y, result)

    if result == 'HIT'
      TkcOval.new(canvas, grid_x * @cell_size, grid_y * @cell_size, (grid_x + 1) * @cell_size, (grid_y + 1) * @cell_size, outline: 'black', fill: 'yellow')
    elsif result == 'MISS'
      TkcOval.new(canvas, grid_x * @cell_size, grid_y * @cell_size, (grid_x + 1) * @cell_size, (grid_y + 1) * @cell_size, outline: 'black', fill: 'grey')
    end
  end


  def check_win_condition(grid)
    if grid.sunken_ships.size == grid.ships.size
      puts grid==@ai_grid ? "You win!" : "Opponent wins!"
      @game_over = true
    end
    @game_over
  end

  def opponent_shoots(player_grid, player_canvas)
    position_to_shoot=[rand(10), rand(10)]
    while player_grid.misses.include?(position_to_shoot)
      position_to_shoot=[rand(10), rand(10)]
    end
    result=player_grid.shoot_at_position(position_to_shoot)
    render_hit_or_miss(player_canvas, position_to_shoot[0], position_to_shoot[1], result[0])
    if result[0] == 'DESTROYED'
      render_sunk_ships(player_grid, player_canvas)
    end
      check_win_condition(player_grid)
  end   

  def render_player_ships(grid, canvas)
    draw_ships(grid.ships, canvas, 'blue')  
  end

  def render_sunk_ships(grid, canvas)
    draw_ships(grid.sunken_ships, canvas, 'red')
  end

  def draw_ships(ships, canvas, color)
    ships.each do |ship|
      ship.positions.each do |position|
        x, y = position
        TkcRectangle.new(canvas, x * @cell_size, y * @cell_size, (x + 1) * @cell_size, (y + 1) * @cell_size, fill: color)
      end
    end
  end

  def redraw_grids
    Tk.root.children.each(&:destroy)
    draw_grids
  end

  def run
    
      Tk.mainloop
    
  end  
end



