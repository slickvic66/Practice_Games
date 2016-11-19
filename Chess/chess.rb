# coding:UTF-8 vi:et:ts=2


# Refactors to consider -- Splitting class Chess up into Class Board and Class Game.  Board builds the board and places the pieces.  Game plays the game and looks for checks and checkmates. 

# Due to a poor initial design choice -- making the instance variable @board a hash within the huge Chess class -- refactoring this will be a large pain, because it will require changing the way board is accessed, accross the, well, board.  Welp, there goes modularity... 

class Chess
  attr_reader :board, :current_player

  def initialize
    @board = {}
    @player1 = User.new("white")
    @player2 = User.new("black")
    @current_player = @player1
  end

  def print_board
    puts
    print "  "
    ("a".."h").each {|ltr| print "  #{ltr}"}
    puts
    print "   "
    8.times { print "___"}
    puts
    puts
    8.downto(1).each do |row|
      print "#{row}|"
      (1..8).each do |column|
        if @board[[row,column]].piece
          print "  #{@board[[row,column]].piece.symbol}"
        else
          print "  ▢"
        end
      end
      print "\n"
    end
  end

  def create_board
    squares_to_board
    ["white","black"].each {|color| set_pieces(color)}
    print_board
  end

   # Side effect of setting pieces to their starting positions
  def set_pieces(color)

    row = (color == "white" ? 2 : 7)
    # Pawns
    (1..8).each do |column|
      tile = @board[[row,column]]
      tile.place_piece(Pawn.new(color, [row, column]))
    end

    row = (color == "white" ? 1 : 8) 
    # Rooks
    [1,8].each do |column|
      tile = @board[[row, column]]
      tile.place_piece(Rook.new(color, [row, column]))
    end

    # Knights
    [2,7].each do |column|
      tile = @board[[row, column]]
      tile.place_piece(Knight.new(color, [row, column]))
    end

    # Bishops
    [3,6].each do |column|
      tile = @board[[row, column]]
      tile.place_piece(Bishop.new(color, [row, column]))
    end

    # King
      tile = @board[[row, 4]]
      tile.place_piece(King.new(color, [row, 4]))

    # Queen
      tile = @board[[row, 5]]
      tile.place_piece(Queen.new(color, [row, 5]))
  end

  def locations_list
    locations = []
    8.downto(1).each do |row|
      (1..8).each do |column|
        locations << [row,column]
      end
    end

    locations
  end

  # Side effect is that @board now has square objects
  def squares_to_board
    locations_list.each do |location|
      @board[location] = Square.new(location)
    end
  end

  def play
    create_board
    move_count = 1

    while move_count
      # Switches between players
      checked = false
      @current_player = (move_count % 2 == 0 ? @player2 : @player1)
      puts "\n#{@current_player.color.capitalize}'s Turn:"

      if in_check? 
        checked = true 

        if in_checkmate?
          puts "GAME OVER #{current_player.color.capitalize} is in Checkmate"
          return
        end
        puts "#{current_player.color.capitalize} IN CHECK!"
      end

      begin_at, end_at = @current_player.get_move

      # Is there a piece at 'begin_at'?
      if @board[begin_at].piece

        #Does piece belong to current player?
        if @board[begin_at].piece.color == @current_player.color

          # Is move valid?
          if @board[begin_at].piece.move?(end_at, @board)

            # Pick up piece 
            picked_up = @board[begin_at].piece.pick_up(begin_at, @board)

            # For king or if player is in check before starting move.# Move must be validated after completion. 
            if picked_up.class == King || checked == true
              picked_up.re_place(begin_at, @board)
              move_sequence(begin_at, end_at)
              if in_check?
                puts "\nTHAT MOVE WOULD PUT YOU IN CHECK -- Try Again"
                move_sequence(end_at, begin_at)
                print_board
                next
              end
                # Move stands
                move_count += 1
                print_board
                next
            end

            # Does removing piece result in check to @current_player?
            if in_check?
              picked_up.re_place(begin_at, @board)
              puts "\n THAT MOVE WOULD PUT YOU IN CHECK -- Try Again"
              print_board
              next
            end

            # If not, move piece
            picked_up.re_place(begin_at, @board)
            move_sequence(begin_at, end_at)

          else
            puts "\nINVALID MOVE -- Please try again"
            print_board
            next
          end

        else
          puts "\nNOT YOUR PIECE -- Please try again"
          print_board
          next
        end
      else
        puts "\nNO PIECE TO MOVE AT THAT SQUARE -- Please try again."
        print_board
        next
      end
      move_count += 1
      print_board
    end

  end

  def in_check?
    my_pieces = current_pieces
    their_pieces = opposite_pieces(my_pieces)
    king_coords = my_pieces.select{|piece| piece.class == King}[0].coordinates
    opponent_possibles = get_possibles(their_pieces)
    return true if opponent_possibles.include?(king_coords)

    false
  end

  # Make valid moves until there are none to be made or one produces a value that is not in check
  def in_checkmate?
    my_pieces = current_pieces

    until my_pieces.empty?
      piece = my_pieces.shift
      start_at = piece.coordinates

      piece.valid_moves(@board).each do |coords|
        move_sequence(start_at, coords)
        if in_check?
          # Move it back and continue checking
          move_sequence(coords, start_at)
          next
        else
          # Move it back and continue the game 
          move_sequence(coords, start_at)
          return false
        end
      end
    end

    true
  end

  def get_possibles(pieces)
    all_possibles = []
    pieces.each do |piece|
      all_possibles += piece.valid_moves(@board)
    end

    all_possibles
  end

  # Returns array of piece objects of current_player color
  def current_pieces
    pieces = []
    @board.values.select{|tile| tile.piece && tile.piece.color == @current_player.color}.each do |tile|
        pieces << tile.piece
      end

    pieces
  end

  # Returns array of piece objects of non-current_player color
  def opposite_pieces(currents)
    pieces = []
    @board.values.select{|tile| tile.piece && !currents.include?(tile.piece)}.each do |tile|
        pieces << tile.piece
      end

    pieces
  end

  def move_sequence(mv_from, mv_to)
    @board[mv_from].piece.move(mv_to, @board)
    @board[mv_from].remove_piece
  end


  def savegame
  end
