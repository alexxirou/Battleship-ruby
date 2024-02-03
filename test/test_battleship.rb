rrequire 'set'



class Ship
  attr_reader :name, :positions
  attr_accessor :hits

  def initialize(name, positions)
    @name, @positions, @hits = name, positions, Set.new
  end

  def shoot_at_ship(position)
    return 'DESTROYED' if (@hits = @hits.union([position])).eql?(@positions)
    @positions.include?(position) ? 'HIT' : 'MISS'
  end

  def afloat
    @hits.empty?
  end
end

class Grid
  attr_accessor :sizex, :sizey, :ships, :misses

  def initialize(sizex, sizey)
    @sizex, @sizey, @ships, @misses = sizex, sizey, [], Set.new
  end

  def shoot(position)
    ship_hit = @ships.find { |ship| ['HIT', 'DESTROYED'].include?(result = ship.shoot_at_ship(position)) }
    @misses << position if result == 'MISS'
    [result, ship_hit]
  end
end

class BlindGrid
  attr_accessor :sizex, :sizey, :sunken_ships, :misses, :hits

  def initialize(grid)
    @sizex, @sizey, @sunken_ships, @misses, @hits = grid.sizex, grid.sizey, [], grid.misses, Set.new

    grid.ships.each do |ship|
      @sunken_ships << ship if ship.hits.eql?(ship.positions)
      @hits.merge(ship.hits) unless ship.hits.empty?
    end
  end
end

def generic_tester(f, tests)
  puts "Testing #{f}..."
  counter, failed = 0, 0

  tests.each do |arguments, test_out|
    counter += 1
    begin
      real_out = f.call(*arguments)
      if real_out != test_out
        failed += 1
        puts "  Test ##{counter} FAILED:\nArguments = #{arguments}\nExpected #{test_out}\nGot      #{real_out}"
      end
    rescue StandardError => e
      failed += 1
      puts "  Test ##{counter} FAILED with exception #{e}.\nTry debugging with arguments = #{arguments} (expected output = #{test_out})"
    end
  end

  puts "#{counter} tests run, #{counter - failed} passed, #{failed} failed"
  puts '(Congratulations!)' if failed.zero?
end




def file_line_count(filename)
  IO.foreach(filename).count
end

def generic_output_file_without_order_tester(f, arguments, outputfile, ref_outputfile)
  puts "Testing #{f}..."
  passed = true

  begin
    f.call(*arguments)
    ref_line_count = file_line_count(ref_outputfile)
    f_line_count = file_line_count(outputfile)

    if ref_line_count != f_line_count
      puts "\nFAILED (wrong number of lines: #{outputfile} #{f_line_count}, but #{ref_outputfile} #{ref_line_count})"
      passed = false
    else
      reference = File.readlines(ref_outputfile)
      counter = 1

      File.foreach(outputfile) do |oline|
        unless reference.include?(oline)
          puts "\nFAILED (in output line #{counter},#{outputfile}:\ndid not find #{oline.strip} in reference file\n)"
          passed = false
          break
        end
        counter += 1
      end
    end

    puts 'passed!' if passed
    puts 'Congratulations!' if passed
  rescue StandardError => e
    puts "\nFAILED with exception #{e}.\nTry debugging with arguments = #{arguments}"
  end
end

def generic_value_tester(functions, expected)
  puts 'Testing...'
  counter = 0
  failed = 0

  functions.zip(expected).each do |function, expected_result|
    counter += 1
    begin
      real_out = function.call
      if real_out != expected_result
        failed += 1
        puts "  Test ##{counter} FAILED:\nRan \"#{function.name}\"\nExpected \"#{expected_result}\"\nGot      \"#{real_out}\""
      end
    rescue StandardError => e
      failed += 1
      puts "  Test ##{counter} FAILED with exception \"#{e}\" when running \"#{function.name}\"."
    end
  end

  puts "#{counter} tests run, #{counter - failed} passed, #{failed} failed"
  puts '(Congratulations!)' if failed.zero?
end

def unordered_print_tester(f, args)
  stream = StringIO.new
  $stdout = stream
  f.call(*args)
  $stdout = STDOUT
  stream.string.split("\n").tally
end

def ordered_print_tester(f, args)
  stream = StringIO.new
  $stdout = stream
  f.call(*args)
  $stdout = STDOUT
  stream.string
end

def ship1
  s1 = Ship.new('Destroyer', Set[[1, 2], [2, 3]])
  s1.__send__(:instance_variable_set, :@hits, Set.new)
  s1.__send__(:instance_variable_set, :@name, '')
  s1.__send__(:instance_variable_set, :@positions, Set[[1, 2], [2, 3]])
  s1.__send__(:instance_variable_get, :@hits).merge(Set.new)
  s1.__send__(:instance_variable_get, :@name)
  s1.__send__(:instance_variable_get, :@positions)
end

