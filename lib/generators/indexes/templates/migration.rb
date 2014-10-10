class <%=class_name%>FkIndexes < ActiveRecord::Migration
  def change
<%for key in foreign_keys -%>
    add_index :<%=table_name%>, :<%=key%>
<%end -%>
  end
end
