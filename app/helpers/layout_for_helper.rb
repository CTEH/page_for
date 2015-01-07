module LayoutForHelper
  def layout_for(name, yield_proc, *args)
    options = args.extract_options!
    builder = LayoutFor::LayoutBuilder.new(self, name, options)
    yield(builder)
    render_page_for(partial: "layout", locals: {layout_builder: builder, yield_proc: yield_proc})
  end
end



