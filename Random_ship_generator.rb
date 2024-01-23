require_relative 'Model.rb'


def random_ship_positions_array
    ship_length=6
    ships_array =[]
    positions_array=[]
    ships_classes= [
        "Carrier", 
        "Battleship ", 
        "Cruiser ",
        "Submarine", 
        "Destroyer"
    ]
    ships_classes.each do |ship|
        positions_array=build_ship_positions(ship_length, positions_array)
        ship = Ship.new(ship, positions_array )
        ships_array.push(ship)
        ship_length-=1 if ship_length>3
    end
    ships_array
end    


def build_ship_positions(ship_length, positions_array)
    ship_position_range = ship_length - 1
    ship_random_positions = generate_random_positions(ship_position_range)
    current_ships_coordinates_as_two_digits_chars = positions_array.map do |position|
        "#{position[0]}#{position[1]}"
    end
    while positions_overlap?(ship_random_positions, current_ships_coordinates_as_two_digits_chars)
        ship_random_positions = generate_random_positions(ship_position_range)
    end
    ship_random_positions = ship_random_positions.map { |number| number.chars.map(&:to_i) }
end

def generate_random_positions(ship_position_range)
    ship_random_positions = []
    excluded_numbers = [20, 30, 40, 50, 60, 70, 90]
    ship_starting_position=generate_random_number_with_exclusions(excluded_numbers, 11 ,90)
    ship_orientation_coefficient = rand(2)
    position = ship_starting_position
    max_ship_position = (1*ship_position_range)+ ship_starting_position
    
    operation = ((max_ship_position % 10 != 0) && max_ship_position <100)  ? :+ : :-
    (0..ship_position_range).each do |offset|
        position_increment_step= 1 * offset
        position = operation == :+ ? position_increment_step + ship_starting_position : ship_starting_position - position_increment_step 
        ship_random_positions << position.to_s
    end
    ship_random_positions.map! { |position| position.reverse } if ship_orientation_coefficient == 1
    ship_random_positions
    

end

def positions_overlap?(positions1, positions2)
    positions1.any? { |element| positions2.include?(element) }
end

def generate_random_number_with_exclusions(excluded_numbers, start, limit)
    begin
        random_number = rand(start..limit)
    end while excluded_numbers.include?(random_number)
random_number
end
