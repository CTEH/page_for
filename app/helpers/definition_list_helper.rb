module DefinitionListHelper

  def definition_list_for(resource, &block)
    builder = DefinitionListFor::DefinitionListBuilder.new(resource, self)

#    yield(builder) if block_given?
#    return builder.render.html_safe

    output = capture(builder, &block) if block_given?
    content_tag('dl', output.html_safe, class: 'dl-horizontal') + builder.render_more_button
  end

end
