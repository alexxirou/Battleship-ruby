require_relative 'Random_ship_generator.rb'
require_relative 'Graphics.rb'

def main
  player_grid = Grid.new(10, 10)
  ai_grid = Grid.new(10, 10)
  player_ships_array = random_ship_positions_array
  ai_ships_array = random_ship_positions_array

  player_ships_array.each do |ship|
    player_grid.add_ship_to_grid(ship)
  end

  ai_ships_array.each do |ship|
    ai_grid.add_ship_to_grid(ship)
  end

  new_game = BattleshipGUI.new(player_grid, ai_grid)
  new_game.run
end

if $PROGRAM_NAME == __FILE__
  main
end
