#!/bin/ruby -d

# Very similar to a Ruby class but use module because the items don't really
# go together.

module FighterValues
  BAMBOO_HEAD = { 'life' => 120, 'hit' => 9 }
  DEATH = { 'life' => 90, 'hit' => 13 }
  KOALA = { 'life' => 100, 'hit' => 10 }
  CHUCK_NORRIS = { 'life' => 60000, 'hit' => 99999999 }
  def chuck_fact
    puts "Chuck Norris' tears can cure cancer..."
    puts "Too bad he never cries."
  end
end

module ConstantValues
  DEATH = -5 # Pandas can live PAST DEATH.
  EASY_HANDICAP = 10
  MEDIUM_HANDICAP = 25
  HARD_HANDICAP = 50
end

puts FighterValues::DEATH
puts
puts ConstantValues::DEATH
