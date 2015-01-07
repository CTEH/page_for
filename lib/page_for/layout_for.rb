module LayoutFor

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
    attr_accessor :context, :options, :navigation_item_container, :message_menus, :usermenu,
                  :name, :skin, :navigation_renderer, :content_block, :search_path,
                  :navbar_block, :content_blocks

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
    def navigation(options={}, &block)
      # Creates an active navigation_item_container much like render_navigation does from
      # https://github.com/codeplant/simple-navigation/blob/master/lib/simple_navigation/helpers.rb
      self.navigation_item_container = self.context.active_navigation_item_container(options, &block)
      self.navigation_renderer = SimpleNavigation::Renderer::Base.new(options)
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