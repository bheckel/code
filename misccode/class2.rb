#!/bin/ruby -d

class Boogeyman
  MY_BOSS_CLASSANDINST_CONSTANT = 'Mr. Bogeyman'

  def initialize(name, location)
    # Hidden instance variables
    @name = name
    @location = location
    # Hidden class variables
    @@latest = @name
    @@location = @location

    puts "Yes, master?"
  end

  def change_location(newlocation)
    @location = newlocation

    puts "I moved to #{newlocation}!"
    self.get_info
  end

  def get_info
    puts "I am #{@name} in #{@location}."
  end

  # get (reader)
  def scare_factor
    @scare_factor
  end
  # set (writer)
  def scare_factor=(factor)
    @scare_factor = factor
  end
  # or if not messing with the received parm, just use
  ###attr_reader :scare_factor
  ###attr_writer :scare_factor

  private
    def phone_home(message)
      puts message
    end
  public  # change mode back to public
    def scare(who)
      phone_home("I just scared the living poop out of #{who}!")
    end

  def Boogeyman.latest_monster
    puts "The latest  monster is #{@@latest}."
    puts "He is in #{@@location}."
  end
end

monster1 = Boogeyman.new("Mister Creepy", "New York, NY")

monster1.change_location("Newark, NJ")

monster1.scare_factor = 666
puts monster1.scare_factor

monster1.scare('bob')

monster2 = Boogeyman.new("Gory Gary", "Seattle, WA")
Boogeyman.latest_monster
