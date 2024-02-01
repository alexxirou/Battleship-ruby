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
# The `Grid` class represents a game grid for battleships.
class Grid
  # Getter methods for instance variables
  attr_reader :size_x, :size_y, :ships, :misses, :observers

  # Initializes a new instance of the `Grid` class.
  #
  # @param size_x [Integer] The horizontal size of the grid.
  # @param size_y [Integer] The vertical size of the grid.
  # @param ships [Array] An array of ships on the grid (default is an empty array).
  # @param misses [Array] An array of positions where shots have been missed (default is an empty array).
  def initialize(size_x:, size_y:, ships: [], misses: [])
    @size_x = size_x
    @size_y = size_y
    @ships = Set.new(ships)
    @misses = Set.new(misses)
    @observers = []
  end

  # Setter method for updating the set of ships on the grid.
  #
  # @param ship_array [Array] An array of ships to be set on the grid.
  def ships=(ship_array)
    @ships = Set.new(ship_array)
  end

  # Adds an observer to the list of observers for the grid.
  #
  # @param observer [Object] The observer object to be added.
  def add_observer(observer)
    @observers << observer
  end

  # Shoots at a specified position on the grid.
  #
  # @param shot [Array] The position to shoot at in the format [x, y].
  # @return [Array] An array indicating the result of the shot, e.g., ['MISS'] or ['HIT', 'ship_name'].
  def shoot_at_position(shot)
    result = ['MISS']

    # Check if the shot position has not been previously missed
    unless @misses.include?(shot)
      @ships.each do |ship|
        ship_shot_result = ship.shoot_at_ship(shot)

        # Add an observer if a ship is destroyed
        add_observer(Sunk_ship_observer.new(ship)) if ship_shot_result == 'DESTROYED'

        # Update result based on the shot result
        result = ship_shot_result == 'DESTROYED' ? [ship_shot_result, ship.name] : [ship_shot_result]

        # Return result if a ship is destroyed or hit
        return result if result[0] == 'DESTROYED' || result[0] == 'HIT'
      end

      # Add the shot position to misses if it is a miss
      @misses.add(shot) if result[0] == 'MISS'
    end

    result
  end

  # Checks if the win condition is met (all ships are destroyed).
  #
  # @return [Boolean] Returns true if the win condition is met, false otherwise.
  def win_condition_met?
    @observers.size == @ships.size
  end
end

# The `ShipObserver` class is a base class for observing a ship's state.
class ShipObserver
  # Initializes a new instance of the `ShipObserver` class.
  #
  # @param ship [Ship] The ship to observe.
  def initialize(ship)
    @positions = Set.new(ship.positions)
  end

  # Updates the sunk positions based on the observed ship's state change.
  #
  # This method can be customized in subclasses if specific behavior is needed.
  #
  # @param _ [Object] Ignored parameter for compatibility with observers.
  def update_sunk_positions(_)
    # No need to update positions for individual ships by default
    # Override this method in subclasses for custom behavior
  end
end

# The `Sunk_ship_observer` class is a specialized observer for observing sunk ships.
class Sunk_ship_observer < ShipObserver
  # Getter method for the set of sunk positions.
  #
  # @return [Set] The set of sunk positions.
  attr_reader :positions

  # Initializes a new instance of the `Sunk_ship_observer` class.
  #
  # @param ship [Ship] The ship to observe.
  def initialize(ship)
    super(ship)
  end

  # Updates the sunk positions based on the observed ship's state change.
  #
  # @param ship [Ship] The ship that has been sunk.
  def update_sunk_positions(ship)
    @positions.merge(ship.positions)
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