end

class Square
  attr_reader :piece, :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
    @piece = nil
  end

  def place_piece(piece)
    @piece = piece
  end

  def remove_piece
    @piece = nil
  end
end

class Piece
  JUMPINGMOVES = {
  "king_moves" => [[1,1],[1,0],[1,-1],[0,-1],[0,1],[-1,1],[-1,0],[-1,-1]],
  "knight_moves" => [[2, 1],[2, -1],[-2, 1],[-2,-1],[1, 2],[1, -2],[-1, 2],[-1,-2]] }

  attr_reader :color, :symbol, :moved, :coordinates

  def initialize(color, coordinates)
    @coordinates = coordinates
    @moved = false
    @color = color
    @symbol = @color == "white" ? symbols[0] : symbols[1]
  end

  def move(target, board)
    @coordinates = target
    @moved = true
    board[target].place_piece(self)
  end

  def pick_up(from_tile, board)
    @coordinates = nil
    board[from_tile].remove_piece

    self
  end

  # Just like .move except it doesn't change the @moved attribute
  def re_place(target, board)
    @coordinates = target
    board[target].place_piece(self)
  end


  def move?(target, board)
    valid_moves(board).include?(target)
  end

  def valids_rook(board)
    start = @coordinates
    valids = []
    directions = [1,-1]

    directions.each do |direction|
    
      # builds valid path up and down (add/subtract rows)
      1.upto(7) do |i|
        i = i * direction
        new_coords = [(start[0]+i), start[1]]

        if board.has_key?(new_coords) # Coords exist on board
          if board[new_coords].piece == nil # Empty square
            valids << new_coords
          elsif board[new_coords].piece.color == self.color
            break
          else # Has a piece of opposite color
            valids << new_coords
            break
          end
        end
      end

      1.upto(7) do |i|
        i = i * direction
        new_coords = [start[0], (start[1]+i)]

        if board.has_key?(new_coords)
          if board[new_coords].piece == nil
            valids << new_coords
          elsif board[new_coords].piece.color == self.color
            break
          else
              valids << new_coords
              break
          end
        end
      end

    end

    valids
  end

  def valids_bishop(board)
    start = @coordinates
    valids = []
    directions = [1,-1]

    directions.each do |direction|

      # builds left to right diagonal
      1.upto(7) do |i|
        i = i * direction
        new_coords = [(start[0]+i), (start[1]+i)]

        if board.has_key?(new_coords) # Coords exist on board
          if board[new_coords].piece == nil # Empty square
            valids << new_coords
          elsif board[new_coords].piece.color == self.color
            break
          else # Has a piece of opposite color
            valids << new_coords
            break
          end
        end
      end

      # builds right to left diagonal
      1.upto(7) do |i|
        i = i * direction
        new_coords = [(start[0]-i), (start[1]+i)]

        if board.has_key?(new_coords) # Coords exist on board
          if board[new_coords].piece == nil # Empty square
            valids << new_coords
          elsif board[new_coords].piece.color == self.color
            break
          else # Has a piece of opposite color
            valids << new_coords
            break
          end
        end
      end
    end

    valids
  end

  # Default for jumping pieces
  def valid_moves(board)
    valids = []
    constant = JUMPINGMOVES[self.class.to_s.downcase + "_moves"]

      valids = constant.map do |coord|
        x = coord[0] + @coordinates[0]
        y = coord[1] + @coordinates[1]
        [x, y]
      end

    # Select only moves that are on the board  
    valids.select! { |valid| (1..8).include?(valid[0]) && (1..8).include?(valid[1]) }

    # Remove any moves that kill friendly pieces
    valids = valids - valids.select{|v| board[v].piece && board[v].piece.color == self.color}

    valids
  end

