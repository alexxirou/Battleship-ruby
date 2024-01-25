require 'sinatra'
require 'json'
require_relative 'Model.rb'
require_relative 'Random_ship_generator.rb'
require_relative 'Opponent_logic.rb'

enable :sessions
set :port, 4567
ai = AI.new

post '/api/move' do
  session[:game_state] ||= initialize_game_state(params['gridSize'].to_i, params['NumShips'].to_i)
  game_state = session[:game_state]

  player_result = game_state[:ai_grid].shoot_at_position([params['shoot_position'].split(',').map(&:to_i)])
  opponent_sunken_ships = game_state[:ai_grid].sunken_ships_positions.to_a if player_result[0] == 'DESTROYED'
  ai_shoot_position = ai.next_shot(game_state[:player_grid])
  ai_result = game_state[:player_grid].shoot_at_position(ai_shoot_position)
  ai.record_shot(ai_shoot_position, ai_result, game_state[:player_grid])
  player_sunken_ships = game_state[:player_grid].sunken_ships_positions.to_a if ai_result[0] == 'DESTROYED'

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
  session[:game_state] ||= initialize_game_state(params['gridSize'].to_i, params['NumShips'].to_i)
  game_state = session[:game_state]

  content_type :json
  {
    player_grid: game_state[:player_grid],
    ai_grid: game_state[:ai_grid]
    # Exclude player_ships_array from the response
  }.to_json
end

def initialize_game_state(grid_size, num_ships)
  player_grid = Grid.new(grid_size, grid_size)
  ai_grid = Grid.new(grid_size, grid_size)

  player_ships_array = RandomShipGenerator.new.generate_random_ships(num_ships)
  ai_ships_array = RandomShipGenerator.new.generate_random_ships(num_ships)

  player_ships_array.each { |ship| player_grid.add_ship_to_grid(ship) }
  ai_ships_array.each { |ship| ai_grid.add_ship_to_grid(ship) }

  { player_grid: player_grid, ai_grid: ai_grid }
end
