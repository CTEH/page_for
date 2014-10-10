module PivotForHelper
  # Leans heavily on pivot_table gem
  # https://github.com/edjames/pivot_table

  def pivot_for(resources)
    if resources == nil or resources.length == 0
      return 'No Data'
    end
    resources = [] if resources == nil
    builder = PivotFor::PivotBuilder.new(self, resources)
    yield(builder)
    return builder.render
  end

end