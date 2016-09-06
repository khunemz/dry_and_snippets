# development gems
gem_group :development , :test do
	gem 'puma'
	gem 'rspec-rails'
	gem 'pry'
end

# development database
# MySQL
if yes?("Use mysql")
	dbname = ask("dbname?").underscore
	username = ask("dev db username?").underscore
	password = ask("dev db password?").underscore
	gsub_file 'Gemfile', "gem 'sqlite3'", "gem 'mysql2'"
	comment_lines 'config/database.yml', ""
	append_file 'config/database.yml' , 
"#
#
default: &default
  adapter: mysql2
  encoding: utf8
  pool: 5
  username: #{username}
  password: #{password}
  socket: /tmp/mysql.sock

development:
  <<: *default
  database: #{dbname}_development

#
#
test:
  <<: *default
  database: #{dbname}_test

#
#
production:
  <<: *default
  database: #{dbname}_production
  username: root
  password: <%= ENV['DATABASE_PASSWORD'] %>"

# Postgresql
elsif yes?("Use pg")
	dbname = ask("dbname?").underscore
	gsub_file 'Gemfile', "gem 'sqlite3'", "gem 'pg'"
	comment_lines 'config/database.yml', ""
	append_file 'config/database.yml' , 
	"default: &default
  adapter: postgresql
  encoding: unicode
  pool: 5

development:
  <<: *default
  database: #{dbname}_development

test:
  <<: *default
  database: #{dbname}_test

production:
  <<: *default
  database: #{dbname}_production
  username: root
  password: <%= ENV['DATABASE_PASSWORD'] %>"
end


# production gems
gem_group :production do
	gem 'unicorn'
end

# Front end framework

## Foundation
if yes?("Use Foundation ??")
	gem 'foundation-rails'
	run 'bundle install'
	generate "foundation:install -f"

## Bootswatch
elsif yes?("Use Bootswatch Cosmo??")
	gem 'bootswatch-rails'
	run 'bundle install'
	inject_into_file "app/assets/stylesheets/application.css", :after => " */\n" do <<-'RUBY'
@import "bootstrap-sprockets";
@import "bootswatch/cosmo/variables";
@import "bootstrap";
@import "bootswatch/cosmo/bootswatch";
	  RUBY
	end

	inject_into_file "app/assets/javascripts/application.js", :after => "//= require jquery_ujs\n" do <<-'RUBY'
//= require bootstrap-sprockets
	  RUBY
	end

## Plain old Bootstrap
else
	gem 'bootstrap-sass'
	run 'bundle install'
	inject_into_file "app/assets/stylesheets/application.css", :after => " */\n" do <<-'RUBY'
@import "bootstrap-sprockets";
@import "bootstrap";
	  RUBY
	end
	inject_into_file "app/assets/javascripts/application.js", :after => "//= require jquery_ujs\n" do <<-'RUBY'
//= require bootstrap-sprockets
	  RUBY
	end
end

# gsub application.html.erb : adding container
gsub_file 'app/views/layouts/application.html.erb', '<%= yield %>', "<div class='container'><%= yield %></div>"

# Routing
route "# root '#index'"

# README
remove_file "README.rdoc"
create_file "README.md", "## Initialized README ##"

# create database foreach adapter
rake "db:create"

# Git
git :init
append_file ".gitignore",  "config/database.yml"
append_file ".gitignore",  "config/secret.yml"
run 'cp config/database.yml config/example_database.yml'
run 'cp config/secret.yml config/example_secret.yml'
git add: ".", commit: "-m 'initial commit'"
