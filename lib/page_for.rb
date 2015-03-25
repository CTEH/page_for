require "page_for/version"

require 'page_for/format'
require 'page_for/action_sheet_for'
require 'page_for/table_for'
require 'page_for/definition_list_for'
require 'page_for/pivot_for'
require 'page_for/routes_for'
require 'page_for/layout_for'

<<<<<<< HEAD

require 'simple_form_for/adminlte'

# require 'page_for/engine'

module PageFor
  class << self
    attr_accessor :configuration
  end

  def self.root
    File.expand_path('../..', __FILE__)
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
  end

  class Configuration
    attr_accessor :theme

    def initialize
      @theme = 'hyperia'
    end

    def simple_form_for(theme)
      eval("initialize_#{theme}_simple_form_for()")
    end
  end

  self.configure # Configure, with defaults if not explicitly called

  class Engine < ::Rails::Engine
  end

  # A page has secondary content that is a mixture of HTML blocks
  # and structured navigation.
  # The assumption is that a desktop would render in order tree navigation
  # and context intermixed.
  # A 'phone' may choose to omit the HTML content or present it in a modal
  # when the user clicks on a title.

  class SecondaryContent
    attr_accessor :page_builder, :title, :type, :block,
                  :nav_container, :id, :content

    def initialize(page_builder, title, type, id, block)
      self.page_builder = page_builder
      if type=='navigation'
        self.nav_container = self.page_builder.context.active_navigation_item_container({}, &block)
      end
      if type == 'content'
        self.content = self.page_builder.context.capture &block
      end
      self.type = type
      self.title = title
      self.id = id
    end

  end


  class AddButtonBuilder
    attr_accessor :page_builder, :label, :url_options,
                  :child_klass, :method,
                  :resource, :url, :block,
                  :remote, :options

    def initialize(page_builder, child_klass, options, block)
      self.child_klass = child_klass
      self.page_builder = page_builder
      self.resource = self.page_builder.resource
      self.block = block
      self.options = options

      if self.resource.class == Class
        if options[:nester]
          self.url = self.page_builder.context.polymorphic_path([:new, options[:nester], self.child_klass])
        else
          self.url = self.page_builder.context.polymorphic_path([:new, self.child_klass])
        end
      else
        self.url = self.page_builder.context.polymorphic_path([:new, self.resource, self.child_klass ])
      end

      self.remote = options[:remote] || false
      self.label = options[:label] || "Add #{self.child_klass.to_s.titleize}"
      self.method = options[:method] || 'get'
    end

    def css_class(default=nil)
      options[:class] || default || 'btn btn-default'
    end

    def phone_class(default=nil)
      options[:phone_class] || default || 'page_links'
    end


    def render_dropdown
      '<li class="'+self.phone_class+'">'+self.page_builder.context.link_to(self.label, self.url, remote: self.remote, method: self.method) + '</li>'
    end

    def render
      self.page_builder.context.link_to self.label, self.url, method: self.method, class: self.css_class, remote: self.remote
    end

    def can?
      if self.resource.class == Class
        # Collection Action
        self.page_builder.context.can? :create, self.resource
      else
        # Member Action
        # TODO Probably need to be smarter about the has_many method
        association = self.resource.send(self.child_klass.to_s.pluralize)
        obj = association.new
        can_result = self.page_builder.context.can? :create, obj
        # Remove the virtual created object from the association
        association.delete(obj)
        can_result
      end
    end
  end



  class JavascriptButtonBuilder
    attr_accessor :page_builder, :label, :javascript, :phone_class, :class, :icon

    def initialize(page_builder, label, javascript, options)
      self.page_builder = page_builder
      self.javascript = javascript
      self.label = label
      self.class = options[:class] || 'btn btn-sm btn-default'
      self.icon = options[:icon] || nil
      self.phone_class = options[:phone_class] || 'page_links'
    end

    # http://stackoverflow.com/questions/14324919/status-of-rails-link-to-function-deprecation
    # link_to "Greeting", '#', onclick: "alert('Hello world!'); return false", class: "nav_link"

    def render_dropdown
      '<li class="'+self.phone_class+'">'+self.page_builder.context.link_to(iconed_label, '#', onclick: self.javascript) + '</li>'
    end

    def iconed_label
      if self.icon
        "<i class='#{self.icon}'></i> #{label}".html_safe
      else
        self.label
      end
    end

    def render
      self.page_builder.context.link_to iconed_label,'#', class: self.class, onclick: self.javascript
    end

  end


  class ButtonBuilder
    attr_accessor :page_builder, :label, :url_options,
                  :action, :method,
                  :resource, :url, :block,
                  :remote, :params, :nester, :options

    def initialize(page_builder, action, options, block)
      self.action = action.to_s.underscore.to_sym
      self.page_builder = page_builder
      self.resource = self.page_builder.resource
      self.block = block
      self.params = options[:params] || nil
      self.nester = options[:nester] || nil

      if options[:url] == nil
        if self.resource.class.name == 'Class'
          self.url = self.page_builder.context.polymorphic_path([action.to_sym, self.resource], *self.params)
        else
          if action.to_sym != :destroy
            trgt = [self.nester, self.resource].compact
            self.url = self.page_builder.context.polymorphic_path([action.to_sym, trgt].flatten, *self.params)
          else
            trgt = [self.nester, self.resource].compact
            self.url = self.page_builder.context.polymorphic_path(trgt, *self.params)
          end
        end
      else
        self.url = options[:url]
      end

      self.remote = options[:remote] || false
      self.label = options[:label] || self.label = action.to_s.titleize
      self.method = options[:method] || 'get'
      self.options = options
    end

    def css_class(default=nil)
        options[:class] || default || 'btn btn-default'
    end

    def phone_class(default=nil)
      options[:phone_class] || default || 'page_links'
    end

    def render_dropdown
      '<li class="'+self.phone_class+'">'+self.page_builder.context.link_to(self.label, self.url, method: self.method, remote: self.remote) + '</li>'
    end

    def render
      self.page_builder.context.link_to self.label, self.url, method: self.method, class: self.css_class, remote: self.remote
    end

    def can?
      self.page_builder.context.can? self.action, self.resource
    end
  end


  class TabSectionBuilder
    attr_accessor :page, :context, :tab_titles, :tab_contents, :unique, :tab_options, :tab_ids

    def initialize(page)
      self.page = page
      self.context = page.context
      self.tab_titles = []
      self.tab_contents = []
      self.tab_options = []
      self.tab_ids = []
    end

    def tab(title, tab_id, options, &block)
      self.tab_ids << tab_id
      self.tab_options.append(options)
      self.tab_titles.append(title)

      # SET CURRENT TAB OF PAGE PRIOR TO CAPTURING
      self.page.current_tab_id = tab_id
      self.tab_contents.append(self.context.capture &block)
      self.page.current_tab_id = nil
      ''
    end

    def active_tab
      tab_titles.each_with_index do |t, i|
        return i if self.context.params["q_#{t.to_s.gsub(/( )/, '_').underscore.singularize}".to_sym] || self.context.params[:force_active_tab] == t
      end
      return 0
    end

    def acronym(t)
      t.to_s.split().map { |x| x.first.upcase + '.'}.join('')
    end

    def render
      if tab_titles.length > 0
        self.context.render_page_for(partial: "tabs", locals: { tab_section_builder: self })
      else
        ''
      end
    end

    def tab_id(index)
      "tab_#{self.tab_ids[index]}"
    end

  end


  class SectionBuilder
    attr_accessor :page_helper, :title, :block, :nowrap, :content

    def initialize(page_helper, title, block, nowrap=false)
      self.page_helper = page_helper
      self.title = title
      self.block = block
      self.nowrap = nowrap
      self.content = self.page_helper.context.capture(&block).to_s
    end


    def render
      if self.nowrap
        self.content
      else
        self.page_helper.context.render_page_for(partial: "section", locals: { section_builder: self })
      end
    end
  end


  # describe "text"
  # button :action
  # button_add :singular_child_name
  # section "title" do
  # tab "tab_title" do
  class PageBuilder
    attr_accessor :context, :buttons, :title, :description,
                  :page_options, :sections, :tab_section_builder,
                  :resource, :top_tab_section_builder, :secondary_items

    attr_accessor :action_sheet_id, :tab_id, :section_id, :table_id,
                  :current_tab_id, :secondary_item_id, :navigation_renderer

    def initialize(context, resource, options)
      self.page_options = options
      self.context = context
      self.resource = resource
      self.title = build_title if self.title == nil
      self.sections = []
      self.top_tab_section_builder = TabSectionBuilder.new(self)
      self.tab_section_builder =  TabSectionBuilder.new(self)
      self.buttons = []
      self.secondary_items = []
      self.navigation_renderer = SimpleNavigation::Renderer::Base.new({})

      # Initialize ID Incs
      self.action_sheet_id = 0
      self.tab_id = 0
      self.section_id = 0
      self.table_id = 0
      self.current_tab_id = nil
      self.secondary_item_id = 0

      # secondary_items
    end

    def build_title
      if page_options[:title]
        page_options[:title]
      else
        if resource.class == Class
          resource.name.titleize.pluralize
        else
          if resource.id == nil
            "New #{resource.class.name.titleize}"
          else
            "#{resource.class.name.titleize} #{resource.to_s}".html_safe
          end
        end
      end
    end


    def build_xs_title
      if page_options[:title]
        page_options[:title]
      else
        if resource.class == Class
          resource.name.titleize.pluralize
        else
          if resource.id == nil
            "New #{resource.class.name.titleize}"
          else
            resource.class.name.titleize
          end
        end
      end
    end



    def add_button(child_class, *args, &block)
      options = args.extract_options!
      b = AddButtonBuilder.new(self, child_class, options, block)
      self.buttons << b if b.can?
      ''
    end

    def button(action, *args, &block)
      options = args.extract_options!
      b = ButtonBuilder.new(self, action, options, block)
      self.buttons << b if b.can?
      ''
    end

    def javascript_button(label, javascript, *args)
      options = args.extract_options!
      b = JavascriptButtonBuilder.new(self, label, javascript, options)
      self.buttons << b
      ''
    end

    def insert(&block)
      # ADD A RAW SECTION WITH NO WRAPPING HTML
      self.sections << SectionBuilder.new(self,nil,block, true)
      ''
    end

    def section(title=nil, &block)
      self.sections << SectionBuilder.new(self, title, block)
      ''
    end

    def secondary_content(title, &block)
      self.secondary_item_id+=1
      self.secondary_items << SecondaryContent.new(self, title, "content", self.secondary_item_id, block)
    end

    def secondary_navigation(title, &block)
      self.secondary_item_id+=1
      self.secondary_items << SecondaryContent.new(self, title, "navigation", self.secondary_item_id, block)
    end

    def tab(title, *args, &block)
      options = args.extract_options!
      self.tab_id += 1
      self.current_tab_id = self.tab_id
      self.tab_section_builder.tab(title, self.tab_id, options, &block)
      ''
    end

    def top_tab(title, *args, &block)
      options = args.extract_options!
      self.tab_id += 1
      self.current_tab_id = self.tab_id
      self.top_tab_section_builder.tab(title, self.tab_id, options, &block)
      ''
    end

    def describe(description, *args, &block)
      if block
        self.description = self.context.capture(&block)
      else
        self.description = description
      end
      ''
    end

    #############################################################################
    ## Sub-Builders
    #############################################################################

    def definition_list_for(resource, &block)
        builder = DefinitionListFor::DefinitionListBuilder.new(resource, self)
        yield(builder) if block_given?
        self.context.render_page_for(partial: "definition_list", locals: { builder: builder, page: self })
    end

    def action_sheet_for(klass=nil)
      self.action_sheet_id+=1
      builder = ActionSheetFor::ActionSheetBuilder.new(self, klass, self.action_sheet_id)
      yield(builder) if block_given?
      self.context.render_page_for(partial: "action_sheet", locals: { builder: builder, page: self})
    end

    # Options
    # viewport: true,false
    # ransack_obj
    # ransack_key
    def table_for(resources, *args, &block)
      self.table_id += 1
      # no need to render the table if we don't have any items
      if resources.length == 0
        builder = nil
      else
        options = args.extract_options!
        builder = TableFor::TableBuilder.new(self, resources, options, self.table_id)
        yield(builder) if block_given?
      end
      self.context.render_page_for(partial: "table", locals: { table_builder: builder, resources: resources, page: self })
    end

    def table_builder(resources, *args, &block)
      self.table_id += 1
      # no need to render the table if we don't have any items
      if resources.length == 0
        builder = nil
      else
        options = args.extract_options!
        options[:ransack_obj] ||= eval("@q_#{resources.first.class.name.demodulize.underscore}")
        builder = TableFor::TableBuilder.new(self, resources, options, self.table_id)
        yield(builder) if block_given?
      end
      return builder
    end

    def table_render(builder)
      self.context.render_page_for(partial: "table", locals: { table_builder: builder, resources: builder.resources, page: self })
    end

    #############################################################################
    ## Deprecated
    #############################################################################

    def render_page
      self.context.render_page_for(partial: "page", locals: { page_builder: self })
    end

    def render_header
      self.context.render_page_for(partial: "header", locals: { page_builder: self })
    end

    def render_title
      self.context.render_page_for(partial: "title", locals: { page_builder: self })
    end

    def render_buttons
      self.context.render_page_for(partial: "buttons", locals: { page_builder: self })
    end

    def render_title_bar
      self.title + self.render_button_dropdown
    end

    def render_button_dropdown
      if self.buttons.length > 0
        ('<div class="btn-group pull-right" style="margin: 0;">
        <a style="border: 1px solid white;" class="btn dropdown-toggle" data-toggle="dropdown" href="#">
         &nbsp;
        <span class="icon-edit"></span>
         &nbsp;
        </a>
       <ul class="dropdown-menu">' +
            self.buttons.map {|b| b.render_dropdown }.join('') +
            '</ul>
       </div>').html_safe

      else
        ''
      end
    end
  end
end

