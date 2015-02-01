module LayoutFor


  # THIS COULD BE USED IN A LOT OF PLACES
  class LinkBuilder
    attr_accessor :context, :args, :block

    def initialize(context, args, block)
      self.context = context
      self.args = args
      self.block = block
    end

    def render(klass=nil)
      classed_link_to(klass, *args, &block)
    end

    def classed_link_to(klass=nil, name = nil, options = nil, html_options = nil, block=nil)
      html_options, options, name = options, name, block if block
      options ||= {}

      html_options = convert_options_to_data_attributes(options, html_options)

      url = context.url_for(options)
      html_options['href'] ||= url
      html_options['class'] = klass

      self.context.content_tag(:a, name || url, html_options, &block)
    end

    # ActionViewHelper made this private so I'm remaking it myself
    def convert_options_to_data_attributes(options, html_options)
      if html_options
        html_options = html_options.stringify_keys
        html_options['data-remote'] = 'true' if self.link_to_remote_options?(options) || link_to_remote_options?(html_options)

        method  = html_options.delete('method')

        add_method_to_attributes!(html_options, method) if method

        html_options
      else
        self.link_to_remote_options?(options) ? {'data-remote' => 'true'} : {}
      end
    end

    # ActionViewHelper made this private so I'm remaking it myself
    def link_to_remote_options?(options)
      if options.is_a?(Hash)
        options.delete('remote') || options.delete(:remote)
      end
    end

  end

  class UserMenuBuilder
    attr_accessor :context, :name, :title, :tagline, :avatar,
                  :links, :profile_link_args, :signout_link_args

    def initialize(context, options)
      self.context = context
      self.name = options[:name]
      self.title = options[:title]
      self.tagline = options[:tagline]
      if options[:avatar] and not options[:avatar].blank?
        self.avatar = options[:avatar]
      else
        self.avatar = '/assets/adminlte_no_avatar.png'
      end
      self.links = []
      self.profile_link_args = nil
      self.signout_link_args = nil
    end

    def link_to(*args)
      self.links << args
    end

    def profile_link_to(*args)
      self.profile_link_args = args
    end

    def signout_link_to(*args)
      self.signout_link_args = args
    end
  end


  class MessageMenuBuilder
    attr_accessor :context, :entries, :icon,
                  :header, :footer,
                  :danger_qty, :warning_qty, :info_qty, :success_qty

    def initialize(context, options)
      self.context = context
      self.icon = options[:icon]
      self.entries = []

      self.danger_qty = 0
      self.warning_qty = 0
      self.info_qty = 0
      self.success_qty = 0
    end

    def qty
      self.danger_qty + self.warning_qty + self.info_qty + self.success_qty
    end

    def label
      if danger_qty > 0
        return 'danger'
      end
      if warning_qty > 0
        return 'warning'
      end
      if success_qty > 0
        return 'success'
      end
      return 'info'
    end

    def header(&block)
      self.header = block
    end

    def footer(&block)
      self.footer = block
    end

    def warning(*args)
      notify(:warning, *args)
    end

    def danger(*args)
      notify(:danger, *args)
    end

    def info(*args)
      notify(:info, *args)
    end

    def success(*args)
      notify(:success, *args)
    end

    def notify(entry_type, *args)

      case entry_type
        when :danger
          self.danger_qty+=1
        when :warning
          self.warning_qty+=1
        when :info
          self.info_qty+=1
        when :success
          self.succss_qty+=1
      end

      options = args.extract_options!
      entries.append({
                         img: options[:img],
                         path: options[:path],
                         title: options[:title],
                         icon: options[:icon],
                         message: options[:message],
                         entry_type: entry_type
                     })
    end

  end

  # OPTIONS:
  #   skin: skin-blue, skin-black
  class LayoutBuilder
    attr_accessor :context, :options, :contextual_nav_container, :message_menus, :usermenu,
                  :name, :skin, :navigation_renderer, :content_block, :search_path,
                  :navbar_block, :content_blocks, :global_nav_container,
                  :contextual_nav_options, :global_nav_options, :contextual_nav_title,
                  :global_nav_title, :bread_crumbs, :layout_icon

    def initialize(context, name, options)
      self.name = name
      self.options = options
      self.context = context
      self.message_menus = []
      self.usermenu = nil
      if options[:skin]
        self.skin = options[:skin]
      else
        self.skin = 'skin-blue'
      end
      self.search_path = nil
      self.content_blocks={}
      self.contextual_nav_container = nil
      self.global_nav_container = nil
      self.bread_crumbs = []
    end

    def title
      name
    end

    # Renders the navigation according to the specified options-hash.
    #
    # The following options are supported:
    # * <tt>:level</tt> - defaults to :all which renders the the sub_navigation
    #   for an active primary_navigation inside that active
    #   primary_navigation item.
    #   Specify a specific level to only render that level of navigation
    #   (e.g. level: 1 for primary_navigation, etc).
    #   Specifiy a Range of levels to render only those specific levels
    #   (e.g. level: 1..2 to render both your first and second levels, maybe
    #   you want to render your third level somewhere else on the page)
    # * <tt>:expand_all</tt> - defaults to false. If set to true the all
    #   specified levels will be rendered as a fully expanded
    #   tree (always open). This is useful for javascript menus like Superfish.
    # * <tt>:context</tt> - specifies the context for which you would render
    #   the navigation. Defaults to :default which loads the default
    #   navigation.rb (i.e. config/navigation.rb).
    #   If you specify a context then the plugin tries to load the configuration
    #   file for that context, e.g. if you call
    #   <tt>render_navigation(context: :admin)</tt> the file
    #   config/admin_navigation.rb will be loaded and used for rendering
    #   the navigation.
    # * <tt>:items</tt> - you can specify the items directly (e.g. if items are
    #   dynamically generated from database).
    #   See SimpleNavigation::ItemsProvider for documentation on what to
    #   provide as items.
    # * <tt>:renderer</tt> - (NOT APPLICABLE) specify the renderer to be used for rendering the
    #   navigation. Either provide the Class or a symbol matching a registered
    #   renderer. Defaults to :list (html list renderer).
    #
    # Instead of using the <tt>:items</tt> option, a block can be passed to
    # specify the items dynamically
    #
    # ==== Examples
    #   navigation do |menu|
    #     menu.item :posts, "Posts", posts_path
    #   end
    #
    def global_navigation(title, *args, &block)
      # Creates an active navigation_item_container much like render_navigation does from
      # https://github.com/codeplant/simple-navigation/blob/master/lib/simple_navigation/helpers.rb
      self.global_nav_options = args.extract_options!
      self.global_nav_title = title
      self.global_nav_container = self.context.active_navigation_item_container(options, &block)
      self.navigation_renderer = SimpleNavigation::Renderer::Base.new(options)
    end

    def contextual_navigation(title, *args, &block)
      # Creates an active navigation_item_container much like render_navigation does from
      # https://github.com/codeplant/simple-navigation/blob/master/lib/simple_navigation/helpers.rb
      self.contextual_nav_title = title
      self.contextual_nav_options = args.extract_options!
      self.contextual_nav_container = self.context.active_navigation_item_container(options, &block)
      self.navigation_renderer = SimpleNavigation::Renderer::Base.new(options)
    end

    def icon(i)
      self.layout_icon = i
    end

    def breadcrumb(*args, &block)
      self.bread_crumbs << LinkBuilder.new(self.context, args, block)
    end

    def message_menu(*args)
      options = args.extract_options!
      mb = MessageMenuBuilder.new(context, options)
      yield(mb)
      message_menus.append(mb)
    end

    def user_menu(*args)
      options = args.extract_options!
      um = UserMenuBuilder.new(context, options)
      yield(um)
      self.usermenu = um
    end

    def register(name, &block)
      content_blocks[name] = block
    end

    def search_action(path)
      self.search_path = path
    end

  end
end