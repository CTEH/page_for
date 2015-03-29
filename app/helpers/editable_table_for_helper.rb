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
  #
  #   options
  #      limit: Pass an array of children you would like to restrict
  #             has many to.
  #
  #      disable_add: Pass true if you don't want an add button

  def editable_table_for(form, has_many_method, *args)
    builder = EditableTableBuilder.new(self, form, has_many_method, args)
    yield(builder)
    render_page_for(partial: "editable_table", locals: {builder: builder})
  end

  class EditableTableBuilder
    attr_accessor :sort_args, :inputs, :f, :has_many_method, :options,
                  :unique_new_flag, :table_id, :tr_class, :delete_if_can,
                  :context, :content_columns, :reflection, :numerous_id, :sorted

    def initialize(context, form, has_many_method, args)
      self.context, self.f, self.has_many_method, self.options = context, form, has_many_method, args.dup.extract_options!
      self.inputs = []
      self.unique_new_flag = SecureRandom.uuid.gsub('-','')
      self.table_id = SecureRandom.uuid.gsub('-','')
      self.tr_class = SecureRandom.uuid.gsub('-','')
      self.numerous_id = SecureRandom.uuid.gsub('-','')
      self.options = args.extract_options!
      self.sorted = false

      self.reflection = form.object.class.reflect_on_all_associations(:has_many).find {|hm| hm.name == has_many_method.to_sym}
      self.content_columns = reflection.try(:class_name).try(:constantize).try(:content_columns) || []
      self.delete_if_can = false
    end


    ##################################
    ## BUILDER METHODS
    ##################################

    # See simple form #input_field for args

    def input_column(field, *args)
      if args.length == 0
        args = [ {size: 25} ]
      end
      # TODO Mixin class
      column = content_columns.find {|c| c.name.to_s==field.to_s }
      self.inputs << {field: field, args: args, column: column, class: "tblfor_#{column.try(:type)}"}
    end

    def input(field, *args)
      raise "Deprication Error: Too confusing to use simple form api"
    end

    def sort_on(*args)
      self.sorted = true
      self.sort_args = args
    end

    def delete_link_if_can
      self.delete_if_can = true
    end

    #####################################
    ## VIEW METHODS
    #####################################

    def new_record
      self.reflection.class_name.constantize.new
      #dd=DataDefinition.new
      #dd.model_definition_id = self.f.object.id
      #self.f.object.data_definitions.build
      #dd
    end

    def data
      #binding.pry
      if self.options[:data]
        self.options[:data]
      else
        if self.sorted
          self.f.object.send(has_many_method).reorder(*sort_args)
        else
          self.f.object.send(has_many_method)
        end
      end
    end


  end

end
