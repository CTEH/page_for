module WizardFormHelper

  def wizard(page, simple_form)
    builder = WizardFormBuilder.new(self, page, simple_form, params)
    yield(builder)
    return builder.render
  end

  class WizardSection
    attr_accessor :wizard_builder, :title, :block, :index

    def initialize(wizard_builder, title, index, &block)
      self.wizard_builder = wizard_builder
      self.title = title
      self.block = block
      self.index = index
    end

    def content
      self.wizard_builder.context.capture(self, &block).to_s
    end


    def render
      self.content.html_safe
    end

    def commit_button(label)
      self.wizard_builder.document_ready_set_wz(self.index) +  self.wizard_builder.simple_form.button(:submit, value: label)
    end

  end

  class WizardFormBuilder

    attr_accessor :wizard_sections, :context, :params, :step_count, :simple_form, :page

    def initialize(context, page, simple_form, params)
      self.wizard_sections = []
      self.context = context
      self.params = params
      self.step_count = 0
      self.simple_form = simple_form
      self.page = page
    end

    def document_ready_set_wz(index)
      "
      <script type='text/javascript'>
      $(function() {
        $('input[name=\"wz\"]').val(#{index});
      });
      </script>
      ".html_safe
    end

    def requested_step
      self.params[:wz].to_i || 0
    end

    def previous_section
      requested_step-1
    end

    def next_section
      requested_step+1
    end

    def section(title, *args, &block)
      options = args.extract_options!
      is_complete = options[:is_complete]
      self.step_count+=1
      self.wizard_sections << WizardSection.new(self, title, self.step_count-1, &block)
      if self.requested_step != 0 and self.wizard_sections.length > self.requested_step.to_i
        self.page.title = self.wizard_sections[self.requested_step].title
      end
      if is_complete and is_complete != nil and not is_complete.blank?
        self.page.javascript_button title, "wizard_submit(#{self.step_count-1})", icon: 'icon-ok'
      else
        self.page.javascript_button title, "wizard_submit(#{self.step_count-1})"
      end

      ''
    end

    def render
      render_requested_step + render_navigation + render_jquery
    end

    def render_requested_step
      wizard_sections[requested_step].render
    end

    def render_wz_field
      "<input type='hidden' name='wz'>".html_safe
    end

    def render_navigation
      self.context.content_tag("div", self.context.content_tag("div", previous_button + "&nbsp;&nbsp;&nbsp;".html_safe + next_button, class: 'controls' ),  class: 'wizard control-group')
    end

    def render_jquery
      jquery+render_wz_field
    end

    def next_button
      self.context.button_tag(type: :button, onclick: "wizard_submit(#{next_section});", class:"btn") do
        "Next&nbsp;".html_safe + self.context.content_tag(:i,'', class: "icon-arrow-right").html_safe
      end
      #self.simple_form.button :submit, value: 'next', :input_html => {:onClick => "wizard_submit(#{next_section})"}
    end

    def previous_button
      self.context.button_tag(type: :button, onclick: "wizard_submit(#{previous_section});", class:"btn") do
        self.context.content_tag(:i,'', class: "icon-arrow-left").html_safe + "&nbsp;Previous".html_safe
      end

    end

    def jquery
      "<script type='text/javascript'>

      function set_wz(wz) {
        $('input[name=\"wz\"]').val(wz);
        alert('Submit?');
      }

      function wizard_submit(wz) {
        $('input[name=\"wz\"]').val(wz);
        $('input[name=\"wz\"]').closest(\"form\").submit();
      }
      </script>".html_safe
    end

  end

end