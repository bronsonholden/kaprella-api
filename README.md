# Kaprella API Server

Kaprella is a purpose-built Ag platform that connects players across the
industry, providing a unified system to capture, true-up, and analyze data
along the production chain.

## Setup

Kaprella uses the PostGIS extension for PostgreSQL. PostGIS must be installed
on your machine and enabled in the database. Visit https://postgis.net/install
for more information. Once PostGIS is installed, run the setup Rake task:

```
$ rake db:gis:setup
```

## Heroku Setup

1. Create the Heroku Rails app

2. Set up the PostGIS extension:

   ```
   $ heroku run -a $APP_NAME rake db:gis:setup
   ```

3. Migrate the database

   ```
   $ heroku run -a $APP_NAME rake db:migrate
   ```
