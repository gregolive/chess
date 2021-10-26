# frozen_string_literal: true

# Play a game of chess
class Game
  def initialize
    @check = false
    @checkmate = false
    play
  end

  def play
    introduction
    setup
    5.times { play_round }
  end

  def setup
    puts "\e[36mPlayer 1\e[0m controls the white pieces. Please enter your name:"
    @player1 = gets.chomp
    puts "\e[36mPlayer 2\e[0m controls the black pieces. Please enter your name:"
    @player2 = gets.chomp
    @turn = @player1
    @board = Board.new(@player1, @player2)
  end

  def play_round
    show_board
    ask_move
    @board.move_piece(@piece, @move_to)
    @turn = @turn == @player1 ? @player2 : @player1 unless @checkmate
    @board.update_moves
  end

  def show_board
    @board.display_board
    puts "\n\e[36m#{@turn}'s move.\e[0m\n"
  end

  def ask_move
    puts '1) Enter the column-row coordinates of the piece you wish to move:'
    @piece = player_move('start')
    puts '2) Enter the column-row coordinates to move the piece to:'
    @move_to = player_move('end')
  end

  def player_move(type)
    loop do
      @current_move = gets.chomp
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
    return piece if !piece.nil? && piece[:owner] == @turn

    puts "\e[31mYou do not have a chess piece at #{@current_move}.\e[0m"
  end

  def can_move?(piece)
    return piece unless piece[:moves].nil?

    puts "\e[31mYour #{piece[:label]} cannot move.\e[0m"
  end

  def verify_end_coords
    return nil unless valid_coords

    can_move_to
  end

  def can_move_to
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

  private

  def introduction
    puts <<~HEREDOC

      \e[33m♕ ♔ ♗ ♘ ♖ ♙ Ruby Chess ♟ ♜ ♞ ♝ ♚ ♛\e[0m

      Play classic chess against a friend or a computer.
      Take your opponent's king before they take yours! 👑

    HEREDOC
  end
end
