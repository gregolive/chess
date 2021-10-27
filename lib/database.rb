# frozen_string_literal: true

# Save and load gamefiles
module Database
  def save_game
    game_data = to_yaml
    create_file(game_data)
    exit
  end

  def to_yaml
    YAML.dump({
                board: @board,
                player1: @player1,
                player2: @player2,
                turn: @turn,
                check: @check
              })
  end

  def create_file(data)
    Dir.mkdir('saved') unless Dir.exist?('saved')
    filename = "saved/#{create_filename}.yml"
    File.open(filename, 'w') do |file|
      file.puts data
    end
  end

  def create_filename
    puts 'Enter save file name.'
    filename = gets.chomp
    while saved_games.include?(filename) || !filename.match?(/^[a-zA-Z\d ]*$/i)
      puts "\e[31mThis filename is taken or includes invalid characters. Please enter a new name.\e[0m"
      filename = gets.chomp
    end
    filename
  end

  def load_game
    filename = ask_filename
    load_save_file(filename)
    play
  end

  def ask_filename
    puts "\n\e[33mSave files:\e[0m\n"
    puts files = saved_games
    puts "\nChoose a save file to load."
    filename = gets.chomp
    until files.include?(filename)
      puts "\e[31mFile not found. Please enter a valid filename.\e[0m"
      filename = gets.chomp
    end
    filename
  end

  def saved_games
    files = []
    Dir.glob('./saved/*').each { |file| files.push(file[0...-4][8..-1]) }
    files
  end

  def load_save_file(string)
    data = YAML.load_file("./saved/#{string}.yml")
    begin
      pull_data(data, string)
    rescue StandardError
      puts "\e[31m\nERROR: This save file can't be loaded. Please select a different file.\e[0m"
      load_game
    end
  end

  def pull_data(data, string)
    @board = data[:board]
    @player1 = data[:player1]
    @player2 = data[:player2]
    @turn = data[:turn]
    @check = data[:check]
    @file = "./saved/#{string}.yml"
  end
end
