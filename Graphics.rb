module Graphics
  # Represents the graphical user interface for the Battleship game.
  class BattleshipGUI
    # Initializes a new instance of the BattleshipGUI class.
    #
    # @param [Grid] grid1 The player's grid.
    # @param [Grid] grid2 The AI's grid.
    def initialize(grid1, grid2)
      @player_grid = grid1
      @ai_grid = grid2
      @game_over = false  # Initialize game_over to false
      @root = TkRoot.new { title "Battleship" }
      @cell_size = 40
      draw_grids
      @ai = OpponentLogic::AI.new
    end


    # Draws grid lines on the canvas.
    #
    # @param [TkCanvas] canvas The canvas to draw on.
    # @param [Integer] sizex The horizontal size of the grid.
    # @param [Integer] sizey The vertical size of the grid.
    # @param [Integer] cell_size The size of each grid cell.
    def draw_grid_lines(canvas, sizex, sizey, cell_size)
      (1..sizex).each do |i|
        TkcLine.new(canvas, i * cell_size, 0, i * cell_size, sizey * cell_size, fill: "#D3D3D3")
      end

      (1..sizey).each do |j|
        TkcLine.new(canvas, 0, j * cell_size, sizex * cell_size, j * cell_size, fill: "#D3D3D3")
      end
    end

    # Draws the player's grid on the canvas.
    #
    # @param [TkCanvas] canvas The canvas to draw on.
    def draw_player_grid(canvas)
      draw_grid_lines(canvas, @player_grid.size_x, @player_grid.size_y, @cell_size)
      render_player_ships(@player_grid, canvas)
    end

    # Draws the AI's grid on the canvas.
    #
    # @param [TkCanvas] canvas The canvas to draw on.
    def draw_ai_grid(canvas)
      draw_grid_lines(canvas, @ai_grid.size_x, @ai_grid.size_y, @cell_size)
    end

    # Draws both player and AI grids on the Tk root.
    def draw_grids
      player_canvas = TkCanvas.new(@root) { width 400; height 400; background "white" }.pack
      ai_canvas = TkCanvas.new(@root) { width 400; height 400; background "white" }.pack

      draw_player_grid(player_canvas)
      draw_ai_grid(ai_canvas)
      ai_canvas.bind("Button-1", proc { |event| on_player_click(event.x, event.y, ai_canvas, player_canvas) })
    end

    # Handles the player's click event on the canvas.
    #
    # @param [Integer] x The x-coordinate of the click.
    # @param [Integer] y The y-coordinate of the click.
    # @param [TkCanvas] ai_canvas The AI's canvas.
    # @param [TkCanvas] player_canvas The player's canvas.
    def on_player_click(x, y, ai_canvas, player_canvas)
      return if @game_over
      result = @ai_grid.shoot_at_position([x / @cell_size, y / @cell_size])

      render_hit_or_miss(ai_canvas, (x / @cell_size), (y / @cell_size), result[0])
      if result[0] == "DESTROYED"
        render_sunk_ships(@ai_grid, ai_canvas)
        puts "#{result}"
        return if check_win_condition(@ai_grid)
      end
      opponent_shoots(@player_grid, player_canvas)
    end

    # Renders a hit or miss on the canvas.
    #
    # @param [TkCanvas] canvas The canvas to draw on.
    # @param [Integer] grid_x The x-coordinate on the grid.
    # @param [Integer] grid_y The y-coordinate on the grid.
    # @param [String] result The result of the shot ('HIT' or 'MISS').
    def render_hit_or_miss(canvas, grid_x, grid_y, result)
      if result == "HIT"
        TkcOval.new(canvas, grid_x * @cell_size, grid_y * @cell_size, (grid_x + 1) * @cell_size, (grid_y + 1) * @cell_size, outline: "black", fill: "yellow")
      elsif result == "MISS"
        TkcOval.new(canvas, grid_x * @cell_size, grid_y * @cell_size, (grid_x + 1) * @cell_size, (grid_y + 1) * @cell_size, outline: "black", fill: "grey")
      end
    end

    # Checks the win condition for the game.
    #
    # @param [Grid] grid The grid to check for win condition.
    # @return [Boolean] True if the game is over, false otherwise.
    def check_win_condition(grid)
      if grid.win_condition_met?
        puts grid == @ai_grid ? "You win!" : "Opponent wins!"
        @game_over = true
      end
      @game_over
    end

    # Handles the opponent's shot and updates the canvas accordingly.
    #
    # @param [Grid] player_grid The player's grid.
    # @param [TkCanvas] player_canvas The player's canvas.
    def opponent_shoots(player_grid, player_canvas)
      position_to_shoot = @ai.next_shot(player_grid)
      result = player_grid.shoot_at_position(position_to_shoot)
      puts "Opponent shot at #{position_to_shoot[0]}, #{position_to_shoot[1]}. Result: #{result}" unless result[0] == "DESTROYED"
      render_hit_or_miss(player_canvas, position_to_shoot[0], position_to_shoot[1], result[0])
      if result[0] == "DESTROYED"
        puts "#{result}"
        render_sunk_ships(player_grid, player_canvas)
      end
      check_win_condition(player_grid)
      @ai.record_shot(position_to_shoot, result[0], player_grid)
    end

    # Renders the player's ships on the canvas.
    #
    # @param [Grid] grid The player's grid.
    # @param [TkCanvas] canvas The canvas to draw on.
    def render_player_ships(grid, canvas)
      draw_ships(grid.ships, canvas, "blue")
    end

    # Renders the opponent's sunk ships on the canvas.
    #
    # @param [Grid] grid The opponent's grid.
    # @param [TkCanvas] canvas The canvas to draw on.
    def render_sunk_ships(grid, canvas)
      draw_ships(grid.observers, canvas, "red")
    end

    # Draws ships on the canvas.
    #
    # @param [Array<Ship>] ships An array of Ship objects.
    # @param [TkCanvas] canvas The canvas to draw on.
    # @param [String] color The color of the ships.
    def draw_ships(ships, canvas, color)
      ships.each do |ship|
        ship.positions.each do |position|
          x, y = position
          TkcRectangle.new(canvas, x * @cell_size, y * @cell_size, (x + 1) * @cell_size, (y + 1) * @cell_size, fill: color)
        end
      end
    end

    # Redraws both player and AI grids.
    def redraw_grids
      Tk.root.children.each(&:destroy)
      draw_grids
    end

    # Runs the Tk main loop.
    def run
      Tk.mainloop
    end
  end
end
