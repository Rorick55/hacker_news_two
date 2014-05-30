require 'sinatra'
require 'pg'

def db_connection
  begin
    connection = PG.connect(dbname: 'slacker_news')

    yield(connection)

  ensure
    connection.close
  end
end




def article_exists(params)
  errors = []
  articles_pg = db_connection do |conn|
  conn.exec('SELECT * FROM articles;')
    end
  articles = articles_pg.to_a
  articles.each do |article|
    if article['url'] == params
      errors << 1
    end
  end
  errors
end


get '/' do

@articles = db_connection do |conn|
  conn.exec('SELECT * FROM articles;')
    end
@articles = @articles.to_a
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
    insert = "INSERT INTO articles (name, headline, url, description) VALUES ($1, $2, $3, $4);"
    articles_pg = db_connection do |conn|
  conn.exec_params(insert, [name, headline, url, description])
    end
    redirect '/'
  end
end

post '/comments/:id' do
  name = params[:name]
  content = params[:comments]
  article_id = params[:id]
  insert = "INSERT INTO comments (name, content, article_id, time_created) VALUES ($1, $2, $3, now());"
    articles_pg = db_connection do |conn|
  conn.exec_params(insert, [name, content, article_id])
    end
    redirect '/'
  end

get '/articles/:id/comments' do

    @articles = db_connection do |conn|
  conn.exec("SELECT articles.name, articles.id, articles.headline, articles.url, articles.description, comments.content,
    comments.name AS commenter FROM articles JOIN comments ON comments.article_id = articles.id WHERE articles.id = #{params[:id]};")
    end
  @articles = @articles.to_a
  erb :comments
end
