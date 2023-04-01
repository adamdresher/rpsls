# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'
require 'pry'
require 'byebug'

VALID_CHOICES = %w(rock paper scissors lizard spock)

RPSLS = ["Scissors cut paper",
         "Paper covers rock",
         "Rock crushes lizard",
         "Lizard poisons Spock",
         "Spock smashes scissors",
         "Scissors decapitate lizard",
         "Lizard eats paper",
         "Paper disproves Spock",
         "Spock vaporizes rock",
         "Rock crushes scissors"]

configure do
  enable :sessions
  set :session_secret, '7444a1c99002fe7f03d719e47da9e5dcf46618d4026576b5f866c77f2f9ffecd'
end

def setup_game
  session[:history] = []
  session[:current_round] = 0


  session[:players] = {}

  [:you, :computer].each do |player|
    session[:players][player] = {}
    session[:players][player][:moves] = []
    session[:players][player][:score] = 0
  end
end

def computer_move
  VALID_CHOICES.sample
end

def current_round_description
  user_move = session[:players][:you][:moves].last
  computer_move = session[:players][:computer][:moves].last

  RPSLS.each do |str|
    words = str.downcase.split
    return "It's a tie!" if user_move == computer_move
    return str if words.count(user_move) == 1 && words.count(computer_move) == 1
    # return str if [user_move, computer_move].all? { |player| words.include? player }
  end
end

def record_round_moves_and_description!
  session[:players][:you][:moves] << params[:move]
  session[:players][:computer][:moves] << computer_move
  session[:history][session[:current_round]] = current_round_description
end

def update_scores!(winner)
  session[:players][winner][:score] += 1
end

def determine_round_winner
  user_move = session[:players][:you][:moves].last
  computer_move = session[:players][:computer][:moves].last

  RPSLS.each do |str|
    words = str.downcase.split
    return :you if words.first == user_move && words.last == computer_move 
    return :computer if words.first == computer_move && words.last == user_move 
  end
  nil
end

def game_winner
  session[:players].each do |player, records|
    return player if winner?(records)
  end
  nil
end

def winner?(player)
  player_score = player[:score]
  winning_score = session[:winner_needs]

  player_score >= winning_score
end

def winning_message(player, round_or_game)
  if player == 'you'
    "You have won the #{round_or_game}!"
  else
    "The computer has won the #{round_or_game}!"
  end
end

get '/' do
  erb :index
end

get '/new_game' do
  session[:winner_needs] = (params[:rounds].to_i / 2) + 1
  setup_game

  redirect '/play'
end

get '/play' do
  erb :play
end

post '/play' do
  record_round_moves_and_description!
  session[:current_round] += 1
  winner = determine_round_winner
  update_scores!(winner) if winner
  if game_winner
    session[:message] = [winning_message(game_winner, 'game')]
    redirect '/winner'
  else
    session[:message] = [session[:history].last]
    session[:message] << "\n#{winning_message(winner, 'round')}" if winner
  end

  redirect '/play'
end

get '/winner' do
  erb :winner
end
