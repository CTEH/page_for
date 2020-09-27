require 'csv'
module CsvForHelper

  def csv_for(resources, *args, &block)
    if resources.length == 0
      return '<p>No items to list</p>'.html_safe
    end
    options = args.extract_options!
    if options[:ransack_key]
      options[:ransack_obj] ||= eval("@#{options[:ransack_key]}")
    else
      options[:ransack_obj] ||= eval("@q_#{resources.first.class.name.underscore}")
    end


    builder = CsvBuilder.new(self, resources, options)
    yield(builder)
    return builder.render.html_safe
  end

  class ColumnBuilder
    attr_accessor :csv_builder, :attribute, :options, :block,
                  :content_type, :is_belongs_to, :is_content_column,
                  :cell_class, :header_class, :cell_options, :table_options

    def initialize(csv_builder,attribute,cell_options, table_options,block)
      self.table_options = table_options
      self.csv_builder = csv_builder
      self.attribute = attribute
      self.is_content_column = self.csv_builder.content_column?(attribute)
      self.is_belongs_to = self.csv_builder.belongs_to?(attribute)
      self.content_type = self.csv_builder.content_type(attribute)
      self.block = block
      self.cell_options = cell_options
      if cell_options[:class]
        self.cell_class = "tblfor_td_#{content_type} #{cell_options[:class]}"
        self.header_class = "tblfor_th_#{content_type} #{cell_options[:class]}"
      else
        self.cell_class = "tblfor_td_#{content_type}"
        self.header_class = "tblfor_th_#{content_type}"
      end

    end


    def cell_body(resource)
      self.format(resource)
    end


    def header_body
      self.attribute.to_s.titleize
    end

    def nested_title
      if self.attribute.to_s["."]
        a = self.attribute.to_s.split('.').reverse
        a.pop
        a.reverse!
        a.join(' ').titleize
      else
        self.attribute.to_s.titlecase
      end
    end


    def nested_send(resource)
      attributes = attribute.to_s.split(".")
      result = resource
      attributes.each do |a|
        result = result.try(a)
      end
      return result
    end

    def format(resource)
      if self.block
        output = self.csv_builder.context.capture(resource, &block)
        return output
      end
      if is_content_column
        case content_type
          when :string
            nested_send(resource)
          when :decimal
            if v=nested_send(resource)
              return "%.2f"%(v)
            else
              return ''
            end
          when :text
            return nested_send(resource)
          when :datetime
            self.name_reflect_datetime(resource)
          when :date
            nested_send(resource).try(:strftime, "%b %d, %Y")
          when :integer
            nested_send(resource)
          when :float
            begin
              return "%.2f"%(nested_send(resource))
            rescue
              return nested_send(resource)
            end
          when :boolean
            nested_send(resource)
          else
            "Unhandled type in table_for_helper"
        end
      else
        if is_belongs_to
          name = nested_send(resource).to_s
          name = 'Untitled' if name.blank?
          if nested_send(resource)
            nested_send(resource)
            #self.csv_builder.context.link_to name, resource.send(attribute)
          else
            ''
          end
        else
          if paperclip_file?(resource,attribute)
            if nested_send(resource).exists?
              return self.csv_builder.context.link_to "Download (#{paperclip_size(resource)})", nested_send(resource).url
            else
              return "<i>No #{attribute}</i>".html_safe
            end
          else
            nested_send(resource)
          end
        end
      end
    end


    def paperclip_size(resource)
      self.csv_builder.context.number_to_human_size(resource.send("#{attribute}_file_size"))
    end

    def paperclip_file?(resource, attribute_name)
      begin
        file = nested_send(resource)
        file && file.class == Paperclip::Attachment
      rescue
        false
      end
    end

    def name_reflect_datetime(resource)
      if attribute.to_s["_on"]
        d = nested_send(resource).try(:strftime, "%b %d, %Y")
      end
      d = nested_send(resource).try(:strftime, "%b %d, %Y %I:%M %p %Z")
    end

  end

  class CsvBuilder

    attr_accessor :context, :columns, :resources, :table_options,
                  :content_columns, :belongs_to, :column_names, :bt_names,
                  :resource_klass, :actions, :paginate, :searchable, :filtered_resources,
                  :current_ability, :apply_abilities, :search, :page_size, :filters,
                  :klass

    def initialize(context, resources, options)
      self.context = context
      self.resources = resources

      self.filtered_resources = resources
      self.columns = []
      self.table_options = options
      self.actions = []
      self.current_ability = context.current_ability

      self.apply_abilities = options[:apply_abilities]
      self.apply_abilities = true if self.apply_abilities.nil?
      self.setup_abilities if self.apply_abilities

      self.setup_ransack unless options[:ransack_obj]


      if self.resources.length > 0
        resource = resources.first
        self.klass = resource.class
        self.resource_klass = resource.class.name.underscore
        self.content_columns = resource.class.content_columns || []
        self.column_names = self.content_columns.map {|x|x.name.to_s} || []
        self.belongs_to = resource.class.reflect_on_all_associations(:belongs_to)
        self.bt_names = self.belongs_to.map {|x|x.name.to_s}
      end

      ""
    end

    def setup_abilities
      self.filtered_resources = self.filtered_resources.accessible_by(self.current_ability)
    end

    def ransack_key
      table_options[:ransack_key] || "q_#{resources.first.class.name.underscore}"
    end

    def setup_ransack
      self.table_options[:ransack_obj] = self.filtered_resources.ransack(self.context.params[self.ransack_key.to_sym], search_key: self.ransack_key.to_sym)
      self.filtered_resources = self.table_options[:ransack_obj].result(distinct: true)
    end

    # def define(attribute, *args)
    def column(attribute, *args, &block)
      if self.filtered_resources.length == 0
        return ""
      end
      column_options = args.extract_options!
      c = ColumnBuilder.new(self, attribute, column_options, table_options, block)
      self.columns.append(c)
      ""
    end

    def content_column?(attribute)
      self.column_names.include?(attribute.to_s)
    end

    def belongs_to?(attribute)
      self.bt_names.include?(attribute.to_s)
    end

    def reflection(attribute)
      self.belongs_to.select{ |x| x.name.to_sym == attribute.to_sym}.first
    end

    def content_type(attribute)
      if attribute["."]
        'string'
      else
        aname = attribute.to_s
        self.content_columns.select {|c| c.name.to_s == aname}.first.try(:type) || "reference"
      end
    end

    def render
      CSV.generate(encoding: 'utf-8') do |row|
        row << self.columns.map {|x|x.nested_title}
        self.filtered_resources.each do |r|
          row << column_body(r)
        end
      end
    end

    def column_body(resource)
      self.columns.map {|c| c.cell_body(resource)}
    end

  end

end
