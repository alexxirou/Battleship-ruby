require 'tk'
require 'set'
require_relative 'RandomShipGenerator'
require_relative 'OpponentLogic'
require_relative 'Graphics'
require_relative 'Model'

# main method to initialize the game
def main
  # create player and AI grids
  player_grid = Model::Grid.new(size_x: 10, size_y: 10)
  ai_grid = Model::Grid.new(size_x: 10, size_y: 10)

  # generate random ship positions for player and AI using Random_ship_generator
  player_ships_array = RandomShipGenerator.random_ship_positions_array(player_grid.size_x)
  ai_ships_array = RandomShipGenerator.random_ship_positions_array(ai_grid.size_x)

  # set ships on the grids
  player_grid.ships = player_ships_array
  ai_grid.ships = ai_ships_array

  # create a new BattleshipGUI instance and run the game
  new_game = Graphics::BattleshipGUI.new(player_grid, ai_grid)
  new_game.run
end

if $PROGRAM_NAME == __FILE__
  main
end
