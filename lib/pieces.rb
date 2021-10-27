# frozen_string_literal: true

# Track the chess pieces
class ChessPieces
  attr_accessor :all

  WHITE = ['♟', '♟', '♟', '♟', '♟', '♟', '♟', '♟', '♜', '♞', '♝', '♛', '♚', '♝', '♞', '♜'].freeze
  BLACK = ['♖', '♘', '♗', '♕', '♔', '♗', '♘', '♖', '♙', '♙', '♙', '♙', '♙', '♙', '♙', '♙'].freeze

  def initialize(player1, player2)
    @all = collect_pieces(player2, BLACK) + collect_pieces(player1, WHITE)
  end

  def collect_pieces(name, pieces, output = [])
    row = pieces == WHITE ? [6, 7] : [0, 1]
    pieces.each_with_index do |piece, index|
      location = index < 8 ? [row[0], index] : [row[1], (index - 8)]
      info = { label: piece, owner: name, location: location, moves: nil }
      output.push(info)
    end
    output
  end
end
