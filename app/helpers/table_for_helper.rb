module TableForHelper


  def table_for(resources, *args, &block)

    # no need to render the table if we don't have any items
    return self.render_page_for(partial: "table_for/no_items") if resources.length == 0

    options = args.extract_options!
    options[:ransack_obj] ||= eval("@q_#{resources.first.class.name.demodulize.underscore}")

    builder = TableFor::TableBuilder.new(self, resources, options)
    yield(builder) if block_given?
    builder.render.html_safe
  end


end
