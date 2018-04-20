class Todo < Sinatra::Application
  before do
    unless %w[login signup].include? (request.path_info.split('/')[1]) && current_user
      redirect '/login'
    end
    @min_date = Time.now.strftime('%Y-%m-%d')
    @user = User.first(id: session[:user_id])
  end

  helpers do
    def current_user
      @current_user ||= User.first(id: session[:user_id]) if session[:user_id]
    end
  end
end