end

class Pawn < Piece

  def symbols
    ["♟", "♙"]
  end

  def valid_moves(board)
    valids = []

    if color == "white"
      shift = [1, 2]
    else
      shift = [-1, -2]
    end

    diagonal_squares = [
      [(@coordinates[0]+shift[0]), (@coordinates[1]+shift[0])],
      [(@coordinates[0]+shift[0]), (@coordinates[1]-shift[0])]
    ]

    # Straight moves
    if moved == false
      shift.each do |i| 
        new_coords = [(@coordinates[0]+i), @coordinates[1]]
        if board[new_coords].piece 
          break
        else
          valids << new_coords
        end
      end
    
    else 
      new_coords = [(@coordinates[0]+shift[0]),@coordinates[1]]
      valids << new_coords if board[new_coords].piece == nil
    end

    # Check for opposite color pieces on the sides and add to valid moves if there are
    diagonal_squares.select! do |coords| 
      board.has_key?(coords) && board[coords].piece
    end
    unless diagonal_squares.empty? 
      diagonal_squares.each do |coords|
        unless board[coords].piece.color == color
          valids << coords
        end
      end
    end

    valids
  end

end

class Rook < Piece
  def symbols
    ["♜", "♖"]
  end

  def valid_moves(board)
    valids_rook(board)
  end
end


# Has its own valid moves method because its a sliding piece
class Bishop < Piece
  def symbols
    ["♝", "♗"]
  end

  def valid_moves(board)
    valids_bishop(board)
  end

end

class Knight < Piece

  def symbols
    ["♞", "♘"]
  end

end

class King < Piece

  def symbols
    ["♛", "♕"]
  end

end

class Queen < Piece
  def symbols
    ["♚", "♔"]
  end

  def valid_moves(board)
    valids_rook(board) + valids_bishop(board)
  end

end

class User
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def get_move
    move_set = []
    column_letters = %w(a b c d e f g h)
    column_ref = {}
    column_letters.each_with_index {|ltr, i| column_ref[ltr] = i+1}

    puts "Select tile to move from (ex: a2):"
    temp = gets.chomp.split("")
    move_set << [(temp[1].to_i), column_ref[temp[0]]]

    puts "Select tile to move to (ex: a3):"
    temp = gets.chomp.split("")
    move_set << [(temp[1].to_i), column_ref[temp[0]]]
  end

end


