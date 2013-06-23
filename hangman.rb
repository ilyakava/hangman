require 'debugger'

class Hangman

	def initialize(
		master = ComputerPlayer.new,
		guesser = HumanPlayer.new
		)
		@master = master
		@guesser = guesser
	end

	def play_game
		curr_board = make_board(@master.word_length)
		turns_left = 7

		while curr_board.include?("_") && turns_left > -1
			puts "You have #{turns_left} turns left. Game status: #{curr_board}"
			curr_guess = @guesser.make_guess
			reply_to_guess = @master.reply_to_guess(curr_guess)

			if reply_to_guess
				curr_board = update_board(curr_board, curr_guess, reply_to_guess)
			else
				turns_left -= 1
			end
		end

		if win?(curr_board)
			puts "The Guesser guessed the word!"
		else
			puts "Guesser looses. Master, what was the word?"
			puts "Master says the word was: #{@master.reveal_word}"

		end
	end

	def update_board(curr_board, curr_guess, reply_to_guess)
		reply_to_guess.each do |index|
			curr_board[index] = curr_guess
		end
		curr_board
	end


	def make_board(word_length)
		"_" * word_length
	end

	def win?(curr_board)
		!curr_board.include?("_")
	end

end

class HumanPlayer

	def make_guess
		guess = "invalid_guess"
		
		until guess =~ /^.{1}$/
			puts "Enter a single letter guess"
			guess = gets.chomp
		end
		guess
	end

end

class ComputerPlayer

	attr_reader :dict_hash

	def initialize
	end

	def choose_word
		read_dict
		@chosen_word = @dict_hash[rand(@dict_hash.length)]
	end

	def word_length
		choose_word
		@chosen_word.length
	end

	def reply_to_guess(letter)
		matching_positions = []
		@chosen_word.size.times do |letter_index|
			matching_positions << letter_index if @chosen_word[letter_index] == letter
		end
		matching_positions.empty? ? nil : matching_positions
	end

	def reveal_word
		@chosen_word
	end

	def read_dict(dictionary = './dictionary.txt', &block)
		block ||= Proc.new { |word| word }
		@dict_hash = Hash.new
		index = 0

		File.foreach(dictionary) do |word|
			((dict_hash[index] = word.chomp) && index += 1) if block.call(word.chomp)
		end
	end
end

if $0 == __FILE__
	game = Hangman.new
	game.play_game
end