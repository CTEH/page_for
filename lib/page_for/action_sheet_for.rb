module ActionSheetFor

  class ActionBuilder
    attr_accessor :as_builder, :args, :block

    def initialize(as_builder, args, block)
      self.as_builder = as_builder
      self.args = args
      self.block = block
    end

    def name
      if self.block
        self.as_builder.context.capture(&self.block)
      else
        self.args.first.to_s
      end
    end

  end

  class ActionSheetBuilder

    attr_accessor :context, :actions, :action_sheet_id, :klass,
                  :max_xs_length

    # klass: btn-xs
    def initialize(context, klass, id)
      self.context = context
      self.actions = []
      self.action_sheet_id = id
      self.klass=klass
      self.max_xs_length = 4
    end

    # Class for 'Launch Button'
    def css_class(default='')
      if self.klass
        self.klass
      else
        default
      end
    end

    def link_to(*args, &block)
      if block_given?
        self.actions.append(ActionBuilder.new(self, args, block))
      else
        self.actions.append(ActionBuilder.new(self, args, nil))
      end

      ''
    end

    def primary_name_too_long?
      primary_action.name.length > max_xs_length
    end

    def needs_action_sheet?
      multiple_actions? or primary_name_too_long?
    end

    def has_actions?
      self.actions.length > 0
    end

    def multiple_actions?
      self.actions.length > 1
    end

    def primary_action()
      self.actions.first
    end

    def secondary_actions()
      self.actions[1..-1]
    end

  end

end
