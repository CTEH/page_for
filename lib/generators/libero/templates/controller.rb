class <%=class_name.pluralize%>Controller < ApplicationController
  before_filter :authenticate_user!


  def index
    @<%=plural_table_name%> = <%=class_name%>.accessible_by(current_ability)
    @q = @<%=plural_table_name%>.search(params[:q])
    @<%=plural_table_name%> = @q.result.page params[:page]

    respond_to do |format|
      format.html
    end
  end

  def show
    @<%=singular_table_name%> = <%=class_name%>.find(params[:id])
    authorize! :read, @<%=singular_table_name%>

    respond_to do |format|
      format.html
    end
  end

  def new
    @<%=singular_table_name%> = @nester.<%=plural_table_name%>.new
    authorize! :create, @<%=singular_table_name%>

    respond_to do |format|
      format.html
    end
  end

  def edit
    @<%=singular_table_name%> = <%=class_name%>.find(params[:id])
    authorize! :update, @<%=singular_table_name%>
  end

  def create
    @<%=singular_table_name%> = @nester.<%=plural_table_name%>.new(params[:<%=singular_table_name%>])
    authorize! :create, @<%=singular_table_name%>

    respond_to do |format|
      if @<%=singular_table_name%>.save
        format.html { redirect_to @<%=singular_table_name%>, notice: '<%=class_name%> was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    @<%=singular_table_name%> = <%=class_name%>.find(params[:id])
    authorize! :update, @<%=singular_table_name%>

    respond_to do |format|
      if @<%=singular_table_name%>.update_attributes(params[:<%=singular_table_name%>])
        format.html { redirect_to @<%=singular_table_name%>, notice: '<%=class_name%> was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @<%=singular_table_name%> = <%=class_name%>.find(params[:id])
    authorize! :destroy, @<%=singular_table_name%>
    @<%=singular_table_name%>.destroy

    redirect_to <%=plural_table_name%>_path, notice: "Successfully destroyed <%=singular_table_name%>."
  end

end
