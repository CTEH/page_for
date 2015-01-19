require 'rails/generators/base'
require 'rails/generators/resource_helpers'

module PageFor
  module Generators
    class ScaffoldGenerator < Rails::Generators::NamedBase
      include ::Rails::Generators::ResourceHelpers

      source_root File.expand_path("../templates", __FILE__)

      def view_templates
        template "_layout.html.slim", "app/views/#{plural_file_name}/_layout.html.slim"
        template "_form.html.slim", "app/views/#{plural_file_name}/_form.html.slim"
        template "edit.html.slim", "app/views/#{plural_file_name}/edit.html.slim"
        template "index.html.slim", "app/views/#{plural_file_name}/index.html.slim"
        template "new.html.slim", "app/views/#{plural_file_name}/new.html.slim"
        template "show.html.slim", "app/views/#{plural_file_name}/show.html.slim"
        template "controller.rb", "app/controllers/#{plural_file_name}_controller.rb"
        template "controller_test.rb", "test/controllers/#{plural_file_name}_controller_test.rb"
        template "actions_for_resources.rb.slim", "config/actions_for_resources/actions_for_#{plural_file_name}.rb"
      end

      protected

      def has_many_associations?(cname=nil)
        cn = cname || class_name
        cn.constantize.reflect_on_all_associations(:has_many).map(&:name).length > 0
      end


      def has_many_associations(cname=nil)
        cn = cname || class_name
        cn.constantize.reflect_on_all_associations(:has_many).map(&:name).select {|hm| hm.downcase != 'versions'}
      end

      def belongs_to_associations(cname=nil)
        cn = cname || class_name
        begin
          cn.constantize.reflect_on_all_associations(:belongs_to).map(&:name)
        rescue
          []
        end
      end

      def content_columns(cname=nil)
        cn = cname || class_name
        begin
          cn.constantize.content_columns.map(&:name).map {|c|self.clean(c)}.compact
        rescue
          []
        end
      end

      def clean(c)
        c=c.to_s

        if ['updated_at', 'created_at', 'deleted', 'deleted_at'].include?(c)
          return nil
        else
          if c['_file_name']
            return c.to_s.gsub('_file_name','')
          else
            if c['_file_size'] or c['_updated_at'] or c['content_type']
              return nil
            else
              return c
            end
          end
        end
      end

      def guess_sort_column(cname)
        begin
          n=cname.camelcase.singularize.constantize.content_columns.select {|c| c.name['name'] }.first.try(:name)
          if not n
            n=cname.camelcase.singularize.constantize.content_columns.first.try(:name)
          end
        rescue
          n='name'
        end

        n
      end

    end
  end
end
