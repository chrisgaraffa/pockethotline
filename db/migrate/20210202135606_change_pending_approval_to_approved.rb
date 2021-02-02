class ChangePendingApprovalToApproved < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :pending_approval, :approved
  end
end
