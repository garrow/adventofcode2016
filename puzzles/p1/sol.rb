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

  def input_commands
    regex =  /(R|L)(\d+)/

    inputs.split(", ").map { |input|
      matches = input.match(regex)
      direction = matches[1]
      distance = matches[2]

      [direction, distance]
    }.map { |pair|
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


  def call
    inputs.split(", ")
  end

end



class TaxiCab
  attr_reader :x, :y, :facing

  def initialize
    @x = 0
    @y = 0
    @facing = :north
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

  def test_inits
    assert_equal DirectionSimulator.new(nil, "1, 2, 3, 4").call, %w[1 2 3 4]
  end


  def test_inputs_split_to_commands

    # simulator = DirectionSimulator.new(nil, "R5")
    simulator = DirectionSimulator.new(nil, "R5, L2, L1")
    assert_equal simulator.input_commands, [["R", "5"], ["L", "2"], ["L", "1"]]
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
