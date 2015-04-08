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

    # Get the grid size values for a column
    def self.bootstrap_form_units_for_column(cname, column)
      klass = cname.to_s.classify.constantize
      size_values = {
        xs: column.type == :text ? 12 : 6,
        sm: column.type == :text ? 8 : 4,
        md: column.type == :text ? 4 : 2,
      }
      size_values
    end

    def self.bootstrap_form_units_for_association()
      size_values = {
        xs: 6,
        sm: 4,
        md: 2,
      }
      size_values
    end

    # Get the grid size values for each column of a class for a multi-record form
    def self.bootstrap_form_unit_map(cname)
      klass = cname.to_s.classify.constantize

      size_sums = {}

      belongs_to_array = klass.reflect_on_all_associations(:belongs_to).map do |bt|
        # currently all associations have same size_map, but still need to do the sums
        size_values = EditableTableForHelper::EditableTableBuilder.bootstrap_form_units_for_association

        # sum up the total units for each size as we go
        size_values.each do |size, value|
          size_sums[size] = (size_sums[size] || 0) + value
        end

        [bt.name.to_sym, OpenStruct.new(size_values: size_values, association: bt)]
      end

      columns = klass.content_columns.find_all{|c| clean_content_column_names(c.name).present?}
      columns_array = columns.map do |column|
        size_values = EditableTableForHelper::EditableTableBuilder.bootstrap_form_units_for_column(cname, column)

        # sum up the total units for each size as we go
        size_values.each do |size, value|
          size_sums[size] = (size_sums[size] || 0) + value
        end

        [column.name.to_sym, {size_values: size_values, column: column}]
      end

      result = OpenStruct.new(size_sums: size_sums, belongs_to_associations: Hash[belongs_to_array], columns: Hash[columns_array])
      result
    end

    def self.clean_content_column_names(c)
      c = c.to_s
      return nil if c.in?(%w(updated_at created_at deleted deleted_at)) || c =~ /_file_size|_updated_at|_content_type/
      c.to_s.gsub('_file_name','')
    end


    ##################################
    ## BUILDER METHODS
    ##################################

    # See simple form #input_field for args

    def fields_for_options
      {
        wrapper: :editable_table_form,
        wrapper_mappings: {
          check_boxes: :editable_table_boolean,
          radio_buttons: :editable_table_radio_and_checkboxes,
          file: :editable_table_file_input,
          boolean: :editable_table_boolean,
          select: :editable_table_form,
          string: :editable_table_form,
          decimal: :editable_table_form,
          integer: :editable_table_form,
          date: :editable_table_form,
          datetime: :editable_table_form,
          text: :editable_table_form,
        },
      }
    end

    def input_column(field, *args)
      wrapper_class = args.delete(:wrapper_class)
      column = content_columns.find {|c| c.name.to_s==field.to_s }
      if args.present?
        args[0].reverse_merge!(fields_for_options)
      else
        args = [fields_for_options]
      end

      self.inputs << {field: field, args: args, column: column, class: ["etblfor_#{column.try(:type)}", wrapper_class].compact.join(' ')}
    end

    def input(field, *args)
      raise "Deprecation Error: Too confusing to use simple form api"
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
