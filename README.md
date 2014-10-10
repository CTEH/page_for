# PageFor

## Configuration

To change the theme for your application, create an initializer that follows the following formation:

    PageFor.configure do |config|
      config.theme = 'theme-name-here'
    end

## Generator

The existing libero generator has been renamed page_for:scaffold. This is because it generates a
page_for layout, and not something specific to the libero style.