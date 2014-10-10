module TabSectionHelper

  def tab_section(&block)
    builder = PageFor::TabSectionBuilder.new(self)
    yield(builder) if block_given?
    return builder.render.html_safe
  end

end
