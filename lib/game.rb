# frozen_string_literal: true

# Display output to the command line
module Display
  private

  def introduction
    puts <<~HEREDOC

      \e[33m♕ ♔ ♗ ♘ ♖ ♙ Ruby Chess ♟ ♜ ♞ ♝ ♚ ♛\e[0m

      Play classic chess against a friend or a computer.
      Take your opponent's king before they take yours! 👑

    HEREDOC
  end

  def display_turn_info
    @board.display_board
    puts "\n\e[31mCHECK 😱\e[0m" if @check
    puts "\n\e[36m#{@turn}'s move.\e[0m\n"
  end

  def display_winner
    @board.display_board
    puts "\n\e[31mCHECKMATE 😵\e[0m"
    @turn = @turn == @player1 ? @player2 : @player1
    puts "\n\e[36m#{@turn} is the winner!\e[0m"
  end
end

# Check if a player is in check or checkmate
module CheckCheckmate
  def check?
    check = false
    attackers = @board.find_attackers(@turn)
    king = @board.find_king(@turn)
    attackers.each { |attacker| check = true if attacker[:moves].any?(king[:location]) }
    check
  end

  def checkmate?
    attacking = dangerous_attackers
    protectors = collect_protectors
    attacking.each { |attacker| @board.move_piece(attacker, attacker[:location]) }
    @board.update_moves
    protectors.empty? ? true : false
  end

  def dangerous_attackers(danger = [])
    attackers = @board.find_attackers(@turn)
    king = @board.find_king(@turn)
    attackers.each do |attacker|
      attacker[:moves].each { |move| danger.push(attacker) if move == king[:location] }
    end
    danger
  end

  def collect_protectors(protectors = [])
    defenders = @board.find_defenders(@turn)
    defenders.each do |defender|
      next if defender[:moves].empty?

      protectors = defending?(defender, protectors)
    end
    protectors.uniq
  end

  def defending?(defender, protectors)
    position = defender[:location]
    defender[:moves].each do |move|
      @board.move_piece(defender, move)
      @board.update_moves
      protectors.push(defender) unless check?
      @board.move_piece(defender, position)
      @board.update_moves
    end
    protectors
  end
end

# Play a game of chess
class Game
  include CheckCheckmate
  include Display

  def initialize
    @checkmate = false
    introduction
    new_or_load
  end

  def new_or_load
    puts "Enter '1' to start a new game of chess or '2' to continue a saved game."
    input = gets.chomp
    while %w[1 2].include?(input) == false
      puts error_message[0]
      input = gets.chomp
    end
    input == '1' ? new_game : load_game
  end

  def new_game
    @player1 = ask_name("\e[36mPlayer 1\e[0m controls the white pieces. Please enter your name:")
    @player2 = ask_name("\e[36mPlayer 2\e[0m controls the black pieces. Please enter your name:", true)
    @turn = @player1
    @board = Board.new(@player1, @player2)
    @check = false
    play
  end

  def play
    play_round until @checkmate
    display_winner
  end

  def ask_name(message, player2 = nil)
    puts message
    loop do
      input = gets.chomp
      input = empty?(input)
      input = same_as_p1?(input) unless player2.nil?
      return input unless input.nil?
    end
  end

  def empty?(input)
    return input unless input == ''

    puts "\e[31mPlease enter your name.\e[0m"
  end

  def same_as_p1?(input)
    return input unless input == @player1

    puts "\e[31mName must be different than player 1.\e[0m"
  end

  def play_round
    display_turn_info
    make_move
    prepare_next_turn
  end

  def prepare_next_turn
    @turn = @turn == @player1 ? @player2 : @player1
    @check = check?
    @checkmate = checkmate? if @check
  end

  def make_move
    ask_move
    refresh_board
    double_check
  end

  def ask_move
    puts '1) Enter the column-row coordinates of the piece you wish to move:'
    @piece = player_move('start')
    @move_from = @piece[:location]
    puts "2) Enter the coordinates to move #{@piece[:label]} to or 'back' to change piece:"
    @move_to = player_move('end')
  end

  def refresh_board(move = @move_to)
    @board.move_piece(@piece, move)
    @board.update_moves
  end

  def double_check
    return unless check?

    puts "\e[31mInvalid move: #{@piece[:label]} to '#{@current_move}'. You'll be in check. Try again.\e[0m"
    refresh_board(@move_from)
    make_move
  end

  def player_move(type)
    loop do
      @current_move = gets.chomp
      ask_move if @current_move == 'back' && type == 'end'
      verified_move = type == 'start' ? verify_start_coords : verify_end_coords
      return verified_move if verified_move
    end
  end

  def valid_coords
    alph = ('a'..'h').to_a
    num = ('1'..'8').to_a
    if @current_move.length == 2 && alph.include?(@current_move.chr) && num.include?(@current_move.reverse.chr)
      return true
    end

    puts "\e[31mPlease enter the proper column-row coordinates. Example: 'g2'.\e[0m"
  end

  def verify_start_coords
    return nil unless valid_coords

    piece = search_board
    return piece unless piece.nil? || piece[:moves].empty?

    puts "\e[31mYour #{piece[:label]} cannot move.\e[0m"
  end

  def search_board
    piece = @board.find_piece(convert_coords(@current_move))
    return piece if !piece.nil? && piece[:owner] == @turn

    puts "\e[31mYou do not have a chess piece at #{@current_move}.\e[0m"
  end

  def verify_end_coords
    return nil unless valid_coords

    end_coords = convert_coords(@current_move)
    return end_coords if @piece[:moves].include?(end_coords)

    puts "\e[31mYou cannot move #{@piece[:label]} to #{@current_move}.\e[0m"
  end

  def convert_coords(player_input)
    alph = ('a'..'h').to_a
    player_input.chr
    col = alph.find_index(player_input.chr)
    row = (player_input.reverse.chr.to_i - 8).abs
    [row, col]
  end
end
