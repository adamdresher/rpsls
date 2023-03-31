# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'
require 'pry'
require 'byebug'

configure do
  enable :sessions
  set :session_secret, '7444a1c99002fe7f03d719e47da9e5dcf46618d4026576b5f866c77f2f9ffecd'
end

def setup_game(rounds)
  session[:rounds] = {}
  (1..rounds.to_i).each { |round| session[:rounds][round] = "" } # fix the range here.  should be 'rounds'

  session[:players] = {}

  [:user, :computer].each do |player|
    session[:players][player] = {}
    session[:players][player][:moves] = []
    session[:players][player][:score] = 0
  end
end

def game_winner
  if game_started?
    session[:players].each do |player, records|
      return player if winner?(records)
    end
  end
end

def winner?(player)
  player_score = player[:score]

  return nil if player_score.zero?
  session[:rounds].size.divmod(player_score) == [2, 1]
end

get '/' do
  erb :index
end

get '/new_game' do
  setup_game(params[:rounds])

  redirect '/play'
end

get '/play' do
  erb :play
end

post '/play' do
  if game_winner
    # set flash message for game winner
    # redirect to '/winner'
  else
    # add user's move choice to records
    # select random choice for computer
    # add computer's choice to records
    session[:players][:user][:move] += params[:move]
    session[:players][:computer][:move] += computer_move

    # evaluate round's winner
    round_winner = "ROUND WINNER"

    # set flash message for winner
    session[:message] = "#{round_winner} has won this round!"
  end

  redirect '/play'
end

