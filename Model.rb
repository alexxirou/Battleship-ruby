require 'set'

# A ship that can be placed on the grid
class Ship
  attr_reader :name, :positions

  # Initializes a new instance of the Ship class.
  #
  # @param [String] ship_name The name of the ship.
  # @param [Array<Array<Integer, Integer>>] ship_positions The positions occupied by the ship.
  def initialize(ship_name, ship_positions)
    @name = ship_name
    @positions = Set.new(ship_positions)
    @hits_received = Set.new
  end

  # Compares two ships to check if they are equal.
  #
  # @param [Ship] other_ship The ship to compare.
  # @return [Boolean] True if the ships are equal, false otherwise.
  def compare_ships(other_ship)
    @name == other_ship.name && @positions == other_ship.positions
  end

  # Checks if the ship is still afloat (not destroyed).
  #
  # @return [Boolean] True if the ship is afloat, false if destroyed.
  def ship_afloat?
    @positions != @hits_received
  end

  # Fires a shot at the ship.
  #
  # @param [Array<Integer, Integer>] shot The coordinates of the shot.
  # @return [String] The result of the shot ('HIT', 'DESTROYED', 'MISS').
  def shoot_at_ship(shot)
    if @positions.include?(shot)
      @hits_received.add(shot)
      return ship_afloat? ? 'HIT' : 'DESTROYED'
    end
    'MISS'
  end
end
# Represents the grid for the Battleship game.
class Grid
  attr_reader :size_x, :size_y, :ships, :misses, :observers

  def initialize(size_x, size_y, ships = Set[], misses = Set[])
    @size_x = size_x
    @size_y = size_y
    @ships = Set.new(ships)
    @misses = misses
    @observers = []
  end

  def ships=(ship_array)
    @ships = Set.new(ship_array)
  end

  def add_observer(observer)
    @observers << observer
  end



  def shoot_at_position(shot)
    result = ['MISS']
    unless @misses.include?(shot)
      @ships.each do |ship|
        ship_shot_result = ship.shoot_at_ship(shot)
        
          add_observer(observer = Sunk_ship_observer.new(ship.positions)) if ship_shot_result == 'DESTROYED'
        
        result = ship_shot_result == 'DESTROYED' ? [ship_shot_result, ship.name] : [ship_shot_result]
        return result if result[0] == 'DESTROYED' || result[0] == 'HIT'
      end
      @misses.add(shot) if result[0] == 'MISS'
    end
    result
  end

  def win_condition_met?
    @observers.size == @ships.size
  end
end

class ShipObserver
  def initialize(positions)
    @positions = Set.new(positions)
  end

  def update_sunk_positions(_)
    # No need to update positions for individual ships
    # You can customize this method if needed
  end
end

class Sunk_ship_observer < ShipObserver
  attr_reader :positions

  def initialize(positions)
    super(positions)
  end

  def update_sunk_positions(positions)
    @positions.merge(positions)
  end
end




# Loads a grid from a file containing grid dimensions and ship data.
#
# @param [String] file The path to the file containing grid dimensions and ship data.
# @return [Grid] The grid loaded from the file.
def load_grid_from_file(file)
  dimensions_x_y = []
  ships_array = []
  File.foreach(file).with_index do |line, line_number|
    if line_number == 0
      dimensions_x_y = line.chomp.strip.split(":").flatten
    end
    ships_array << add_ships_from_data_source(line) if line_number >= 1
  end
  Grid.new(dimensions_x_y[0].to_i, dimensions_x_y[1].to_i, ships_array)
end

# Adds ships to the grid based on data from a data source (e.g., file).
#
# @param [String] source The data source containing ship information.
# @return [Ship] The ship created from the data source.
def add_ships_from_data_source(source)
  ship_params = source.chomp.split(" ")
  name = ship_params[0]
  positions = ship_params[1..].map { |pos| pos.split(":").map(&:to_i) }
  Ship.new(name, positions)
end
