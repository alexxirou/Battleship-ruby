module OpponentLogic
  class AI
    #
    # Initializes a new instance of the AI class.
    #
    def initialize
      @grid_hits = Set.new
      @last_hit_position = nil
      @ship_orientation = nil
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
      if result == "HIT" || result == "DESTROYED"
        update_ship_orientation(shot, grid)
        @last_hit_position = shot
        @grid_hits.add(shot)
      end
    end

    private

    # Determines the highest probability position for the next shot.
    #
    # @param [Grid] grid The current state of the grid.
    # @return [Array<Integer, Integer>] The target position for the next shot.
    def highest_probability_position(grid)
      hits = @grid_hits
      adjacent_shot = target_around_last_hit(grid)

      return adjacent_shot || random_position(grid)
    end

    # Generates a random position on the grid.
    #
    # @param [Grid] grid The current state of the grid.
    # @return [Array<Integer, Integer>] The randomly chosen position.
    def random_position(grid)
      all_possible_positions = all_possible_positions(grid)
      mid_x = grid.size_x / 2
      mid_y = grid.size_y / 2

      parts = {
        top_left: all_possible_positions.select { |pos| pos[0] < mid_x && pos[1] < mid_y },
        top_right: all_possible_positions.select { |pos| pos[0] >= mid_x && pos[1] < mid_y },
        bottom_left: all_possible_positions.select { |pos| pos[0] < mid_x && pos[1] >= mid_y },
        bottom_right: all_possible_positions.select { |pos| pos[0] >= mid_x && pos[1] >= mid_y },
      }

      missed_hits_counts = parts.transform_values { |positions| positions.count { |pos| grid.misses.include?(pos) } }
      best_part = missed_hits_counts.min_by { |_, count| count }.first
      filtered_positions = parts[best_part].reject { |pos| grid.misses.include?(pos) || @grid_hits.include?(pos) }

      return filtered_positions.sample if filtered_positions.any?

      all_possible_positions.reject { |pos| grid.misses.include?(pos) || @grid_hits.include?(pos) }.sample
    end

    # Gets all possible positions on the grid.
    #
    # @param [Grid] grid The current state of the grid.
    # @return [Array<Array<Integer, Integer>>] All possible positions on the grid.
    def all_possible_positions(grid)
      (0..grid.size_x - 1).to_a.product((0..grid.size_y - 1).to_a)
    end

    # Determines the target positions around the last hit.
    #
    # @param [Grid] grid The current state of the grid.
    # @return [Array<Integer, Integer>] The target position around the last hit.
    def target_around_last_hit(grid)
      return nil if @last_hit_position.nil? || grid_observers_include_last_hit?(grid)

      x, y = @last_hit_position

      if @ship_orientation
        (1..3).each do |offset|
          potential_positions = if @ship_orientation == "Horizontal"
              [[x + offset, y], [x - offset, y]]
            else
              [[x, y + offset], [x, y - offset]]
            end
          potential_positions.reject! do |pos|
            pos[0].negative? || pos[1].negative? || pos[0] >= grid.size_x || pos[1] >= grid.size_y || grid.misses.include?(pos) || @grid_hits.include?(pos)
          end
          return potential_positions.sample if potential_positions.any?
        end
      else
        potential_positions = [
          [x - 1, y],
          [x + 1, y],
          [x, y - 1],
          [x, y + 1],
        ]
      end

      return potential_positions.sample if potential_positions&.any?
    end

    # Updates the ship orientation based on the last hit and current grid state.
    #
    # @param [Array<Integer, Integer>] last_hit The coordinates of the last hit.
    # @param [Grid] grid The current state of the grid.
    def update_ship_orientation(last_hit, grid)
      @ship_orientation = nil
      return if @last_hit_position.nil? || grid_observers_include_last_hit?(grid)

      last_x, last_y = @last_hit_position
      current_x, current_y = last_hit

      if last_x == current_x
        @ship_orientation = "Vertical"
      elsif last_y == current_y
        @ship_orientation = "Horizontal"
      end
    end

    # Checks if any grid observers include the last hit position.
    #
    # @param [Grid] grid The current state of the grid.
    # @return [Boolean] True if any observer includes the last hit position, false otherwise.
    def grid_observers_include_last_hit?(grid)
      grid.observers.any? { |observer| observer.positions.include?(@last_hit_position) }
    end
  end
end