def ship2
  s1 = Ship.new('Destroyer', Set[[10, 22], [22, 32]])
  s1.__send__(:instance_variable_set, :@hits, Set.new)
  s1.__send__(:instance_variable_set, :@name, '')
  s1.__send__(:instance_variable_set, :@positions, Set[[10, 22], [22, 32]])
  s1.__send__(:instance_variable_get, :@hits).merge(Set.new)
  s1.__send__(:instance_variable_get, :@name)
  s1.__send__(:instance_variable_get, :@positions)
end

def ship_eq1
  s1 = Ship.new('Destroyer', Set[[1, 2], [2, 3]])
  s2 = Ship.new('Destroyer', Set[[1, 2], [2, 3]])
  s1 == s2
end

def ship_eq2
  s1 = Ship.new('Destroyer', Set[[1, 2], [2, 3]])
  s2 = Ship.new('Destroyer2', Set[[1, 2], [2, 3]])
  s1 == s2
end

def ship_eq3
  s1 = Ship.new('Destroyer', Set[[1, 2], [2, 3]])
  s2 = Ship.new('Destroyer', Set[[12, 2], [2, 3]])
  s1 == s2
end

def ship_eq4
  s1 = Ship.new('Destroyer', Set[[1, 2], [2, 3]])
  s1.__send__(:instance_variable_set, :@hits, Set[[1, 2]])
  s2 = Ship.new('Destroyer', Set[[1, 2], [2, 3]])
  s1 == s2
end

def afloat1
  s1 = Ship.new('Destroyer', Set[[1, 2], [2, 3]])
  s1.is_afloat
end

def afloat2
  s1 = Ship.new('Destroyer', Set[[1, 2], [2, 3]])
  s1.__send__(:instance_variable_set, :@hits, Set[[1, 2], [2, 3]])
  s1.is_afloat
end

def test_ship
  f = [method(:ship1), method(:ship2), method(:ship_eq1), method(:ship_eq2), method(:ship_eq3), method(:ship_eq4), method(:afloat1), method(:afloat2)]
  v = [{hits: Set.new, name: 'Destroyer', positions: Set[[1, 2], [2, 3]]},
       {hits: Set.new, name: 'Destroyer', positions: Set[[10, 22], [22, 32]]},
       true, false, false, false, true, false]
  generic_value_tester(f, v)
end

def grid1
  battleship.Grid.new(10, 11).instance_variable_get(:@__dict__)
end

def grid2
  g = battleship.Grid.new(100, 110)
  g.ships.push(Ship.new('Destroyer', Set[[1, 2], [2, 2]]))
  g.instance_variable_get(:@__dict__)
end

def grid3
  g = battleship.Grid.new(2, 3)
  g.misses.add(Set[[2, 3]])
  g.instance_variable_get(:@__dict__)
end

def test_grid
  f = [method(:grid1), method(:grid2), method(:grid3)]
  v = [{misses: Set.new, ships: [], sizex: 10, sizey: 11},
       {misses: Set.new, ships: [Ship.new('Destroyer', Set[[1, 2], [2, 2]])], sizex: 100, sizey: 110},
       {misses: Set[[2, 3]], ships: [], sizex: 2, sizey: 3}]
  generic_value_tester(f, v)
end

def load_helper(filename)
  battleship.load_grid_from_file(filename).instance_variable_get(:@__dict__)
end


def test_load
  tests = {
    'grid1.grd' => { 'sizex' => 5, 'sizey' => 5, 'ships' => [Battleship::Ship.new('Destroyer', [[1, 2], [2, 2]])], 'misses' => Set.new },
    'grid2.grd' => {
      'sizex' => 10,
      'sizey' => 10,
      'ships' => [
        Battleship::Ship.new('Carrier', [[2, 5], [2, 6], [2, 3], [2, 4], [2, 2]]),
        Battleship::Ship.new('Battleship', [[3, 8], [2, 8], [5, 8], [4, 8]]),
        Battleship::Ship.new('Cruiser', [[4, 5], [5, 5], [6, 5]]),
        Battleship::Ship.new('Submarine', [[8, 9], [9, 9], [7, 9]]),
        Battleship::Ship.new('Destroyer', [[1, 8], [1, 9]])
      ],
      'misses' => Set.new
    }
  }
  generic_tester(method(:load_helper), tests)
end

def miss
  ship = Battleship::Ship.new('', [[1, 1]])
  result = ship.shoot_at_ship([0, 0])
  [result, ship.instance_variables.map { |var| [var, ship.instance_variable_get(var)] }.to_h]
end

def hit
  ship = Battleship::Ship.new('', [[1, 1], [1, 2]])
  result = ship.shoot_at_ship([1, 1])
  [result, ship.instance_variables.map { |var| [var, ship.instance_variable_get(var)] }.to_h]
end

def kill
  ship = Battleship::Ship.new('', [[1, 1], [1, 2]])
  ship.shoot_at_ship([1, 1])
  result = ship.shoot_at_ship([1, 2])
  [result, ship.instance_variables.map { |var| [var, ship.instance_variable_get(var)] }.to_h]
end

def double_shot
  ship = Battleship::Ship.new('', [[1, 1], [1, 2]])
  ship.shoot_at_ship([1, 1])
  result = ship.shoot_at_ship([1, 1])
  [result, ship.instance_variables.map { |var| [var, ship.instance_variable_get(var)] }.to_h]
