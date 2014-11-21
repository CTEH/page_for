task "nav_tree" => :environment do
  Rails.application.eager_load!
  ActiveRecord::Base.descendants.each do |c|
    plural = c.name.pluralize
    puts "primary.item :#{plural.underscore}, '#{plural.titleize}', #{plural.underscore}_path"
  end
end
