#!/usr/bin/env ruby

require 'minitest'
require 'minitest/rg'




def input
  "R5, L2, L1, R1, R3, R3, L3, R3, R4, L2, R4, L4, R4, R3, L2, L1, L1, R2, R4, R4, L4, R3, L2, R1, L4, R1, R3, L5, L4, L5, R3, L3, L1, L1, R4, R2, R2, L1, L4, R191, R5, L2, R46, R3, L1, R74, L2, R2, R187, R3, R4, R1, L4, L4, L2, R4, L5, R4, R3, L2, L1, R3, R3, R3, R1, R1, L4, R4, R1, R5, R2, R1, R3, L4, L2, L2, R1, L3, R1, R3, L5, L3, R5, R3, R4, L1, R3, R2, R1, R2, L4, L1, L1, R3, L3, R4, L2, L4, L5, L5, L4, R2, R5, L4, R4, L2, R3, L4, L3, L5, R5, L4, L2, R3, R5, R5, L1, L4, R3, L1, R2, L5, L1, R4, L1, R5, R1, L4, L4, L4, R4, R3, L5, R1, L3, R4, R3, L2, L1, R1, R2, R2, R2, L1, L1, L2, L5, L3, L1"
end


class DirectionSimulator

  attr_reader :actor, :inputs

  def initialize(actor, inputs ="")
    @actor = actor
    @inputs = inputs
  end


  def raw_inputs
    inputs.split(", ")
  end


  def input_commands
    regex =  /(R|L)(\d+)/

    raw_inputs.map { |input|
      matches = input.match(regex)

      next unless matches
      direction = matches[1]
      distance = matches[2]

      [direction, distance]
    }.compact
  end



  def parsed_commands
    input_commands.map { |pair|
      direction = pair.first
      distance = pair.last

      case direction
        when "R"
          direction_method = :right
        when "L"
          direction_method = :left
      end

      distance = distance.to_i

      [direction_method, distance]
    }
  end


  def process_commands
    parsed_commands.map { |(direction, distance)|
      actor.send(direction)
      distance.times { actor.move  }

      actor.mark
    }
  end

  def call
    process_commands
  end

end



class TaxiCab
  attr_reader :x, :y, :facing

  def initialize
    @x = 0
    @y = 0
    @facing = :north
    @locations = []
  end

  def directionality
    {
        north: -> (x, y) { [x + 1, y] },
        east:  -> (x, y) { [x, y + 1] },
        south: -> (x, y) { [x - 1, y] },
        west:  -> (x, y) { [x, y - 1] }
    }
  end

  def compass
    directionality.keys
  end

  def left
    @facing = compass.rotate(compass.index(facing))[-1]
  end

  def right
    @facing = compass.rotate(compass.index(facing))[1]
  end

  def move
    @x, @y = directionality[facing].call(x, y)
  end

  def mark
    @locations << { x: x, y: y, distance: distance_from_origin }
  end

  def distance_from_origin
    x.abs + y.abs
  end
end

class InputsTest < MiniTest::Test
  def test_that_the_drink_is_water
    assert_equal 149, input.split(", ").count
  end
end

class DirectionSimulatorTest < MiniTest::Test
  def test_init
    assert_equal DirectionSimulator.new("go").actor, "go"
  end

  def test_raw_split_inputs
    assert_equal DirectionSimulator.new(nil, "1, 2, 3, 4").raw_inputs, %w[1 2 3 4]
  end


  def test_inputs_split_to_commands
    simulator = DirectionSimulator.new(nil, "R5, L2, L1")
    assert_equal simulator.input_commands, [["R", "5"], ["L", "2"], ["L", "1"]]
  end

  def test_inputs_commands_to_args
    simulator = DirectionSimulator.new(nil, "R5, L2, L1")
    assert_equal simulator.parsed_commands, [[:right, 5], [:left, 2], [:left, 1]]
  end

  def test_simulate_simple
    cab = TaxiCab.new
    simulator = DirectionSimulator.new(cab, "R5")
    assert_equal simulator.parsed_commands, [[:right, 5]]

    simulator.process_commands
    assert_equal 5, simulator.actor.y

  end


  def assert_distance(distance:, commands:)
    cab = TaxiCab.new
    simulator = DirectionSimulator.new(cab, commands)
    simulator.call

    #puts commands
    #puts  simulator.actor.inspect

    assert_equal distance, simulator.actor.distance_from_origin
  end



  def test_simulate_testcase1
    assert_distance(distance: 5, commands:  "R2, L3")
  end

  def test_simulate_testcase2
    assert_distance(distance: 2, commands:  "R2, R2, R2")
  end

  def test_simulate_testcase3
    assert_distance(distance: 12, commands:  "R5, L5, R5, R3")
  end



  def test_simulate_testcase4
    assert_distance(distance: 20, commands:  "L10, L10")
  end

  def test_simulate_final_answer
    assert_distance(distance: 287, commands:  input)
  end




end


class TaxiCabTest < MiniTest::Test
  def test_compass
    cab = TaxiCab.new
    assert_equal cab.facing, :north
  end

  def test_starting_pos
    cab = TaxiCab.new
    assert_equal cab.x, 0
    assert_equal cab.y, 0
  end

  def test_moving_left
    cab = TaxiCab.new
    cab.left
    assert_equal cab.facing, :west
  end

  def test_moving_left_more
    cab = TaxiCab.new
    cab.left
    cab.left
    assert_equal cab.facing, :south
  end

  def test_moving_left
    cab = TaxiCab.new
    cab.right
    cab.right
    cab.right

    assert_equal cab.facing, :west
  end

  def test_move_north
    cab = TaxiCab.new
    cab.move

    assert_equal cab.x, 1
    assert_equal cab.y, 0
  end

  def test_move_north_twice
    cab = TaxiCab.new
    cab.move
    cab.move
    cab.move
    cab.move
    cab.move
    cab.right
    cab.move
    cab.move

    assert_equal cab.x, 5
    assert_equal cab.y, 2
  end
end


if MiniTest.run
  puts "Tests Passed! Process can proceed."
else
  puts "Tests Failed! Drink *is not* safe!"
  puts "-- No process run --"
end
