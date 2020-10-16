module TableFor
  class TableActionBuilder
    attr_accessor :table_builder, :label, :action_options, :url_options,
                  :class, :action, :method,
                  :resource, :url, :block, :phone_class,
                  :remote, :nester, :params, :target,
                  :path, :data

    def initialize(table_builder, action, options, block)
      self.action = action.to_s.underscore.to_sym
      self.action_options = options
      self.table_builder = table_builder
      self.label = options[:label] || self.action.to_s.titleize
      self.remote = options[:remote] || false
      self.target = options[:target]
      self.class = options[:class] || 'btn btn-sm btn-default'
      self.method = options[:method]
      self.phone_class = options[:phone_class] || 'page_links'
      self.nester = options[:nester]
      self.path = options[:path]
      self.data = options[:data]
      self.block = block
      
      self.params = options[:params] || {}
      self.params = self.params.(self) if self.params.is_a?(Proc)
      if ::ActiveRecord::VERSION::MAJOR >= 5 && self.params.respond_to?(:to_unsafe_h)
        self.params = self.params.to_unsafe_h
      end
    end

    def url
      trgt = [nester, table_builder.klass].compact

      if path
        if path.is_a?(Proc)
          self.url = path.call(self)
        else
          self.url = table_builder.context.send(path, [trgt].flatten, params)
        end
      else
        if action == :export_csv
          p = params.merge(format: :csv)
          p = p.merge(tf_table_id: table_builder.table_id) unless action_options[:skip_table_id]
          self.url = table_builder.context.polymorphic_path([trgt].flatten, p)
        else
          self.url = table_builder.context.polymorphic_path([action.to_sym, trgt].flatten, params)
        end
      end
    end

    def render
      table_builder.context.render_page_for(partial: "table_for/action_builder/action", locals: { table_builder: table_builder, action_builder: self, resource: table_builder.klass })
    end

    def render_dropdown
      table_builder.context.render_page_for(partial: "table_for/action_builder/dropdown", locals: { table_builder: table_builder, action_builder: self, resource: table_builder.klass  })
    end

    def can?(resource)
      table_builder.context.can? action, resource
    end

  end
end