require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'linguistics'
gem 'haml', '~> 2.0'

Linguistics::use( :en )

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/cal.sqlite3")

DataMapper::Logger.new(STDOUT, :debug) 

class Story 
  include DataMapper::Resource
  property :id, Integer, :serial => true
  property :partial, String
  property :verb, String
  property :adverb, String
  property :noun, String
  property :proper_noun, String
  property :pronoun, String
  property :adjective, String
  property :created_at, DateTime
  property :updated_at, DateTime
end

DataMapper.auto_upgrade!

get '/' do
  haml :index
end

post "/stories/create" do
  @story = Story.create(
     :verb => params[:story_verb],
     :adverb => params[:story_adverb],
     :noun => params[:story_noun],
     :proper_noun => params[:story_proper_noun],
     :pronoun => params[:story_pronoun],
     :adjective => params[:story_adjective],
     :partial => params[:story_partial])
  if @story.save
    redirect "/#{@story.id}"
  else
    redirect '/'
  end
end

get '/:id' do
  @story = Story.get(params[:id])
  haml :show
end

get "/stylesheets/style.css" do
  content_type 'text/css'
  headers "Expires" => (Time.now + 60*60*24*356*3).httpdate # Cache for 3 years
  sass :"stylesheets/style"
end

helpers do
  def versioned_stylesheet(stylesheet)
    "/stylesheets/style.css?" + File.mtime(File.join(Sinatra.application.options.views, "stylesheets", "style.sass")).to_i.to_s
  end
  def partial(name)
      haml(:"_#{name}", :layout => false)
  end
  def random_partial
    array = %w(one two three)
    array[rand(array.size)]
  end
end