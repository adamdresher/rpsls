require 'yaml'

MESSAGES = YAML.load_file('rpsls.yml')

VALID_CHOICES = %w(rock paper scissors lizard Spock)

RPSLS = [["Scissors", "cuts", "paper"],
         ["Paper", "covers", "rock"],
         ["Rock", "crushes", "lizard"],
         ["Lizard", "poisons", "Spock"],
         ["Spock", "smashes", "scissors"],
         ["Scissors", "decapitates", "lizard"],
         ["Lizard", "eats", "paper"],
         ["Paper", "disproves", "Spock"],
         ["Spock", "vaporizes", "rock"],
         ["Rock", "crushes", "scissors"]]

# Helper methods

def prompt(message)
  puts("==> #{MESSAGES[message]}")
end

def prompt_alt(message)
  puts("==> #{message}")
end

def empty_line
  puts()
end

def continue
  2.times { empty_line }
  prompt('continue')
  gets()
end

def clear_screen
  system('clear')
end

def display_instructions?
  prompt('instructions?')
  if gets.chomp.downcase.start_with?('y')
    empty_line
    prompt('instructions')
    RPSLS.each { |string| prompt_alt(string.join(' ') + ('.')) }
    continue
  end
end

def greetings
  empty_line
  prompt('hi')
  prompt('divider')
  empty_line
  prompt('game_rules')
  display_instructions?
  empty_line
  prompt('begin')
  sleep(0.7)
end

def check_name(input)
  if %w(spock spoc spo sp).any?(input.downcase)
    'Spock'
  else
    input.downcase
  end
end

def user_input
  input = nil
  loop do
    prompt_alt("Choose one: #{VALID_CHOICES.join(', ')}")
    input = check_name(gets.chomp)

    if input == ''
      prompt('invalid')
    elsif VALID_CHOICES.any? { |choice| choice.start_with?(choice) }
      input == 's' ? prompt('spock') : break
    else
      prompt('invalid')
    end
  end
  input
end

def complete_word!(user_choice)
  RPSLS.each do |phrase|
    if check_name(phrase[0]).start_with?(user_choice)
      user_choice.replace(check_name(phrase[0]))
    end
  end
  user_choice
end

def match?(first, second)
  RPSLS.each do |scenario|
    if check_name(scenario[0]).start_with?(first)\
    && scenario[2].start_with?(second)
      return scenario
    end
  end
  false
end

def display_match(user, computer)
  if match?(user, computer)
    match = match?(user, computer)
  elsif match?(computer, user)
    match = match?(computer, user)
  end
  match.join(' ').insert(-1, '.')
end

def display_match_winner(user, computer)
  empty_line
  prompt_alt("You chose: #{user}")
  prompt_alt("Computer chose: #{computer}\n\n")

  if match?(user, computer)
    prompt_alt(display_match(user, computer))
    prompt('users_match')
  elsif match?(computer, user)
    prompt_alt(display_match(computer, user))
    prompt('computers_match')
  else
    prompt('tie_match')
  end
  empty_line
end

def grand_winner?(user, computer)
  if user >= 3
    'user'
  elsif computer >= 3
    'computer'
  else
    continue
    false
  end
end

def display_grand_winner(player)
  if player
    continue
    clear_screen
    10.times { empty_line }
    prompt("#{player}_grand_win")
  end
end

# Program begins

greetings

loop do
  match = 0
  user = 0
  computer = 0

  loop do
    clear_screen
    match += 1
    prompt_alt("Match # #{match}  -  User: #{user}  /  Computer: #{computer}")
    prompt('divider')

    user_choice = complete_word!(user_input)
    computer_choice = check_name(VALID_CHOICES.sample)

    display_match_winner(user_choice, computer_choice)

    if match?(user_choice, computer_choice) then user     += 1 end
    if match?(computer_choice, user_choice) then computer += 1 end
    prompt_alt("The score is now:\n    user:  #{user}\
    computer:  #{computer}")

    winner = grand_winner?(user, computer)
    if winner
      display_grand_winner(winner)
      break
    end
  end

  prompt('replay?')
  replay = gets.chomp
  break unless replay.downcase.start_with?('y')
  prompt('replay')
end

prompt('goodbye')
