require 'debugger'

class Minesweeper
  attr_reader :board

  def initialize(board_size=9, bomb_count=10)
    @board_size = board_size
    # puts "before"
    @board = create_board(@board_size)
    # puts "after"
    @bomb_count = bomb_count
  end

  def play
#    debugger
    populate_board

    # Place bombs
    place_bombs

    # print_board_mark

    # Get the human's move
    get_move

  #  print_board_adjacent

  #  print_board_row_col
  #  print_board_num_bombs

    return nil

  end

  def get_move
    print_board_mark

    puts "Give us a move similar to: F 1 1"
    input = gets.chomp.downcase.split
    command = input[0]
    row = input[1].to_i
    col = input[2].to_i

    square = @board[row][col]

    case command
    when "r"
      if square.bomb?
        # lose
        puts "YOU LOSE!!!!!"
        return
      else
        reveal(square)
      end
    when "f"
      square.place_flag
    end
    print_board_mark
  end

  # This method assumes the square is not a bomb
  def reveal(square)
    # p square
    # If there are adjacent bombs, we just show the number/count
    if square.num_adjacent_bombs != 0
      # Set square's mark to the number of adjacent bombs
      square.mark = square.num_adjacent_bombs.to_s
      square.revealed = true
      puts "#{square.mark}"
      return
    end

    # do nothing if it's a bomb
    return if square.bomb?

    # Set the square to 0 or Blank (in user view)
    # square.mark = 0
    square.mark = 0.to_s
    square.revealed = true
    puts "#{square.mark}"


    # We have to interrogate the square's adjacent neighbors
    square.adjacent_coordinates.each do |square_coord|
      #unless @board[row][col].revealed == true

      row, col = square_coord
      puts "Working on: #{square_coord}"
      reveal(@board[row][col])
    end
  end

  def create_board(board_size)
    board = []
    @board_size.times do
      board << Array.new(board_size)
    end
    board
  end

  def populate_board
    @board.each_with_index do |row, row_index|
      row.each_with_index do |square_obj, col_index|
        square_obj = Square.new(@board)
        square_obj.row = row_index
        square_obj.col = col_index
        @board[row_index][col_index] = square_obj
      end
    end
  end

  def print_board_mark
    puts "This is the board:"
    puts "  0 1 2 3 4 5 6 7 8"

    @board.each_with_index do |row, index|
      print "#{index} "
      row.each do |square|
        print square.mark + " "
      end
      puts
    end
  end

  def print_board_row_col
    puts "This is the board:"
    puts "  0   1   2   3   4   5   6   7   8"

    @board.each_with_index do |row, index|
      print "#{index} "
      row.each do |square|
        print "[#{square.row }, #{square.col}] "
      end
      puts
    end
  end

  def print_board_adjacent
    puts "This is the board:"
    puts "  0   1   2   3   4   5   6   7   8"

    @board.each_with_index do |row, index|
      print "#{index} "
      row.each do |square|
        print "[#{square.adjacent_coordinates}, #{square.adjacent_coordinates}] "
      end
      puts
    end
  end

  def print_board_num_bombs
    puts "This is the board:"
    puts "  0 1 2 3 4 5 6 7 8"

    @board.each_with_index do |row, index|
      print "#{index} "
      row.each do |square|
        print square.num_adjacent_bombs + " "
      end
      puts
    end
  end

  def generate_bomb_coordinates(board_size, bomb_count)
    bomb_coordinates = []
    all_coordinates = []

    board_size.times do |row|
      board_size.times do |col|
        all_coordinates << [row, col]
      end
    end

    shuffled_coordinates = all_coordinates.shuffle
    bomb_count.times { bomb_coordinates << shuffled_coordinates.pop }

    p bomb_coordinates

    bomb_coordinates
  end

  def place_bombs
    bomb_coordinates = generate_bomb_coordinates(@board_size, @bomb_count)

    bomb_coordinates.each do |coordinate|
      row, col = coordinate
      @board[row][col].bomb = true
    end
  end

end


class Square
  attr_accessor :revealed, :bomb, :flagged, :mark, :row, :col, :board

  def initialize(board, mark="*")
    @board = board
    @row = nil
    @col = nil
    @flagged = false
    @revealed = false
    @bomb = false
    @mark = mark
  end

  def bomb?
    @bomb
  end

  def bomb=(bomb)
    @bomb = bomb
    @mark = "B"
  end

  def place_flag
    @flagged = !@flagged
    @mark = "F"
  end

  def num_adjacent_bombs
    num_adjacent_bombs = 0

    adjacent_coordinates.each do |adj_coord|
      adj_row, adj_col = adj_coord
      num_adjacent_bombs += 1 if @board[adj_row][adj_col].bomb?
    end

    num_adjacent_bombs
  end

  # def find_adjacent_coordinates
  def adjacent_coordinates
    adjacent_coordinates = []

    (@row-1..@row+1).each do |adj_row|
      (@col-1..@col+1).each do |adj_col|
        unless (adj_row < 0 || adj_col < 0 || adj_row > @board.size-1 || adj_col > @board.size-1 || [adj_row, adj_col] == [@row, @col])
          adjacent_coordinates << [adj_row, adj_col]
        end
      end
    end

    adjacent_coordinates
  end

end


#Scripts-----------------------------------------

game = Minesweeper.new(9,10)
game.play







  # def set_adjacent_neighbors
  #   @board.each_with_index do |row, row_index|
  #     row.each_with_index do |square_obj, col_index|
  #       adjacent_coordinates = find_adjacent_coordinates([row_index, col_index])
  #       adjacent_coordinates.each do |neighbor_coord|
  #         puts square_obj
  #         row, col = neighbor_coord
  #         square_obj.adjacent_squares << @board[row][col]
  #       end
  #     end
  #   end
  # end