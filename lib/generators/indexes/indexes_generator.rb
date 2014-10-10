class IndexesGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  desc "This generator looks at the model to find belongs to associations and generates an indexes migration"

  def go
    template "migration.rb", "db/migrate/#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_#{class_name.underscore}_fk_indexes.rb"
  end

  private

  def table_name
    constantize.table_name
  end

  def reflections
    reflections = constantize.reflections.select do |association_name, reflection|
      reflection.macro == :belongs_to
    end
    return reflections
  end

  def foreign_keys
    reflections.map {|x|x.last.foreign_key}
  end

  def constantize
    class_name.constantize
  end
end
