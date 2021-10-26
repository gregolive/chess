# frozen_string_literal: true

require_relative '../lib/pieces'

# Determine update moves on the board
module Moves
  def update_moves
    @board.each do |row|
      row.each do |piece|
        next if piece.nil?

        piece[:moves] = calculate_moves(piece)
      end
    end
  end

  def calculate_moves(piece)
    case piece[:label]
    when '♖', '♜'
      #puts 'rook'
    when '♘', '♞'
      #puts 'knight'
    when '♗', '♝'
      #puts 'bishop'
    when '♕', '♛'
      #puts 'queen'
    when '♔', '♚'
      #puts 'king'
    else
      pawn_moves(piece)
    end
  end
end

# Calculate possible moves for pawns
module PawnMoves
  def pawn_moves(piece, moves = [])
    moves.push(directly_forward(piece, 1))
    moves.push(directly_forward(piece, 2)) if first_move?(piece) && !moves[0].nil?
    diagonal_attack(piece).each { |move| moves.push(move) unless move.nil? }
    moves
  end

  def directly_forward(piece, dist)
    row = piece[:location].first
    col = piece[:location].last
    goal = piece[:label] == '♙' ? [(row + dist), col] : [(row - dist), col]
    return unless @board[goal[0]][goal[1]].nil?

    goal
  end

  def first_move?(piece, label = piece[:label], row = piece[:location].first)
    true if (label == '♙' && row == 1) || (label == '♟' && row == 6)
  end

  def diagonal_attack(piece)
    case piece[:label]
    when '♙'
      diagonal_moves(piece, 1)
    when '♟'
      diagonal_moves(piece, -1)
    end
  end

  def diagonal_moves(piece, row_dir, valid = [])
    row = piece[:location].first
    col = piece[:location].last
    moves = [[(row + row_dir), (col - 1)], [(row + row_dir), (col + 1)]]
    moves.each do |move|
      next if (move[0]).negative? || (move[1]).negative?

      target = @board[move[0]][move[1]]
      valid.push(move) if !target.nil? && target[:owner] != piece[:owner]
    end
    valid
  end
end

# Controls the chess board
class Board
  include PawnMoves
  include Moves

  TOP_ROW = '╭┈╔═╤═╤═╤═╤═╤═╤═╤═╗'
  INTER_ROW = '┊ ╟─┼─┼─┼─┼─┼─┼─┼─╢'
  END_ROWS = "┊ ╚═╧═╧═╧═╧═╧═╧═╧═╝\n╰┈┈a┈b┈c┈d┈e┈f┈g┈h╯"

  def initialize(player1, player2)
    @pieces = ChessPieces.new(player1, player2)
    @board = create_board
    update_moves
  end

  def create_board(board = [])
    board.push(@pieces.all[0..7]).push(@pieces.all[8..15])
    4.times { board.push([nil, nil, nil, nil, nil, nil, nil, nil]) }
    board.push(@pieces.all[16..23]).push(@pieces.all[24..31])
  end

  def display_board
    puts TOP_ROW
    display_mid_rows
    puts END_ROWS
  end

  def display_mid_rows(row_num = 8)
    @board.each do |row|
      display_num_row(row, row_num)
      puts INTER_ROW unless row_num == 1
      row_num -= 1
    end
  end

  def display_num_row(row, row_num)
    output = ["#{row_num} ║"]
    row.each_with_index do |piece, index|
      output.push(add_piece(piece, index))
    end
    output.each { |section| print section }
  end

  def add_piece(piece, index)
    if piece.nil?
      index < 7 ? ' │' : " ║\n"
    else
      index < 7 ? "#{piece[:label]}│" : "#{piece[:label]}║\n"
    end
  end

  def move_piece(piece, finish)
    start = piece[:location]
    @board[start[0]][start[1]] = nil
    @board[finish[0]][finish[1]] = piece
    @board[finish[0]][finish[1]][:location] = finish
    @board
  end

  def find_piece(coords)
    @pieces.all.each do |piece|
      return piece if piece[:location] == coords
    end
    nil
  end
end
