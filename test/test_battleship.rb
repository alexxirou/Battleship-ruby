require 'minitest/autorun'
require 'set'
require 'json'
require_relative '../Model'
require_relative '../RandomShipGenerator'

class ModelTest < Minitest::Test
  def setup
    @grid1 = Model.load_grid_from_file('grid1.grd')
    @grid2 = Model.load_grid_from_file('grid2.grd')
  end

  def test_ship
    ship1 = Model::Ship.new('Destroyer', [[1, 2], [2, 3]])
    assert_equal 'Destroyer', ship1.name
    assert_equal Set[[1, 2], [2, 3]], ship1.positions

    ship2 = Model::Ship.new('Destroyer', [[10, 22], [22, 32]])
    assert_equal 'Destroyer', ship2.name
    assert_equal Set[[10, 22], [22, 32]], ship2.positions

    assert ship1.compare_ships(Model::Ship.new('Destroyer', [[1, 2], [2, 3]]))
    refute ship1.compare_ships(Model::Ship.new('Destroyer2', [[1, 2], [2, 3]]))
    refute ship1.compare_ships(Model::Ship.new('Destroyer', [[12, 2], [2, 3]]))

    ship1.shoot_at_ship([1, 2])
    assert ship1.ship_afloat?

    ship1.shoot_at_ship([2, 3])
    refute ship1.ship_afloat?
  end

  def test_grid
    assert_equal(
      {
        size_x: 5,
        size_y: 5,
        ships: [],
        misses: Set.new
      }.to_json,

      {
        size_x: @grid1.size_x,
        size_y: @grid1.size_y,
        ships: @grid1.ships,
        misses: @grid1.misses
      }.to_json
    )

    assert_equal(
      {
        size_x: 10,
        size_y: 10,
        ships: @grid2.ships,
        misses: Set.new
      }.to_json,

      {
        size_x: @grid2.size_x,
        size_y: @grid2.size_y,
        ships: @grid2.ships,
        misses: Set.new
      }.to_json
    )
  end

  def test_shoot_at_position_miss
    grid = Model::Grid.new(size_x: 5, size_y: 5, ships: [])
    result = grid.shoot_at_position([1, 1])
    assert_equal(["MISS"], result)
  end

  def test_shoot_at_position_hit
    grid = Model::Grid.new(size_x: 5, size_y: 5, ships: [["Ship", Set[[1, 1],[2, 2]]]])
    result = grid.shoot_at_position([1, 1])
    assert_equal(["HIT"], result)
  end

  def test_shoot_at_position_destroyed
    grid = Model::Grid.new(size_x: 5, size_y: 5, ships: [["Ship", Set[[1, 1]]]])
    grid.shoot_at_position([1, 1])
    result = grid.shoot_at_position([1, 1])
    assert_equal(["DESTROYED", "Ship"], result)
  end

  def test_shoot_at_position_already_missed
    grid = Model::Grid.new(size_x: 5, size_y: 5, ships: [], misses: Set[[1, 1]])
    result = grid.shoot_at_position([1, 1])
    assert_equal(["MISS"], result)
  end

  def test_ship_afloat
    grid = Model::Grid.new(size_x: 5, size_y: 5, ships: [["Ship", Set[[3, 3]]]])
    assert_equal(true, grid.ships[0].ship_afloat?)
    grid.shoot_at_position([3, 3])
    assert_equal(false, grid.ships[0].ship_afloat?)
  end
end

class RandomShipGeneratorTest < Minitest::Test
  def setup
    @row_length = 10
  end

  def teardown
    @row_length = nil
  end

  def test_random_ship_positions_array
    assert_equal 4, RandomShipGenerator.random_ship_positions_array(@row_length).size
  end

  def test_build_ship_positions
    positions_array = [[1, 1], [2, 2], [3, 3]]
    ship_positions = RandomShipGenerator.build_ship_positions(4, positions_array, @row_length)
    refute RandomShipGenerator.positions_overlap?(ship_positions, positions_array)
  end

  def test_generate_random_positions
    ship_random_positions = RandomShipGenerator.generate_random_positions(3, @row_length)
    assert_equal 4, ship_random_positions.size
    assert ship_random_positions.all? { |pos| pos.all? { |coord| coord.between?(0, @row_length - 1) } }
  end

  def test_positions_overlap
    positions1 = [[1, 1], [2, 2], [3, 3]]
    positions2 = [[4, 4], [5, 5], [3, 3]]
    positions3 = [[6, 6], [7, 7], [8, 8]]
    assert RandomShipGenerator.positions_overlap?(positions1, positions2)
    refute RandomShipGenerator.positions_overlap?(positions1, positions3)
  end
end
