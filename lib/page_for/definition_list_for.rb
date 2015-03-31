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
      self.dl_builder.resource.send(self.attribute)
    end

    def block_contents
      self.dl_builder.context.capture(self.dl_builder.resource, &self.block)
    end

    def belongs_to?
      self.dl_builder.belongs_to?(self.attribute)
    end

    def selector
      self.dl_builder.selector(self.attribute)
    end

    def dl_selector
      self.dl_builder.dl_selector(self.attribute)
    end

    def format
      self.dl_builder.format(self.attribute)
    end

  end


  class DefinitionListBuilder

    attr_accessor :resource, :content_columns, :belongs_to, :column_names, :bt_names, :context,
                  :klass, :klass_name, :is_more, :definitions, :more_definitions, :page

    def initialize(resource, page)
      self.page = page
      self.context = page.context
      self.resource = resource
      self.klass = resource.class
      self.klass_name = self.klass.name.underscore
      self.content_columns = self.klass.content_columns
      self.column_names = self.content_columns.map {|x|x.name.to_s}
      self.belongs_to = self.klass.reflect_on_all_associations(:belongs_to)
      self.bt_names = self.belongs_to.map {|x|x.name.to_s}
      self.context = context
      self.is_more = false
      self.definitions = []
      self.more_definitions = []
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
      self.definitions.append(d)
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
        self.context.link_to("More Details...", "#", class: 'visible-phone btn', onclick: "#{self.render_jquery} return false", id: "#{self.dl_selector}");
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
      $(\"##{self.dl_selector}\").hide();
      $(\"##{self.dl_selector}\").removeClass('visible-phone');"
    end

    def dl_selector
      "dl_#{self.klass_name}_#{self.resource.id}"
    end

    def selector(attribute)
      "#{self.klass_name}_#{self.resource.id}_#{attribute}"
    end

    def format(attribute)
      v = self.resource.send(attribute)
      type = content_type(attribute)
      if v == nil or v.blank? and type!=:boolean
        return '<i>Blank</i>'.html_safe
      end
      if content_column?(attribute)
        if PageFor::Format.respond_to?(type)
          PageFor::Format.send(type, v)
        else
          "Unhandled type in definition_list_helper"
        end
      else
        if belongs_to?(attribute)
          if self.resource.send(attribute)
            self.context.link_to self.resource.send(attribute), self.resource.send(attribute)
          else
            "<i>No #{attribute.to_s.titleize}</i>".html_safe
          end
        else
          if file_method?(attribute)
            self.context.link_to "Download", self.resource.send(attribute).url
          else
            self.resource.send(attribute)
          end
        end
      end
    end

    def file_method?(attribute_name)
      file = self.resource.send(attribute_name) if self.resource.respond_to?(attribute_name)
      begin
        file && file.file?
      rescue
        false
      end
    end

    def content_column?(attribute)
      self.column_names.include?(attribute.to_s)
    end

    def belongs_to?(attribute)
      self.bt_names.include?(attribute.to_s)
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