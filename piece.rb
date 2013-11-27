require_relative './board.rb'

class MethodUndefinedError < StandardError
end

class Piece
  attr_accessor :position, :color

  def initialize(position, color, board)
    @position, @color, @board = position, color, board
  end

  def remove
    @position = nil
  end


  def move(new_position)
    @position = new_position
  end

  def valid_moves
    raise MethodUndefinedError.new("valid_moves method not yet implemented")
  end

  def to_s
    raise MethodUndefinedError.new("to_s method not yet implemented")
  end

  def position_in_bounds?(pos)
    pos[0].between?(0,7) && pos[1].between?(0,7)
  end
end


class Pawn < Piece

  def initialize(position, color, board)
    super(position, color, board)
    determine_direction
  end

  def determine_direction
    @direction = @color == :b ? -1 : 1
  end

  def on_beginning_line?
    return true if @color == :b && @position[0] == 6
    return true if @color == :w && @position[0] == 1
    false
  end

  def valid_moves
    offsets = [[1,0], [1, -1], [1,1]]

    potential_moves = offsets.map! do |coord|
      [(coord[0] * @direction) + @position[0], (coord[1] + @position[1])]
    end

    potential_moves.select! { |coord| position_in_bounds?(coord) }

    all_valid_moves = []

    potential_moves.each_with_index do |move, index|
      current_piece = @board[move[0], move[1]]
      case index
      when 0
        all_valid_moves << move if current_piece.nil?
      else
        all_valid_moves << move if !current_piece.nil? && current_piece.color != @color
      end
    end
    all_valid_moves
  end

  def to_s
    "[P#{color}]"
  end

end


class SteppingPiece < Piece

  def valid_moves
    all_valid_moves = []

    offsets.each do |offset|

      prior_position = @position
      new_pos = [(prior_position[0] + offset[0]), (prior_position[1] + offset[1])]

      next unless position_in_bounds?(new_pos)

      current_piece = @board[new_pos[0], new_pos[1]]
      all_valid_moves << new_pos if current_piece.nil? || current_piece.color != self.color
    end
    all_valid_moves

  end

  def offsets
    raise "Not Yet Implemented"
  end

end

class King < SteppingPiece
  def offsets
    [ [1, 1], [-1, 1], [1, -1], [-1, -1], [1, 0], [-1, 0], [0, 1],  [0, -1] ]
  end

  def to_s
    "[K#{color}]"
  end

end

class Knight < SteppingPiece
  def offsets
    [ [1, 2], [-1, 2], [1, -2], [-1, -2], [2, 1], [-2, 1], [2, -1], [-2, -1] ]
  end

  def to_s
    "[N#{color}]"
  end
end


class SlidingPiece < Piece
  DIAGONAL_OFFSETS  = [[1, 1], [-1, 1], [1, -1], [-1, -1] ]
  HORIZVERT_OFFSETS = [[1, 0], [-1, 0], [0, 1],  [0, -1]  ]

  def offsets
    raise "Not Yet Implemented"
  end

  #this is all moves, regardless of other pieces on the board
  def valid_moves
    all_valid_moves = []

    offsets.each do |offset|
      prior_position = @position

      while true
        new_pos = [(prior_position[0] + offset[0]), (prior_position[1] + offset[1])]
        break unless position_in_bounds?(new_pos)
        current_piece = @board[new_pos[0], new_pos[1]]
        all_valid_moves << new_pos if current_piece.nil? || current_piece.color != self.color
        break if !current_piece.nil?
        prior_position = new_pos
      end
    end
    all_valid_moves
  end
end

class Rook < SlidingPiece

  def offsets
    HORIZVERT_OFFSETS
  end

  def to_s
    "[R#{color}]"
  end

end

class Queen < SlidingPiece

  def offsets
    HORIZVERT_OFFSETS + DIAGONAL_OFFSETS
  end

  def to_s
    "[Q#{color}]"
  end

end

class Bishop < SlidingPiece

  def offsets
    DIAGONAL_OFFSETS
  end

  def to_s
    "[B#{color}]"
  end

end



b = Board.new
rook = Rook.new([4,3], :b, b)
b[4, 3] = rook

rook2 = Rook.new([6, 4], :b, b)
b[6,4] = rook2


#
b.render_grid
#
piece = Pawn.new([6, 5], :b, b)
b[6, 5] = piece

puts
puts
b.render_available_moves(piece)

puts piece.on_beginning_line?
# puts p.class
# p.valid_moves