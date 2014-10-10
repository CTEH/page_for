module PageForHelper

  def page_for_theme_dir
    "page_for/skins/#{PageFor.configuration.theme}/"
  end

  def render_page_for(*args)
    options = args.extract_options!
    options[:partial] = page_for_theme_dir + options[:partial]

    ApplicationController.new.render_to_string(options).html_safe
  end


  def page_for(resource, *args, &block)
    options = args.extract_options!

    builder = PageFor::PageBuilder.new(self, resource, options)
    yield(builder) if block_given?
    body = builder.render_page.html_safe

    # Iphone
    self.content_for :title_bar, builder.render_title_bar.html_safe

    # Desktop
    self.content_for :title, builder.render_top.html_safe

    body
  end

end