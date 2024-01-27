require 'set'

# The AI class represents an artificial intelligence player for the Battleship game.
class AI
  # Initializes a new instance of the AI class.
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
    highest_probability_position(grid) || random_position(grid)
  end

  # Records the result of a shot fired by the AI.
  #
  # @param [Array<Integer, Integer>] shot The coordinates of the shot.
  # @param [String] result The result of the shot ('HIT', 'MISS', 'DESTROYED').
  # @param [Grid] grid The current state of the grid.
  def record_shot(shot, result, grid)
    if ['HIT', 'DESTROYED'].include?(result)
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
    adjacent_shot = target_around_last_hit(grid)
    return adjacent_shot if adjacent_shot

    random_position(grid)
  end

  # Generates a random position on the grid.
  #
  # @param [Grid] grid The current state of the grid.
  # @return [Array<Integer, Integer>] The randomly chosen position.
  def random_position(grid)
    all_possible_positions(grid).reject do |pos|
      grid.misses.include?(pos) || @grid_hits.include?(pos)
    end.sample
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
    potential_positions = []

    if @ship_orientation
      (1..3).each do |offset|
        potential_positions = calculate_potential_positions(x, y, offset)
        break if potential_positions.any?
      end
    else
      potential_positions = calculate_potential_positions(x, y, 1)
    end

    potential_positions.sample
  end

  # Calculates potential positions around the last hit based on the ship orientation.
  #
  # @param [Integer] x The x-coordinate of the last hit.
  # @param [Integer] y The y-coordinate of the last hit.
  # @param [Integer] offset The offset to calculate positions around the last hit.
  # @return [Array<Array<Integer, Integer>>] The potential positions.
  def calculate_potential_positions(x, y, offset)
    directions = @ship_orientation == 'Horizontal' ? [[0, offset], [0, -offset]] : [[offset, 0], [-offset, 0]]

    directions.reject! do |dx, dy|
      pos = [x + dx, y + dy]
      pos[0].negative? || pos[1].negative? || pos[0] >= grid.size_x || pos[1] >= grid.size_y ||
        grid.misses.include?(pos) || @grid_hits.include?(pos)
    end
  end

  # Updates the ship orientation based on the last hit.
  #
  # @param [Array<Integer, Integer>] last_hit The coordinates of the last hit.
  # @param [Grid] grid The current state of the grid.
  def update_ship_orientation(last_hit, grid)
    return if @last_hit_position.nil? || grid_observers_include_last_hit?(grid)

    last_x, last_y = @last_hit_position
    current_x, current_y = last_hit

    @ship_orientation = if last_x == current_x
                          'Vertical'
                        elsif last_y == current_y
                          'Horizontal'
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
