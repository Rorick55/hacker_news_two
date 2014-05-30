require 'sinatra'
require_relative 'method_list'

get '/' do
@articles = all_articles
erb :home
end

get '/new' do

  erb :new
end

post '/new' do
  @url = params[:url]
  @errors = article_exists(@url)
  @url_exists = "ARTICLE ALREADY EXISTS"

  if !@errors.empty?

    erb :new
  else
    name = params["name"]
    headline = params[:new_article]
    url = params[:url]
    description = params[:description]
      add_article(name, headline, url, description)

    redirect '/'
  end
end

post '/comments/:id' do
  name = params[:name]
  content = params[:comments]
  article_id = params[:id]
    add_comment(name, content, article_id)

    redirect '/'
  end

get '/articles/:id/comments' do
  id = params[:id]
    @articles = article_and_comments(id)
  erb :comments
end
