class <%=class_name.pluralize%>Controller < ApplicationController
  before_filter :authenticate_user!


  def index
    @<%=plural_table_name%> = <%=class_name%>.accessible_by(current_ability)

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
    if @nester
      @<%=singular_table_name%> = @nester.<%=plural_table_name%>.new
    else
      @<%=singular_table_name%> = <%=class_name%>.new
    end

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
    if @nester
      @<%=singular_table_name%> = @nester.<%=plural_table_name%>.new(params[:<%=singular_table_name%>])
    else
      @<%=singular_table_name%> = <%=class_name%>.new(params[:<%=singular_table_name%>])
    end
    authorize! :create, @<%=singular_table_name%>

    respond_to do |format|
      if @<%=singular_table_name%>.save
        if @nester
          format.html { redirect_to @nester, notice: '<%=class_name%> was successfully created.' }
        else
          format.html { redirect_to @<%=singular_table_name%>, notice: '<%=class_name%> was successfully created.' }
        end
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
        if @nester
          format.html { redirect_to @<%=singular_table_name%>, notice: '<%=class_name%> was successfully updated.' }
        else
          format.html { redirect_to @nester, notice: '<%=class_name%> was successfully updated.' }
        end
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @<%=singular_table_name%> = <%=class_name%>.find(params[:id])
    authorize! :destroy, @<%=singular_table_name%>
    @<%=singular_table_name%>.destroy

    if @nester
      redirect_to @nester, notice: "Successfully destroyed <%=singular_table_name%>."
    else
      redirect_to <%=plural_table_name%>_path, notice: "Successfully destroyed <%=singular_table_name%>."
    end
  end

end
