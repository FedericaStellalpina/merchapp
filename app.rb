require 'sinatra'
require 'sqlite3'


db = SQLite3::Database.new "merchapp.db"


DataRow = Struct.new(:id, :item, :size, :type, :price, :expected, :count, :sold)

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

  # -- fill the table --
  rows = db.execute( "select * from data" ).map do |row|
    DataRow.new(*row)
  end
  puts rows

  erb :index, locals: { data_rows: rows }
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

  # -- fill the table --
  rows = db.execute( "select * from data" ).map do |row|
    DataRow.new(*row)
  end
  puts rows

  erb :index, locals: { data_rows: rows }
end
