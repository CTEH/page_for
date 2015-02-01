module PageForHelper
  def page_for_theme_dir
    "page_for/#{PageFor.configuration.theme}/"
  end

  def render_page_for(*args)
    options = args.extract_options!
    options[:partial] = page_for_theme_dir + options[:partial]

    # Not compatible with Rails 4.1.rc1
    ApplicationController.new.render_to_string(options).html_safe
  end

  def page_for(resource, *args, &block)
    options = args.extract_options!

    builder = PageFor::PageBuilder.new(self, resource, options)
    yield(builder) if block_given?

    if ['libero','hyperia'].include?(PageFor.configuration.theme)
      page_for_legacy_slots(builder)
    end

    render_page_for(partial: "page", locals: { page_builder: builder, page_for_cluids: @page_for_cluids })
  end


  def page_for_legacy_slots(builder)
    # Iphone
    self.content_for :title_bar, builder.render_title_bar.html_safe

    # Desktop
    self.content_for :title, builder.render_title.html_safe
    self.content_for :buttons, builder.render_buttons.html_safe
    self.content_for :page_header, builder.render_header.html_safe
  end


  def classed_link_to(klass=nil, name = nil, options = nil, html_options = nil, block=nil)
    html_options, options, name = options, name, block if block
    options ||= {}

    html_options = convert_options_to_data_attributes(options, html_options)

    url = url_for(options)
    html_options['href'] ||= url
    html_options['class'] = klass

    content_tag(:a, name || url, html_options, &block)
  end
end


