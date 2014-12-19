module SignboardForHelper

  def signboard_for(resources, *args, &block)
    options = args.extract_options!
    builder = SignboardFor::SignBoardBuilder.new(self, resources, options)
    yield(builder) if block_given?
    builder.render.html_safe
  end

end


module SignboardFor

  class SignBoardBuilder
    attr_accessor :context, :resources, :options

    def initialize(context, resources, options)
      self.context = context
      self.resources = resources
      self.options = options
    end

    def link_to(*args)
      self.links << args
    end

    def profile_link_to(*args)
      self.profile = args
    end

    def signout_link_to(*args)
      self.signout = args
    end


  end


end