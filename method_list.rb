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

def all_articles
  articles = db_connection do |conn|
    conn.exec('SELECT * FROM articles;')
  end
  articles = articles.to_a
end

def add_article(name, headline, url, description)
  insert = "INSERT INTO articles (name, headline, url, description) VALUES ($1, $2, $3, $4);"
    articles_pg = db_connection do |conn|
      conn.exec_params(insert, [name, headline, url, description])
    end
end

def add_comment(name, content, id)
  insert = "INSERT INTO comments (name, content, article_id, time_created) VALUES ($1, $2, $3, now());"
    articles_pg = db_connection do |conn|
      conn.exec_params(insert, [name, content, id])
    end
end

def article_and_comments(article_id)
  articles = db_connection do |conn|
      conn.exec("SELECT articles.name, articles.id, articles.headline, articles.url, articles.description, comments.content,
    comments.name AS commenter FROM articles JOIN comments ON comments.article_id = articles.id WHERE articles.id = #{article_id};")
    end
  articles = articles.to_a
end







