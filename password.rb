require "mysql2"
require "colorize"
require 'highline'

CHARS = ('0'..'9').to_a + ('A'..'Z').to_a + ('a'..'z').to_a

def random_password(length=10)
  # creates a random 10 digit password
  password = CHARS.sort_by { rand }.join[0...length]
  return password
end

def save_credentials(service, username, password)
  # save the credentials for the given service, username and password in the database
  client()
  sql = "INSERT INTO `password`.`passwords` (`Service`, `Username`, `Password`) VALUES ('#{ service }', '#{ username }', '#{ password }');"
  client.query(sql)
end

def create
  # create credentials for a new service
  cli = HighLine.new
  service = cli.ask "We start creating new credentials.\nWhat is the name of the service?"
  username = cli.ask "What is your username?"
  password = random_password()
  puts "Use this password for your service".red, "Password: #{ password.blue }"
  save_credentials(service, username, password)
end

def get
  # gets the credentials of a service
  client
  sql = " SELECT * FROM passwords "
  res = client.query(sql, :as => :hash)
  res.each do |row|
    puts row['Service'].red
  end
  puts "Please type the service you want"
  service = gets.chomp
  sql = " SELECT * FROM passwords where service = '#{service}';"
  res = client.query(sql, :as => :hash)
  res.each do |row|
    puts "#{ "Username: ".green } #{ row['Username'].blue } \n #{ "Password: ".green } #{ row['Password'].blue }"

  end
end

def to_do
  # choose if you want to get or create credentials
  cli = HighLine.new
  c = "create".red
  g = "get".red
  input = cli.ask "What do you want to do?\n#{ c }\n#{ g }\nPlease select one of the above"
  if input == "create"
    create
  elsif input == "get"
    get
  end
end

def ask_password
  # ask for the supersecret password
  cli = HighLine.new
  pass = cli.ask "What is your supersecret password?"
  if pass == "s"
    to_do
  else
    puts "Sorry mate, get out of here!"
  end
end

def client
  # returns a mysql connection to the database
  client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "root", :database => "password")
  return client
end

ask_password

