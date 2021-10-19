def initialize_mdb_simple_form_for
  initialize_default_mdb_simple_form_for
  initialize_bootstrap_mdb_simple_form_for
end

def initialize_default_mdb_simple_form_for
  # *** From generated simple_form.rb simple_form v5.1.0 *** #
  SimpleForm.setup do |config|
    # Wrappers are used by the form builder to generate a
    # complete input. You can remove any component from the
    # wrapper, change the order or even add your own to the
    # stack. The options given below are used to wrap the
    # whole input.
    config.wrappers :default, class: :input,
      hint_class: :field_with_hint, error_class: :field_with_errors, valid_class: :field_without_errors do |b|
      ## Extensions enabled by default
      # Any of these extensions can be disabled for a
      # given input by passing: `f.input EXTENSION_NAME => false`.
      # You can make any of these extensions optional by
      # renaming `b.use` to `b.optional`.

      # Determines whether to use HTML5 (:email, :url, ...)
      # and required attributes
      b.use :html5

      # Calculates placeholders automatically from I18n
      # You can also pass a string as f.input placeholder: "Placeholder"
      b.use :placeholder

      ## Optional extensions
      # They are disabled unless you pass `f.input EXTENSION_NAME => true`
      # to the input. If so, they will retrieve the values from the model
      # if any exists. If you want to enable any of those
      # extensions by default, you can change `b.optional` to `b.use`.

      # Calculates maxlength from length validations for string inputs
      # and/or database column lengths
      b.optional :maxlength

      # Calculate minlength from length validations for string inputs
      b.optional :minlength

      # Calculates pattern from format validations for string inputs
      b.optional :pattern

      # Calculates min and max from length validations for numeric inputs
      b.optional :min_max

      # Calculates readonly automatically from readonly attributes
      b.optional :readonly

      ## Inputs
      # b.use :input, class: 'input', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :label_input
      b.use :hint,  wrap_with: { tag: :span, class: :hint }
      b.use :error, wrap_with: { tag: :span, class: :error }

      ## full_messages_for
      # If you want to display the full error message for the attribute, you can
      # use the component :full_error, like:
      #
      # b.use :full_error, wrap_with: { tag: :span, class: :error }
    end

    # The default wrapper to be used by the FormBuilder.
    config.default_wrapper = :default

    # Define the way to render check boxes / radio buttons with labels.
    # Defaults to :nested for bootstrap config.
    #   inline: input + label
    #   nested: label > input
    config.boolean_style = :nested

    # Default class for buttons
    config.button_class = 'btn'

    # Method used to tidy up errors. Specify any Rails Array method.
    # :first lists the first message for each field.
    # Use :to_sentence to list all errors for each field.
    # config.error_method = :first

    # Default tag used for error notification helper.
    config.error_notification_tag = :div

    # CSS class to add for error notification helper.
    config.error_notification_class = 'error_notification'

    # Series of attempts to detect a default label method for collection.
    # config.collection_label_methods = [ :to_label, :name, :title, :to_s ]

    # Series of attempts to detect a default value method for collection.
    # config.collection_value_methods = [ :id, :to_s ]

    # You can wrap a collection of radio/check boxes in a pre-defined tag, defaulting to none.
    # config.collection_wrapper_tag = nil

    # You can define the class to use on all collection wrappers. Defaulting to none.
    # config.collection_wrapper_class = nil

    # You can wrap each item in a collection of radio/check boxes with a tag,
    # defaulting to :span.
    # config.item_wrapper_tag = :span

    # You can define a class to use in all item wrappers. Defaulting to none.
    # config.item_wrapper_class = nil

    # How the label text should be generated altogether with the required text.
    # config.label_text = lambda { |label, required, explicit_label| "#{required} #{label}" }

    # You can define the class to use on all labels. Default is nil.
    # config.label_class = nil

    # You can define the default class to be used on forms. Can be overriden
    # with `html: { :class }`. Defaulting to none.
    # config.default_form_class = nil

    # You can define which elements should obtain additional classes
    # config.generate_additional_classes_for = [:wrapper, :label, :input]

    # Whether attributes are required by default (or not). Default is true.
    # config.required_by_default = true

    # Tell browsers whether to use the native HTML5 validations (novalidate form option).
    # These validations are enabled in SimpleForm's internal config but disabled by default
    # in this configuration, which is recommended due to some quirks from different browsers.
    # To stop SimpleForm from generating the novalidate option, enabling the HTML5 validations,
    # change this configuration to true.
    config.browser_validations = false

    # Custom mappings for input types. This should be a hash containing a regexp
    # to match as key, and the input type that will be used when the field name
    # matches the regexp as value.
    # config.input_mappings = { /count/ => :integer }

    # Custom wrappers for input types. This should be a hash containing an input
    # type as key and the wrapper that will be used for all inputs with specified type.
    # config.wrapper_mappings = { string: :prepend }

    # Namespaces where SimpleForm should look for custom input classes that
    # override default inputs.
    # config.custom_inputs_namespaces << "CustomInputs"

    # Default priority for time_zone inputs.
    # config.time_zone_priority = nil

    # Default priority for country inputs.
    # config.country_priority = nil

    # When false, do not use translations for labels.
    # config.translate_labels = true

    # Automatically discover new inputs in Rails' autoload path.
    # config.inputs_discovery = true

    # Cache SimpleForm inputs discovery
    # config.cache_discovery = !Rails.env.development?

    # Default class for inputs
    # config.input_class = nil

    # Define the default class of the input wrapper of the boolean input.
    config.boolean_label_class = 'checkbox'

    # Defines if the default input wrapper class should be included in radio
    # collection wrappers.
    # config.include_default_input_wrapper_class = true

    # Defines which i18n scope will be used in Simple Form.
    # config.i18n_scope = 'simple_form'

    # Defines validation classes to the input_field. By default it's nil.
    # config.input_field_valid_class = 'is-valid'
    # config.input_field_error_class = 'is-invalid'
  end
