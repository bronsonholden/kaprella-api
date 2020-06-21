# Kaprella API Server

Kaprella connects Ag industry players, providing a unified platform to
capture, true-up, and analyze data.

## Setup

Kaprella uses the PostGIS extension for PostgreSQL. PostGIS must be installed
on your machine and enabled in the database. Visit https://postgis.net/install
for more information. Once PostGIS is installed, run the setup Rake task:

```
$ rake db:gis:setup
```
