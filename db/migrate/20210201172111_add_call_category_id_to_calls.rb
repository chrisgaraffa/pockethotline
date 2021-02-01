class AddCallCategoryIdToCalls < ActiveRecord::Migration[6.1]
  def change
    add_reference :calls, :callcategory, index: true
  end
end
