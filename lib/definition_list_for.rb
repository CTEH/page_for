module DefinitionListFor

  class DefinitionListBuilder

    attr_accessor :resource, :content_columns, :belongs_to, :column_names, :bt_names, :context,
                  :klass_name, :is_more

    def initialize(resource, context)
      self.resource = resource
      self.klass_name = resource.class.name.underscore
      self.content_columns = resource.class.content_columns
      self.column_names = self.content_columns.map {|x|x.name.to_s}
      self.belongs_to = resource.class.reflect_on_all_associations(:belongs_to)
      self.bt_names = self.belongs_to.map {|x|x.name.to_s}
      self.context = context
      self.is_more = false
    end

    #
    # link  | Set to true to link to resource, ignored for associations
    # label | Override attribute.titleize
    #
    def define(attribute, *args,  &block)
      options = args.extract_options!
      label = options[:label] || attribute.to_s.titleize
      link = options[:link] || false

      dt = "<dt>#{label}</dt>"

      if block_given?
        output = ApplicationController.new.capture(self.resource, &block)
        dd = "<dd id='#{selector(attribute)}'>#{output}</dd>"
      else
        if link and not self.belongs_to?(attribute)
          dd = "<dd id='#{selector(attribute)}'>#{self.context.link_to format(attribute), self.resource.send(attribute)}</dd>"
        else
          dd = "<dd id='#{selector(attribute)}'>#{format(attribute)}</dd>"
        end
      end

      return "#{dt}#{dd}".html_safe
    end

    #
    # link  | Set to true to link to resource, ignored for associations
    # label | Override attribute.titleize
    #
    def define_more(attribute, *args)
      options = args.extract_options!
      self.is_more = true
      label = options[:label] || attribute.to_s.titleize
      link = options[:link] || false

      dt = "<dt class='hidden-phone' dlmore='true'>#{label}</dt>"

      if link and not self.belongs_to?(attribute)
        dd = "<dd class='hidden-phone' dlmore='true' id='#{selector(attribute)}'>#{self.context.link_to format(attribute), self.resource.send(attribute)}</dd>"
      else
        dd = "<dd class='hidden-phone' dlmore='true' id='#{selector(attribute)}'>#{format(attribute)}</dd>"
      end

      return "#{dt}#{dd}".html_safe
    end


    def render_more_button
      if self.is_more
        self.context.link_to("More Details...", "#", class: 'visible-phone btn', onclick: "#{self.render_jquery} return false", id: "#{self.dl_selector}");
      else
        ''.html_safe
      end
    end

    protected

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
      if v == nil or v.blank? and content_type(attribute)!=:boolean
        return '<i>Blank</i>'
      end
      if content_column?(attribute)
        if PageFor::Format.respond_to?(:content_type)
          PageFor::Format.send(:content_type, v)
        else
          "Unhandled type in definition_list_helper"
        end
      else
        if belongs_to?(attribute)
          if self.resource.send(attribute)
            self.context.link_to self.resource.send(attribute), self.resource.send(attribute)
          else
            "<i>No #{attribute.to_s.titleize}</i>"
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
      begin
        self.content_columns.select {|c| c.name.to_s == aname}.first.type
      rescue
        :string
      end
    end


  end

end