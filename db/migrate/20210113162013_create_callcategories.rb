class CreateCallcategories < ActiveRecord::Migration[6.1]
  def change
    create_table :callcategories do |t|
      t.string :name
      t.boolean :active
      t.integer :sort_order
      t.text :description

      t.timestamps
    end
  end
end
