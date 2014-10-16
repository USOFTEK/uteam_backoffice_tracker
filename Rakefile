require "rubygems"
require "bundler/setup"
require "em-synchrony/activerecord"
require "digest/md5"
require "yaml"
require "erb"
require "factory_girl"
require "database_cleaner"
require "faker"
require "active_support/all"

# helpers
def db_configuration
  YAML.load(ERB.new(File.read("#{File.dirname(__FILE__)}/config/database.yml")).result)
end

# Database namespace
namespace(:db) do
  desc("load configurations and connecting to database")
  task(:connect) do
    config = db_configuration
    ENV["RACK_ENV"] ||= "development"
    ActiveRecord::Base.remove_connection
    ActiveRecord::Base.establish_connection(config[ENV["RACK_ENV"].downcase])
  end
  
  desc "creates and migrates your database"
  task(:setup) do
    Rake::Task["db:create"].invoke
    db_configuration.each { |env,config|
      puts("Setting up database for: #{env}")
      system("RACK_ENV=#{env} rake db:migrate", out: $stdout, err: :out)
    }
  end

  desc("migrate database")
  task(:migrate => ["db:connect"]) do
    ENV["VERSION"] ||= nil
    ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths, ENV["VERSION"])
  end

  desc "Drop databases"
  task(:drop) do
    db_configuration.each { |env,config| system("mysqladmin --user=#{config["username"]} -f drop #{config["database"]}", out: $stdout, err: :out) }
  end

  desc "Create databases"
  task(:create) do
  	db_configuration.each { |env,config| system("mysql --user=#{config["username"]} -e 'create DATABASE #{config["database"]} DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci '", out: $stdout, err: :out) }
  end

  desc("Check for pending migrations")
  task(:abort_if_pending_migrations => ["db:connect"]) do
    abort("Run `rake db:migrate` to update database!") if ActiveRecord::Migrator.open(ActiveRecord::Migrator.migrations_paths).pending_migrations.any?
  end

  desc("Clean database")
  task(:clean => ["db:connect"]) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    DatabaseCleaner.clean
  end

  desc("Load seeds")
  task(:seed => ["db:clean"]) do
    ENV["NUMB"] ||= 1.to_s
    Rake::Task["db:abort_if_pending_migrations"].invoke
    Dir.glob("#{File.dirname(__FILE__)}/app/models/*.rb").each { |m| require m }
    # Load factories
    # FactoryGirl.definition_file_paths = ["#{File.dirname(__FILE__)}/spec/"]
    # FactoryGirl.find_definitions
    FactoryGirl.reload
    FactoryGirl.create_list(:user, ENV["NUMB"].to_i)
  end

end

# Testing
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new("spec")

task :default => ["db:migrate", :spec]
