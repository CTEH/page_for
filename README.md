# PageFor

## Dependencies

* gem 'kaminari'

* gem 'ransack'

* gem 'cancan'

* gem 'simple-navigation'

* gem 'polywag'

* gem 'bootstrap-kaminari-views'

## Skin Dependencies

* gem 'adminlte-rails'


## Configuration

To change the theme for your application, create an initializer that follows the following formation:

    PageFor.configure do |config|
      config.theme = 'theme-name-here'
    end


## Once your AcitveRecord model exists and migrations have run, you can scaffold views and controllers via

    rails g page_for:scaffold ModelName

## Change Log

* 12/27/2014 - Kaminari looks for theme in subfolder.  For example.  app/views/kaminari/adminlte/*
