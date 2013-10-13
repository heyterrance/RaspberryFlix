require 'rubygems'
require 'sinatra'
require 'shotgun'
require 'data_mapper'
require 'directory_watcher'
require 'pathname'
require 'imdb_party'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/media.db")

class Movie
	include DataMapper::Resource
	property :id,						Serial
	property :path, 				String, :required => true
	property :imdb,					String
	property :title, 				String
	property :year,					String
	property :plot,	Text
end

DataMapper.finalize.auto_upgrade!

# listener = fork do
# 	exec 'ruby listener.rb'
# end
# Process.detach(listener)

### Upload Routes ###

get '/upload' do
	@title = 'Upload'
	erb :form
end

post '/upload' do
	if params[:path]
		m = Movie.new
		m.title = params[:title] ? params[:title] : params[:path]
		m.path = params[:path]
		m.save
	end
	redirect '/'
end


### Watch Routes ###

get '/watch/:id' do
	m = Movie.get params[:id]
	if m
		@title = m.title
		@movie = m
		@path = "/media/#{m.path}"
		erb :watch, :layout => :theater
	else
		redirect '/'
	end
end

### Edit Routes ###

get '/edit/:id' do
	m = Movie.get params[:id]
	@title = "Edit #{m.title}"
	@movie = m
	erb :edit
end

put '/:id' do
	m = Movie.get params[:id]
	imdb = ImdbParty::Imdb.new
	movie = imdb.find_movie_by_id params[:imdbid]
	puts movie.title
	m.imdb = params[:imdbid]
	m.title = movie.title
	m.year = movie.release_date[0,4]
	m.plot = movie.plot
	m.save
	redirect '/'
end

### Delete Routes ###

get '/delete/:id' do
	@title = 'Delete'
	@movie = Movie.get params[:id]
	erb :delete
end

delete '/:id' do
	m = Movie.get params[:id]
	m.destroy
	redirect '/'
end

###################

get '/' do
	@movies = Movie.all :order => :title.desc
	@title = 'Home'
	erb :home
end
