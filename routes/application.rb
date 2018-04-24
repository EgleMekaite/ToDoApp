# helpers and hooks
# frozen_string_literal: true

class Todo < Sinatra::Application
  before do
    redirect '/login' if !%w[login signup].include?(request.path_info.split('/')[1]) && !current_user
    @min_date = Time.now.strftime('%Y-%m-%d')
  end

  helpers do
    def current_user
      @user ||= User.first(id: session[:user_id]) if session[:user_id]
    end
  end
end
