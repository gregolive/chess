# frozen_string_literal: true

# Display output to the command line
module Display
  private

  def introduction
    puts <<~HEREDOC

      \e[33m♕ ♔ ♗ ♘ ♖ ♙ Ruby Chess ♟ ♜ ♞ ♝ ♚ ♛\e[0m

      Play classic chess against a friend or the computer.
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
  include Database
  include Display

  def initialize
    @checkmate = false
    introduction
    new_or_load
  end

  def new_or_load
    puts "Enter \e[33m'1'\e[0m to start a new game of chess or \e[33m'2'\e[0m to continue a saved game."
    game_mode == '1' ? new_game : load_game
  end

  def new_game
    puts "\e[36m\nNew Game\e[0m\nEnter \e[33m'1'\e[0m for 1 player game or \e[33m'2'\e[0m for 2 players."
    game_mode == '1' ? one_player : two_player
    @turn = @player1
    @board = Board.new(@player1, @player2)
    @check = false
    play
  end

  def one_player
    puts "\e[36m\nSingle Player\e[0m\nEnter \e[33m'1'\e[0m to play as white or \e[33m'2'\e[0m to play as black."
    game_mode == '1' ? player_white : player_black
  end

  def player_white
    @player1 = ask_name("You control the white pieces. Please enter your name:")
    @player2 = 'COMPUTER'
  end

  def player_black
    @player2 = ask_name("You control the black pieces. Please enter your name:")
    @player1 = 'COMPUTER'
  end

  def two_player
    @player1 = ask_name("\e[36m\nPlayer 1\e[0m controls the white pieces. Please enter your name:")
    @player2 = ask_name("\e[36mPlayer 2\e[0m controls the black pieces. Please enter your name:", true)
  end

  def game_mode
    input = gets.chomp
    while %w[1 2].include?(input) == false
      "\e[31mYou must enter '1' or '2'.\e[0m"
      input = gets.chomp
    end
    input
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
    puts "1) Enter the coordinates of the piece you wish to move or 'save' to save the game in progess:"
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
      save_game if @current_move == 'save'
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
    can_move?(piece) unless piece.nil?
  end

  def search_board
    piece = @board.find_piece(convert_coords(@current_move))
    return piece unless piece.nil? || piece[:owner] != @turn

    puts "\e[31mYou do not have a chess piece at #{@current_move}.\e[0m"
  end

  def can_move?(piece)
    return piece unless piece[:moves].empty?

    puts "\e[31mYour #{piece[:label]} cannot move.\e[0m"
  end

  def verify_end_coords
    return nil unless valid_coords

    valid_target?
  end

  def valid_target?
    move_coords = convert_coords(@current_move)

    return move_coords if @piece[:moves].include?(move_coords)
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
