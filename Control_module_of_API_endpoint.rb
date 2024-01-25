require 'sinatra'
require 'json'
require_relative 'Model.rb'
require_relative 'Random_ship_generator.rb'
require_relative 'Opponent_logic.rb'

set :port, 4567 
ai = AI.new

post '/api/move' do
  player_result = initial_game_data[:ai_grid].shoot_at_position([params[:shoot_position].split(',').map(&:to_i)])
  opponent_sunken_ships = ai.sunken_ships_positions.to_a if player_result[0] == 'DESTROYED'
  ai_shoot_position = ai.next_shot(initial_game_data[:player_grid])
  ai_result = initial_game_data[:player_grid].shoot_at_position(ai_shoot_position)
  ai.record_shot(ai_shoot_position, ai_result, initial_game_data[:player_grid])
  player_sunken_ships = initial_game_data[:player_grid].sunken_ships_positions.to_a if ai_result[0] == 'DESTROYED'
  
  content_type :json
  {
    player_result: player_result,
    opponent_sunken_ships: opponent_sunken_ships,
    ai_result: ai_result,
    ai_shoot_position: ai_shoot_position,
    player_sunken_ships: player_sunken_ships
  }.to_json
end

get '/initial_game_data' do
  content_type :json
  
  # Create grids
  player_grid = Grid.new(params['gridSize'].to_i, params['gridSize'].to_i)
  ai_grid = Grid.new(params['gridSize'].to_i, params['gridSize'].to_i)

  # Generate ship arrays based on the number of ships data from the frontend
  player_ships_array = RandomShipGenerator.new.generate_random_ships(params['NumShips'])
  ai_ships_array = RandomShipGenerator.new.generate_random_ships(params['NumShips'])

  player_ships_array.each { |ship| player_grid.add_ship_to_grid(ship) }
  ai_ships_array.each { |ship| ai_grid.add_ship_to_grid(ship) }

  # You can include other necessary information in the initial game data
  initial_game_data = {
    player_grid: player_grid,
    ai_grid: ai_grid
    # Exclude player_ships_array from the response
  }

  initial_game_data.to_json
end
