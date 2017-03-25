#### Setting up a production environment

The app is hosted on DigitalOcean and the one-click _Ruby on Rails on Ubuntu 14.04
(Postgres, Nginx, Unicorn)_ droplet was used. It includes Ruby v2.2.1, installed with RVM,
and Rails v4.2.4.

Capistrano is used for deployment. You should enable passwordless sudo for the `rails`
user by adding the following above the `#includedir` line:

```shell
rails ALL=(ALL) NOPASSWD:ALL
```

After that, set any required environment variables inside the user's `.bashrc` file. Be sure
to put them before the comment that says "If not running interactively, don't do anything":

```shell
export APP_DATABASE_NAME="..."
export APP_DATABASE_USERNAME="..."
export APP_DATABASE_PASSWORD="..."
export SECRET_KEY_BASE="..."
```

Finally, you should create a clean database or restore one from a dump file:

```shell
pg_dump -U rails -W -h localhost -f jscoach.sql jscoach_development
createdb jscoach_production -U rails -W -h localhost
psql -U rails -W -h localhost -d jscoach_production -f ~/jscoach.sql
```

If you ever end up needing more permissions (for example, to create extensions) you can:

```shell
sudo -u postgres psql
postgres=# alter role rails with superuser;
```

You should now be able to deploy the application:

```shell
bundle exec cap production setup
bundle exec cap production deploy
```

To avoid having to enter your password on every deploy, copy your public SSH key:

```shell
cat ~/.ssh/id_rsa.pub | ssh rails@123.45.56.78 "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys"
```

To restart the search server just run:

```shell
sudo service tomcat6 restart
```

Additional packages you may need to install to get it running:

```shell
sudo apt-get install libgmp-dev
```
