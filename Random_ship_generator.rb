require_relative 'Model.rb'

# Generates an array of random ship positions based on predefined ship classes.
#
# @param [Integer] row_length The length of each row in the grid.
# @return [Array<Ship>] An array of Ship objects with random positions.
def random_ship_positions_array(row_length)
  ships_array = []
  positions_array = []

  ships_classes = [
    { class_name: "Carrier", size: 6 },
    { class_name: "Battleship", size: 5 },
    { class_name: "Cruiser", size: 4 },
    { class_name: "Submarine", size: 3 },
    { class_name: "Destroyer", size: 3 },
    { class_name: "Patrol Boat", size: 2 }
  ]

  num_ships_to_sample = 4
  random_sample = ships_classes.sample(num_ships_to_sample)

  random_sample.each do |ship|
    ship_positions_array_for_new_ship = build_ship_positions(ship[:size], positions_array, row_length)
    ships_array << Ship.new(ship[:class_name], ship_positions_array_for_new_ship)
    ship_positions_array_for_new_ship.each do |position|
      positions_array << position
    end
  end

  ships_array
end

# Builds ship positions for a given ship size, ensuring they do not overlap with existing positions.
#
# @param [Integer] ship_size The size of the ship.
# @param [Array<Array<Integer, Integer>>] positions_array The array of existing positions to avoid overlap.
# @param [Integer] row_length The length of each row in the grid.
# @return [Array<Array<Integer, Integer>>] An array of ship positions for a new ship.
def build_ship_positions(ship_size, positions_array, row_length)
  ship_position_range = ship_size - 1
  ship_random_positions = generate_random_positions(ship_position_range, row_length)

  while positions_overlap?(ship_random_positions, positions_array)
    ship_random_positions = generate_random_positions(ship_position_range, row_length)
  end

  ship_random_positions
end

# Generates random positions for a ship based on its size and orientation.
#
# @param [Integer] ship_position_range The range of positions for the ship.
# @param [Integer] row_length The length of each row in the grid.
# @return [Array<Array<Integer, Integer>>] An array of randomly generated ship positions.
def generate_random_positions(ship_position_range, row_length)
  ship_random_positions = []
  ship_orientation = ['Vertical', 'Horizontal'].sample
  coordinate_x = rand(row_length)
  coordinate_y = rand(row_length)

  if ship_orientation == 'Vertical'
    direction = coordinate_y + ship_position_range < row_length ? 1 : -1
    (0..ship_position_range).each do |i|
      ship_random_positions << [coordinate_x, coordinate_y + i * direction]
    end
  else
    direction = coordinate_x + ship_position_range < row_length ? 1 : -1

    (0..ship_position_range).each do |i|
      ship_random_positions << [coordinate_x + i * direction, coordinate_y]
    end
  end

  ship_random_positions
end

# Checks if two sets of positions overlap.
#
# @param [Array<Array<Integer, Integer>>] positions1 The first set of positions.
# @param [Array<Array<Integer, Integer>>] positions2 The second set of positions.
# @return [Boolean] True if there is an overlap, false otherwise.
def positions_overlap?(positions1, positions2)
  positions1.any? { |element| positions2.include?(element) }
end
