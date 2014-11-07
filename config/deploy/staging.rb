server "176.9.31.103", roles: %w(app web db), primary: true
set :deploy_to, "/var/www/cabinet/tracker"

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
set :ssh_options, {
    keys: "/home/yarik/.ssh/id_rsa",
    forward_agent: false,
    auth_methods: %w(publickey),
    user: "yarik"
}

set :project_path, "/var/www/cabinet/tracker/current"
set :main_path, "/var/www/cabinet/main/current"
set :env_rvm, "PATH=$PATH:~/.rvm/bin:~/.rvm/rubies/ruby-2.1.0/bin:~/.rvm/gems/ruby-2.1.0@global/bin &&"

namespace :goliath do
  desc 'Stop Goliath'
  task :stop do
    on "yarik@176.9.31.103" do
      execute "sh /var/www/stop.sh cabinet/tracker"
      execute "sh /var/www/stop.sh cabinet/main"
      p "Killed processes"
    end
  end

  desc 'Start Goliath'
  task :start do
    on "yarik@176.9.31.103" do
      execute "#{fetch(:env_rvm)} cd #{fetch(:project_path)} && ENVIR=staging ruby application.rb -p 9010 -d"
      execute "#{fetch(:env_rvm)} cd #{fetch(:main_path)} && ENVIR=staging ruby server.rb -p 5432 -d"
    end
  end

  desc 'Restart Goliath'
  task :restart
  before :restart, :stop
  before :restart, :start
end

task :bundle_install do
  on "yarik@176.9.31.103" do
    execute "#{fetch(:env_rvm)} cd #{fetch(:project_path)} && bundle install"
  end
end

after :deploy, :bundle_install
after :deploy, "goliath:restart"