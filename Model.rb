require 'set'
#A ship that can be placed on the grid
class Ship
    attr_reader :name, :positions, :hits_received

    def inspect_ship_object
        "Ship.new('#{@name}', #{@positions})"
    end

    def initialize(ship_name, ship_positions)
        @name = ship_name
        @positions = Set.new(ship_positions)
        @hits_received = Set.new
    end

    def compare_ships(other_ship)
        @name==other_ship.name && @positions==other_ship.positions
    end

    def ship_afloat?
        @positions!=@hits_received
    end    

    def shoot_at_ship(shot)
        if @positions.include?(shot) 
            @hits_received.add(shot)
            return ship_afloat? ? 'HIT' : 'DESTROYED'
        end
        'MISS'
    end         

end

class Grid
    attr_reader :size_x, :size_y, :misses, :ships, :sunken_ships
    

    def initialize(size_x, size_y, ships=Set[], misses=Set[])
        @size_x=size_x
        @size_y=size_y
        @ships=ships
        @misses=misses
        @sunken_ships = Set[]
    end
    
    def add_ship_to_grid(ship)
        @ships.add(ship)
    end

    def add_sunken_ship_to_grid(ship)
        @sunken_ships.add(ship) 
    end        

    def shoot_at_position(shot)
        result = ['MISS']
        unless @misses.include?(shot)
            @ships.each do |ship|
                ship_shot_result = ship.shoot_at_ship(shot)
                add_sunken_ship_to_grid(ship) if ship_shot_result == 'DESTROYED'
                result = ship_shot_result== "DESTROYED" ? [ship_shot_result,  ship.name ] : [ship_shot_result] 
                return result if result[0] == 'DESTROYED' || result[0] == 'HIT'
            end
             @misses.add(shot) if result[0] == 'MISS'
        end
        result
    end
end



def load_grid_from_file(file)
    dimensions_x_y = []
    ships_array=[]
    File.foreach(file).with_index do |line, line_number|
        if line_number ==0
        dimensions_x_y = line.chomp.strip.split(":").flatten 
        end
        ships_array<<add_ships_from_data_source(line)  if line_number >= 1 
    end    
    Grid.new(dimensions_x_y[0].to_i, dimensions_x_y[1].to_i, ships_array)
end



def add_ships_from_data_source(source)
    ship_params = source.chomp.split(" ")
    name = ship_params[0]
    positions = ship_params[1..].map { |pos| pos.split(":").map(&:to_i) }
    Ship.new(name, positions)     
end


