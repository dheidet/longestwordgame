require 'open-uri'
require 'json'

class LongestwordsController < ApplicationController
  def game
    @grid = []
    15.times { @grid << ('A'..'Z').to_a.sample }
    @start_time = Time.now
  end

  def score
    @attempt = params[:attempt]
    @end_time = Time.now
    @grid = params[:grid]
    @start_time = Time.parse(params[:start_time])
    run_game(@attempt, @grid, @start_time, @end_time)
  end

  private

  def included_in_grid?(attempt, grid)
     # verifie que attempt est bien issu de grid
    puts attempt
    attempt.upcase.chars.each do |letter|
      if grid.count(letter) == 0 || attempt.chars.count(letter) > grid.count(letter)
       return false
      end
   end
   true
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    @result = {}
    translation_fr = nil
    user_score = 10
    user_message = ""
    data = ""
  #appel de methode time_calculation
    time_taken = (end_time - start_time)
    @result[:time] = time_taken.to_i

    api_url = "http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}"
    open(api_url) do |stream|
      data = JSON.parse(stream.read)
    end

    if included_in_grid?(attempt, grid)
      if data['term0'] != nil
        translation_fr = data['term0']['PrincipalTranslations']['0']['FirstTranslation']['term']
        user_score = attempt.length * 100 + 100 / time_taken.to_i
        user_message = "well done"
      else
        user_message = "not an english word"
        user_score = 0
      end
    else
      user_message = "not in the grid"
      user_score = 0
    end
    @result[:translation] = translation_fr
    @result[:score] = user_score
    @result[:message] = user_message
  end
end
