#!/usr/bin/env ruby


require 'minitest'
require 'minitest/rg'

class Drink                                    # The Code to Test
  attr_reader :type
  
  def initialize
    @type = "water"
  end
  
  def describe_type
    puts "This is a drink of #{type}."
  end
end


class DrinkTest < MiniTest::Test               # The Test Suite
  def test_that_the_drink_is_water
    drink = Drink.new
    assert_equal "water", drink.type
  end
end





if MiniTest.run                                # The Run/Kill Switch
  puts "Tests Passed! Process can proceed."
  drink = Drink.new
  drink.describe_type
else
  puts "Tests Failed! Drink *is not* safe!"
  puts "-- No process run --"
end
