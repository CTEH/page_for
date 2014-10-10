require "page_for/version"

require 'table_for'
require 'definition_list_for'
require 'pivot_for'

module PageFor

  class << self
    attr_accessor :configuration
  end

  def self.root
    File.expand_path('../..', __FILE__)
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :theme

    def initialize
      @theme = 'hyperia'
    end
  end

  class Engine < ::Rails::Engine
  end

  class AddButtonBuilder

    attr_accessor :page_builder, :label, :url_options,
                  :class, :child_klass, :method,
                  :resource, :url, :block, :phone_class,
                  :remote

    def initialize(page_builder, child_klass, options, block)
      self.child_klass = child_klass
      self.page_builder = page_builder
      self.resource = self.page_builder.resource
      self.block = block

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
      self.class = options[:class] || 'btn btn-default'
      self.method = options[:method] || 'get'
      self.phone_class = options[:phone_class] || 'page_links'
    end

    def render_dropdown
      '<li class="'+self.phone_class+'">'+self.page_builder.context.link_to(self.label, self.url, remote: self.remote, method: self.method) + '</li>'
    end

    def render
      self.page_builder.context.link_to self.label, self.url, method: self.method, class: self.class, remote: self.remote
    end

    def can?
      if self.resource.class == Class
        # Collection Action
        self.page_builder.context.can? :create, self.resource
      else
        # Member Action
        # TODO Probably need to be smarter about the has_many method
        obj = self.resource.send(self.child_klass.to_s.pluralize).build
        self.page_builder.context.can? :create, obj
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
                  :class, :action, :method,
                  :resource, :url, :block, :phone_class,
                  :remote, :params, :nester

    def initialize(page_builder, action, options, block)
      self.action = action.to_s.underscore.to_sym
      self.page_builder = page_builder
      self.resource = self.page_builder.resource
      self.block = block
      self.params = options[:params] || nil
      self.nester = options[:nester] || nil
      trgt = [self.nester, self.resource].compact

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
      self.class = options[:class] || 'btn btn-default'
      self.method = options[:method] || 'get'
      self.phone_class = options[:phone_class] || 'page_links'
    end

    def render_dropdown
      '<li class="'+self.phone_class+'">'+self.page_builder.context.link_to(self.label, self.url, method: self.method, remote: self.remote) + '</li>'
    end

    def render
      self.page_builder.context.link_to self.label, self.url, method: self.method, class: self.class, remote: self.remote
    end

    def can?
      self.page_builder.context.can? self.action, self.resource
    end

  end

  class TabSectionBuilder

    attr_accessor :context, :tab_titles, :tab_contents, :unique

    def initialize(context)
      self.context = context
      self.unique = ''
      self.tab_titles = []
      self.tab_contents = []
    end

    def tab(title, &block)
      self.tab_titles.append(title)
      self.tab_contents.append(self.context.capture &block)
      ''
    end

    def active_tab

      tab_titles.each_with_index do |t, i|
        return i if self.context.params["q_#{t.to_s.gsub(/( )/, '_').underscore.singularize}".to_sym] || self.context.params[:force_active_tab] == t
      end

      return 0

    end

    def acronym(t)
      t.to_s.split().map { |x| x.first.upcase + '.'}.join("")
    end

    def render
      if tab_titles.length > 0
        self.context.render_page_for(partial: "tabs", locals: { tab_section_builder: self })
      else
        ''
      end
    end

    def tab_id(index)
      "#{tab_titles[index].to_s.underscore}_tab".gsub(' ','_')
    end

  end


  class SectionBuilder
    attr_accessor :page_helper, :title, :block, :nowrap

    def initialize(page_helper, title, block, nowrap=false)
      self.page_helper = page_helper
      self.title = title
      self.block = block
      self.nowrap = nowrap
    end

    def content
      self.page_helper.context.capture(&block).to_s
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
                  :resource, :top_tab_section_builder

    def initialize(context, resource, options)
      self.page_options = options
      self.context = context
      self.resource = resource
      self.title = build_title if self.title == nil
      self.sections = []
      self.top_tab_section_builder = TabSectionBuilder.new(self.context)
      self.tab_section_builder =  TabSectionBuilder.new(self.context)
      self.buttons = []
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
            "#{resource.class.name.titleize}<span class='hidden-phone'>: #{resource.to_s}</span>"
          end
        end
      end
    end

    def add_button(child_class, *args, &block)
      options = args.extract_options!
      b = AddButtonBuilder.new(self, child_class, options, block)
      self.buttons << b if b.can?
      ""
    end

    def button(action, *args, &block)
      options = args.extract_options!
      b = ButtonBuilder.new(self, action, options, block)
      self.buttons << b if b.can?
      ""
    end

    def javascript_button(label, javascript, *args)
      options = args.extract_options!
      b = JavascriptButtonBuilder.new(self, label, javascript, options)
      self.buttons << b
      ""
    end

    def insert(&block)
      # ADD A RAW SECTION WITH NO WRAPPING HTML
      self.sections << SectionBuilder.new(self,nil,block, true)
      ""
    end

    def section(title=nil, &block)
      self.sections << SectionBuilder.new(self, title, block)
      ""
    end

    def top_tab(title, &block)
      self.top_tab_section_builder.tab(title, &block)
      ""
    end

    def tab(title, &block)
      self.tab_section_builder.tab(title, &block)
      ""
    end

    def describe(description, *args, &block)
      if block
        self.description = self.context.capture(&block)
      else
        self.description = description
      end
      ""
    end

    def render_page
      self.context.render_page_for(partial: "page", locals: { page_builder: self })
    end

    def render_top
      self.context.render_page_for(partial: "title", locals: { page_builder: self })
    end

    def render_buttons
      if self.buttons.length > 0
      end
    end

    def render_title_bar
      self.title + self.render_button_dropdown
    end

    def render_button_dropdown
      if self.buttons.length > 0
        '<div class="btn-group pull-right" style="margin: 0;">
        <a style="border: 1px solid white;" class="btn dropdown-toggle" data-toggle="dropdown" href="#">
         &nbsp;
        <span class="icon-edit"></span>
         &nbsp;
        </a>
       <ul class="dropdown-menu">' +
            self.buttons.map {|b| b.render_dropdown }.join('') +
            '</ul>
       </div>'

      else
        ''
      end
    end

  end

end
