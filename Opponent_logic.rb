require 'set'

class AI
  #
  # Initializes a new instance of the AI class.
  #
  def initialize
 
  
    @grid_hits = Set.new
    @last_hit_position = nil
    @ship_orientation = nil
    @sunken_ships_positions = Set.new
  end

  # Gets the next shot for the AI based on the current state of the grid.
  #
  # @param [Grid] grid The current state of the grid.
  # @return [Array<Integer, Integer>] The target position for the next shot.
  def next_shot(grid)
    target_position = highest_probability_position(grid)
    target_position
  end

  # Records the result of a shot fired by the AI.
  #
  # @param [Array<Integer, Integer>] shot The coordinates of the shot.
  # @param [String] result The result of the shot ('HIT', 'MISS', 'DESTROYED').
  # @param [Grid] grid The current state of the grid.
  def record_shot(shot, result, grid)
    if result == 'HIT' || result == 'DESTROYED'
      
      update_ship_orientation(shot,grid)
      @last_hit_position = shot
      @grid_hits.add(shot)
    end

    update_remaining_ships(result, grid)
  end

  private

  # Determines the highest probability position for the next shot.
  #
  # @param [Grid] grid The current state of the grid.
  # @return [Array<Integer, Integer>] The target position for the next shot.
  def highest_probability_position(grid)
    # Get all hits on the grid
    hits = @grid_hits

    adjacent_shot=target_around_last_hit(grid)


    # If no hits, choose a random position as a starting point
    return adjacent_shot ? adjacent_shot : random_position(grid)
    end
  end

  # Generates a random position on the grid.  
  #
  # @param [Grid] grid The current state of the grid.
  # @return [Array<Integer, Integer>] The randomly chosen position.
  def random_position(grid)
    # Get all possible positions on the grid
    all_possible_positions = all_possible_positions(grid)

    # Divide the grid into four parts
    grid_size_x = grid.size_x
    grid_size_y = grid.size_y
    mid_x = grid_size_x / 2
    mid_y = grid_size_y / 2

    # Separate positions into four parts based on their coordinates
    parts = {
      top_left: all_possible_positions.select { |pos| pos[0] < mid_x && pos[1] < mid_y },
      top_right: all_possible_positions.select { |pos| pos[0] >= mid_x && pos[1] < mid_y },
      bottom_left: all_possible_positions.select { |pos| pos[0] < mid_x && pos[1] >= mid_y },
      bottom_right: all_possible_positions.select { |pos| pos[0] >= mid_x && pos[1] >= mid_y }
    }

    # Calculate the count of missed hits in each part
    missed_hits_counts = parts.transform_values do |positions|
      positions.count { |pos| grid.misses.include?(pos) }
    end

    # Find the part with the lowest count of missed hits
    best_part = missed_hits_counts.min_by { |_, count| count }.first
    # Filter out positions in the chosen part
    filtered_positions = parts[best_part].reject { |pos| grid.misses.include?(pos) || @grid_hits.include?(pos) }

    # If there are positions in the chosen part, choose a random one
    return filtered_positions.sample if filtered_positions.any?

    # If there are no available positions in the chosen part, choose a completely random position
    return all_possible_positions.reject { |pos| grid.misses.include?(pos) || @grid_hits.include?(pos) }.sample
  end


  # Gets all possible positions on the grid.
  #
  # @param [Grid] grid The current state of the grid.
  # @return [Array<Array<Integer, Integer>>] All possible positions on the grid.
  def all_possible_positions(grid)
    # Implement logic to get all possible positions based on the grid size (10x10)
    (0..grid.size_x - 1).to_a.product((0..grid.size_y - 1).to_a)
  end

  # Determines the target positions around the last hit.
  #
  # @param [Grid] grid The current state of the grid.
  # @return [Array<Integer, Integer>] The target position around the last hit.
  def target_around_last_hit(grid)
    return nil if @last_hit_position.nil? || @sunken_ships_positions.include?(@last_hit_position)

    x, y = @last_hit_position

  # Prioritize targets based on ship orientation
    if @ship_orientation!=nil  
      (1..3).each do |offset|
        if @ship_orientation == 'Horizontal'  
          potential_positions = [[x + offset, y], [x - offset, y]]
        end
        if @ship_orientation == 'Vertical'  
          potential_positions = [[x,  y + offset], [x, y- offset]]
        end
        potential_positions.reject! do |pos| 
          pos[0].negative? || pos[1].negative? || pos[0] >= grid.size_x || pos[1] >= grid.size_y || grid.misses.include?(pos) || @grid_hits.include?(pos)
        end
        return potential_positions.sample if potential_positions.any?
      end  
    
    else
    # If ship orientation is not defined, consider all directions
      potential_positions = [
      [x - 1, y],
      [x + 1, y],
      [x, y - 1],
      [x, y + 1]
      ]
    end

    if potential_positions
    # Filter out positions that are outside the grid boundaries or have already been explored
      valid_positions = potential_positions.reject do |pos|
        pos[0].negative? || pos[1].negative? || pos[0] >= grid.size_x || pos[1] >= grid.size_y || grid.misses.include?(pos) || @grid_hits.include?(pos)
      end
      valid_positions.sample
    end  
  end




  def update_ship_orientation(last_hit, grid)
    return if @last_hit_position.nil?

  # Check if the last hit position is of a sunken ship
    if grid.observers.flatten.include?(@last_hit_position)
      @ship_orientation = nil
    else
      last_x, last_y = @last_hit_position
      current_x, current_y = last_hit

    # Check if the last two hits are in the same row or column
      if last_x == current_x
        @ship_orientation = 'Vertical'
      elsif last_y == current_y
        @ship_orientation = 'Horizontal'
      else
      # If the hits are neither in the same row nor column, reset the ship orientation
        @ship_orientation = nil
      end
    end
  end

  


