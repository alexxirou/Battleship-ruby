require 'set'

class AI
  def initialize
    @grid_hits = Set.new
    @last_hit_position = nil
    @ship_orientation = nil
  end

  def next_shot(grid)
    target_position = highest_probability_position(grid)
    target_position
  end

  def record_shot(shot, result, grid)
    if result == 'HIT' || result == 'DESTROYED'
      update_ship_orientation(shot, grid)
      @last_hit_position = shot
      @grid_hits.add(shot)
    end
  end

  private

  def highest_probability_position(grid)
    hits = @grid_hits
    adjacent_shot = target_around_last_hit(grid)

    return adjacent_shot || random_position(grid)
  end

  def random_position(grid)
    all_possible_positions = all_possible_positions(grid)
    mid_x = grid.size_x / 2
    mid_y = grid.size_y / 2

    parts = {
      top_left: all_possible_positions.select { |pos| pos[0] < mid_x && pos[1] < mid_y },
      top_right: all_possible_positions.select { |pos| pos[0] >= mid_x && pos[1] < mid_y },
      bottom_left: all_possible_positions.select { |pos| pos[0] < mid_x && pos[1] >= mid_y },
      bottom_right: all_possible_positions.select { |pos| pos[0] >= mid_x && pos[1] >= mid_y }
    }

    missed_hits_counts = parts.transform_values { |positions| positions.count { |pos| grid.misses.include?(pos) } }
    best_part = missed_hits_counts.min_by { |_, count| count }.first
    filtered_positions = parts[best_part].reject { |pos| grid.misses.include?(pos) || @grid_hits.include?(pos) }

    return filtered_positions.sample if filtered_positions.any?

    all_possible_positions.reject { |pos| grid.misses.include?(pos) || @grid_hits.include?(pos) }.sample
  end

  def all_possible_positions(grid)
    (0..grid.size_x - 1).to_a.product((0..grid.size_y - 1).to_a)
  end

  def target_around_last_hit(grid)
    return nil if @last_hit_position.nil? || grid_observers_include_last_hit?(grid)

    x, y = @last_hit_position

    if @ship_orientation
      (1..3).each do |offset|
        potential_positions = if @ship_orientation == 'Horizontal'
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
        [x, y + 1]
      ]
    end

    return potential_positions.sample if potential_positions&.any?
  end

  def update_ship_orientation(last_hit, grid)
    @ship_orientation = nil
    return if @last_hit_position.nil? || grid_observers_include_last_hit?(grid)

    last_x, last_y = @last_hit_position
    current_x, current_y = last_hit

    if last_x == current_x
      @ship_orientation = 'Vertical'
    elsif last_y == current_y
      @ship_orientation = 'Horizontal'
    end
  end

  def grid_observers_include_last_hit?(grid)
    grid.observers.any? { |observer| observer.positions.include?(@last_hit_position) }
  end
end
