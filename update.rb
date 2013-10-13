require 'rubygems'
require 'directory_watcher'
require 'pathname'
require 'data_mapper'

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

dw = DirectoryWatcher.new './public/media', :glob => '**/*.{mp4,mkv}'
dw.add_observer {|*args| args.each do |event|
	filename = Pathname.new(event.path).basename
	m = Movie.first :path => filename
	if event.type == :added
		unless m
			m = Movie.new
			m.title = filename
			m.path = filename
			m.save
			puts "Added '#{filename}' to database"
		end
	elsif event.type == :removed
		if m
			m.destroy
			puts "Deleted '#{filename}' from database"
		end
	else
		puts "Found '#{filename}'"
	end
end }

# sleep 1.0
# dw.run_once

dw.start
gets
dw.stop
