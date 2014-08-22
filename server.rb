require "sinatra"
# require "sinatra/reloader"
# require "CSV"
# require "pry"
require "redis"
require "json"

def get_connection
  if ENV.has_key?("REDISCLOUD_URL")
    Redis.new(url: ENV["REDISCLOUD_URL"])
  else
    Redis.new
  end
end

def find_articles
  redis = get_connection
  serialized_articles = redis.lrange("slacker:articles", 0, -1)

  articles = []

  serialized_articles.each do |article|
    articles << JSON.parse(article, symbolize_names: true)
  end

  articles
end

def save_article(url, title, description)
  article = { url: url, title: title, description: description }

  redis = get_connection
  redis.rpush("slacker:articles", article.to_json)
end

get '/' do
  @submission = find_articles
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
  save_article(url, title, description)
  redirect '/'
end
