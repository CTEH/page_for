module EditableTableForHelper

  # REQUIREMENTS
  # https://github.com/ryanb/nested_form

  #   = render 'errors', object: @workflow
  #
  #   = f.input :name
  #
  #   h3 Workflow Statuses
  #   = editable_table_for f, :workflow_statuses do |t|
  #     - t.sort_on :position
  #     - t.input :name
  #     - t.input :is_default
  #     - t.input :is_closed
  #     - t.input :assign_to
  #     - t.input :restrict_to_assigned

  def editable_table_for(form, has_many_method, *args)
    builder = EditableTableBuilder.new(self, form, has_many_method, args)
    yield(builder)
    render_page_for(partial: "editable_table", locals: {builder: builder})
  end

  class EditableTableBuilder
    attr_accessor :sort_args, :inputs, :f, :has_many_method, :options,
                  :unique_new_flag, :table_id, :tr_class, :delete_if_can,
                  :context

    def initialize(context, form, has_many_method, args)
      self.context, self.f, self.has_many_method, self.options = context, form, has_many_method, args.dup.extract_options!
      self.inputs = []
      self.unique_new_flag = SecureRandom.uuid.gsub('-','')
      self.table_id = SecureRandom.uuid.gsub('-','')
      self.tr_class = SecureRandom.uuid.gsub('-','')
      self.delete_if_can = false
    end

    ##################################
    ## BUILDER METHODS
    ##################################

    def input(field, *args)
      if args.length == 0
        args = [ {size: 25} ]
      end
      self.inputs << {field: field, args: args}
    end

    def sort_on(*args)
      self.sort_args = args
    end

    def delete_link_if_can
      self.delete_if_can = true
    end

    #####################################
    ## VIEW METHODS
    #####################################

    def data
      self.f.object.send(has_many_method).reorder(*sort_args)
    end


  end

end
