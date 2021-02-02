class AddCustomUserFields < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :phone, :string
    add_column :users, :on_call, :boolean, :default => false
    add_column :users, :admin, :boolean, :default => false
    add_column :users, :bio, :text
    add_column :users, :schedule_emails, :boolean, :default => true
    add_column :users, :pending_approval, :boolean, :default => false
    add_column :users, :volunteers_first_availability_emails, :boolean, :default => true
    add_column :users, :admins_notified_of_first_availability_at, :timestamp
  end
end
