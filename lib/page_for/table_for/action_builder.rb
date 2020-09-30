module TableFor
  class ActionBuilder
    attr_accessor :table_builder, :label, :url_options,
                  :class, :action, :method,
                  :resource, :url, :block, :phone_class,
                  :remote, :nester, :params, :target,
                  :path, :data

    def initialize(table_builder, action, options, block)
      self.action = action.to_s.underscore.to_sym
      self.table_builder = table_builder
      self.label = options[:label] || self.action.to_s.titleize
      self.remote = options[:remote] || false
      self.target = options[:target] || nil
      self.class = options[:class] || (self.action == :destroy ? 'btn btn-sm btn-warning' : 'btn btn-sm btn-default')
      self.method = options[:method] || (self.action == :destroy ? :delete : nil)
      self.phone_class = options[:phone_class] || 'page_links'
      self.nester = options[:nester] || nil
      self.params = options[:params] || {}
      self.path = options[:path] || nil
      self.data = options[:data]

      self.action = :show if self.action == :view

      self.block = block
    end

    def url(resource)
      trgt = [nester, resource].compact

      if path
        if path.is_a?(Proc)
          self.url = path.call(resource)
        else
          self.url = table_builder.context.send(path, [trgt].flatten, params)
        end
      else
        if action == :show || action == :destroy
          self.url = table_builder.context.polymorphic_path([trgt].flatten, params)
        else
          self.url = table_builder.context.polymorphic_path([action.to_sym, trgt].flatten, params)
        end
      end
    end

    def render(resource)
      table_builder.context.render_page_for(partial: "table_for/action_builder/action", locals: { table_builder: table_builder, action_builder: self, resource: resource })
    end

    def render_dropdown(resource)
      table_builder.context.render_page_for(partial: "table_for/action_builder/dropdown", locals: { table_builder: table_builder, action_builder: self, resource: resource })
    end

    def can?(resource)
      table_builder.context.can? action, resource
    end

  end
end