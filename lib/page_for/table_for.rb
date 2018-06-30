module TableFor
  class TableBuilder

    attr_accessor :page, :context, :columns, :resources, :table_options,
                  :content_columns, :column_names,
                  :actions,
                  :paginate, :page_size, :kaminari_key,
                  :searchable, :search, :filters, :ransack_key, :ransack_obj,
                  :current_ability, :apply_abilities, :filtered_resources,
                  :belongs_to, :belongs_to_names,
                  :klass, :klass_name, :freeze_header, :table_id, :row_html_options,
                  :viewport

    def initialize(page, resources, options, table_id)
      self.page = page
      self.context = page.context
      self.table_id = table_id
      self.resources = resources
      self.filtered_resources = resources
      self.columns = []
      self.table_options = options
      self.actions = []
      self.current_ability = context.current_ability
      self.filters = []

      self.paginate = true
      self.paginate = options[:paginate] unless options[:paginate] == nil
      self.page_size = options[:page_size] unless options[:page_size] == nil

      self.freeze_header = true
      self.freeze_header = options[:freeze_header] if options[:freeze_header] != nil

      self.apply_abilities = true
      self.apply_abilities = options[:apply_abilities] if options[:apply_abilities] != nil

      self.searchable = true
      self.searchable = options[:searchable] if options[:searchable] != nil

      self.viewport = true
      self.viewport = options[:viewport] if options[:viewport] != nil

      self.ransack_key = options[:ransack_key] ||= "q_#{self.table_id}"
      self.ransack_obj = options.fetch(:ransack_obj, instance_variable_get("@#{ransack_key}"))
      self.kaminari_key = "p_#{self.table_id}"

      self.klass = resources.klass
      self.klass_name = self.klass.name.demodulize.underscore

      self.content_columns = self.klass.content_columns || []
      self.column_names = self.content_columns.map { |x| x.name.to_s } || []

      self.belongs_to = self.klass.reflect_on_all_associations(:belongs_to)
      self.belongs_to_names = self.belongs_to.map {|x|x.name.to_s}
      self.row_html_options = options[:row_html_options]
    end

    def html
      self.context.render_page_for(partial: "table", locals: { table_builder: self, resources: self.resources, page: self.page })
    end

    def resource_action_sheet_id(resource)
      "ActionSheet_T#{self.table_id}_R#{resource.id}"
    end

    def ransack_obj
      # If @ransack_obj is passed in via options, we're not going to alter it
      # If filtered_resources is called before ransack_obj, @ransack_obj will be created (relying on that here!)
      # If ransack_obj is called before filtered_resources, go ahead and build the whole filtered_resources to ensure @ransack_obj is built
      return @ransack_obj if @ransack_obj
      setup_resources
      @ransack_obj
    end

    def filtered_resources
      # Only run setup once
      return @filtered_resources if @filtered_resources
      setup_resources
    end

    def setup_resources
      @filtered_resources = resources
      self.setup_abilities
      self.setup_ransack
      self.setup_kaminari
      @filtered_resources
    end

    def setup_abilities
      return @filtered_resources unless apply_abilities
      @filtered_resources = @filtered_resources.accessible_by(self.current_ability)
    end

    def setup_ransack
      # passing @ransack_obj in options does 2 things:
      #   1) provides the ransack_obj for later use
      #   2) prevents filtering results by a default ransack obj
      # make sure you don't change that behavior
      return @filtered_resources if @ransack_obj
      default_params = filters.reduce({}){|memo, f| memo.merge(f.ransack_default_params)}
      # pp default_params
      if ::ActiveRecord::VERSION::MAJOR >= 5 && context.params.respond_to?(:to_unsafe_h)
        extra_params = context.params.to_unsafe_h[ransack_key.to_sym] || {}
      else
        extra_params = context.params[ransack_key.to_sym] || {}
      end
      ransack_params = default_params.merge(extra_params).presence
      # pp ransack_params
      @ransack_obj = @filtered_resources.search(ransack_params, search_key: ransack_key.to_sym)
      @filtered_resources = ransack_obj.result()
    end

    def setup_kaminari
      if paginate
        @filtered_resources = @filtered_resources.page(self.context.params[self.kaminari_key.to_sym])
        @filtered_resources = @filtered_resources.per(self.page_size) if self.page_size
      end
    end

    # Useful for creating params for filters on the table
    def ransack_params(field, value)
      {self.ransack_key=> {"#{field}_eq"=>value}}
    end

    def filter(attribute, *args, &block)
      # return nil if self.filtered_resources.size == 0
      # need filters to show dropdowns, even if blank

      filter_options = args.extract_options!
      f = FilterBuilder.new(self, attribute, filter_options, block)
      self.filters.append(f)

      nil
    end

    def column(attribute, *args, &block)
      # return nil if self.filtered_resources.size == 0
      # need filters to build default ransack, even if blank

      column_options = args.extract_options!
      column_options[:hidden]= false
      c = ColumnBuilder.new(self, attribute, column_options, table_options, block)
      self.columns.append(c)

      nil
    end

    def action(attribute, *args, &block)
      return nil if self.filtered_resources.size == 0

      button_options = args.extract_options!
      c = ActionBuilder.new(self, attribute, button_options, block)
      self.actions.append(c)

      nil
    end

    def hidden_phone_column(attribute, *args, &block)
      # return nil if self.filtered_resources.size == 0
      # need filters to build default ransack, even if blank

      column_options = args.extract_options!
      column_options[:class]= 'hidden-phone'
      column_options[:hidden]= true
      c = ColumnBuilder.new(self, attribute, column_options, table_options, block)
      self.columns.append(c)

      nil
    end

    def content_column?(attribute)
      self.column_names.include?(attribute.to_s)
    end

    def belongs_to?(attribute)
      self.belongs_to_names.include?(attribute.to_s)
    end

    def reflection(attribute)
      self.belongs_to.select{ |x| x.name.to_sym == attribute.to_sym }.first
    end

    def content_type(attribute)
      if attribute["."]
        'string'
      else
        aname = attribute.to_s
        return :enumerize if self.klass.respond_to?(:enumerized_attributes) && self.klass.enumerized_attributes[aname]
        self.content_columns.select { |c| c.name.to_s == aname} .first.try(:type) || "reference"
      end
    end

    def table_class
      if self.freeze_header
        "freeze-header"
      else
        ""
      end
    end

    def render
      self.context.render_page_for(partial: "table_for/container", locals: { table_builder: self })
    end

    def render_table
      if self.filtered_resources.size == 0
        self.context.render_page_for(partial: "table_for/no_items")
      else
        self.context.render_page_for(partial: "table_for/table", locals: { table_builder: self })
      end
    end

    def row_attributes(resource)
      if row_html_options.is_a?(Proc)
        self.row_html_options.call(resource)
      else
        self.row_html_options || {}
      end
    end

    def render_search_bar
      if self.searchable
        self.context.render_page_for(partial: "table_for/search", locals: { table_builder: self, placeholder: "Search #{self.klass_name.pluralize.titleize}...", filters: filters })
      end
    end

    def ransack_cont_fields
      return self.searchable if self.searchable.is_a?(String) && self.searchable.present?
      fnames = self.columns.map {|c|c.attribute}
      fields = self.resources.klass.content_columns.select { |c| fnames.include?(c.name.to_sym) and c.type == :string || c.type == :text }.map { |c| c.name }
      fields += self.columns.select {|c|c.attribute["."]}.map {|c|c.attribute.gsub(".","_")}
      fields.join("_or_") + "_cont"
    end

    def render_pagination
      return '' unless self.paginate
      self.context.paginate self.filtered_resources, param_name: kaminari_key, :theme => PageFor.configuration.theme
    end

  end

  class ActionBuilder

    attr_accessor :table_builder, :label, :url_options,
                  :class, :action, :method,
                  :resource, :url, :block, :phone_class,
                  :remote, :nester, :params, :target,
                  :path

    def initialize(table_builder, action, options, block)
      self.action = action.to_s.underscore.to_sym
      self.table_builder = table_builder
      self.label = options[:label] || action.to_s.titleize
      self.remote = options[:remote] || false
      self.target = options[:target] || nil
      self.class = options[:class] || 'btn btn-sm btn-default'
      self.method = options[:method] || nil
      self.phone_class = options[:phone_class] || 'page_links'
      self.nester = options[:nester] || nil
      self.params = options[:params] || {}
      self.path = options[:path] || nil


      self.action = :show if self.action == :view

      self.block = block
    end

    def url(resource)

      trgt = [self.nester, resource].compact

      if self.path
        if path.is_a?(Proc)
          self.url = path.call(resource)
        else
          self.url = self.table_builder.context.send(self.path, [trgt].flatten, self.params)
        end
      else
        if self.action == :show
          self.url = self.table_builder.context.polymorphic_path([trgt].flatten, self.params)
        else
          self.url = self.table_builder.context.polymorphic_path([action.to_sym, trgt].flatten, self.params)
        end
      end

    end

    def render(resource)
      self.table_builder.context.render_page_for(partial: "table_for/action_builder/action", locals: { table_builder: self.table_builder, action_builder: self, resource: resource })
    end

    def render_dropdown(resource)
      self.table_builder.context.render_page_for(partial: "table_for/action_builder/dropdown", locals: { table_builder: self.table_builder, action_builder: self, resource: resource })
    end

    def can?(resource)
      self.table_builder.context.can? self.action, resource
    end

  end

  class FilterBuilder
    attr_accessor :table_builder, :attribute, :options, :block, :is_content_column, :is_belongs_to,
                  :content_type, :block, :collection, :class, :custom_options, :ransack_clause, :default,
                  :prompt, :label

    def initialize(table_builder, attribute, options, block)
      self.table_builder = table_builder
      self.attribute = attribute
      self.is_content_column = self.table_builder.content_column?(attribute)
      self.is_belongs_to = self.table_builder.belongs_to?(attribute)
      self.content_type = self.table_builder.content_type(attribute)
      self.block = block
      self.label = options[:label] || self.attribute.to_s.titleize
      self.custom_options = options[:options]
      self.ransack_clause = (options[:ransack_clause] || "#{self.attribute}_eq").to_s
      self.default = options[:default]
      self.prompt = options[:prompt].presence || "-- #{self.label} --"
      self.class = options[:class]
    end

    def render(form)
      if custom_options.present?
        return render_custom(form)
      end
      if is_content_column
        return render_content_column(form)
      end
      if is_belongs_to
        return render_belongs_to(form)
      end
    end

    def ransack_default_params
      default ? { ransack_clause => default } : {}
    end

    def render_custom(form)
      tb = self.table_builder
      c = tb.context
      values = custom_options
      value = (c.params[tb.ransack_key.to_sym] || {}).fetch(ransack_clause, default)
      options = c.options_for_select(values, value)

      return c.select_tag "#{tb.ransack_key}[#{ransack_clause}]", options, { include_blank: true, prompt: prompt }
    end

    def render_content_column(form)
      if self.content_type == :string || self.content_type == :text
        return render_cont(form)
      end
      if self.content_type == :datetime
        return render_datetime(form)
      end
      if self.content_type == :decimal || self.content_type == :float || self.content_type == :integer
        return render_numeric(form)
      end
    end

    def render_cont(form)
      ""
    end

    def render_numeric(form)

    end

    def render_datetime(form)

    end

    def render_belongs_to(form)
      tb = self.table_builder
      c = tb.context
      reflection = tb.reflection(self.attribute)
      unique_sql = tb.resources.all.tap{|r| r.select_values.clear}.select(reflection.foreign_key).distinct
      #unique_sql = tb.resources.distinct.to_sql
      values = reflection.klass.where(reflection.klass.primary_key => unique_sql)

      predicated_reflection = "#{reflection.foreign_key}_eq".to_sym
      begin
        value = c.params[tb.ransack_key.to_sym][predicated_reflection]
      rescue Exception=>e
      end

      return c.select_tag "#{tb.ransack_key}[#{predicated_reflection}]", c.options_from_collection_for_select(values, reflection.klass.primary_key, :to_s, selected: value), { include_blank: true, prompt: prompt }
    end

  end

  class ColumnBuilder
    attr_accessor :table_builder, :attribute, :options, :block,
                  :content_type, :is_belongs_to, :is_content_column,
                  :cell_class, :header_class, :cell_options, :table_options,
                  :hidden

    def initialize(table_builder,attribute,cell_options, table_options,block)
      self.table_options = table_options
      self.table_builder = table_builder
      self.attribute = attribute
      self.is_content_column = cell_options[:content_type] ? true : self.table_builder.content_column?(attribute)
      self.is_belongs_to = self.table_builder.belongs_to?(attribute)
      self.block = block
      self.cell_options = cell_options
      self.content_type = cell_options[:content_type] || self.table_builder.content_type(attribute)
      self.hidden = cell_options[:hidden]
      cell_type_classes = [self.content_type]
      cell_type_classes << 'number' if ['decimal', 'float', 'integer'].include?(content_type.to_s)
      td_classes = cell_type_classes.map{|c| ["tblfor_#{c}", "tblfor_td_#{c}"]}.flatten
      td_classes << cell_options[:class] if cell_options[:class].present?
      th_classes = cell_type_classes.map{|c| ["tblfor_#{c}", "tblfor_th_#{c}"]}.flatten
      th_classes << cell_options[:class] if cell_options[:class].present?
      self.cell_class = td_classes.join(' ')
      self.header_class = th_classes.join(' ')
    end

    def if_hidden(hidden_class)
      if hidden
        hidden_class
      else
        ''
      end
    end


    def cell_body(resource)
      table_builder.context.render_page_for(partial: "table_for/column_builder/body_row", locals: { column_builder: self, resource: resource })
    end

    def header_body
      table_builder.context.render_page_for(partial: "table_for/column_builder/header_row", locals: { column_builder: self })
    end

    def sort_link
      if table_builder.ransack_obj
        self.table_builder.context.sort_link(self.table_builder.ransack_obj, self.sort_link_attribute, self.sort_link_title)
      end
    end

    def sort_link_attribute
      cell_options[:sort] || self.attribute.to_s.gsub('.','_')
    end

    def sort_link_title
      cell_options[:header].to_s.presence || self.nested_title
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
        output = self.table_builder.context.capture(resource, &block)
        return output
      end
      if is_content_column
        if PageFor::Format.respond_to?(content_type)
          PageFor::Format.send(content_type, nested_send(resource), table_options)
        else
          "Unhandled type in table_for_helper"
        end
      else
        if is_belongs_to
          name = nested_send(resource).to_s
          name = 'Untitled' if name.blank?
          if nested_send(resource)
            nested_send(resource)
            #self.table_builder.context.link_to name, resource.send(attribute)
          else
            ''
          end
        else
          if paperclip_file?(resource,attribute)
            if nested_send(resource).exists?
              return self.table_builder.context.link_to "Download (#{paperclip_size(resource)})", nested_send(resource).url
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
      self.table_builder.context.number_to_human_size(resource.send("#{attribute}_file_size"))
    end

    def paperclip_file?(resource, attribute_name)
      begin
        file = nested_send(resource)
        file && file.class == Paperclip::Attachment
      rescue
        false
      end
    end
  end
end
