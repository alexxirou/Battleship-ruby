require_relative 'Model.rb'

def random_ship_positions_array
  ship_length = 6
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
  random_sample = ships_classes.sample(4)

  random_sample.each do |ship|
    ship_positions_array_for_new_ship = build_ship_positions(ship[:size], positions_array)
    ships_array << Ship.new(ship[:class_name], ship_positions_array_for_new_ship)
    ship_positions_array_for_new_ship.each do |position|
      positions_array << position
    end
  end

  ships_array
end

def build_ship_positions(ship_size, positions_array)
  ship_position_range = ship_size - 1
  ship_random_positions = generate_random_positions(ship_position_range)

  while positions_overlap?(ship_random_positions, positions_array)
    ship_random_positions = generate_random_positions(ship_position_range)
  end

  #p ship_random_positions
  ship_random_positions
end

def generate_random_positions(ship_position_range)
  ship_random_positions = []
  ship_orientation = ['Vertical', 'Horizontal'].sample
  coordinate_x = rand(10)
  coordinate_y = rand(10)

  if ship_orientation == 'Vertical'
    direction = coordinate_y + ship_position_range < 10 ? 1 : -1
    (0..ship_position_range).each do |i|
      ship_random_positions << [coordinate_x, coordinate_y + i * direction]
    end
  else
    direction = coordinate_x + ship_position_range < 10 ? 1 : -1

    (0..ship_position_range).each do |i|
      ship_random_positions << [coordinate_x + i * direction, coordinate_y]
    end
  end

  ship_random_positions
end

def positions_overlap?(positions1, positions2)
  positions1.any? { |element| positions2.include?(element) }
end

