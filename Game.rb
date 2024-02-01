require_relative 'Random_ship_generator.rb'
require_relative 'Graphics.rb'

def main
  player_grid = Grid.new(size_x: 10, size_y: 10)
  ai_grid = Grid.new(size_x: 10, size_y: 10)
  player_ships_array = random_ship_positions_array
  ai_ships_array = random_ship_positions_array


  player_grid.ships= player_ships_array
  ai_grid.ships=ai_ships_array
  

  new_game = BattleshipGUI.new(player_grid, ai_grid)
  new_game.run
    
  end

if $PROGRAM_NAME == __FILE__
  main
end
