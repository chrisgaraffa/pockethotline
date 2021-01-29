require "application_system_test_case"

class CallcategoriesTest < ApplicationSystemTestCase
  setup do
    @callcategory = callcategories(:one)
  end

  test "visiting the index" do
    visit callcategories_url
    assert_selector "h1", text: "Callcategories"
  end

  test "creating a Callcategory" do
    visit callcategories_url
    click_on "New Callcategory"

    check "Active" if @callcategory.active
    fill_in "Description", with: @callcategory.description
    fill_in "Name", with: @callcategory.name
    fill_in "Sort order", with: @callcategory.sort_order
    click_on "Create Callcategory"

    assert_text "Callcategory was successfully created"
    click_on "Back"
  end

  test "updating a Callcategory" do
    visit callcategories_url
    click_on "Edit", match: :first

    check "Active" if @callcategory.active
    fill_in "Description", with: @callcategory.description
    fill_in "Name", with: @callcategory.name
    fill_in "Sort order", with: @callcategory.sort_order
    click_on "Update Callcategory"

    assert_text "Callcategory was successfully updated"
    click_on "Back"
  end

  test "destroying a Callcategory" do
    visit callcategories_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Callcategory was successfully destroyed"
  end
end
