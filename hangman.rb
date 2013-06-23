require 'debugger'
require 'set'

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
			puts "Game status is: #{curr_board}"
			puts "You have #{turns_left} turns left."
			curr_guess = @guesser.make_guess(curr_board)
			reply_to_guess = @master.reply_to_guess(curr_guess)

			unless reply_to_guess.empty?
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

	def make_guess(board)
		guess = "invalid_guess"
		
		until guess =~ /^.{1}$/
			puts "Enter a single letter guess"
			guess = gets.chomp
		end
		guess
	end

	def word_length
		puts "Master, how long is the word you picked?"
		gets.chomp.to_i
	end

	def reply_to_guess(curr_guess)
		puts "The guess is #{curr_guess}"
		puts "reply with the comma separated indexes that this letter can be found at in your word"
		gets.chomp.split(",").map { |num| num.to_i }
	end
end

class ComputerPlayer

	attr_reader :dict_hash
	attr_accessor :picked_letters

	def initialize
		@picked_letters = []
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
		matching_positions
	end

	def reveal_word
		@chosen_word
	end

	def make_regex(curr_board)
		Regexp.new ("^" + curr_board.split("").map { |char| char == "_" ? "." : char }.join + "$")
	end

	def prune_dict(curr_board)
		unless @curr_dict
			read_dict
			@curr_dict = @dict_hash
		end
		@curr_dict.select! { |index, word| word =~ make_regex(curr_board) }
		p @curr_dict
		@curr_dict
	end

	def pick_letter
		freq = Hash.new { |hash, key| hash[key] = 0 }
		@curr_dict.values.each do |word|
			word.chars do |letter|
				freq[letter] += 1
			end
		end
		freq.reject! { |letter, count| @picked_letters.include?(letter) }
		freq.sort_by { |letter, count| count }.last[0]
	end

	def make_guess(curr_board)
		prune_dict(curr_board)
		guess = pick_letter
		@picked_letters << guess
		guess
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
	game = Hangman.new(
		master = HumanPlayer.new,
		guesser = ComputerPlayer.new
		)
	game.play_game
end