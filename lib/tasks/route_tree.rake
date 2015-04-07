task "route_tree" => :environment do
  Rails.application.eager_load!
  puts "  actions_for_resources"
  puts "  routes_for do |tree|"
  ActiveRecord::Base.descendants.each do |c|
    puts "    tree.add :#{c.name.pluralize.underscore}, ["
    has_manys = c.reflect_on_all_associations(:has_many).find_all do |hm|
      Module.const_get(hm.name.to_s.singularize.classify).is_a?(Class) rescue false
    end

    has_manys.each do |hm|
      puts "      :#{hm.name},"
    end
    puts "    ]"
  end
  puts "  end"
end
