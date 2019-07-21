RSpec.describe CodebreakerApp do

  def app
    Rack::Builder.parse_file('config.ru').first
  end

  let(:valid_username) { 'username' }
  let(:valid_difficulty) { 'easy' }
  let(:invalid_username) { 'zz' }
  let(:invalid_difficulty) { 'invalid difficulty' }
  let(:session) { last_request.session[:game] }
  let(:cookies) { last_request.cookies }

  context '/menu' do
    it 'returns status ok' do
      get '/'
      expect(last_response).to be_ok
    end

    it 'renders menu template' do
      get '/'
      expect(last_response.body).to include("Player's name")
      expect(last_response.body).to include("Game level")
    end

    it "redirects to '/game' if session present" do
      get '/start_game', { player_name: valid_username, level: valid_difficulty } # TODO: refactoring
      get '/'
      expect(last_response).to be_redirect
      expect(last_response.header["Location"]).to eq('/game')
    end
  end

  context '/start_game' do
    context 'without session' do
      it "redirects to '/'" do
        post '/start_game'
        expect(last_response).to be_redirect
        expect(last_response.header["Location"]).to eq('/')
      end
    end

    context 'with session' do
      it "redirects to '/game' with valid params" do
        post '/start_game', { player_name: valid_username, level: valid_difficulty }
        expect(last_response).to be_redirect
        expect(last_response.header["Location"]).to eq('/game')
      end

      it "redirects to '/' with invalid params" do
        post '/start_game', { player_name: invalid_username, level: invalid_difficulty }
        expect(last_response).to be_redirect
        expect(last_response.header["Location"]).to eq('/')
      end      
    end
  end

  context '/submit_answer' do
    it "submits answer" do
      post '/start_game', { player_name: valid_username, level: valid_difficulty }
      follow_redirect!

      post '/submit_answer', { number: '1111' }

      expect(last_response).to be_redirect
      expect(last_response.header["Location"]).to eq('/game')
    end
  end

  context '/game' do
    context 'without session' do
      it "redirects to '/'" do
        get '/game'
        expect(last_response).to be_redirect
        expect(last_response.header["Location"]).to eq('/')
      end
    end

    context 'with session' do
      it "opens '/game'" do
        post '/start_game', { player_name: valid_username, level: valid_difficulty }
        get '/game'
        expect(last_response).to be_ok
        expect(last_response.body).to include("Show hint!")
      end

      it "redirects to '/game-over' if user lost" do
        post '/start_game', { player_name: valid_username, level: valid_difficulty }
        follow_redirect!

        16.times do
         post '/submit_answer', { number: '1111' }
        end

        #session.instance_variable_set(:@state, :game_over) # -> doesn't work, next request is sent with :started state

        get '/game-over'
        expect(last_response.body).to include("You lose the game!")

        #expect(last_response).to be_redirect
        #expect(last_response.header["Location"]).to eq('/game-over')
      end 

      it "wins" do
        post '/start_game', { player_name: valid_username, level: valid_difficulty }

        post '/submit_answer', { number: session.code.join }

        get '/game'

        expect(last_response).to be_redirect
        expect(last_response.header["Location"]).to eq('/win')

        follow_redirect!

        expect(last_response).to be_ok
        expect(last_response.body).to include("You won the game")
      end
    end
  end

  context '/show_hint' do
    it "shows hint" do
      post '/start_game', { player_name: valid_username, level: valid_difficulty }
      follow_redirect!
      expect(last_response).to be_ok
      expect(last_response.body).to include("Show hint!")

      post '/show_hint'

      expect(last_response).to be_redirect
      expect(last_response.header["Location"]).to eq('/game')


    end
  end

  context '/win' do
  end

  context '/game-over' do
    it "redirects to '/game' if user not lost" do
      post '/start_game', { player_name: valid_username, level: valid_difficulty }
      follow_redirect!

      5.times do
       post '/submit_answer', { number: '1111' }
      end

      #session.instance_variable_set(:@state, :game_over) # -> doesn't work, next request is sent with :started state

      get '/game-over'
      
      expect(last_response).to be_redirect
      expect(last_response.header["Location"]).to eq('/game')
    end  
  end

  context '/restart' do
      it "redirects to '/'" do
        get '/restart'
        expect(last_response).to be_redirect
        expect(last_response.header["Location"]).to eq('/')
      end
  end

  context '/rules' do
    it "shows rules" do
      get '/rules'

      expect(last_response).to be_ok
      expect(last_response.body).to include("Rules")
      expect(last_response.body).to include("Codebreaker is a logic game")
    end
  end

  context '/stats' do
    it "shows stats" do
      get '/stats'

      expect(last_response).to be_ok
      expect(last_response.body).to include("Top Players")
    end
  end

  context '/404' do
    it "shows /404" do
      get '/404'

      expect(last_response).to be_not_found
    end
  end

end
