class DuplicateGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def model
    template 'model.rb', "app/models/"+"#{class_name}Duplicate_".underscore+".rb"
  end

  private

  def table_name
    constantize.table_name
  end

  def reflections_of(klass)
    begin
      reflections = klass.reflections.select do |association_name, reflection|
        reflection.macro == :belongs_to
      end
      return reflections.map {|x|x.last}.select {|x| x.name == class_name.underscore.to_sym or x.options[:class_name]==class_name.to_s}
    rescue
      print "Unable to reflect on #{klass}\n"
    end
  end

  def references
    results = []
    ActiveRecord::Base.connection.tables.each do |table|
      next if table.match(/\Aschema_migrations\Z/)
      begin
        klass = table.singularize.camelize.constantize
      rescue Exception=>e
        print "Unable to constantize #{table}\n"
        next
      end
      results += [reflections_of(klass)]
    end
    results.flatten
  end

  def foreign_keys
    reflections.map {|x|x.last.foreign_key}
  end

  def constantize
    class_name.constantize
  end


end
