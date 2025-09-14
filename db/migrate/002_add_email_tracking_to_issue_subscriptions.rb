class AddEmailTrackingToIssueSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_subscriptions, :last_notification_sent_at, :datetime, null: true
    add_column :issue_subscriptions, :notification_count, :integer, default: 0, null: false
    add_column :issue_subscriptions, :last_notified_due_date, :date, null: true
    
    add_index :issue_subscriptions, :last_notification_sent_at
    add_index :issue_subscriptions, :last_notified_due_date
  end
end
