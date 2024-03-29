# control_module_of_api_endpoints.rb
require 'sinatra'
require 'json'
require 'set'
require_relative 'Model'
require_relative 'RandomShipGenerator'
require_relative 'OpponentLogic'

module ControlModuleOfAPIEndpoints
  enable :sessions
  set :port, 4567

  AI = OpponentLogic::AI.new

  before do
    content_type :json
  end

  self.post '/api/move' do
    session[:game_state] ||= initialize_game_state(params['gridSize'].to_i, params['NumShips'].to_i)
    game_state = session[:game_state]

    player_result = game_state[:ai_grid].shoot_at_position(params['shoot_position'].split(',').map(&:to_i))
    opponent_last_sunken_ship = game_state[:ai_grid].observers.last.positions.to_a if player_result[0] == 'DESTROYED'
    ai_shoot_position = AI.next_shot(game_state[:player_grid])
    ai_result = game_state[:player_grid].shoot_at_position(ai_shoot_position)
    AI.record_shot(ai_shoot_position, ai_result, game_state[:player_grid])
    player_last_sunken_ship = game_state[:player_grid].observers.last.positions.to_a if ai_result[0] == 'DESTROYED'

    game_over = check_win_condition(game_state[:ai_grid])

    clear_session if game_over

    {
      player_result: player_result,
      opponent_sunken_ships: opponent_last_sunken_ship,
      ai_result: ai_result,
      ai_shoot_position: ai_shoot_position,
      player_sunken_ships: player_last_sunken_ship,
      game_over: game_over
    }.to_json
  end

  self.get '/initial_game_data' do
    session[:game_state] ||= initialize_game_state(params['gridSize'].to_i, params['NumShips'].to_i)
    game_state = session[:game_state]

    {
      player_grid: game_state[:player_grid],
      ai_grid: game_state[:ai_grid],
      game_over: false
      # Exclude player_ships_array from the response
    }.to_json
  end

  helpers do
    def self.initialize_game_state(grid_size, num_ships)
      player_grid = Model::Grid.new(size_x: grid_size, size_y: grid_size)
      ai_grid = Model::Grid.new(size_x: grid_size, size_y: grid_size)

      player_ships_array = RandomShipGenerator.random_ship_positions_array(Model::Grid.size_x)
      ai_ships_array = RandomShipGenerator.random_ship_positions_array(Model::Grid.size_x)

      player_grid.ships = player_ships_array
      ai_grid.ships = ai_ships_array

      { player_grid: player_grid, ai_grid: ai_grid }
    end

    def self.check_win_condition(grid)
      if grid.win_condition_met?
        puts grid == session[:game_state][:ai_grid] ? "You win!" : "Opponent wins!"
        true
      else
        false
      end
    end

    def clear_session
      session.clear
    end
  end
end
