module DefinitionListFor
  class DefinitionBuilder
    attr_accessor :label, :attribute, :link, :options, :block_given, :block, :is_more, :dl_builder

    def initialize(dl_builder, attribute, options, block)
      self.dl_builder = dl_builder
      self.options = options
      self.label = options[:label] || attribute.to_s.titleize
      self.is_more = options[:is_more]
      self.link = options[:link] || false
      self.block_given = options[:block_given]
      self.attribute = attribute
      self.block = block
    end

    def value
      dl_builder.resource.send(attribute)
    end

    def block_contents
      dl_builder.context.capture(dl_builder.resource, &self.block)
    end

    def belongs_to?
      dl_builder.belongs_to?(attribute)
    end

    def selector
      dl_builder.selector(attribute)
    end

    def dl_selector
      dl_builder.dl_selector(attribute)
    end

    def format
      dl_builder.format(attribute)
    end

  end


  class DefinitionListBuilder

    attr_accessor :resource, :content_columns, :belongs_to, :column_names, :bt_names, :context,
                  :klass, :klass_name, :is_more, :definitions, :more_definitions, :page, :dl_options

    def initialize(resource, page, dl_options)
      self.page = page
      self.context = page.context
      self.resource = resource
      self.klass = resource.class
      self.klass_name = self.klass.name.underscore
      self.content_columns = self.klass.content_columns
      self.column_names = self.content_columns.map {|x|x.name.to_s}
      self.belongs_to = self.klass.reflect_on_all_associations(:belongs_to)
      self.bt_names = self.belongs_to.map {|x|x.name.to_s}
      self.is_more = false
      self.definitions = []
      self.more_definitions = []
      self.dl_options = dl_options

    end

    #
    # link  | Set to true to link to resource, ignored for associations
    # label | Override attribute.titleize
    #
    def define(attribute, *args,  &block)
      options = args.extract_options!
      options[:is_more] = false
      options[:block_given] = block_given?
      d = DefinitionBuilder.new(self, attribute, options, block)
      definitions.append(d)
      ''
    end

    #
    # link  | Set to true to link to resource, ignored for associations
    # label | Override attribute.titleize
    #
    def define_more(attribute, *args, &block)
      options = args.extract_options!
      options[:is_more] = true
      options[:block_given] = block_given?
      self.is_more = true
      d = DefinitionBuilder.new(self, attribute, options, block)
      self.definitions.append(d)

      ''
    end


    def render_more_button
      if self.is_more
        context.link_to("More Details...", "#", class: 'visible-phone btn', onclick: "#{render_jquery} return false", id: "#{dl_selector}");
      else
        ''.html_safe
      end
    end

    def render_jquery
      "$(\"dt[dlmore='true']\").hide();
      $(\"dd[dlmore='true']\").hide();
      $(\"dt[dlmore='true']\").removeClass('hidden-phone');
      $(\"dd[dlmore='true']\").removeClass('hidden-phone');
      $(\"dt[dlmore='true']\").show('slow');
      $(\"dd[dlmore='true']\").show('slow');
      $(\"##{dl_selector}\").hide();
      $(\"##{dl_selector}\").removeClass('visible-phone');"
    end

    def dl_selector
      "dl_#{self.klass_name}_#{self.resource.id}"
    end

    def selector(attribute)
      "#{self.klass_name}_#{self.resource.id}_#{attribute}"
    end

    def format(attribute)
      v = resource.send(attribute)
      type = content_type(attribute)
      if belongs_to?(attribute)
        if v
          if context.can?(:show, v)
            context.link_to v, v
          else
            v.to_s
          end
        else
          "<i>No #{attribute.to_s.titleize}</i>".html_safe
        end
      elsif v.blank? && type != :boolean
        return '<i>Blank</i>'.html_safe
      elsif content_column?(attribute)
        if PageFor::Format.respond_to?(type)
          PageFor::Format.send(type, v, self.dl_options)
        else
          "Unhandled type in definition_list_helper"
        end
      elsif file_method?(attribute)
        self.context.link_to resource.send("#{attribute}_file_name"), v.url
      else
        v
      end
    end

    def file_method?(attribute_name)
      file = resource.send(attribute_name) if resource.respond_to?(attribute_name)
      begin
        file && file.file?
      rescue
        false
      end
    end

    def content_column?(attribute)
      column_names.include?(attribute.to_s)
    end

    def belongs_to?(attribute)
      bt_names.include?(attribute.to_s)
    end

    def content_type(attribute)
      aname = attribute.to_s
      return :enumerize if self.klass.respond_to?(:enumerized_attributes) && self.klass.enumerized_attributes[aname]
      begin
        self.content_columns.select {|c| c.name.to_s == aname}.first.type
      rescue
        :string
      end
    end
  end
end
