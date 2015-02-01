module UltradropHelper

  # - ultradrop_for page, f, :model_id do |ud|
  #  - ud.data @models
  #  - ud.display :name
  #  - ud.value :id
  #  - ud.column :make
  #  - ud.column :foo, output_to: :bar
  #  - ud.filter :make, matches_column: :make, all_on_empty: false

  def ultradrop_for(form, field, *args)
    builder = UltradropBuilder.new(form, field, args)
    yield(builder)
    render_page_for(partial: "ultradrop", locals: {builder: builder})
  end

  class UltradropBuilder
    attr_accessor :filter_field, :filter_matches, :filter_options,
                  :form, :field, :args, :options, :collection, :label_method, :value_method,
                  :populates

    def initialize(form, field, args)
      self.form, self.field, self.args = form, field, args
      self.options = args.dup.extract_options!
      self.collection = self.options[:collection]
      self.populates = []
      if self.options[:label_method]
        self.label_method = self.options[:label_method]
      else
        self.label_method = :to_s
      end
      if self.options[:value_method]
        self.value_method = self.options[:value_method]
      else
        self.value_method = :to_s
      end

    end

    def populate(field, value, proc=nil)
      self.populates << {field: field, value: value, proc: proc}
    end

    def filter(field, matches_column, *args)
      self.filter_field, self.filter_matches, self.filter_options = field, matches_column, args.extract_options!
    end

    def json_data
      collection.map {|r| self.record_data(r)}.to_json.html_safe
    end

    # Return the HTML ID for this drop down
    # TODO: Override if passed in
    def my_input_id
      "#{self.form.object_name}_#{self.field}"
    end

    # Return the HTML ID for field I'm using to filter
    # TODO: Override if passed in
    def filter_input_id
      "#{self.form.object_name}_#{self.filter_field}"
    end

    def record_data(r)
      x={}
      x['_v'] = r.send(self.value_method)
      x['_l'] = r.send(self.label_method)
      self.populates.each do |c|
        if c[:proc]
          x[c[:value]]=c[:proc].call(x)
        else
          x[c[:value]]=r.send(c[:value])
        end
      end
      if self.filter_field
        x[filter_matches] = r.send(self.filter_matches)
      end
      x
    end

  end

end
