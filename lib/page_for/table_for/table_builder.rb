module TableFor
  class TableBuilder

    attr_accessor :page, :context, :columns, :resources, :table_options,
                  :content_columns, :column_names,
                  :actions, :table_actions,
                  :paginate, :page_size, :page_remote, :kaminari_key, :anchors,
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
      self.table_actions = []
      self.current_ability = context.current_ability
      self.filters = []

      self.paginate = true
      self.paginate = options[:paginate] unless options[:paginate] == nil
      self.page_size = options[:page_size] unless options[:page_size] == nil
      self.page_remote = options[:page_remote]

      self.anchors = options.fetch(:anchors, true)

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
      # pp({ransack_params:ransack_params})
      ransack_params = ransack_params&.map{|k,v|
        if v == FilterBuilder::NIL_BOOL
          if k.to_s =~ /_(eq|in)\z/
            [k.to_s.gsub(/_(eq|in)\z/, "_null").to_sym, true]
          else
            [k, nil]
          end
        elsif v.respond_to?(:each)
          if k.to_s =~ /_in\z/ && v.size == 1 && v.include?(FilterBuilder::NIL_BOOL)
            [k.to_s.gsub(/_in\z/, "_null").to_sym, true]
          else
            [k,v]
          end
        else
          [k,v]
        end
      }.to_h.compact
      # pp({ransack_params_after:ransack_params})
      @ransack_obj = @filtered_resources.ransack(ransack_params, search_key: ransack_key.to_sym)
      # pp({ransack_args: @ransack_obj.instance_variable_get(:@scope_args), base: @ransack_obj.base})
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

    def table_action(action, *args, &block)
      return nil if self.filtered_resources.size == 0

      button_options = args.extract_options!
      c = TableActionBuilder.new(self, action, button_options, block)
      self.table_actions.append(c)

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
      !belongs_to?(attribute) && column_names.include?(attribute.to_s)
    end

    def belongs_to?(attribute)
      belongs_to_names.include?(attribute.to_s)
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
      fnames = self.columns.map {|c|c.attribute.to_s}
      fields = self.resources.klass.content_columns
      fields = fields.select { |c| fnames.include?(c.name.to_s) && (c.type == :string || c.type == :text) }.map(&:name)
      fields = fields.reject{|f| f =~ /_or_|_and_/} # fields with _or_ or _and_ are supposed to work, but don't
      fields += self.columns.select {|c|c.attribute["."]}.map {|c|c.attribute.gsub(".","_")}
      fields.join("_or_") + "_cont"
    end

    def render_pagination
      return '' unless self.paginate
      pagination = self.context.paginate self.filtered_resources, param_name: kaminari_key, :theme => PageFor.configuration.theme, remote: page_remote
      pagination = pagination.gsub(/href="([^"]+)"/, "href=\"\\1#t_#{table_id}\"").html_safe if anchors
      pagination
    end
  end
end