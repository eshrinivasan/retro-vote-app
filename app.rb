require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/reloader'
require 'pry'
require 'logger'

logger = Logger.new(STDOUT)

require_relative 'models/user'
require_relative 'models/todo'

class TodoApp < Sinatra::Base
  configure do
    register Sinatra::ActiveRecordExtension
    register Sinatra::Reloader

    set :database, adapter: 'sqlite3', database: 'db/todo.db'

    set :sessions, true
    set :session_secret, '\x1b\x7fJ\x833\xac~\xe6\xbb\xba\nf'
  end

  helpers do
    def authenticated?
      not session[:userdata].nil?
    end
  end

  @@count = 0

  def self.increment()
    @@count = @@count + 1
  end

  def self.count()
    return @@count
  end

  get '/' do
    if authenticated?
      @username = session[:userdata][:username]
      @todos = Todo.where(user_id: session[:userdata][:id]).order(created_at: :desc)
      haml :index
    else
      redirect '/signin'
    end
  end

  # for handling todos
  post '/todo/new' do
    todo = Todo.new
    todo.user_id = session[:userdata][:id]
    todo.content = params[:content]

    if todo.valid?
      todo.save
      redirect '/'
    end
  end

  post '/todo/delete/:todo_id' do
    todo = Todo.find_by(id: params[:todo_id], user_id: session[:userdata][:id])
    if not todo.nil?
      todo.destroy
      redirect '/'
    end
  end

  post '/todo/vote/:todo_id' do 
    todo = Todo.find_by(id: params[:todo_id])
    todo.update(:points => todo.points + 1)
    #todo.update = todo.points + 1
    todo.save
    redirect '/'
  end 

  before do
    puts '[Params]'
    p params
  end

  # for session management
  get '/signup' do
    haml :signup
  end
  
  get '/signin' do
    haml :signin
  end
  
  get '/signout' do
    session.destroy
    redirect '/'
  end

  post '/signup' do
    user = User.new

    user.username = params[:username]
    user.password = params[:password]

    if user.valid? and user.save
      session[:username] = user.username
      redirect '/'
    else
      redirect back
    end
  end

  post '/signin' do
    user = User.find_by(username: params[:username])

    if user and user.authenticate(params[:password])
      session[:userdata] = {id: user.id, username: user.username}
      redirect '/'
    else
      redirect back
    end
  end
end
