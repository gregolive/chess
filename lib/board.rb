# frozen_string_literal: true

require_relative '../lib/pieces'

# Controls the chess board
class Board
  TOP_ROW = '╭┈╔═╤═╤═╤═╤═╤═╤═╤═╗'
  INTER_ROW = '┊ ╟─┼─┼─┼─┼─┼─┼─┼─╢'
  END_ROWS = "┊ ╚═╧═╧═╧═╧═╧═╧═╧═╝\n╰┈┈a┈b┈c┈d┈e┈f┈g┈h╯"

  def initialize(player1, player2)
    @pieces = CHESS_PIECES.new(player1, player2)
    p @board = create_board
    # @pieces.update_moves
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
