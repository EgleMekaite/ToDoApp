# helpers and hooks
# frozen_string_literal: true

require 'pry'

class Todo < Sinatra::Application
  before do
    binding.pry
    redirect '/login' if !%w[login signup].include?(request.path_info.split('/')[1]) && !current_user
    @min_date = Time.now.strftime('%Y-%m-%d')
    # binding.pry
  end

  helpers do
    def current_user
      @user ||= User.first(id: session[:user_id]) if session[:user_id]
    end
  end
end