end

def initialize_bootstrap_mdb_simple_form_for
  # *** From generated simple_form_bootstrap.rb simple_form v5.1.0 *** #
  # frozen_string_literal: true

  # Please do not make direct changes to this file!
  # This generator is maintained by the community around simple_form-bootstrap:
  # https://github.com/rafaelfranca/simple_form-bootstrap
  # All future development, tests, and organization should happen there.
  # Background history: https://github.com/heartcombo/simple_form/issues/1561

  # Uncomment this and change the path if necessary to include your own
  # components.
  # See https://github.com/heartcombo/simple_form#custom-components
  # to know more about custom components.
  # Dir[Rails.root.join('lib/components/**/*.rb')].each { |f| require f }

  # Use this setup block to configure all options available in SimpleForm.
  SimpleForm.setup do |config|
    # Default class for buttons
    config.button_class = 'btn'

    # Define the default class of the input wrapper of the boolean input.
    config.boolean_label_class = 'form-check-label'

    # How the label text should be generated altogether with the required text.
    config.label_text = lambda { |label, required, explicit_label| "#{label} #{required}" }

    # Define the way to render check boxes / radio buttons with labels.
    config.boolean_style = :inline

    # You can wrap each item in a collection of radio/check boxes with a tag
    config.item_wrapper_tag = :div

    # Defines if the default input wrapper class should be included in radio
    # collection wrappers.
    config.include_default_input_wrapper_class = false

    # CSS class to add for error notification helper.
    config.error_notification_class = 'alert alert-danger'

    # Method used to tidy up errors. Specify any Rails Array method.
    # :first lists the first message for each field.
    # :to_sentence to list all errors for each field.
    config.error_method = :to_sentence

    # add validation classes to `input_field`
    config.input_field_error_class = 'is-invalid'
    config.input_field_valid_class = 'is-valid'


    # vertical forms
    #
    # vertical default_wrapper
    config.wrappers :vertical_form, tag: 'div', class: 'form-group', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.use :placeholder
      b.optional :maxlength
      b.optional :minlength
      b.optional :pattern
      b.optional :min_max
      b.optional :readonly
      b.use :label
      b.use :input, class: 'form-control', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # vertical input for boolean
    config.wrappers :vertical_boolean, tag: 'fieldset', class: 'form-group', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.wrapper :form_check_wrapper, tag: 'div', class: 'form-check' do |bb|
        bb.use :input, class: 'form-check-input', error_class: 'is-invalid', valid_class: 'is-valid'
        bb.use :label, class: 'form-check-label'
        bb.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
        bb.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
      end
    end

    # vertical input for radio buttons and check boxes
    config.wrappers :vertical_collection, item_wrapper_class: 'form-check', item_label_class: 'form-check-label', tag: 'fieldset', class: 'form-group', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.wrapper :legend_tag, tag: 'legend', class: 'col-form-label pt-0' do |ba|
        ba.use :label_text
      end
      b.use :input, class: 'form-check-input', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # vertical input for inline radio buttons and check boxes
    config.wrappers :vertical_collection_inline, item_wrapper_class: 'form-check form-check-inline', item_label_class: 'form-check-label', tag: 'fieldset', class: 'form-group', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.wrapper :legend_tag, tag: 'legend', class: 'col-form-label pt-0' do |ba|
        ba.use :label_text
      end
      b.use :input, class: 'form-check-input', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # vertical file input
    config.wrappers :vertical_file, tag: 'div', class: 'form-group', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.use :placeholder
      b.optional :maxlength
      b.optional :minlength
      b.optional :readonly
      b.use :label
      b.use :input, class: 'form-control-file', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # vertical multi select
    config.wrappers :vertical_multi_select, tag: 'div', class: 'form-group', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.use :label
      b.wrapper tag: 'div', class: 'd-flex flex-row justify-content-between align-items-center' do |ba|
        ba.use :input, class: 'form-control mx-1', error_class: 'is-invalid', valid_class: 'is-valid'
      end
      b.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # vertical range input
    config.wrappers :vertical_range, tag: 'div', class: 'form-group', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.use :placeholder
      b.optional :readonly
      b.optional :step
      b.use :label
      b.use :input, class: 'form-control-range', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end


    # horizontal forms
    #
    # horizontal default_wrapper
    config.wrappers :horizontal_form, tag: 'div', class: 'form-group row', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.use :placeholder
      b.optional :maxlength
      b.optional :minlength
      b.optional :pattern
      b.optional :min_max
      b.optional :readonly
      b.use :label, class: 'col-sm-3 col-form-label'
      b.wrapper :grid_wrapper, tag: 'div', class: 'col-sm-9' do |ba|
        ba.use :input, class: 'form-control', error_class: 'is-invalid', valid_class: 'is-valid'
        ba.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
        ba.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
      end
    end

    # horizontal input for boolean
    config.wrappers :horizontal_boolean, tag: 'div', class: 'form-group row', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.wrapper tag: 'label', class: 'col-sm-3' do |ba|
        ba.use :label_text
      end
      b.wrapper :grid_wrapper, tag: 'div', class: 'col-sm-9' do |wr|
        wr.wrapper :form_check_wrapper, tag: 'div', class: 'form-check' do |bb|
          bb.use :input, class: 'form-check-input', error_class: 'is-invalid', valid_class: 'is-valid'
          bb.use :label, class: 'form-check-label'
          bb.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
          bb.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
        end
      end
    end

    # horizontal input for radio buttons and check boxes
    config.wrappers :horizontal_collection, item_wrapper_class: 'form-check', item_label_class: 'form-check-label', tag: 'div', class: 'form-group row', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.use :label, class: 'col-sm-3 col-form-label pt-0'
      b.wrapper :grid_wrapper, tag: 'div', class: 'col-sm-9' do |ba|
        ba.use :input, class: 'form-check-input', error_class: 'is-invalid', valid_class: 'is-valid'
        ba.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
        ba.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
      end
    end

    # horizontal input for inline radio buttons and check boxes
    config.wrappers :horizontal_collection_inline, item_wrapper_class: 'form-check form-check-inline', item_label_class: 'form-check-label', tag: 'div', class: 'form-group row', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.use :label, class: 'col-sm-3 col-form-label pt-0'
      b.wrapper :grid_wrapper, tag: 'div', class: 'col-sm-9' do |ba|
        ba.use :input, class: 'form-check-input', error_class: 'is-invalid', valid_class: 'is-valid'
        ba.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
        ba.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
      end
    end

    # horizontal file input
    config.wrappers :horizontal_file, tag: 'div', class: 'form-group row', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.use :placeholder
      b.optional :maxlength
      b.optional :minlength
      b.optional :readonly
      b.use :label, class: 'col-sm-3 col-form-label'
      b.wrapper :grid_wrapper, tag: 'div', class: 'col-sm-9' do |ba|
        ba.use :input, error_class: 'is-invalid', valid_class: 'is-valid'
        ba.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
        ba.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
      end
    end

    # horizontal multi select
    config.wrappers :horizontal_multi_select, tag: 'div', class: 'form-group row', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.use :label, class: 'col-sm-3 col-form-label'
      b.wrapper :grid_wrapper, tag: 'div', class: 'col-sm-9' do |ba|
        ba.wrapper tag: 'div', class: 'd-flex flex-row justify-content-between align-items-center' do |bb|
          bb.use :input, class: 'form-control mx-1', error_class: 'is-invalid', valid_class: 'is-valid'
        end
        ba.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
        ba.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
      end
    end

    # horizontal range input
    config.wrappers :horizontal_range, tag: 'div', class: 'form-group row', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.use :placeholder
      b.optional :readonly
      b.optional :step
      b.use :label, class: 'col-sm-3 col-form-label'
      b.wrapper :grid_wrapper, tag: 'div', class: 'col-sm-9' do |ba|
        ba.use :input, class: 'form-control-range', error_class: 'is-invalid', valid_class: 'is-valid'
        ba.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
        ba.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
      end
    end


    # inline forms
    #
    # inline default_wrapper
    config.wrappers :inline_form, tag: 'span', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.use :placeholder
      b.optional :maxlength
      b.optional :minlength
      b.optional :pattern
      b.optional :min_max
      b.optional :readonly
      b.use :label, class: 'sr-only'

      b.use :input, class: 'form-control', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
      b.optional :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # inline input for boolean
    config.wrappers :inline_boolean, tag: 'span', class: 'form-check mb-2 mr-sm-2', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.use :input, class: 'form-check-input', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :label, class: 'form-check-label'
      b.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
      b.optional :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end


    # bootstrap custom forms
    #
    # custom input for boolean
    config.wrappers :custom_boolean, tag: 'fieldset', class: 'form-group', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.wrapper :form_check_wrapper, tag: 'div', class: 'custom-control custom-checkbox' do |bb|
        bb.use :input, class: 'custom-control-input', error_class: 'is-invalid', valid_class: 'is-valid'
        bb.use :label, class: 'custom-control-label'
        bb.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
        bb.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
      end
    end

    # custom input switch for boolean
    config.wrappers :custom_boolean_switch, tag: 'fieldset', class: 'form-group', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.wrapper :form_check_wrapper, tag: 'div', class: 'custom-control custom-switch' do |bb|
        bb.use :input, class: 'custom-control-input', error_class: 'is-invalid', valid_class: 'is-valid'
        bb.use :label, class: 'custom-control-label'
        bb.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
        bb.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
      end
    end

    # custom input for radio buttons and check boxes
    config.wrappers :custom_collection, item_wrapper_class: 'custom-control', item_label_class: 'custom-control-label', tag: 'fieldset', class: 'form-group', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.wrapper :legend_tag, tag: 'legend', class: 'col-form-label pt-0' do |ba|
        ba.use :label_text
      end
      b.use :input, class: 'custom-control-input', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # custom input for inline radio buttons and check boxes
    config.wrappers :custom_collection_inline, item_wrapper_class: 'custom-control custom-control-inline', item_label_class: 'custom-control-label', tag: 'fieldset', class: 'form-group', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.wrapper :legend_tag, tag: 'legend', class: 'col-form-label pt-0' do |ba|
        ba.use :label_text
      end
      b.use :input, class: 'custom-control-input', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # custom file input
    config.wrappers :custom_file, tag: 'div', class: 'form-group', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.use :placeholder
      b.optional :maxlength
      b.optional :minlength
      b.optional :readonly
      b.use :label
      b.wrapper :custom_file_wrapper, tag: 'div', class: 'custom-file' do |ba|
        ba.use :input, class: 'custom-file-input', error_class: 'is-invalid', valid_class: 'is-valid'
        ba.use :label, class: 'custom-file-label'
        ba.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
      end
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # custom multi select
    config.wrappers :custom_multi_select, tag: 'div', class: 'form-group', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.use :label
      b.wrapper tag: 'div', class: 'd-flex flex-row justify-content-between align-items-center' do |ba|
        ba.use :input, class: 'custom-select mx-1', error_class: 'is-invalid', valid_class: 'is-valid'
      end
      b.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # custom range input
    config.wrappers :custom_range, tag: 'div', class: 'form-group', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.use :placeholder
      b.optional :readonly
      b.optional :step
      b.use :label
      b.use :input, class: 'custom-range', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end


    # Input Group - custom component
    # see example app and config at https://github.com/rafaelfranca/simple_form-bootstrap
    # config.wrappers :input_group, tag: 'div', class: 'form-group', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
    #   b.use :html5
    #   b.use :placeholder
    #   b.optional :maxlength
    #   b.optional :minlength
    #   b.optional :pattern
    #   b.optional :min_max
    #   b.optional :readonly
    #   b.use :label
    #   b.wrapper :input_group_tag, tag: 'div', class: 'input-group' do |ba|
    #     ba.optional :prepend
    #     ba.use :input, class: 'form-control', error_class: 'is-invalid', valid_class: 'is-valid'
    #     ba.optional :append
    #   end
    #   b.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
    #   b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    # end


    # Floating Labels form
    #
    # floating labels default_wrapper
    config.wrappers :floating_labels_form, tag: 'div', class: 'form-label-group', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.use :placeholder
      b.optional :maxlength
      b.optional :minlength
      b.optional :pattern
      b.optional :min_max
      b.optional :readonly
      b.use :input, class: 'form-control', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :label
      b.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # custom multi select
    config.wrappers :floating_labels_select, tag: 'div', class: 'form-label-group', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.use :input, class: 'custom-select', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :label
      b.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end


    # The default wrapper to be used by the FormBuilder.
    config.default_wrapper = :vertical_form

    # Custom wrappers for input types. This should be a hash containing an input
    # type as key and the wrapper that will be used for all inputs with specified type.
    config.wrapper_mappings = {
      boolean:       :vertical_boolean,
      check_boxes:   :vertical_collection,
      date:          :vertical_multi_select,
      datetime:      :vertical_multi_select,
      file:          :vertical_file,
      radio_buttons: :vertical_collection,
      range:         :vertical_range,
      time:          :vertical_multi_select
    }

    # enable custom form wrappers
    # config.wrapper_mappings = {
    #   boolean:       :custom_boolean,
    #   check_boxes:   :custom_collection,
    #   date:          :custom_multi_select,
    #   datetime:      :custom_multi_select,
    #   file:          :custom_file,
    #   radio_buttons: :custom_collection,
    #   range:         :custom_range,
    #   time:          :custom_multi_select
    # }
  end
end
