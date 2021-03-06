# frozen_string_literal: true

# Determine update moves on the board
module Moves
  KING_QUEEN_MOVES = [[1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1], [1, 0]].freeze
  KNIGHT_MOVES = [[1, -2], [2, -1], [2, 1], [1, 2], [-1, 2], [-2, 1], [-2, -1], [-1, -2]].freeze
  BISHOP_MOVES = [[1, 1], [-1, 1], [1, -1], [-1, -1]].freeze
  ROOK_MOVES = [[1, 0], [-1, 0], [0, 1], [0, -1]].freeze

  def update_moves
    @board.each do |row|
      row.each do |piece|
        next if piece.nil?

        piece[:moves] = calculate_moves(piece).compact
      end
    end
  end

  def calculate_moves(piece)
    case piece[:label]
    when '♖', '♜'
      queen_rook_bishop_moves(piece, ROOK_MOVES)
    when '♘', '♞'
      king_knight_moves(piece, KNIGHT_MOVES)
    when '♗', '♝'
      queen_rook_bishop_moves(piece, BISHOP_MOVES)
    when '♕', '♛'
      queen_rook_bishop_moves(piece, KING_QUEEN_MOVES)
    when '♔', '♚'
      king_knight_moves(piece, KING_QUEEN_MOVES)
    else
      pawn_moves(piece)
    end
  end

  def generate_moves(location, moves)
    moves.map { |dir| [(location[0] + dir[0]), (location[1] + dir[1])] }
         .keep_if { |move| possible(move) }
  end

  def possible(move)
    move[0].between?(0, 7) && move[1].between?(0, 7) ? true : false
  end
end

# Calculate possible moves for rooks
module QueenRookBishopMoves
  def queen_rook_bishop_moves(piece, moves, valid = [])
    moves.each do |move|
      valid_moves = addup_moves(piece, move, piece[:location])
      valid_moves&.each { |valid_move| valid.push(valid_move) }
    end
    valid
  end

  def matching_coords(location, move)
    coords = [(location[0] + move[0]), (location[1] + move[1])]
    possible(coords) ? coords : nil
  end

  def addup_moves(piece, move, location = piece[:location], output = [])
    return unless possible(location)

    target_coords = matching_coords(location, move)
    return if target_coords.nil?

    target = @board[target_coords[0]][target_coords[1]]
    return if !target.nil? && target[:owner] == piece[:owner]

    output.push(target_coords)
    addup_moves(piece, move, target_coords, output) if target.nil?
    output
  end
end

# Calculate possible moves for kings and knights
module KingKnightMoves
  def king_knight_moves(piece, moves, valid = [])
    moves = generate_moves(piece[:location], moves)
    moves.each { |move| valid.push(valid_move(piece, move)) }
    valid
  end

  def valid_move(piece, move)
    target = @board[move[0]][move[1]]
    return move if target.nil? || target[:owner] != piece[:owner]
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
    return unless row.between?(0, 7)

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
    moves = generate_moves(piece[:location], [[row_dir, -1], [row_dir, 1]])
    moves.each { |move| valid.push(diagonal_valid(piece, move)) }
    valid
  end

  def diagonal_valid(piece, move)
    target = @board[move[0]][move[1]]
    return move if !target.nil? && target[:owner] != piece[:owner]
  end
end

# Controls the chess board
class Board
  attr_reader :board

  include KingKnightMoves
  include QueenRookBishopMoves
  include PawnMoves
  include Moves

  TOP_ROW = '╭┈╔═╤═╤═╤═╤═╤═╤═╤═╗'
  INTER_ROW = '┊ ╟─┼─┼─┼─┼─┼─┼─┼─╢'
  END_ROWS = "┊ ╚═╧═╧═╧═╧═╧═╧═╧═╝\n╰┈┈a┈b┈c┈d┈e┈f┈g┈h╯"

  def initialize(player1, player2)
    @board = create_board(player1, player2)
    update_moves
  end

  def create_board(player1, player2, board = [])
    pieces = ChessPieces.new(player1, player2).all
    board.push(pieces[0..7]).push(pieces[8..15])
    4.times { board.push([nil, nil, nil, nil, nil, nil, nil, nil]) }
    board.push(pieces[16..23]).push(pieces[24..31])
    board
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
  end

  def find_piece(coords)
    @board.flatten.each do |piece|
      next if piece.nil?

      return piece if piece[:location] == coords
    end
    nil
  end

  def find_attackers(player, attackers = [])
    @board.flatten.each { |piece| attackers.push(piece) unless piece.nil? || piece[:owner] == player }
    attackers
  end

  def find_king(player, king = nil)
    @board.flatten.each do |piece|
      next if piece.nil?

      king = piece if piece[:owner] == player && ['♔', '♚'].include?(piece[:label])
    end
    king
  end

  def find_defenders(player, defenders = [])
    @board.flatten.each { |piece| defenders.push(piece) unless piece.nil? || piece[:owner] != player }
    defenders
  end
end
