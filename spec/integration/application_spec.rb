require "spec_helper"
require "rack/test"
require_relative '../../app'

def reset_artists_table
  seed_sql = File.read('spec/seeds/artists_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
  connection.exec(seed_sql)
end

describe Application do
  before(:each) do 
    reset_artists_table
  end
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  
  context "GET /artists" do
    it 'returns 200 OK' do
      # Assuming the post with id 1 exists.
      response = get('/artists')

      expect(response.status).to eq(200)
      expect(response.body).to include('Pixies')
      expect(response.body).to include('ABBA')
      expect(response.body).to include('Taylor Swift')
    end
  end

  context "GET /artists/:id" do 
    it "directs to html file of specified artist" do
      response = get('/artists', id:'2')
      expect(response.status).to eq(200)
      expect(response.body).to include('ABBA')
    end
  end  

  context "GET /artists/new" do 
    it "directs to form page" do 
      response = get('/artists/new')
      expect(response.status).to eq(200)
      expect(response.body).to include('<form action="/artists" method="POST">')
    end
  end

  context "POST /artists" do
    it 'returns 200 OK' do
      # Assuming the post with id 1 exists.
      response = post('/artists', name: 'Wild nothing', genre: 'Indie')

      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Artist has been added</h1>')

      # response_2 = get('/artists')

      # expect(response_2.status).to eq(200)
      # expect(response_2.body).to eq('Pixies, ABBA, Taylor Swift, Nina Simone, Wild nothing')
    end
  end
  
  context "GET /albums/new" do 
    it "takes the user to the new post page" do 
      response = get('/albums/new')
      expect(response.status).to eq (200)
      expect(response.body).to include('<form action="/albums" method="POST">')
    end
  end

  context "POST /albums" do ###################
    it 'returns 200 OK' do
      # Assuming the post with id 1 exists.
      response = post('/albums', title: 'Voyage', release_year: '2022', artist_id: '2')

      expect(response.status).to eq(200)
      expect(response.body).to include("<h1>Congratulations! Album has been added successfully</h1>")
    end

    it 'returns 400 Not Found' do
      response = post('/albums', title: 'ocsaint', release_year: '', artist_id: nil)

      expect(response.status).to eq(400)
      expect(response.body).to eq('invalid parameters, please try again')
    end
  end

  context "GET /albums/:id" do 
    it "returns an album in html format" do
      response = get('/albums/2')
      expect(response.body).to include('Surfer Rosa')
      expect(response.status).to eq(200)
    end
  end 

  context "GET /albums" do
    it "returns list of all albums" do
      response = get('/albums')
      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Albums</h1>')
      expect(response.body).to include('Title: Surfer Rosa')
    end
  end
end
