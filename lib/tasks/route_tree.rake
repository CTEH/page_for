task "route_tree" => :environment do
  Rails.application.eager_load!
  ActiveRecord::Base.descendants.each do |c|
    puts "tree.add :#{c.name.pluralize.underscore}, ["
    c.reflect_on_all_associations(:has_many).each do |bt|
      puts "  :#{bt.name},"
    end
    puts "]"
  end
end
