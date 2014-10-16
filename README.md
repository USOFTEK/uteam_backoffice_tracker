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

Optional:
##### To use fake data

>		$ (NUMB=1)* rake db:seed

* - Meens how many times do seeding

7. Start server:
>		$ ruby application.rb -sv -p <port>

## Usage
