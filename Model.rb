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
    attr_reader :size_x, :size_y, :misses, :ships
    

    def initialize(size_x, size_y, ships=[], misses=Set[])
        @size_x=size_x
        @size_y=size_y
        @ships=ships
        @misses=misses
    end
    
    def add_ship_to_grid(ship)
        @ships.push(ship)
    end

    def shoot_at_position(shot)
        unless @misses.include?(shot)
            @ships.each do |ship|
                unless ship.positions.include?(shot)
                    ship_shot_result = ship.shoot_at_ship(shot)
                    @misses.add(shot) if ship_shot_result == 'MISS'
                    return [ship_shot_result, ship_afloat? ? ship : nil]
                end
            end
        end
        ['MISS', nil]
    end
end

class Blind_grid < Grid
    attr_reader :hits, :sunken_ships
    def initialize(grid)
        super(grid.size_x, grid.size_y, [], grid.misses)
        @hits||=add_hits_to_blind_grid(grid)
        @sunken_ships||=add_sunken_ships_to_blind_grid(grid)
    end
    
    def add_sunken_ships_to_blind_grid(grid)
        sunken_ships=Set[]
        grid.ships.each do |ship|
                sunken_ships.add(ship) unless ship.ship_afloat?
        end
        sunken_ships
    end         

    def add_hits_to_blind_grid(grid)
        hits=Set[]
        grid.ships.each do |ship|
            ship.hits_received.each{ |hit| hits.add(hit)}
        end
        hits
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


