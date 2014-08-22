require "sinatra"
require "sinatra/reloader"
require "CSV"
require "pry"
get '/' do
  @submission = []
  CSV.foreach('links.csv', headers: true, :header_converters => :symbol, :converters => :all) do |row|
    @submission << row.to_hash
  end
  erb :index
end

get '/submit' do
  erb :submit
end

post '/submit' do
  title = params["title_form"]
  url = params["url_form"]
  description = params["description_form"]
  formatted_string = "#{title},#{url},#{description}"
  File.open('links.csv', 'a') do |file|
    file.puts(formatted_string)
  end
  redirect '/'
end
