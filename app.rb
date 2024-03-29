# file: app.rb
require 'sinatra'
require 'sinatra/reloader'
require_relative 'lib/database_connection'
require_relative 'lib/album_repository'
require_relative 'lib/artist_repository'

DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/album_repository'
    also_reload 'lib/artist_repository'
  end

  get '/' do
    return erb(:home)
  end

  post '/albums' do ###
    if invalid_parameters == true
      status 400
      return 'invalid parameters, please try again'
    end

    repo = AlbumRepository.new
    album = Album.new
    album.title = params[:title]
    album.release_year = params[:release_year]
    album.artist_id = params[:artist_id]
    
    repo.create(album)
    return erb(:album_created)
  end

  def invalid_parameters
    if params[:title] == nil || params[:release_year] == nil || params[:artist_id] == nil
      return true
    elsif params[:title] == "" || params[:release_year] == "" || params[:artist_id] == ""
      return true
    else
      return false
    end
  end

  get '/albums/new' do ###
    return erb(:new_album)
  end

  get '/albums/:id' do
    repo = AlbumRepository.new
    album = repo.find(params[:id])
    @title = album.title
    @release_year = album.release_year
    
    return erb(:getalbum)
  end

  get '/albums' do
    repo = AlbumRepository.new
    @albums = repo.all
    return erb(:all_albums)
  end

  get '/artists/new' do 
    return erb(:new_artist)
  end

  get '/artists' do
    repo = ArtistRepository.new
    @artists = repo.all
    return erb(:all_artists)
    # names = []
    # artists.each do |artist|
    #   names << artist.name
    # end
    # return names.join(', ')
  end

  get '/artists/:id' do 
    repo = ArtistRepository.new
    @artist = repo.find(params[:id])
    return erb(:get_artist)
  end

  post '/artists' do
    repo = ArtistRepository.new
    artist = Artist.new
    artist.name = params[:name]
    artist.genre = params[:genre]

    repo.create(artist)
    return erb(:artist_created)
  end
end