require 'sinatra'
require 'csv'

#validate query
def is_year?(input)
  reformat = input.gsub(/\D/,"")
  reformat == input && reformat.length == 4
end

def is_rating?(input)
  reformat = input.gsub(/\D/,"")
  reformat == input && reformat.to_i < 101
end

#build results
def generate_hash_from_csv
  movies = {}
  CSV.foreach('movies.csv', headers: true) do |row|
    movies[row["id"]] = row.to_hash
  end
  movies
end

def grab_search_results(query)
  all_movies = generate_hash_from_csv

  results = { }
  all_movies.each do |id, hash|
    if query == nil
      results[hash["title"]] = id

    elsif is_year?(query)
      if hash["year"] == query
        results[hash["title"]] = id
      end

    elsif is_rating?(query)
      if hash["rating"] == query
        results[hash["title"]] = id
      end

    else
      ["title", "synopsis","studio"].each do |search_field|
        if hash[search_field] != nil
          if hash[search_field].match(query) != nil
            results[hash["title"]] = id
          end
        end
      end
     end
  end
  display = results.sort_by { |title, id| title }
end

def grab_movie_info(id)
  movies = generate_hash_from_csv
  selected_movie = movies[id]
end


get "/" do
  redirect "/movies"
end

get "/movies/" do
  redirect "/movies"
end

get "/movies" do

  redirect "/movies" if params[:query] == ""

  params[:query] == nil ? @query = nil : @query = params[:query]
  params[:page] == nil ? @page = 1 : @page = params[:page].to_i

  records_per_page = 20
  ending_record =  (@page*records_per_page)
  starting_record = ending_record - records_per_page

  all_movies = grab_search_results(@query)

  @total_pages = (all_movies.length.to_i / records_per_page) + 1
  @movie_list = all_movies[starting_record...ending_record]

  erb :movies
end

get "/movies/:id" do
  @movie_info = grab_movie_info(params[:id])
  erb :movie_id
end

set :views, File.dirname(__FILE__) + '/views'
set :public_folder, File.dirname(__FILE__) + '/public'
