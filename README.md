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
      config.simple_form_for :theme-name-here
    end


## Once your AcitveRecord model exists and migrations have run, you can scaffold views and controllers via

    rails g page_for:scaffold ModelName

## JS

    //= require jquery
    //= require jquery_ujs
    //= require bootstrap.min
    //= require adminlte-custom
    //= require actionsheet
    //= require page_for_adminlte
    //= require numerous-2.1.1.min


## CSS

   *= require bootstrap
   *= require font-awesome
   *= require ionicons
   *= require adminlte
   *= require page_for_adminlte
   *= require action_sheet

# editable_table_for

To add a 'Remove' button to editable_table_for instances, add '- t.delete_link_if_can'.

# Troubleshooting

If you get an exception "undefined method `has_attribute?' for ...", you likely forgot to add accepts_nested_attributes_for to your model for the has_many relationships in your form.

## Change Log

* 12/27/2014 - Kaminari looks for theme in subfolder.  For example.  app/views/kaminari/adminlte/*
