# PageFor

## Dependencies

* gem 'kaminari'

* gem 'ransack'

* gem 'cancan'

* gem 'simple-navigation'

* gem 'polywag'

## Skin Dependencies

* gem 'adminlte-rails'


## Configuration

To change the theme for your application, create an initializer that follows the following formation:

    PageFor.configure do |config|
      config.theme = 'theme-name-here'
    end

Setup simple-navigation

    rails generate navigation_config

## Once your AcitveRecord model exists and migrations have run, you can scaffold views and controllers via

    rails g page_for:scaffold ModelName

