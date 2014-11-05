class <%=class_name%>FkIndexes < ActiveRecord::Migration
  def change
<%for key in foreign_keys -%>
    begin
      add_index :<%=table_name%>, :<%=key%>
    rescue

    end
<%end -%>
  end
end
