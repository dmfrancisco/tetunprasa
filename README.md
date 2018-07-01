[![tetunprasa.david.tools](https://tetunprasa.david.tools/logo.svg)](https://tetunprasa.david.tools)

## Importing and translating the data

### Import from the DIT (Dili Institute of Technology) Tetun-English dictionary

Download the [ZIP file](http://www.tetundit.tl/Publications/DIT%20Tetun%20-%20English%20Lexicon.zip)
from the [institute's website](http://www.tetundit.tl/) and extract it in the
root of the project with the name `dit`. Finally, run the following rake task:

```shell
rake app:import:dit_dictionary
```

### Translate the entries and examples

Download the credentials file from your [Google console](https://console.cloud.google.com/)
and specify the keys in the `.env` file:

```shell
export GOOGLE_PROJECT_NAME="..."
export GOOGLE_APPLICATION_CREDENTIALS="..."
```

Make sure your billing is correct, otherwise you may end up with permission issues.
Then run the following rake tasks:

```shell
rake app:translate:entries_glossary
rake app:translate:entries_info
rake app:translate:examples
```

## Deployment

### Setting up a production environment

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
export SOLR_HOST="..."
export SOLR_PORT="..."
export SOLR_PATH="..."
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

### Common tasks related to search

To restart the search server just run:

```shell
sudo service tomcat6 restart
```

Additional packages you may need to install to get it running:

```shell
sudo apt-get install libgmp-dev
```

You'll also need to update Solr schema.xml file available at `/usr/share/solr/conf/schema.xml`
and paste the contents from https://git.io/vSkFa.

Make sure you also close access to the solr admin panel. Here's an example setup (you may need `sudo`):

```shell
ufw default deny incoming
ufw allow ssh
ufw allow www
ufw deny 8080/tcp
ufw enable
```
