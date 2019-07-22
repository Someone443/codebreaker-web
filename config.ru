require_relative 'app/codebreaker_app'

use Rack::Reloader
use Rack::Static, :urls => ['/assets'], :root => 'app/views'
use Rack::Session::Cookie, :key => 'rack.session',
                            :path => '/',
                            :expire_after => 2592000,
                            :secret => 'very_secret_password'

run CodebreakerApp
