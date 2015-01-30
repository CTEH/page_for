module LogicpointHelper

  # - logicpoint_for form do |lp|
  #   - lp.field_compare(:f1, '==', :f2)
  #   - lp.value_compare(f1,'==', 'Cat')
  #   - lp.value_in(f1, collection)
  #   - lp.show :field
  #   - lp.show :field
  #   - lp.enable :field

  def logicpoint_for(form)
    builder = LogicpointBuilder.new(form)
    yield(builder)
    render_page_for(partial: "logicpoint", locals: {builder: builder})
  end

  class LogicpointBuilder
    attr_accessor :form, :field_compares, :value_compares, :value_ins, :shows,
                  :is_blanks, :not_blanks, :enables, :uuid, :property_compares

    # TODO: is_blank, not_blank

    def initialize(form)
      self.form, self.property_compares, self.field_compares, self.value_compares, self.shows = form, [], [], [], []
      self.enables, self.value_ins, self.is_blanks, self.not_blanks = [],[],[],[]
      self.uuid = SecureRandom.uuid.gsub('-','')
    end

    #################################################
    ## BUILDER METHODS
    #################################################

    def show(f)
      self.shows << f
    end

    def enable(f)
      self.enables << f
    end

    def value_in(f1, collection)
      self.value_ins << {f1:f1, collection: collection}
    end

    def value_compare(f1, jscript_operator, v)
      self.value_compares << {f1:f1, v:v, jscript_operator: jscript_operator}
    end

    def property_compare(f1, property, jscript_operator, v)
      self.property_compares << {f1:f1, property: property, v:v, jscript_operator: jscript_operator}
    end

    def field_compare(f1, jscript_operator, f2)
      self.field_compares << {f1:f1, f2:f2, jscript_operator: jscript_operator}
    end

    def is_checked(f1)
      self.property_compare(f1, 'checked', '==', true)
    end

    def not_checked(f1)
      self.property_compare(f1, 'checked', '==', false)
    end

    def is_blank(f1)
      self.is_blanks << {f1:f1}
    end

    def not_blank(f1)
      self.not_blanks << {f1:f1}
    end

    #################################################
    ## VIEW HELPERS
    #################################################

    def jscript_condition
      (value_ins.map {|x| value_in_jscript(x)} +
       value_compares.map {|x| value_compare_jscript(x)} +
       property_compares.map {|x| property_compare_jscript(x)} +
       field_compares.map {|x| field_compare_jscript(x)} +
       is_blanks.map {|x| is_blank_jscript(x)} +
       not_blanks.map {|x| not_blank_jscript(x)}
       ).join(' && ').html_safe
    end

    def watched_fields_selector
      (single_fields + double_fields).map {|x| "##{field_id(x)}"}.join(',')
    end

    def show_fields_selector
      self.shows.map {|x| ".#{field_id(x)}"}.join(',')
    end

    def enable_fields_selector
      self.enables.map {|x| "##{field_id(x)}"}.join(',')
    end

    private

    def field_id(x)
      "#{form.object_name}_#{x}"
    end

    def field_jquery_value(x)
      "$('##{field_id(x)}').val()"
    end

    def field_jquery_property(x, property)
      "$('##{field_id(x)}').prop(#{property.inspect})"
    end

    def value_in_jscript(x)
      f1 = field_jquery_value(x[:f1])
      collection = x[:collection].to_json
      "#{collection}.indexOf(#{f1}) != -1"
    end

    def property_compare_jscript(x)
      f1 = field_jquery_property(x[:f1], x[:property])
      v =x[:v]
      jscript_operator = x[:jscript_operator]
      value_compare_helper(f1,jscript_operator,v)
    end

    def value_compare_jscript(x)
      f1 = field_jquery_value(x[:f1])
      v =x[:v]
      jscript_operator = x[:jscript_operator]
      value_compare_helper(f1,jscript_operator,v)
    end

    def value_compare_helper(f1,jscript_operator,v)
      if v.is_a? Integer
        return "Number(#{f1}) #{jscript_operator} #{v.to_json}"
      end
      if v.is_a? Float
        return "Number(#{f1}) #{jscript_operator} #{v.to_json}"
      end
      if v.is_a? String
        return "#{f1} #{jscript_operator} #{v.to_json}"
      end
      if v.is_a? TrueClass
        return "#{f1} #{jscript_operator} #{v.to_json}"
      end
      if v.is_a? FalseClass
        return "#{f1} #{jscript_operator} #{v.to_json}"
      end
      raise "Unable to support value_compare for #{v.class} #{v.inspect}"
    end

    def field_compare_jscript(x)
      f1 = field_jquery_value(x[:f1])
      f2 = field_jquery_value(x[:f2])
      jscript_operator = x[:jscript_operator]
      "#{f1} #{jscript_operator} #{f2}"
    end

    def is_blank_jscript(x)
      f1 = field_jquery_value(x[:f1])
      "(#{f1} == null || #{f1}.length === 0)"
    end

    def not_blank_jscript(x)
      "!(#{is_blank_jscript(x)})"
    end

    def single_fields
      (self.property_compares + self.value_compares + self.value_ins + self.is_blanks + self.not_blanks).map {|x| x[:f1]}
    end

    def double_fields
      self.field_compares.map {|x| [x[:f1], x[:f2]]}.flatten
    end

  end

end