end

def test_shoot_ship
  functions = [method(:miss), method(:hit), method(:double_shot), method(:kill)]
  expected_results = [
    ['MISS', { '@hits' => Set.new, '@positions' => [[1, 1]], '@name' => '' }],
    ['HIT', { '@hits' => Set.new([1, 1]), '@positions' => [[1, 1], [1, 2]], '@name' => '' }],
    ['MISS', { '@hits' => Set.new([1, 1]), '@positions' => [[1, 1], [1, 2]], '@name' => '' }],
    ['DESTROYED', { '@hits' => Set.new([1, 2, 1, 1]), '@positions' => [[1, 2], [1, 1]], '@name' => '' }]
  ]
  generic_value_tester(functions, expected_results)
end

def miss_ships
  grid = Battleship.load_grid_from_file('grid1.grd')
  result = grid.shoot([1, 1])
  [result, grid.instance_variables.map { |var| [var, grid.instance_variable_get(var)] }.to_h]
end

def hit_ship
  grid = Battleship.load_grid_from_file('grid1.grd')
  result = grid.shoot([1, 2])
  [result, grid.instance_variables.map { |var| [var, grid.instance_variable_get(var)] }.to_h]
end

def sink_ship
  grid = Battleship.load_grid_from_file('grid1.grd')
  grid.shoot([2, 2])
  result = grid.shoot([1, 2])
  [result, grid.instance_variables.map { |var| [var, grid.instance_variable_get(var)] }.to_h]
end

def test_shoot_grid
  hit_once = Battleship::Ship.new('Destroyer', [[1, 2], [2, 2]])
  hit_once.instance_variable_set(:@hits, Set.new([1, 2]))

  hit_twice = Battleship::Ship.new('Destroyer', [[1, 2], [2, 2]])
  hit_twice.instance_variable_set(:@hits, Set.new([1, 2, 2, 2]))

  functions = [method(:miss_ships), method(:hit_ship), method(:sink_ship)]
  expected_results = [
    [['MISS', nil], '@sizex' => 5, '@sizey' => 5, '@ships' => [Battleship::Ship.new('Destroyer', [[1, 2], [2, 2]])], '@misses' => Set.new([1, 1])],
    [['HIT', nil], '@sizex' => 5, '@sizey' => 5, '@ships' => [hit_once], '@misses' => Set.new],
    [['DESTROYED', hit_twice], '@sizex' => 5, '@sizey' => 5, '@ships' => [hit_twice], '@misses' => Set.new]
  ]
  generic_value_tester(functions, expected_results)
end

def no_shot
  grid = Battleship.load_grid_from_file('grid1.grd')
  blind_grid = Battleship::BlindGrid.new(grid)
  blind_grid.instance_variables.map { |var| [var, blind_grid.instance_variable_get(var)] }.to_h
end

def only_miss
  grid = Battleship.load_grid_from_file('grid1.grd')
  grid.shoot([1, 1])
  blind_grid = Battleship::BlindGrid.new(grid)
  blind_grid.instance_variables.map { |var| [var, blind_grid.instance_variable_get(var)] }.to_h
end

def one_hit
  grid = Battleship.load_grid_from_file('grid1.grd')
  grid.shoot([1, 1])
  grid.shoot([1, 2])
  blind_grid = Battleship::BlindGrid.new(grid)
  blind_grid.instance_variables.map { |var| [var, blind_grid.instance_variable_get(var)] }.to_h
end

def two_hits
  grid = Battleship.load_grid_from_file('grid1.grd')
  grid.shoot([1, 1])
  grid.shoot([1, 2])
  grid.shoot([2, 2])
  blind_grid = Battleship::BlindGrid.new(grid)
  blind_grid.instance_variables.map { |var| [var, blind_grid.instance_variable_get(var)] }.to_h
end

def test_blind
  sunk = Battleship::Ship.new('Destroyer', [[1, 2], [2, 2]])
  sunk.instance_variable_set(:@hits, Set.new([1, 2, 2, 2]))

  functions = [method(:no_shot), method(:only_miss), method(:one_hit), method(:two_hits)]
  expected_results = [
    { '@sizey' => 5, '@sunken_ships' => [], '@misses' => Set.new, '@hits' => Set.new, '@sizex' => 5 },
    { '@sizey' => 5, '@sunken_ships' => [], '@misses' => Set.new([1, 1]), '@hits' => Set.new, '@sizex' => 5 },
    { '@sizey' => 5, '@sunken_ships' => [], '@misses' => Set.new([1, 1]), '@hits' => Set.new([1, 2]), '@sizex' => 5 },
    { '@sizey' => 5, '@sunken_ships' => [sunk], '@misses' => Set.new([1, 1]), '@hits' => Set.new([1, 2, 2, 2]), '@sizex' => 5 }
  ]
  generic_value_tester(functions, expected_results)
end

generic_tester(method(:test_ship), method(:test_grid), method(:test_blind), method(:test_load), method(:test_shoot_ship), method(:test_shoot_grid))