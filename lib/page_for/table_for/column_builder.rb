module TableFor
  class ColumnBuilder
    attr_accessor :table_builder, :attribute, :options, :block,
                  :content_type, :is_belongs_to, :is_content_column,
                  :cell_class, :header_class, :cell_options, :table_options,
                  :hidden

    def initialize(table_builder,attribute,cell_options, table_options,block)
      self.table_options = table_options
      self.table_builder = table_builder
      self.attribute = attribute
      self.is_content_column = cell_options[:content_type] ? true : self.table_builder.content_column?(attribute)
      self.is_belongs_to = self.table_builder.belongs_to?(attribute)
      self.block = block
      self.cell_options = cell_options
      self.content_type = cell_options[:content_type] || self.table_builder.content_type(attribute)
      self.hidden = cell_options[:hidden]
      cell_type_classes = [self.content_type]
      cell_type_classes << 'number' if ['decimal', 'float', 'integer'].include?(content_type.to_s)
      td_classes = cell_type_classes.map{|c| ["tblfor_#{c}", "tblfor_td_#{c}"]}.flatten
      td_classes << cell_options[:class] if cell_options[:class].present?
      th_classes = cell_type_classes.map{|c| ["tblfor_#{c}", "tblfor_th_#{c}"]}.flatten
      th_classes << cell_options[:class] if cell_options[:class].present?
      self.cell_class = td_classes.join(' ')
      self.header_class = th_classes.join(' ')
    end

    def if_hidden(hidden_class)
      if hidden
        hidden_class
      else
        ''
      end
    end

    def cell_body(resource)
      table_builder.context.render_page_for(partial: "table_for/column_builder/body_row", locals: { column_builder: self, resource: resource })
    end

    def header_body
      table_builder.context.render_page_for(partial: "table_for/column_builder/header_row", locals: { column_builder: self })
    end

    def sort_link
      if table_builder.ransack_obj
        self.table_builder.context.sort_link(self.table_builder.ransack_obj, self.sort_link_attribute, self.sort_link_title)
      end
    end

    def sort_link_attribute
      cell_options[:sort] || self.attribute.to_s.gsub('.','_')
    end

    def sort_link_title
      cell_options[:header].to_s.presence || self.nested_title
    end

    def nested_title
      if self.attribute.to_s["."]
        a = self.attribute.to_s.split('.').reverse
        a.pop
        a.reverse!
        a.join(' ').titleize
      else
        self.attribute.to_s.titlecase
      end
    end

    def nested_send(resource)
      attributes = attribute.to_s.split(".")
      result = resource
      attributes.each do |a|
        result = result.try(a)
      end
      return result
    end

    def format(resource)
      if self.block
        output = self.table_builder.context.capture(resource, &block)
        return output
      end
      if is_content_column
        if PageFor::Format.respond_to?(content_type)
          PageFor::Format.send(content_type, nested_send(resource), table_options)
        else
          "Unhandled type in table_for_helper"
        end
      else
        if is_belongs_to
          name = nested_send(resource).to_s
          name = 'Untitled' if name.blank?
          if nested_send(resource)
            nested_send(resource)
            #self.table_builder.context.link_to name, resource.send(attribute)
          else
            ''
          end
        else
          if paperclip_file?(resource,attribute)
            if nested_send(resource).exists?
              return self.table_builder.context.link_to "Download (#{paperclip_size(resource)})", nested_send(resource).url
            else
              return "<i>No #{attribute}</i>".html_safe
            end
          else
            nested_send(resource)
          end
        end
      end
    end

    def paperclip_size(resource)
      self.table_builder.context.number_to_human_size(resource.send("#{attribute}_file_size"))
    end

    def paperclip_file?(resource, attribute_name)
      begin
        file = nested_send(resource)
        file && file.class == Paperclip::Attachment
      rescue
        false
      end
    end
  end
end