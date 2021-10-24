# frozen_string_literal: true

# Controls the chess board
class Board
  TOP_ROW = '╭┈╔═╤═╤═╤═╤═╤═╤═╤═╗'.freeze
  INTER_ROW = '┊ ╟─┼─┼─┼─┼─┼─┼─┼─╢'.freeze
  END_ROWS = "┊ ╚═╧═╧═╧═╧═╧═╧═╧═╝\n╰┈┈a┈b┈c┈d┈e┈f┈g┈h╯".freeze

  def initialize
    @board = create_board
  end

  def create_board(board = Array.new)
    board.push(['♖', '♘', '♗', '♕', '♔', '♗', '♘', '♖'], ['♙', '♙', '♙', '♙', '♙', '♙', '♙', '♙'])
    4.times { board.push([' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']) }
    board.push(['♟', '♟', '♟', '♟', '♟', '♟', '♟', '♟'], ['♜', '♞', '♝', '♛', '♚', '♝', '♞', '♜'])
  end

  def display_board
    puts TOP_ROW
    display_mid_rows
    puts END_ROWS
  end

  def display_mid_rows(row_num = 8)
    @board.each do |row|
      display_num_rows(row, row_num)
      puts INTER_ROW unless row_num == 1
      row_num -= 1
    end
  end

  def display_num_rows(row, row_num)
    output = ["#{row_num} ║"]
    row.each_with_index do |piece, index|
      index < 7 ? output.push("#{piece}│") : output.push("#{piece}║\n")
    end
    output.each { |section| print section }
  end
end
