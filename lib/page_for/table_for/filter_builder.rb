module TableFor
  class FilterBuilder
    attr_accessor :filter_options, :table_builder, :attribute, :options, :block, :is_content_column, :is_belongs_to,
                  :content_type, :block, :collection, :class, :html_options, :custom_options, :ransack_clause, :default,
                  :prompt, :label, :multiple, :matcher

    def initialize(table_builder, attribute, options, block)
      self.filter_options = options
      self.table_builder = table_builder
      self.attribute = attribute
      self.is_content_column = self.table_builder.content_column?(attribute)
      self.is_belongs_to = self.table_builder.belongs_to?(attribute)
      self.content_type = self.table_builder.content_type(attribute)
      self.block = block
      self.label = options[:label] || self.attribute.to_s.titleize
      self.custom_options = options[:options]
      self.multiple = !!options[:multiple]
      self.matcher = options[:matcher] || :eq
      if multiple
        self.matcher = if self.matcher.to_sym == :eq
          :in
        elsif self.matcher.to_s["_any"]
          self.matcher
        else
          "#{self.matcher}_any".to_sym
        end
      end
      self.ransack_clause = (options[:ransack_clause] || "#{self.attribute}_#{self.matcher}").to_s
      self.default = options[:default]
      self.prompt = options[:prompt] == false ? false : (options[:prompt].presence || "-- #{self.label} --")
      self.class = options[:class]
      self.html_options = (options[:html_options] || {}).merge(class: options[:class])
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

      return c.select_tag "#{tb.ransack_key}[#{ransack_clause}]", options, { include_blank: true, prompt: prompt, multiple: multiple }
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
      if self.content_type == :boolean
        return render_boolean(form)
      end
    end

    def render_cont(form)
      tb = self.table_builder
      c = tb.context
      values = tb.resources.all.unscope(:select).distinct.reorder(attribute).limit(1000).pluck(attribute)

      predicated_reflection = ransack_clause.to_sym
      begin
        value = c.params[tb.ransack_key.to_sym][predicated_reflection]
      rescue Exception=>e
      end
      
      tag_options = { prompt: prompt, class: "table_for_filter table_for_filter_cont", multiple: multiple }.merge(html_options)
      c.select_tag "#{tb.ransack_key}[#{predicated_reflection}]", c.options_from_collection_for_select(values, :to_s, :to_s, selected: value), tag_options
    end

    def render_numeric(form)

    end

    def render_datetime(form)

    end

    NIL_BOOL = "nilbool"

    def render_belongs_to(form)
      tb = self.table_builder
      c = tb.context
      reflection = tb.reflection(self.attribute)
      unique_sql = tb.resources.all.unscope(:select).select(reflection.foreign_key).distinct
      #unique_sql = tb.resources.distinct.to_sql
      values = reflection.klass.where(reflection.klass.primary_key => unique_sql)

      predicated_reflection = "#{reflection.foreign_key}_eq".to_sym
      begin
        value = c.params[tb.ransack_key.to_sym][predicated_reflection]
      rescue Exception=>e
      end

      tag_options = { prompt: prompt, class: "table_for_filter table_for_filter_bt", multiple: multiple }.merge(html_options)
      return c.select_tag "#{tb.ransack_key}[#{predicated_reflection}]", c.options_from_collection_for_select(values, reflection.klass.primary_key, :to_s, selected: value), tag_options
    end

    def render_boolean(form)
      tb = self.table_builder
      c = tb.context
      values = tb.resources.all.unscope(:select).distinct.reorder(attribute).limit(1000).pluck(attribute)
      value_map = [
        values.include?(nil) ? {db: nil, text: "Not Set", value: NIL_BOOL} : nil, # won't show as option if not nullable; nilbool is always converted to nil by TableBuilder
        {db: true, text: "Yes", value: "t"},
        {db: false, text: "No", value: "f"},
      ].compact

      predicated_reflection = ransack_clause.to_sym
      begin
        value = c.params[tb.ransack_key.to_sym][predicated_reflection]
        db_value = value_map.find{|m| m[:value] == value}&.[](:db)
      rescue Exception=>e
      end

      options = c.options_for_select(value_map.map{|m| [m[:text], m[:value]]}, value)
      tag_options = { prompt: prompt, class: "table_for_filter table_for_filter_bool", multiple: multiple }.merge(html_options)
      c.select_tag "#{tb.ransack_key}[#{predicated_reflection}]", options, tag_options
    end
  end
end