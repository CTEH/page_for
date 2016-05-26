require "active_support/core_ext/object/try"
require "active_support/core_ext/hash/slice"

module ActionDispatch::Routing
  class Mapper

    def actions_for_resources
      Dir.glob(Rails.root.join('config','actions_for_resources','*.rb')).each do |fname|
        instance_eval(File.read(fname))
      end
    end

    def routes_for
      builder = RouteTreeBuilder.new(self)
      yield(builder) if block_given?
      builder.draw_routes
    end
  end
end

class RouteTreeBuilder
  attr_accessor :context, :data
  def initialize(context)
    self.context = context
    self.data = {}
  end

  def add(resources_name, children=[])
    data[resources_name] = children
  end

  def draw_routes
    draw_routes_for(self.data.keys,"/")
  end

  def draw_routes_for(rs,p)
    if rs.present?
      rs.each do |resources_name|
        children = self.data[resources_name]
        # puts "DRAW ROUTES FOR #{p}#{resources_name}"
        self.context.resources resources_name, concerns: ["actions_for_#{resources_name}".to_sym] do
          draw_routes_for(children, "#{p}#{resources_name}/")
        end
      end
    end
  end
end