require "test_helper"

class CallcategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @callcategory = callcategories(:one)
  end

  test "should get index" do
    get callcategories_url
    assert_response :success
  end

  test "should get new" do
    get new_callcategory_url
    assert_response :success
  end

  test "should create callcategory" do
    assert_difference('Callcategory.count') do
      post callcategories_url, params: { callcategory: { active: @callcategory.active, description: @callcategory.description, name: @callcategory.name, sort_order: @callcategory.sort_order } }
    end

    assert_redirected_to callcategory_url(Callcategory.last)
  end

  test "should show callcategory" do
    get callcategory_url(@callcategory)
    assert_response :success
  end

  test "should get edit" do
    get edit_callcategory_url(@callcategory)
    assert_response :success
  end

  test "should update callcategory" do
    patch callcategory_url(@callcategory), params: { callcategory: { active: @callcategory.active, description: @callcategory.description, name: @callcategory.name, sort_order: @callcategory.sort_order } }
    assert_redirected_to callcategory_url(@callcategory)
  end

  test "should destroy callcategory" do
    assert_difference('Callcategory.count', -1) do
      delete callcategory_url(@callcategory)
    end

    assert_redirected_to callcategories_url
  end
end
