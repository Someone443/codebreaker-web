class GameLogic

  DIFFICULTIES = ['easy', 'medium', 'hell'].freeze

  def initialize(request)
    @request = request
  end

  def home
    if session_present? && [:started, :win, :game_over].include?(state)
      Rack::Response.new { |response| response.redirect('/game') }
    else
      Rack::Response.new(render('menu.html.erb'))
    end
  end

  def start_game
    return Rack::Response.new { |response| response.redirect('/game') } if session_present?

    username = @request.params['player_name']
    level = @request.params['level']
    @game = CodebreakerSmn::Game.new
    unless @game.valid_name?(username) && DIFFICULTIES.include?(level)
      Rack::Response.new { |response| response.redirect('/') } # with_error
    else
      @game.username = username
      @game.set_difficulty(level)
      @game.start
      @request.session[:game] = @game
      Rack::Response.new { |response| response.redirect('/game') }
    end
  end

  def game
    return Rack::Response.new { |response| response.redirect('/') } unless session_present?

    case state
    when :started
      Rack::Response.new(render('game.html.erb'))
    when :win
      Rack::Response.new do |response|
        Statistics.save(high_scores, response) unless @request.cookies['stats_saved']
        response.redirect('/win') 
      end
    when :game_over
      Rack::Response.new { |response| response.redirect('/game-over') }
    end
  end

  def submit_answer
    answer = @request.params['number']
    result = @request.session[:game].guess_code(answer)
    Rack::Response.new do |response|
      response.set_cookie('result', result)
      response.redirect('/game')
    end
  end

  def show_hint
    Rack::Response.new do |response|
      response.set_cookie('hint', hint)
      response.redirect('/game')
    end
  end

  def win
    return Rack::Response.new { |response| response.redirect('/') } unless session_present?
    
    unless state == :win
      Rack::Response.new { |response| response.redirect('/game') }
    else
      Rack::Response.new(render('win.html.erb'))
    end
  end

  def game_over
    return Rack::Response.new { |response| response.redirect('/') } unless session_present?

    unless state == :game_over
      Rack::Response.new { |response| response.redirect('/game') }
    else
      Rack::Response.new(render('lose.html.erb'))
    end
  end

  def restart
    @request.session.clear
    Rack::Response.new do |response|
      response.delete_cookie('result')
      response.delete_cookie('hint')
      response.delete_cookie('stats_saved')
      response.redirect('/')
    end
  end

  def rules
    Rack::Response.new(render('rules.html.erb'))
  end

  def stats
    @request.session.clear
    Rack::Response.new(render('statistics.html.erb')) do |response|
      response.delete_cookie('result')
      response.delete_cookie('hint')
      response.delete_cookie('stats_saved')
    end
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def session_present?
    @request.session.key?(:game)
  end

  def state
    @request.session[:game].state
  end

  def username
    @request.session[:game].username
  end

  def difficulty
    @request.session[:game].difficulty
  end

  def attempts_left
    @request.session[:game].attempts
  end

  def hints_left
    @request.session[:game].hints
  end

  def result_array
    @request.cookies['result'] || ['x', 'x', 'x', 'x']
  end

  def hints_array
    @request.cookies['hint']
  end

  def code_text
    @request.session[:game].code.join
  end

  def hint
    @request.session[:game].get_hint
  end  

  def high_scores
    @request.session[:game].high_scores
  end  

  def statistics
    Statistics.load
  end
end
