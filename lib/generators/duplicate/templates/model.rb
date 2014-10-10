class <%=class_name%>Duplicate < ActiveRecord::Base

  def relink_children!(master, slave)
<%for r in references -%>
<%begin -%>
    <%=r.active_record.to_s%>.where(<%=r.foreign_key%>: slave_record_id).each do |r|
      ActiveRecord::Base.transaction do
        ru = self.referer_updates.new
        ru.column_name = '<%=r.foreign_key%>'
        ru.old_value = slave_record_id
        ru.new_value = self.master_record_id
        ru.referer = r
        ru.save!
        r.<%=r.foreign_key%> = master_record_id
        r.save!
      end
    end
<%rescue -%>
  # Unable to work with <%=r.inspect%>
<%end -%>
<%end -%>
  end

end