require 'sinatra'
require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: 'movies')

    yield(connection)

  ensure
    connection.close
  end
end

get '/actors' do
  sql = 'SELECT name, id FROM actors ORDER BY name ASC'
  all_actors = db_connection do |conn|
    conn.exec(sql).to_a
  end
  @all_actors = all_actors
  erb :'actors/index'
end



get '/actors/:id' do
  id = params[:id]
  actor_info = db_connection do |conn|
    conn.exec('SELECT movies.title, actors.name, movies.id, cast_members.character FROM movies
    JOIN cast_members ON cast_members.movie_id = movies.id
    JOIN actors ON actors.id = cast_members.actor_id WHERE actors.id = $1',[id]).to_a
  end
@actor_info = actor_info
erb :'actors/show'
end


get "/movies" do
sql = 'SELECT movies.id,movies.title,movies.year, movies.rating, genres.name AS genres, studios.name FROM movies
JOIN genres on movies.genre_id = genres.id
JOIN studios ON movies.studio_id = studios.id
ORDER BY movies.title ASC'
  all_movies = db_connection do |conn|
    conn.exec(sql).to_a
  end
@all_movies = all_movies
erb :'movies/index'
end

get "/movies/:id" do
id = params[:id]
  movie_info = db_connection do |conn|
    conn.exec('SELECT movies.title, movies.id, actors.id AS actor, studios.name AS studios, genres.name AS genres, cast_members.character, actors.name FROM movies
    JOIN genres on movies.genre_id = genres.id
    JOIN studios ON movies.studio_id = studios.id
    JOIN cast_members ON cast_members.movie_id = movies.id
    JOIN actors ON actors.id = cast_members.actor_id WHERE movies.id = $1',[id]).to_a
  end
@movie_info = movie_info
erb :'movies/show'
end
