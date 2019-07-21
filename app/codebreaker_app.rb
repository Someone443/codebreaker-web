require 'codebreaker_smn'
require 'pry'

require_relative 'game_logic'
require_relative 'helpers/statistics'

class CodebreakerApp

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @game_logic = GameLogic.new(@request)
  end

  def response
    case @request.path
    when '/' then @game_logic.home
    when '/start_game' then @game_logic.start_game
    when '/game' then @game_logic.game
    when '/submit_answer' then @game_logic.submit_answer
    when '/show_hint' then @game_logic.show_hint
    when '/win' then @game_logic.win
    when '/game-over' then @game_logic.game_over
    when '/restart' then @game_logic.restart
    when '/rules' then @game_logic.rules
    when '/stats' then @game_logic.stats
    else Rack::Response.new('Not Found', 404)
    end
  end
end
