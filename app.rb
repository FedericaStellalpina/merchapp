require 'sinatra'
require 'sqlite3'

require "sinatra/reloader"  # auto-reloader


# -- functions ----------------------------------------------------------------------
def fill_the_table(db)
  rows = db.execute( "select * from data" ).map do |row|
    DataRow.new(*row)
  end

  erb :index, locals: { data_rows: rows }
end

db = SQLite3::Database.new "merchapp.db"


DataRow ||= Struct.new(:id, :item, :size, :type, :price, :expected, :count, :sold)

# -- create an empty table if not exists
rows = db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    item TEXT NOT NULL,
    size TEXT NOT NULL,
    type TEXT NOT NULL,
    price INTEGER NOT NULL,
    expected INTEGER NOT NULL,
    count INTEGER NOT NULL,
    sold INTEGER NOT NULL
  );
SQL

get '/' do
  fill_the_table(db)
end

post '/' do

  # -- recieve from form --
  puts item  = params[:item]
  puts size  = params[:size]
  puts type  = params[:type]
  puts price = params[:price]
  puts exp   = params[:expected]
  puts count = params[:count]

  # -- insert in table --
  db.execute("INSERT INTO data (item, size, type, price, expected, count, sold) VALUES (?, ?, ?, ?, ?, ?, ?)", 
        [item, size, type, price, exp, count, 0])


  fill_the_table(db)
end

get '/delete' do
  id = params[:id]
  db.execute("DELETE FROM data WHERE id = #{id}")

  fill_the_table(db)
end


get '/edit' do
  id = params[:id]

  rows_up = db.execute( "SELECT * FROM data WHERE id < #{id}" ).map do |row|
    DataRow.new(*row)
  end

  rows_down = db.execute( "SELECT * FROM data WHERE id > #{id}" ).map do |row|
    DataRow.new(*row)
  end

  erb :edit, locals: { data_rows_up: rows_up, data_rows_down: rows_down, id: id }
end

post '/edit' do
  puts "*************  DEBUG   ********************"
  puts id = params[:id]
  puts "*******************************************"

  if id
    rows_up = db.execute( "SELECT * FROM data WHERE id < #{id}" ).map do |row|
      DataRow.new(*row)
    end
 
    rows_down = db.execute( "SELECT * FROM data WHERE id > #{id}" ).map do |row|
      DataRow.new(*row)
    end

    erb :edit, locals: { data_rows_up: rows_up, data_rows_down: rows_down }
  else
    
    # -- recieve from form --
    puts id_ed = params[:id_ed]
    puts item  = params[:item]
    puts size  = params[:size]
    puts type  = params[:type]
    puts price = params[:price]
    puts exp   = params[:expected]
    puts count = params[:count]
 
    # -- insert in table --
    puts ("UPDATE data SET item = #{item}, size = #{size}, type = #{type}, price = #{price}, expected = #{exp}, count = #{count} WHERE id = #{id_ed}") 
    db.execute("UPDATE data SET item = '#{item}', size = '#{size}', type = '#{type}', price = '#{price}', expected = '#{exp}', count = '#{count}' WHERE id = #{id_ed}") 

    rows = db.execute( "SELECT * FROM data" ).map do |row|
      DataRow.new(*row)
    end

    erb :index, locals: { data_rows: rows}
  end

end
