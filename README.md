# Application (tracker)

## Installation
1. Goto app directory:
>		$ cd ../tracker

2. Install missing gems:
>		$ bundle install

3. To create all databases from config by environments:
>		$ rake db:create

4. Execute all migrations:
>		$ RACK_ENV=your_env_name rake db:migrate

5. Run tests
>		$ rspec spec
Or
>		$ rake

6. OR simple:
>		$ rake db:setup

###### Optional:
To use fake data
>		$ (RACK_ENV=production)* (NUMB=1)* (with_team=true)* (password=) rake db:seed

* - 
RACK_ENV - by default :development
NUMB - number of seeds by default 
password - by default password is `my_temp_password`
with_team - User friends (requires for bonus). Build Associations for user.friends of user.bonuses

7. Start server:
>		$ ruby application.rb -sv -p <port>

## Usage
