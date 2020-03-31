module PivotFor
  class PivotTalley
    attr_accessor :value, :nils, :nonnils
  end

  class PivotTree
    attr_accessor :obj, :contents, :children, :is_root_node, :span, :parent, :group,
                  :current_row, :starting_row, :row_done, :key

    # PivotTree helps package nested headers into nested groupings and unpack them in layers helpful for HTML

    def initialize(obj, groups, key)
      self.group = groups[0]
      self.obj = obj
      self.children = {}
      self.span = nil
      self.parent = false
      self.current_row = 0
      self.starting_row = true
      self.row_done = false
      self.key = key

      if obj
        self.is_root_node = false
        self.contents = self.group.pivot_builder.context.capture(self.obj, &self.group.block).to_s
      else
        self.is_root_node = true
      end
    end

    def to_s
      {self.contents => self.children.values.map {|x|x.to_s}}.inspect
    end

    #####################################################
    ## API
    #####################################################

    def include(obj, groups)
      g = groups.first
      key = g.get_key(obj)

      unless children.has_key?(key)
        children[key] = PivotTree.new(obj,groups,key)
      end
      if groups.length > 1
        children[key].include(obj, groups.last(groups.size-1))
        children[key].parent = self
      end
    end

    ######################################################
    ## RENDER HTML COLUMNS
    ######################################################

    def contents_at(depth)
      if depth==0
        return children.values.map {|c| c.package}
      else
        return children.values.map {|c|c.contents_at(depth-1)}.flatten
      end
    end

    def data_keys
      if children.values.first.children == {}
        return children.keys
      else
        return children.values.map {|c| c.data_keys}.flatten
      end
    end

    ######################################################
    ## RENDER HTML  ROWS
    ######################################################

    def package_next_row
      # grab the tops
      # know your depth
      # skip yourself if your current depth still has children
      # can this be done by recursion, not really because need to wrap in a tr

      if self.children == {}
        self.row_done = true
        return []
      else
        if starting_row
          head = [self.children.values[current_row].package]
          self.starting_row=false
        else
          head = []
        end
        results = head + self.children.values[current_row].package_next_row
        if self.children.values[current_row].row_done
          self.current_row+=1
          self.starting_row=true
          if self.children.values.size == self.current_row
            self.row_done=true
          end
        end
        return results
      end
    end

    ######################################################
    ## RENDER HELPERS
    ######################################################

    def package
      {contents: self.contents,
       spans: self.spans,
       key: self.key}
    end

    def spans
      # If this was called before entire tree was populated then the wrong values would be cached
      if self.span == nil
        self.span= self.compute_spans
      else
        self.span
      end
    end

    def compute_spans
      if self.children != {}
        return self.children.values.map {|c|c.spans}.sum
      else
        return 1
      end
    end


  end

  class PivotRow
    attr_accessor :resources, :key, :groups, :pivot_tree, :pivot_builder, :data_keys,
                  :body_struct, :value_block

    def initialize(pivot_builder, resources)
      self.resources = resources
      self.groups = []
      self.pivot_tree = nil
      self.pivot_builder = pivot_builder
      self.data_keys = nil
    end

    ######################################
    ## API
    ######################################

    def value_key(k)
      self.key = k
      ''
    end

    def collection(resources)
      self.resources = resources
      ''
    end

    def group(method, options = {}, &block)
      prg = PivotRowGroup.new(self, method, options, block)

      # Setup Group Relationships
      prg.parent_group = self.groups.last
      prg.parent_group.child_group = prg if prg.parent_group

      # Store Group in Array
      self.groups << prg
      ''
    end

    ######################################
    ## RENDER HTML
    ######################################


    def render_body()
      self.body_struct = self.pivot_builder.value_builder.body_struct
      html=''
      while true
        packages = self.pivot_tree.package_next_row
        break if packages.blank?
        row_key = packages.last[:key]
        html += content_tag(:tr, render_header(packages)+ render_data(row_key) )
        break if self.pivot_tree.row_done
      end
      return content_tag(:tbody, html.html_safe).html_safe
    end

    def render_header(packages)
      packages.map {|p|
        content_tag(:th,content_tag('div',content_tag('span', p[:contents])), rowspan: p[:spans])}.join.html_safe
    end

    def render_data(row_key)
      cells = []
      for column_key in self.data_keys
        colxrow = [column_key, row_key ]
        data = self.body_struct[colxrow] || []
        chtml = context.capture(data, &self.value_block)
        cells << chtml
      end

      cells.map { |c|
        content_tag(:td, c, id: colxrow.inspect)}.join.html_safe
    end

    ######################################
    ## BUILD
    ######################################

    def build
      self.pivot_tree = PivotTree.new(nil, groups,nil )
      resources.each do |r|
        self.pivot_tree.include(r, groups)
      end
      self.data_keys = self.pivot_builder.column_builder.pivot_tree.data_keys
      self.value_block = self.pivot_builder.value_builder.value_block
    end

    def content_tag(tag, body, *args)
      self.pivot_builder.context.content_tag(tag, body, *args)
    end

    def context
      self.pivot_builder.context
    end

  end

  class PivotRowGroup
    attr_accessor :pivot_column, :value_key, :parent_group, :child_group, :row_span, :method, :block,
                  :resources, :pivot_builder, :header

    def initialize(pivot_column, method, options, block)
      self.header = options[:header]
      self.method = method
      self.pivot_column = pivot_column
      self.row_span = 0
      self.block = block
      self.resources = pivot_column.resources
      self.pivot_builder = self.pivot_column.pivot_builder
    end


    ######################################
    ## BUILD
    ######################################

    def get_key(obj)
      obj.send(method)
    end

  end

  class PivotColumn
    attr_accessor :resources, :key, :groups, :pivot_tree, :pivot_builder, :row_header_size, :options
    def initialize(pivot_builder, resources, options)
      self.resources = resources
      self.groups = []
      self.pivot_tree = nil
      self.pivot_builder = pivot_builder
      self.row_header_size = nil
      self.options = options
    end

    ######################################
    ## API
    ######################################

    def value_key(k)
      self.key = k
      ''
    end

    def collection(resources)
      self.resources = resources
      ''
    end

    def group(method, *args, &block)
      group_options =  args.extract_options!
      prg = PivotColumnGroup.new(self, method, group_options, block)

      # Setup Group Relationships
      prg.parent_group = self.groups.last
      prg.parent_group.child_group = prg if prg.parent_group

      # Store Group in Array
      self.groups << prg
      ''
    end

    ######################################
    ## RENDER HTML
    ######################################

    def render_header()
      0.upto(groups.size-1).map {|depth| render_header_row(depth)}.join().html_safe
    end

    def render_header_row(depth)
      group = self.groups[depth]
      packages = self.pivot_tree.contents_at(depth)
      row_group_header_class = "pivot_for_row_group_header"
      if depth == pivot_builder.column_builder.groups.size - 1
        row_group_headers = (pivot_builder.row_builder.groups.map{|g| content_tag(:th, g.header || '', class: row_group_header_class).html_safe}.join).html_safe
      else
        row_group_headers = (content_tag(:th, '', class: row_group_header_class).html_safe*self.row_header_size).html_safe
      end
      if group.options[:vertical]==true
        html_class = 'rotate-45'
        html_style = ''
      else
        html_class = 'pivot_for_column_header'
        html_style = ''
      end

      headings = packages.map{|p| content_tag(:th, content_tag('div',content_tag('span', p[:contents])), colspan: p[:spans], style: html_style, class: html_class)}.join.html_safe

      content_tag(:tr, row_group_headers + headings)
    end

    ######################################
    ## BUILD
    ######################################

    def build
      self.pivot_tree = PivotTree.new(nil, groups, nil)
      resources.each do |r|
        self.pivot_tree.include(r, groups)
      end
      self.row_header_size = self.pivot_builder.row_builder.groups.size
    end

    def content_tag(tag, body, *args)
      self.pivot_builder.context.content_tag(tag, body, *args)
    end

  end

  class PivotColumnGroup
    attr_accessor :pivot_column, :value_key, :parent_group, :child_group, :row_span, :method, :block,
                  :resources, :pivot_builder, :options

    def initialize(pivot_column, method, options, block)
      self.method = method
      self.options = options
      self.pivot_column = pivot_column
      self.row_span = 0
      self.block = block
      self.resources = pivot_column.resources
      self.pivot_builder = self.pivot_column.pivot_builder
    end


    ######################################
    ## BUILD
    ######################################

    def get_key(obj)
      obj.send(method)
    end

  end

  class PivotValue
    attr_accessor :pivot_builder, :resources, :ckey, :rkey, :tally, :total_block, :tally_block, :value_block,
                  :body_struct, :group_tallys

    def initialize(pivot_builder, resources)
      self.pivot_builder = pivot_builder
      self.resources = resources
      self.body_struct = {}
    end

    ###############################
    ## API
    ###############################

    def column_key(ckey)
      self.ckey = ckey
      ''
    end

    def row_key(rkey)
      self.rkey = rkey
      ''
    end

    def for_tally(&block)
      self.tally_block = block
      ''
    end

    def for_totals(&block)
      self.total_block = block
      ''
    end

    def for_values(&block)
      self.value_block = block
      ''
    end

    ###############################
    ## BUILD
    ###############################

    def build
      # Collect resources into colxrow intersection bins
      self.resources.each do |r|
        colxrow = self.body_key(r)
        if self.body_struct.has_key?(colxrow)
          self.body_struct[colxrow] << r
        else
          self.body_struct[colxrow] = [r]
        end
      end
    end

    def body_key(obj)
      [obj.send(ckey), obj.send(rkey)]
    end

    def group_keys
      # WTF Goes Here?
    end

  end

  class PivotBuilder

    attr_accessor :context, :resources, :grid, :block, :row_builder, :column_builder, :value_builder,
                  :freeze_header

    def initialize(context, resources)
      self.context = context
      self.resources = resources
      self.freeze_header = true
    end

    ######################################
    ## API
    ######################################

    def vertical_headers?
      self.column_builder.groups.select {|g|g.options[:vertical]==true}.length > 0
    end

    def define_rows()
      pr = PivotRow.new(self, self.resources)
      yield(pr)
      self.row_builder = pr
      ''
    end

    def define_columns(*args)
      options = args.extract_options!
      pr = PivotColumn.new(self, self.resources, options)
      yield(pr)
      self.column_builder = pr
      ''
    end

    def define_values()
      v = PivotValue.new(self, self.resources)
      yield(v)
      self.value_builder = v
      ''
    end

    ######################################
    ## RENDER HTML
    ######################################


    def render
      self.build
      c = 'table table-striped table-condensed'
      c+= ' freeze-header' if self.freeze_header
      c+= ' table-header-rotated' if self.vertical_headers?
      content_tag(:table, (content_tag(:thead, render_header) + content_tag(:tbody, render_body)), id: 'rotate', class: c)
    end

    def render_header
      return self.column_builder.render_header
    end

    def render_body
      return self.row_builder.render_body
    end


    ######################################
    ## Private
    ######################################

    def build
      self.column_builder.build
      self.row_builder.build
      self.value_builder.build
    end

    def content_tag(tag, body, *args)
      self.context.content_tag(tag, body, *args)
    end

  end
end