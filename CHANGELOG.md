Manual Notes of changes to this fork:

Gemfile
* dog_biscuits
* dotenv

Files from DogBiscuits generator in config, config/initializers and services

config/application.rb
* Dotenv::Railtie.load

Configs TODO
* fedora.yml, solr.yml, blacklight.yml, settings.yml and settings/production.yml set up with .env params

app/assets/stylesheets TODO
* added hykuleaf.scss and included it in application.css (at the bottom so it's called last)

Other files
.sample-env - template for .env

Importer
* added bin/import_from_eprints_json
* added lib/importer/eprints.rb and eprints/ with importer, parser, downloader and mapper
* autoloaded in lib/importer.rb

Generator
* rails generate hyrax:work PublishedWorks
* edited model and indexer
* edited form to remove based_near (not currently in my common metadata)
