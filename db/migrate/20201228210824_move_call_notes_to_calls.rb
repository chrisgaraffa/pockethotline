class MoveCallNotesToCalls < ActiveRecord::Migration[6.1]
  def change
    add_column :calls, :notes, :text

    drop_table :activities

    rename_column :comments, :activity_id, :call_id
  end
end
