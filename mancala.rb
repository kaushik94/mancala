require 'pp'
require 'pry'

class Player
  @number
  @score
  @human
  @engine
  @pits
  attr_reader :number, :human
  attr_accessor :score, :pits
  def initialize(player, engine=nil)
    if !engine
      @human = true
    else
      @human = false
      @engine = engine
    end
    @score = 0
    @number = player
    @pits = Array.new(6).map{|slot| slot = 3}
  end
  def [] n
    @pits[n]
  end
  def []= n, a
    @pits[n] = a
  end
end

class Mancala
  @p1
  @p2
  @gameover

  def initialize(num_players)
    # create the arrays and fill them in w/ proper # of pieces.
    @gameover = false
    num_players = num_players.to_i
    if num_players > 0
      @p1 = Player.new(1)
    else
      @p1 = Player.new(1, "dumb")
    end
    if num_players < 2
      @p2 = Player.new(2, "dumb")
    else
      @p2 = Player.new(2)
    end
  end

  def pick_pit(player)
    if player.human
      puts self
      puts "Player #{player.number}, enter your move!"
      move = gets.chomp!
      if move == "exit"
        puts "bye!"
        exit
      end
      move = move.to_i
      until 1.upto(6).include?(move)
        puts "Please enter an integer from 1-6:"
        move = gets.chomp!.to_i
      end
      until player[move-1] != 0
        puts "Don't pick an empty space! Pick again:"
        move = gets.chomp!.to_i
      end
    else
      # bot!
      # TODO abstract this out of here into the engine
      puts "The diabolical computer opponent is thinking..."
      move = 1 + rand(6)
    end
    return move
  end

  def move(player, opponent, pit)
    # going to be a value between 1 and numpieces
    puts "moving player #{player.number}'s pit \##{pit}\n"
    pit=pit.to_i
    remaining = player[pit-1]
    range = remaining
    player.pits[pit-1]=0
    player.pits[pit, remaining]=player.pits[pit, remaining].map!{|t| t += 1}
    # subtract the items you have dropped
    remaining = remaining - player[pit..-1].size
    if remaining > 0
      # then this goes around the board
      # put one in your home
      remaining -= 1
      player.score += 1
      if remaining > 0
        opponent.pits[0, remaining]=player.pits[0, remaining].map!{|t| t += 1}
      else
        unless player.pits.inject(:+) == 0
          puts "You get another turn!"
          move(player, opponent, pick_pit(player))
        end
      end
    else
      # ending on this side of the board... gotta check empty
      # going to be a 1 if capture, because you've already put down the rest of the pieces
      if player[pit+range-1] == 1
        puts "Empty! You capture!"
        player.score += opponent[-1 * (pit+range)]
        opponent.pits[-1 * (pit+range)] = 0
      end
    end
  end

  def game
    # this should be the game loop
    # you should check for moves, then check to see if game has ended
    player    = @p1
    opponent  = @p2

    until @gameover
      # prompt player
      move(player, opponent, pick_pit(player))
      @gameover = true if player.pits.inject(:+)==0 or opponent.pits.inject(:+)==0
      # switch positions
      player, opponent = opponent, player
    end
    # TODO refactor this
    if @p1.score > @p2.score
      puts "Player one wins with #{@p1.score} to #{@p2.score}!"
    else
      puts "Player two wins with #{@p2.score} to #{@p1.score}!"
    end
  end

  def to_s
    p1s = @p1.pits
    p2s = @p2.pits
    p1h_b = @p1.score.to_s
    p2h_b = @p2.score.to_s

    if p1h_b.size == 1 
      p1h_b = " " + p1h_b
    end
    if p2h_b.size == 1 
      p2h_b = " " + p2h_b
    end
    "        6 5 4 3 2 1  \n    +-----------------+\n    |  #{p2s[6]} #{p2s[5]} #{p2s[4]} #{p2s[3]} #{p2s[2]} #{p2s[1]} #{p2s[0]}   |\n  P2|#{p2h_b}            #{p1h_b} |P1\n    |   #{p1s[0]} #{p1s[1]} #{p1s[2]} #{p1s[3]} #{p1s[4]} #{p1s[5]} #{p1s[6]}  |\n    +-----------------+\n        1 2 3 4 5 6"
  end
end

puts ".  . .-. . . .-. .-. .   .-. \n |\/| |-| |\| |   |-| |   |-| \n'  ` ` ' ' ` `-' ` ' `-' ` ' "
puts "============================"
puts "How many human players? (0-2)"
num_players = gets.chomp!
until 0.upto(2).include?(num_players.to_i)
  puts "whoops, try again:\n"
  num_players = gets.chomp!
end
b = Mancala.new(num_players)
b.game
