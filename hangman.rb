require 'yaml'

class GameFlow

    def initialize
        @secret_word = []
        @concealed_word = []
        @wrong_letters = []
        @attempts = 7
    end

    def game_start
        word_db = '5desk.txt'
        File.open(word_db, 'r') do |file|
            chosen = false
            words = file.readlines()
            while chosen == false    
                word = words[rand(0...words.size())].slice(0..-2)
                if word.length >= 5 and word.length <= 12
                    @secret_word = word.downcase.split('')
                    chosen = true
                end
            end
        end
                
        i = 0
        while i < @secret_word.length
            @concealed_word << '_'
            i += 1
        end

        puts 'game started'
        print "#{@concealed_word}\n"
    end

    def load_game
        load_files = YAML.load(File.read('saved_game.yml'))
        @secret_word = load_files[:secret]
        @concealed_word = load_files[:concealed]
        @wrong_letters = load_files[:wrong]
        @attempts = load_files[:attempts]
        puts 'game loaded, keep having fun'
        print "#{@concealed_word}\n"
        print "wrong letters: #{@wrong_letters}\n"
        print "attempts left: #{@attempts}\n"
    end

    def input_check(input)
        if input == '5'
            self.save_game

        else
            self.letter_check(input)
        end
    end

    def save_game
        data = { secret: @secret_word,
                 concealed: @concealed_word,
                 wrong: @wrong_letters,
                 attempts: @attempts }

        saved_data = 'saved_game.yml'
        File.open('saved_game.yml', 'w') do |file|
            file.write(data.to_yaml)
        end
        puts 'game saved'
        puts 'goodbye'
    end

    def letter_check(input)
        letter = input
        puts ''
        i = 0

        if @secret_word.any? { |char| char == letter }
            while i < @secret_word.length
                if letter == @secret_word[i]
                    @concealed_word[i] = @secret_word[i].upcase
                end
                i += 1
            end
        else
            @wrong_letters << letter.upcase
            @attempts -= 1
        end                

        puts %{#{@concealed_word}

    wrong letters: #{@wrong_letters}
        
    attempts left: #{@attempts}}
        puts ''

        if self.word_check
            return 'solved'
        end
    end

    def word_check
        @concealed_word.none? { |char| char == '_' }
    end

    def still_playing
        if @attempts > 0
            return true
        else
            puts 'game over'
            return false
        end
    end

end

puts %{Hangman in Ruby

You have 7 attempts to guess letters from a random word chosen among thousands of words.
Good luck... you're gonna need it.
}

hangman = GameFlow.new
continue = hangman.still_playing
puts 'load game? (y/n)'
to_load = gets.chomp
if to_load == 'y'
    hangman.load_game
else
    hangman.game_start
end

while continue == true
    puts 'say a letter, or save the game by pressing 5, then Enter'
    input = gets.chomp
    hangman.input_check(input)
    if input == '5'
        break
    end
    is_solved = hangman.word_check
    if is_solved
        puts 'solved!'
        break
    end
    continue = hangman.still_playing
    if continue == false
        break
    end    
end