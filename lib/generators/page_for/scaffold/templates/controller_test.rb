require "test_helper"

<% module_namespacing do -%>
class <%= controller_class_name %>ControllerTest < ActionController::TestCase
<% belongs_to_associations.each do |attribute| -%>
  let(:<%=attribute%>) { FactoryGirl.create :<%=attribute%> }
<% end -%>
  let(:<%=singular_table_name%>) { FactoryGirl.create :<%=singular_table_name%> }

  def setup
    @request.env['devise.mapping'] = Devise.mappings[:admin]
    sign_in FactoryGirl.create(:admin)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:<%= table_name %>)
    assert_nil assigns(:nester)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create' do
    assert_difference('<%= class_name %>.count') do
      post :create, <%= "#{singular_table_name}: FactoryGirl.attributes_for(:#{singular_table_name})" %>
    end

    assert_redirected_to <%= singular_table_name %>_path(assigns(:<%= singular_table_name %>))
  end

  test 'should show' do
    get :show, id: <%= singular_table_name %>
    assert_response :success
  end

  test 'should edit' do
    get :edit, id: <%= singular_table_name %>
    assert_response :success
  end

  test 'should update' do
    put :update, id: <%= singular_table_name %>, <%= "#{singular_table_name}: { #{content_columns.any? ? "#{content_columns.first}: 'New value'" : nil} }" %>
    assert_redirected_to <%= singular_table_name %>_path(assigns(:<%= singular_table_name %>))
  end

  test 'should destroy' do
    delete :destroy, id: <%= singular_table_name %>
    assert_equal true, assigns(:<%= singular_table_name %>).deleted
    assert_redirected_to <%= index_helper %>_path
  end
end
<% end -%>
