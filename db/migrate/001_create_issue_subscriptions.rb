class CreateIssueSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :issue_subscriptions do |t|
      t.references :issue, null: false, index: true
      t.references :user, null: false, index: true
      t.timestamps null: false
    end

    add_index :issue_subscriptions, [:issue_id, :user_id], unique: true
  end
end 